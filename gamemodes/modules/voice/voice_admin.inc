/*
    voice_admin.inc - Mute-System, Adminbefehle, Logging, Persistenz.

    Three tiers of silence, from broad to narrow:

      1. global   - an admin mutes a player everywhere. Uses the plugin's own
                    mute flag, so the client stops recording at all, and is
                    written to VOICE_MUTE_TABLE so it survives a relog.
      2. channel  - an admin mutes a player on one radio channel. Everywhere
                    else they keep talking. Lives in memory only, like every
                    other channel state.
      3. ignore   - a player decides not to hear another player. Enforced on
                    radio channels by leaving the ignoring listener off the
                    channel while the ignored player transmits.

    The personal ignore does not reach proximity speech: those streams pick
    their listeners inside the plugin by distance, interior and virtual world,
    and re-attach anybody the script detaches on their next tick. sampvoice
    brings its own client side blacklist for exactly that case - see README.

    Every admin action lands in VOICE_LOG_FILE through the gamemode's Log().
*/

#if defined _voice_admin_included
    #endinput
#endif
#define _voice_admin_included

#if !defined _voice_radio_included
    #error voice_admin.inc benoetigt voice_radio.inc. Bitte voice.inc einbinden.
#endif

forward VoiceOnMuteLoad(playerid, name[]);

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

stock VoiceLogAdmin(adminid, const text[])
{
    new entry[256], logfile[] = VOICE_LOG_FILE;
    format(entry, sizeof(entry), "%s (ID %d): %s", SpielerName(adminid), adminid, text);
    Log(logfile, entry);
    return 1;
}

// ---------------------------------------------------------------------------
// Global mute - tier 1
// ---------------------------------------------------------------------------

stock VoiceApplyGlobalMute(playerid, bool:muted, const reason[] = "")
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    VoiceGlobalMute[playerid] = muted;

    if(muted)
    {
        format(VoiceGlobalMuteReason[playerid], 64, "%s", reason);
        VoiceStopAllTransmissions(playerid);
        if(VoiceSystemReady && SvGetVersion(playerid) != 0) SvMutePlayerEnable(playerid);
    }
    else
    {
        VoiceGlobalMuteReason[playerid][0] = EOS;
        if(VoiceSystemReady && SvGetVersion(playerid) != 0) SvMutePlayerDisable(playerid);
    }
    return 1;
}

// Reads a standing mute for this player out of the database. Called once the
// player is set up, so a mute survives a relog.
stock VoiceLoadMute(playerid)
{
    new query[160];
    new fmt[] = "SELECT Grund FROM " VOICE_MUTE_TABLE " WHERE Name = '%e' LIMIT 1";
    new cb[] = "VoiceOnMuteLoad", cbfmt[] = "is";

    mysql_format(MySQL_R394, query, sizeof(query), fmt, SpielerName(playerid));

    // The name travels with the query. Between sending it and the answer coming
    // back the player can have left and the slot can already belong to somebody
    // else - muting that person would be permanent and silent.
    mysql_tquery(MySQL_R394, query, cb, cbfmt, playerid, SpielerName(playerid));
    return 1;
}

public VoiceOnMuteLoad(playerid, name[])
{
    new rows, fields;
    cache_get_data(rows, fields, MySQL_R394);

    // Rule 6: nothing is read before the row count was checked.
    if(rows < 1) return 1;
    if(!IsPlayerConnected(playerid)) return 1;
    if(strcmp(SpielerName(playerid), name, true) != 0) return 1;

    new reason[64];
    cache_get_field_content(0, "Grund", reason, MySQL_R394, sizeof(reason));

    VoiceApplyGlobalMute(playerid, true, reason);

    new msg[160];
    if(reason[0] != EOS) format(msg, sizeof(msg), "[Voice] Du bist im Sprachchat stummgeschaltet. Grund: %s", reason);
    else                 format(msg, sizeof(msg), "[Voice] Du bist im Sprachchat stummgeschaltet.");
    SendClientMessage(playerid, VOICE_COLOR, msg);
    return 1;
}

stock VoiceStoreMute(const name[], const reason[], const adminName[])
{
    new query[320];
    new fmt[] = "REPLACE INTO " VOICE_MUTE_TABLE " (Name,Grund,Admin,Datum) VALUES ('%e','%e','%e',NOW())";
    new none[1];

    mysql_format(MySQL_R394, query, sizeof(query), fmt, name, reason, adminName);
    mysql_tquery(MySQL_R394, query, none, none);
    return 1;
}

