/*
    voice_core.inc - Zustand, Stream-Lebenszyklus und Hooks des Voice-Systems.

    Everything in this file is server side. The client plugin (sampvoice, open.mp
    fork by AmyrAhmady) decides on its own when to record: it starts as soon as
    one of the activation keys registered via SvAddKey() is held down. Where that
    audio ends up is decided here, by attaching the player as a *speaker* to a
    stream - and only for as long as the key is held.

    That is deliberate. A player who is not attached to any stream can send as
    many voice packets as a patched client likes; they are dropped, because the
    server forwards audio only along speakerStreams.

    Stream model (see VOICE_PROGRESS.md for the reasoning):
      - one DynamicLocalStreamAtPlayer per player that actually has the plugin,
        created once at handshake, deleted on disconnect
      - listeners of that stream are managed by the plugin itself (distance,
        interior and virtual world are checked in its own tick), so this script
        never attaches proximity listeners by hand
      - the three distance tiers do not create three streams; they change the
        radius of the one stream via SvUpdateDistanceForLStream()
*/

#if defined _voice_core_included
    #endinput
#endif
#define _voice_core_included

#if !defined _sampvoice_included
    #error voice_core.inc benoetigt <sampvoice>. Bitte in ScriptInc.inc einbinden.
#endif
#if !defined _voice_config_included
    #error voice_core.inc benoetigt voice_config.inc. Bitte voice.inc einbinden.
#endif

// ---------------------------------------------------------------------------
// Per player state
// ---------------------------------------------------------------------------

enum e_VoicePlayerData
{
    // Handle of this player's proximity stream, SV_NULL while none exists.
    vpProxStream,
    // Handshake with the client plugin is done, keys are registered and the
    // proximity stream exists. Nothing may be attached before this is true.
    bool:vpPluginReady,
    // VOICE_RANGE_WHISPER / _NORMAL / _SHOUT
    vpRange,
    // Proximity push to talk is currently held and the player is a speaker.
    bool:vpProxActive,
    // GetTickCount() when the current transmission started, 0 while silent.
    vpTalkStart,
    // GetTickCount() when the last transmission ended. Feeds the cooldown.
    vpLastTalkEnd,
    // Player switched voice off for themselves via /voice.
    bool:vpEnabled,
    // "no microphone" hint was already shown once, do not repeat it.
    bool:vpMicroNotified,
    // Watchdog cut the transmission off. Blocks re-keying until release.
    bool:vpCutOff,

    // --- radio (phase 2) ---

    // Radio push to talk is currently held and the player is a speaker.
    bool:vpRadioActive,
    // Channel the radio key transmits on, VOICE_CHANNEL_NONE when none.
    vpActiveChannel,
    // Channels this player is attached to as a listener. VOICE_CHANNEL_NONE
    // marks a free slot. The admin channel is kept outside of this list, it
    // is not a channel a player chooses.
    vpMonitor[VOICE_MAX_MONITORED],
    // Attached to the admin announcement channel.
    bool:vpOnAdminChannel,
    // GetTickCount() of the last channel switch. Feeds the switch rate limit.
    vpLastSwitch,

    // Snapshot of the membership this player was last synchronised for. The
    // watchdog compares it against the live values, so a promotion or a
    // dismissal takes effect without a relog and without the faction system
    // having to know that a voice system exists.
    vpSeenFraktion,
    vpSeenRang,
    vpSeenOrg,
    vpSeenPartei
}

new VoicePlayer[MAX_PLAYERS][e_VoicePlayerData];

// SvInit() was called. Guards every native call, so that a server started
// without the plugin fails loudly once instead of on every key press.
new bool:VoiceSystemReady = false;

// Handle of the repeating watchdog timer, -1 while it does not run.
new VoiceWatchdogTimer = -1;

// Range id -> radius. Index is VOICE_RANGE_*, kept dense on purpose.
new Float:VoiceRangeDistance[VOICE_RANGE_COUNT] =
{
    VOICE_DIST_WHISPER,
    VOICE_DIST_NORMAL,
    VOICE_DIST_SHOUT
};

// Range id -> German label for chat output.
new VoiceRangeName[VOICE_RANGE_COUNT][12] =
{
    "Flüstern",
    "Normal",
    "Rufen"
};

