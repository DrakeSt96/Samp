/*
    voice_proximity.inc - Proximity-Sprache: Distanzstufen, Push-to-Talk, Befehle.

    The client starts recording by itself once an activation key registered with
    SvAddKey() goes down; the server is told through OnPlayerActivationKeyPress.
    Attaching the speaker here and detaching on release is what actually decides
    whether anybody hears anything - the recording alone goes nowhere.
*/

#if defined _voice_proximity_included
    #endinput
#endif
#define _voice_proximity_included

#if !defined _voice_core_included
    #error voice_proximity.inc benoetigt voice_core.inc. Bitte voice.inc einbinden.
#endif

// ---------------------------------------------------------------------------
// Transmission
// ---------------------------------------------------------------------------

stock VoiceProximityStart(playerid)
{
    if(VoicePlayer[playerid][vpProxActive]) return 0;

    new reason[96];
    if(!VoiceMayTransmit(playerid, reason, sizeof(reason)))
    {
        if(reason[0] != EOS)
        {
            new msg[128];
            format(msg, sizeof(msg), "[Voice] %s", reason);
            SendClientMessage(playerid, VOICE_COLOR, msg);
        }
        return 0;
    }

    if(!SvAttachSpeakerToStream(VoicePlayer[playerid][vpProxStream], playerid))
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Sprachkanal konnte nicht geoeffnet werden.");
        return 0;
    }

    VoicePlayer[playerid][vpProxActive] = true;
    VoicePlayer[playerid][vpTalkStart]  = GetTickCount();
    VoiceIndicateProximity(playerid, true);
    return 1;
}

stock VoiceProximityStop(playerid)
{
    if(!VoicePlayer[playerid][vpProxActive]) return 0;

    if(VoicePlayer[playerid][vpProxStream] != SV_NULL)
    {
        SvDetachSpeakerFromStream(VoicePlayer[playerid][vpProxStream], playerid);
    }

    VoicePlayer[playerid][vpProxActive]   = false;
    VoicePlayer[playerid][vpTalkStart]    = 0;
    VoicePlayer[playerid][vpLastTalkEnd]  = GetTickCount();
    VoiceIndicateProximity(playerid, false);
    return 1;
}

// ---------------------------------------------------------------------------
// Distance tiers
// ---------------------------------------------------------------------------

// Switches the radius of the player's single proximity stream. No stream is
// created or destroyed here - that is the whole point of using one dynamic
// local stream per player instead of one per tier.
stock VoiceSetRange(playerid, range, bool:announce = true)
{
    if(!VoiceIsReady(playerid)) return 0;
    if(range < 0 || range >= VOICE_RANGE_COUNT) return 0;
    if(VoicePlayer[playerid][vpProxStream] == SV_NULL) return 0;

    VoicePlayer[playerid][vpRange] = range;
    SvUpdateDistanceForLStream(VoicePlayer[playerid][vpProxStream], VoiceRangeDistance[range]);
    if(VoicePlayer[playerid][vpProxActive]) VoiceIndicateProximity(playerid, true);

    if(announce)
    {
        new msg[128];
        format(msg, sizeof(msg), "[Voice] Sprechweite: %s (%.0f Meter).",
            VoiceRangeName[range], VoiceRangeDistance[range]);
        SendClientMessage(playerid, VOICE_COLOR, msg);
    }
    return 1;
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

CMD:reichweite(playerid, params[])
{
    if(!VoiceIsReady(playerid))
    {
        return SendClientMessage(playerid, VOICE_COLOR, "[Voice] Dein Voice-Plugin ist nicht verbunden.");
    }

    // No argument cycles through the tiers, so it works as a bound key too.
    if(isnull(params))
    {
        new next = VoicePlayer[playerid][vpRange] + 1;
        if(next >= VOICE_RANGE_COUNT) next = 0;
        VoiceSetRange(playerid, next);
        return 1;
    }

    if(!strcmp(params, "fluestern", true) || !strcmp(params, "flüstern", true) || !strcmp(params, "1", true))
    {
        VoiceSetRange(playerid, VOICE_RANGE_WHISPER);
    }
    else if(!strcmp(params, "normal", true) || !strcmp(params, "2", true))
    {
        VoiceSetRange(playerid, VOICE_RANGE_NORMAL);
    }
    else if(!strcmp(params, "rufen", true) || !strcmp(params, "3", true))
    {
        VoiceSetRange(playerid, VOICE_RANGE_SHOUT);
    }
    else
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Benutzung: /reichweite [fluestern|normal|rufen] - ohne Angabe wird durchgeschaltet.");
    }
    return 1;
}

CMD:fluestern(playerid, params[])
{
    #pragma unused params
    if(!VoiceSetRange(playerid, VOICE_RANGE_WHISPER))
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Dein Voice-Plugin ist nicht verbunden.");
    }
    // Always 1: a 0 would make zcmd answer with "unknown command".
    return 1;
}

CMD:rufen(playerid, params[])
{
    #pragma unused params
    if(!VoiceSetRange(playerid, VOICE_RANGE_SHOUT))
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Dein Voice-Plugin ist nicht verbunden.");
    }
    return 1;
}

CMD:voice(playerid, params[])
{
    if(!VoiceIsReady(playerid))
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Dein Voice-Plugin ist nicht verbunden. Ohne sampvoice hoerst du niemanden.");
        return 1;
    }

    if(VoicePlayer[playerid][vpEnabled])
    {
        VoiceStopAllTransmissions(playerid);
        VoicePlayer[playerid][vpEnabled] = false;
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Sprachchat ausgeschaltet. Du hoerst weiter, sendest aber nicht mehr.");
    }
    else
    {
        VoicePlayer[playerid][vpEnabled] = true;
        SendClientMessage(playerid, VOICE_COLOR, "[Voice] Sprachchat eingeschaltet.");
    }
    return 1;
}

CMD:voicehelp(playerid, params[])
{
    #pragma unused params
    SendClientMessage(playerid, VOICE_COLOR, "--- Sprachchat ---");
    SendClientMessage(playerid, VOICE_COLOR, "Y gedrueckt halten: im Nahbereich sprechen");
    SendClientMessage(playerid, VOICE_COLOR, "X gedrueckt halten: funken (Fraktion, Unternehmen, Partei)");
    SendClientMessage(playerid, VOICE_COLOR, "/reichweite [fluestern|normal|rufen] - Sprechweite umschalten");
    SendClientMessage(playerid, VOICE_COLOR, "/fluestern, /rufen - direkt umschalten");
    SendClientMessage(playerid, VOICE_COLOR, "/funkkanal [Nr] - Sendekanal waehlen, ohne Nr: Liste");
    SendClientMessage(playerid, VOICE_COLOR, "/funkinfo - Sendekanal und mitgehoerte Kanaele");
    SendClientMessage(playerid, VOICE_COLOR, "/vignore [Spieler] - jemanden im Funk ausblenden, /vignoreliste zeigt sie");
    SendClientMessage(playerid, VOICE_COLOR, "/voice - eigenen Sprachchat an- und ausschalten");

    if(isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL))
    {
        SendClientMessage(playerid, VOICE_COLOR, "--- Admin ---");
        SendClientMessage(playerid, VOICE_COLOR, "/vmute /vunmute /vkanalmute /vabhoeren /vsperren /vkanaele /durchsage");
    }
    return 1;
}