stock VoiceRemoveMute(const name[])
{
    new query[160];
    new fmt[] = "DELETE FROM " VOICE_MUTE_TABLE " WHERE Name = '%e'";
    new none[1];

    mysql_format(MySQL_R394, query, sizeof(query), fmt, name);
    mysql_tquery(MySQL_R394, query, none, none);
    return 1;
}

// ---------------------------------------------------------------------------
// Admin commands
// ---------------------------------------------------------------------------

CMD:vmute(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new pID, reason[64], msg[192];
    if(sscanf(params, "us[64]", pID, reason))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" /vmute [playerid/Name] [Grund]");
    }
    if(!IsPlayerConnected(pID) || IsPlayerNPC(pID)) return SCM(playerid, SAMP_WEISS, ""IINFO" Spieler nicht gefunden.");
    if(VoiceGlobalMute[pID])                        return SCM(playerid, SAMP_WEISS, ""IINFO" Spieler ist bereits stummgeschaltet.");

    VoiceApplyGlobalMute(pID, true, reason);
    VoiceStoreMute(SpielerName(pID), reason, SpielerName(playerid));

    format(msg, sizeof(msg), "[Voice] %s hat %s im Sprachchat stummgeschaltet. Grund: %s",
        SpielerName(playerid), SpielerName(pID), reason);
    SendAdminMessage(VOICE_COLOR, msg);

    format(msg, sizeof(msg), "[Voice] Du wurdest im Sprachchat stummgeschaltet. Grund: %s", reason);
    SendClientMessage(pID, VOICE_COLOR, msg);

    format(msg, sizeof(msg), "vmute %s (ID %d) Grund: %s", SpielerName(pID), pID, reason);
    VoiceLogAdmin(playerid, msg);
    return 1;
}

CMD:vunmute(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new pID, msg[192];
    if(sscanf(params, "u", pID))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" /vunmute [playerid/Name]");
    }
    if(!IsPlayerConnected(pID) || IsPlayerNPC(pID)) return SCM(playerid, SAMP_WEISS, ""IINFO" Spieler nicht gefunden.");

    // The mute is dropped from the database in any case: it may be standing
    // there from an earlier session even when the flag in memory is clear.
    VoiceApplyGlobalMute(pID, false);
    VoiceRemoveMute(SpielerName(pID));

    format(msg, sizeof(msg), "[Voice] %s hat die Stummschaltung von %s aufgehoben.",
        SpielerName(playerid), SpielerName(pID));
    SendAdminMessage(VOICE_COLOR, msg);
    SendClientMessage(pID, VOICE_COLOR, "[Voice] Deine Stummschaltung im Sprachchat wurde aufgehoben.");

    format(msg, sizeof(msg), "vunmute %s (ID %d)", SpielerName(pID), pID);
    VoiceLogAdmin(playerid, msg);
    return 1;
}

CMD:vkanalmute(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new pID, msg[192], name[64];
    if(sscanf(params, "u", pID))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" /vkanalmute [playerid/Name] - schaltet auf dessen aktuellem Sendekanal stumm");
    }
    if(!IsPlayerConnected(pID) || IsPlayerNPC(pID)) return SCM(playerid, SAMP_WEISS, ""IINFO" Spieler nicht gefunden.");

    new channel = VoicePlayer[pID][vpActiveChannel];
    if(channel == VOICE_CHANNEL_NONE) return SCM(playerid, SAMP_WEISS, ""IINFO" Spieler hat keinen Sendekanal gewaehlt.");

    VoiceGetChannelName(channel, name, sizeof(name));

    new bool:muted = !VoiceIsChannelMuted(pID, channel);
    VoiceBitSet(VoiceChannelMute[pID], channel, muted);
    if(muted && VoicePlayer[pID][vpRadioActive]) VoiceRadioStop(pID, false);

    format(msg, sizeof(msg), "[Voice] %s hat %s auf dem Kanal %s %s.",
        SpielerName(playerid), SpielerName(pID), name, muted ? ("stummgeschaltet") : ("freigeschaltet"));
    SendAdminMessage(VOICE_COLOR, msg);

    format(msg, sizeof(msg), "[Funk] Du bist auf dem Kanal %s %s.", name,
        muted ? ("stummgeschaltet") : ("wieder freigeschaltet"));
    SendClientMessage(pID, VOICE_COLOR, msg);

    format(msg, sizeof(msg), "vkanalmute %s (ID %d) Kanal %s -> %s",
        SpielerName(pID), pID, name, muted ? ("stumm") : ("frei"));
    VoiceLogAdmin(playerid, msg);
    return 1;
}