// ---------------------------------------------------------------------------
// Forward declarations
// ---------------------------------------------------------------------------

forward VoiceWatchdog();

// ---------------------------------------------------------------------------
// State helpers
// ---------------------------------------------------------------------------

// Wipes a slot back to its defaults. Does NOT touch streams - callers that own
// a stream have to release it first, otherwise the handle is lost and the
// stream leaks until gamemode exit.
stock VoiceResetPlayerData(playerid)
{
    VoicePlayer[playerid][vpProxStream]     = SV_NULL;
    VoicePlayer[playerid][vpPluginReady]    = false;
    VoicePlayer[playerid][vpRange]          = VOICE_RANGE_DEFAULT;
    VoicePlayer[playerid][vpProxActive]     = false;
    VoicePlayer[playerid][vpTalkStart]      = 0;
    VoicePlayer[playerid][vpLastTalkEnd]    = 0;
    VoicePlayer[playerid][vpEnabled]        = true;
    VoicePlayer[playerid][vpMicroNotified]  = false;
    VoicePlayer[playerid][vpCutOff]         = false;

    VoicePlayer[playerid][vpRadioActive]    = false;
    VoicePlayer[playerid][vpActiveChannel]  = VOICE_CHANNEL_NONE;
    VoicePlayer[playerid][vpOnAdminChannel] = false;
    VoicePlayer[playerid][vpLastSwitch]     = 0;
    VoicePlayer[playerid][vpSeenFraktion]   = -1;
    VoicePlayer[playerid][vpSeenRang]       = -1;
    VoicePlayer[playerid][vpSeenOrg]        = -1;
    VoicePlayer[playerid][vpSeenPartei]     = -1;
    for(new s = 0; s < VOICE_MAX_MONITORED; s++)
    {
        VoicePlayer[playerid][vpMonitor][s] = VOICE_CHANNEL_NONE;
    }
    return 1;
}

// True when this player can be attached to a stream at all.
stock bool:VoiceIsReady(playerid)
{
    if(!VoiceSystemReady) return false;
    if(playerid < 0 || playerid >= MAX_PLAYERS) return false;
    if(!IsPlayerConnected(playerid)) return false;
    if(!VoicePlayer[playerid][vpPluginReady]) return false;
    return true;
}

// True when the player is allowed to start a transmission right now.
// Reason is written to reasonText so the caller can tell the player why not.
stock bool:VoiceMayTransmit(playerid, reasonText[], reasonLen)
{
    reasonText[0] = EOS;

    if(!VoiceIsReady(playerid))
    {
        strcat(reasonText, "Dein Voice-Plugin ist nicht verbunden.", reasonLen);
        return false;
    }
    if(!VoicePlayer[playerid][vpEnabled])
    {
        strcat(reasonText, "Du hast Voice ausgeschaltet. Mit /voice wieder an.", reasonLen);
        return false;
    }
    if(GetPVarInt(playerid, "Eingeloggt") != 1)
    {
        strcat(reasonText, "Du bist nicht eingeloggt.", reasonLen);
        return false;
    }
    if(GetPlayerState(playerid) == PLAYER_STATE_WASTED)
    {
        strcat(reasonText, "Tote reden nicht.", reasonLen);
        return false;
    }
    if(SvMutePlayerStatus(playerid))
    {
        strcat(reasonText, "Du bist stummgeschaltet.", reasonLen);
        return false;
    }
    if(VoicePlayer[playerid][vpCutOff])
    {
        strcat(reasonText, "Bitte die Sprechtaste einmal loslassen.", reasonLen);
        return false;
    }
    if(VoicePlayer[playerid][vpLastTalkEnd] != 0 &&
       (GetTickCount() - VoicePlayer[playerid][vpLastTalkEnd]) < VOICE_COOLDOWN_MS)
    {
        // Deliberately no reason text: the cooldown is short enough that a
        // chat line about it would be more annoying than the block itself.
        return false;
    }
    return true;
}

// ---------------------------------------------------------------------------
// Stream lifecycle
// ---------------------------------------------------------------------------