CMD:vabhoeren(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new channel, msg[192], name[64];
    if(sscanf(params, "d", channel))
    {
        SCM(playerid, SAMP_WEISS, ""IINFO" /vabhoeren [Kanal-ID] - /vkanaele listet die IDs");
        return 1;
    }
    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL)
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" Diesen Funkkanal gibt es nicht.");
    }
    if(!VoiceIsReady(playerid)) return SCM(playerid, SAMP_WEISS, ""IINFO" Dein Voice-Plugin ist nicht verbunden.");

    VoiceGetChannelName(channel, name, sizeof(name));

    // Stop listening in.
    if(VoicePlayer[playerid][vpListenIn] == channel)
    {
        VoicePlayer[playerid][vpListenIn] = VOICE_CHANNEL_NONE;

        // Only actually leave when the admin is not a regular member as well.
        if(!VoiceIsMonitoring(playerid, channel) &&
           SvHasListenerInStream(VoiceChannelStream[channel], playerid))
        {
            SvDetachListenerFromStream(VoiceChannelStream[channel], playerid);
            if(VoiceChannelListeners[channel] > 0) VoiceChannelListeners[channel]--;
        }

        format(msg, sizeof(msg), "[Voice] Du hoerst den Kanal %s nicht mehr ab.", name);
        SendClientMessage(playerid, VOICE_COLOR, msg);

        format(msg, sizeof(msg), "vabhoeren beendet: %s", name);
        VoiceLogAdmin(playerid, msg);
        return 1;
    }

    if(VoiceIsMonitoring(playerid, channel))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" Auf diesem Kanal bist du ohnehin schon.");
    }

    // Listening in counts against the ceiling like any other listener - the
    // exemption is for the admin announcement channel, not for admins. It does
    // NOT take one of the player's own channel slots.
    if(VoiceChannelListeners[channel] >= VOICE_CHANNEL_MAX_LISTENERS &&
       VoiceCountChannelListeners(channel) >= VOICE_CHANNEL_MAX_LISTENERS)
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" Dieser Kanal ist voll.");
    }
    if(!SvAttachListenerToStream(VoiceChannelStream[channel], playerid))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" Der Kanal konnte nicht geoeffnet werden.");
    }
    VoiceChannelListeners[channel]++;
    VoicePlayer[playerid][vpListenIn] = channel;

    format(msg, sizeof(msg), "[Voice] Du hoerst den Kanal %s ab. Nochmal /vabhoeren %d beendet es.", name, channel);
    SendClientMessage(playerid, VOICE_COLOR, msg);

    format(msg, sizeof(msg), "vabhoeren gestartet: %s", name);
    VoiceLogAdmin(playerid, msg);
    return 1;
}

CMD:vsperren(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new channel, msg[192], name[64];
    if(sscanf(params, "d", channel))
    {
        SCM(playerid, SAMP_WEISS, ""IINFO" /vsperren [Kanal-ID] - /vkanaele listet die IDs");
        return 1;
    }
    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL)
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" Diesen Funkkanal gibt es nicht.");
    }

    VoiceGetChannelName(channel, name, sizeof(name));
    VoiceChannelLocked[channel] = !VoiceChannelLocked[channel];

    if(VoiceChannelLocked[channel] && VoiceChannelSpeaker[channel] != INVALID_PLAYER_ID)
    {
        new speaker = VoiceChannelSpeaker[channel];
        if(IsPlayerConnected(speaker) && !isPlayerAnAdmin(speaker, VOICE_ADMIN_LEVEL)) VoiceRadioStop(speaker, false);
    }

    format(msg, sizeof(msg), "[Voice] %s hat den Funkkanal %s %s.",
        SpielerName(playerid), name, VoiceChannelLocked[channel] ? ("gesperrt") : ("entsperrt"));
    SendAdminMessage(VOICE_COLOR, msg);

    format(msg, sizeof(msg), "vsperren %s -> %s", name, VoiceChannelLocked[channel] ? ("gesperrt") : ("offen"));
    VoiceLogAdmin(playerid, msg);
    return 1;
}