// Finishes the setup as soon as the client plugin has announced itself.
// Called from OnPlayerSpawn and from the watchdog, so a late handshake is
// picked up without the player having to do anything.
stock VoiceTrySetupPlayer(playerid)
{
    if(!VoiceSystemReady) return 0;
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 0;
    if(VoicePlayer[playerid][vpPluginReady]) return 1;

    // Zero means the client has not connected its plugin (or has none at all).
    if(SvGetVersion(playerid) == 0) return 0;

    // Not before the login is through - the login screen is a wall of
    // textdraws and a chat line about voice has no business there. The
    // watchdog retries, so this costs at most one interval after login.
    if(GetPVarInt(playerid, "Eingeloggt") != 1) return 0;

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));

    new stream = SvCreateDLStreamAtPlayer(
        VoiceRangeDistance[VOICE_RANGE_DEFAULT],
        VOICE_PROXIMITY_MAX_LISTENERS,
        playerid,
        VOICE_COLOR,
        name
    );

    if(stream == SV_NULL)
    {
        printf("[Voice] Proximity-Stream fuer %s (ID %d) konnte nicht angelegt werden.", name, playerid);
        return 0;
    }

    VoicePlayer[playerid][vpProxStream]  = stream;
    VoicePlayer[playerid][vpRange]       = VOICE_RANGE_DEFAULT;
    VoicePlayer[playerid][vpPluginReady] = true;

    // Push to talk. Both keys are registered here so that the radio key of
    // phase 2 is live the moment a player joins a channel.
    SvRemoveAllKeys(playerid);
    SvAddKey(playerid, VOICE_KEY_PROXIMITY);
    SvAddKey(playerid, VOICE_KEY_RADIO);

    SendClientMessage(playerid, VOICE_COLOR, "[Voice] Sprachchat aktiv. Y gedrueckt halten zum Sprechen, /reichweite fuer die Lautstaerke.");

    // Puts the player on every channel their faction, organisation and party
    // entitle them to, and picks a sensible transmit channel.
    VoiceRefreshPlayer(playerid, false);

    if(!SvHasMicro(playerid) && !VoicePlayer[playerid][vpMicroNotified])
    {
        VoicePlayer[playerid][vpMicroNotified] = true;
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Es wurde kein Mikrofon gefunden. Du hoerst andere, kannst aber nicht sprechen.");
    }
    return 1;
}

// Ends every transmission of this player without touching the streams
// themselves. Safe to call at any time, also for players without a plugin.
stock VoiceStopAllTransmissions(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    if(VoicePlayer[playerid][vpRadioActive])
    {
        VoiceRadioStop(playerid, false);
    }

    if(VoicePlayer[playerid][vpProxActive])
    {
        if(VoicePlayer[playerid][vpProxStream] != SV_NULL)
        {
            SvDetachSpeakerFromStream(VoicePlayer[playerid][vpProxStream], playerid);
        }
        VoicePlayer[playerid][vpProxActive] = false;
    }

    if(VoicePlayer[playerid][vpTalkStart] != 0)
    {
        VoicePlayer[playerid][vpTalkStart]   = 0;
        VoicePlayer[playerid][vpLastTalkEnd] = GetTickCount();
    }
    return 1;
}

// Full teardown: transmissions stopped, stream destroyed, keys released,
// state wiped. This is the single destruction path required by rule 3.
stock VoiceTeardownPlayer(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    VoiceStopAllTransmissions(playerid);
    VoiceDetachFromAllChannels(playerid);

    if(VoicePlayer[playerid][vpProxStream] != SV_NULL)
    {
        SvDeleteStream(VoicePlayer[playerid][vpProxStream]);
        VoicePlayer[playerid][vpProxStream] = SV_NULL;
    }

    if(VoiceSystemReady && IsPlayerConnected(playerid) && SvGetVersion(playerid) != 0)
    {
        SvRemoveAllKeys(playerid);
    }

    VoiceResetPlayerData(playerid);
    return 1;
}

// ---------------------------------------------------------------------------
// Hooks - called from the gamemode callbacks, one line each
// ---------------------------------------------------------------------------

stock VoiceInitSystem()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        VoiceResetPlayerData(i);
    }

    SvInit(VOICE_BITRATE);
    VoiceSystemReady = true;

    VoiceCreateChannels();

    if(VoiceWatchdogTimer != -1)
    {
        KillTimer(VoiceWatchdogTimer);
        VoiceWatchdogTimer = -1;
    }
    VoiceWatchdogTimer = SetTimer("VoiceWatchdog", VOICE_WATCHDOG_INTERVAL_MS, true);

    printf("[Voice] Sprachsystem bereit - %d Bit/s, Proximity bis %.1f Einheiten.",
        VOICE_BITRATE, VoiceRangeDistance[VOICE_RANGE_SHOUT]);
    return 1;
}

stock VoiceShutdownSystem()
{
    if(VoiceWatchdogTimer != -1)
    {
        KillTimer(VoiceWatchdogTimer);
        VoiceWatchdogTimer = -1;
    }

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(VoicePlayer[i][vpProxStream] != SV_NULL)
        {
            SvDeleteStream(VoicePlayer[i][vpProxStream]);
            VoicePlayer[i][vpProxStream] = SV_NULL;
        }
        VoiceResetPlayerData(i);
    }

    VoiceDestroyChannels();

    VoiceSystemReady = false;
    return 1;
}

stock VoiceOnPlayerConnect(playerid)
{
    // Nothing is created here on purpose: at this point the client plugin has
    // not announced itself yet, so SvGetVersion() would still be zero.
    //
    // Teardown rather than a plain reset: should the slot still carry a stream
    // from a disconnect that did not run, this is the last chance to release it
    // before the handle is overwritten and the stream leaks until gamemode exit.
    VoiceTeardownPlayer(playerid);
    return 1;
}

stock VoiceOnPlayerDisconnect(playerid)
{
    VoiceTeardownPlayer(playerid);
    return 1;
}

stock VoiceOnPlayerSpawn(playerid)
{
    // When the setup runs here it refreshes on its own, otherwise a spawn is
    // still a good moment to re-check: joining a faction usually ends in one.
    if(!VoiceTrySetupPlayer(playerid) && VoiceIsReady(playerid))
    {
        VoiceRefreshPlayer(playerid, false);
    }
    return 1;
}

stock VoiceOnPlayerDeath(playerid)
{
    // A dead player stops sending immediately but keeps their stream, so they
    // are still a listener while lying on the ground.
    VoiceStopAllTransmissions(playerid);
    return 1;
}

// ---------------------------------------------------------------------------
// Watchdog
// ---------------------------------------------------------------------------

public VoiceWatchdog()
{
    if(!VoiceSystemReady) return 1;

    new tick = GetTickCount();

    ForEachPlayer(i)
    {
        if(IsPlayerNPC(i)) continue;

        if(!VoicePlayer[i][vpPluginReady])
        {
            // Picks up a handshake that arrived after the last spawn.
            VoiceTrySetupPlayer(i);
            continue;
        }

        // The client plugin can go away while the player stays connected (a
        // crash of the .asi, a manual unload). The plugin then drops them from
        // every stream without telling the script, so the state is rebuilt from
        // scratch instead of pointing at attachments that no longer exist.
        if(SvGetVersion(i) == 0)
        {
            VoiceTeardownPlayer(i);
            continue;
        }

        // Promotion, dismissal, faction or clan change: the faction system
        // writes into Spieler[][...] without knowing about voice, so the
        // change is picked up here instead of hooking 37 write sites.
        // A transmission attempt re-checks the live values anyway, this only
        // moves the listener attachments and tells the player what happened.
        if(VoicePlayer[i][vpSeenFraktion] != Spieler[i][pFraktion]  ||
           VoicePlayer[i][vpSeenRang]     != Spieler[i][pFraktRang] ||
           VoicePlayer[i][vpSeenOrg]      != Spieler[i][pOrgMember] ||
           VoicePlayer[i][vpSeenPartei]   != Spieler[i][pParteiMember])
        {
            VoiceRefreshPlayer(i, true);
        }

        // Taped down push to talk key: cut the transmission and refuse to
        // start a new one until the key was actually released.
        if(VoicePlayer[i][vpTalkStart] != 0 &&
           (tick - VoicePlayer[i][vpTalkStart]) > VOICE_MAX_TALK_MS)
        {
            VoiceStopAllTransmissions(i);
            VoicePlayer[i][vpCutOff] = true;
            SendClientMessage(i, VOICE_COLOR, "[Voice] Uebertragung automatisch beendet. Sprechtaste loslassen und neu druecken.");
        }
    }
    return 1;
}