CMD:durchsage(playerid, params[])
{
    #pragma unused params

    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL_BROADCAST)) return ADMIN_MSG(playerid);
    if(!VoiceIsReady(playerid)) return SCM(playerid, SAMP_WEISS, ""IINFO" Dein Voice-Plugin ist nicht verbunden.");

    if(VoicePlayer[playerid][vpActiveChannel] == VOICE_CH_ADMIN)
    {
        VoicePlayer[playerid][vpActiveChannel] = VOICE_CHANNEL_NONE;
        VoiceRefreshPlayer(playerid, false);
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Durchsagemodus beendet.");
        VoiceLogAdmin(playerid, "durchsage beendet");
        return 1;
    }

    if(!VoicePlayer[playerid][vpOnAdminChannel]) VoiceAttachToChannel(playerid, VOICE_CH_ADMIN);
    VoicePlayer[playerid][vpActiveChannel] = VOICE_CH_ADMIN;
    VoicePlayer[playerid][vpLastSwitch]    = GetTickCount();

    SendClientMessage(playerid, VOICE_COLOR, "[Voice] Durchsagemodus aktiv. X gedrueckt halten sendet an alle Admins auf dem Durchsagekanal. Nochmal /durchsage beendet ihn.");
    VoiceLogAdmin(playerid, "durchsage gestartet");
    return 1;
}

CMD:vkanaele(playerid, params[])
{
    #pragma unused params

    if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new name[64], msg[160];
    SendClientMessage(playerid, VOICE_COLOR, "--- Funkkanaele (ID | Name | Zuhoerer | Status) ---");

    for(new ch = 0; ch < VOICE_STREAM_COUNT; ch++)
    {
        if(VoiceChannelStream[ch] == SV_NULL) continue;
        if(VoiceChannelListeners[ch] == 0 && !VoiceChannelLocked[ch] &&
           VoiceChannelSpeaker[ch] == INVALID_PLAYER_ID) continue;

        VoiceGetChannelName(ch, name, sizeof(name));
        format(msg, sizeof(msg), "%d | %s | %d/%d | %s",
            ch, name, VoiceChannelListeners[ch],
            (ch == VOICE_CH_ADMIN) ? VOICE_ADMIN_MAX_LISTENERS : VOICE_CHANNEL_MAX_LISTENERS,
            VoiceChannelLocked[ch] ? ("gesperrt") : ("offen"));
        SendClientMessage(playerid, VOICE_COLOR, msg);
    }
    SendClientMessage(playerid, VOICE_COLOR, "Leere und offene Kanaele werden ausgelassen.");
    return 1;
}

// ---------------------------------------------------------------------------
// Personal ignore - tier 3, for players
// ---------------------------------------------------------------------------

CMD:vignore(playerid, params[])
{
    new pID, msg[160];
    if(sscanf(params, "u", pID))
    {
        SCM(playerid, SAMP_WEISS, ""IINFO" /vignore [playerid/Name] - blendet jemanden im Funk aus");
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Im Nahbereich blendest du jemanden ueber das sampvoice-Menue aus (Blacklist).");
        return 1;
    }
    if(!IsPlayerConnected(pID) || IsPlayerNPC(pID)) return SCM(playerid, SAMP_WEISS, ""IINFO" Spieler nicht gefunden.");
    if(pID == playerid)                             return SCM(playerid, SAMP_WEISS, ""IINFO" Dich selbst kannst du nicht ausblenden.");

    new bool:ignored = !VoiceIgnores(playerid, pID);
    VoiceBitSet(VoiceIgnore[playerid], pID, ignored);

    // Takes effect at once when that player is on the air right now.
    if(ignored && VoicePlayer[pID][vpRadioActive])
    {
        new channel = VoicePlayer[pID][vpActiveChannel];
        if(VoiceIsValidChannel(channel)) VoiceSyncChannelListeners(channel, pID);
    }

    if(ignored) format(msg, sizeof(msg), "[Voice] Du hoerst %s im Funk nicht mehr.", SpielerName(pID));
    else        format(msg, sizeof(msg), "[Voice] Du hoerst %s im Funk wieder.", SpielerName(pID));
    SendClientMessage(playerid, VOICE_COLOR, msg);
    return 1;
}

CMD:vignoreliste(playerid, params[])
{
    #pragma unused params

    new msg[160], count = 0;
    SendClientMessage(playerid, VOICE_COLOR, "--- Im Funk ausgeblendet ---");

    ForEachPlayer(i)
    {
        if(!VoiceIgnores(playerid, i)) continue;
        format(msg, sizeof(msg), " - %s (ID %d)", SpielerName(i), i);
        SendClientMessage(playerid, VOICE_COLOR, msg);
        count++;
    }
    if(count == 0) SendClientMessage(playerid, VOICE_COLOR, "Niemand.");
    return 1;
}
