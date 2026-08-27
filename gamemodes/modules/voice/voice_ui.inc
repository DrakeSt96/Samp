/*
    voice_ui.inc - "spricht gerade"-Anzeige.

    One player textdraw per player, created together with the rest of their
    voice state and destroyed with it.

    What it shows is decided in one place, VoiceRefreshIndicator(), by a fixed
    priority:

        1. the player transmits on the radio     -> channel they are on
        2. the player transmits in proximity     -> range they are on
        3. somebody else is on a channel they    -> who, and where
           listen to
        4. nothing                               -> hidden

    Going through one function matters: an incoming radio transmission must not
    wipe the indicator of a player who is talking themselves, and the end of
    that transmission must not hide theirs either. Doing it per event is exactly
    how that kind of bug gets in.

    Cost is bounded by half duplex: at most one speaker per channel, so the
    string is built once per transmission and not per frame.
*/

#if defined _voice_ui_included
    #endinput
#endif
#define _voice_ui_included

#if !defined _voice_radio_included
    #error voice_ui.inc benoetigt voice_radio.inc. Bitte voice.inc einbinden.
#endif

new PlayerText:VoiceIndicator[MAX_PLAYERS] = {INVALID_PLAYER_TEXT_DRAW, ...};
new bool:VoiceIndicatorShown[MAX_PLAYERS];

// ---------------------------------------------------------------------------
// Textdraw lifecycle
// ---------------------------------------------------------------------------

stock VoiceCreateIndicator(playerid)
{
    if(VoiceIndicator[playerid] != INVALID_PLAYER_TEXT_DRAW) return 1;

    VoiceIndicator[playerid] = CreatePlayerTextDraw(playerid, VOICE_TD_POS_X, VOICE_TD_POS_Y, "_");
    PlayerTextDrawLetterSize(playerid, VoiceIndicator[playerid], 0.220000, 1.100000);
    PlayerTextDrawAlignment(playerid, VoiceIndicator[playerid], TEXT_DRAW_ALIGN_LEFT);
    PlayerTextDrawColour(playerid, VoiceIndicator[playerid], VOICE_COLOR);
    PlayerTextDrawSetShadow(playerid, VoiceIndicator[playerid], 0);
    PlayerTextDrawSetOutline(playerid, VoiceIndicator[playerid], 1);
    PlayerTextDrawBackgroundColour(playerid, VoiceIndicator[playerid], 255);
    PlayerTextDrawFont(playerid, VoiceIndicator[playerid], TEXT_DRAW_FONT_2);
    PlayerTextDrawSetProportional(playerid, VoiceIndicator[playerid], true);

    VoiceIndicatorShown[playerid] = false;
    return 1;
}

stock VoiceDestroyIndicator(playerid)
{
    if(VoiceIndicator[playerid] == INVALID_PLAYER_TEXT_DRAW) return 0;

    PlayerTextDrawDestroy(playerid, VoiceIndicator[playerid]);
    VoiceIndicator[playerid]      = INVALID_PLAYER_TEXT_DRAW;
    VoiceIndicatorShown[playerid] = false;
    return 1;
}

// ---------------------------------------------------------------------------
// What a single player currently sees
// ---------------------------------------------------------------------------

// Rebuilds one player's indicator from the current state. Every event in the
// voice system ends up here rather than drawing on its own.
stock VoiceRefreshIndicator(playerid)
{
    if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 0;
    if(VoiceIndicator[playerid] == INVALID_PLAYER_TEXT_DRAW) return 0;

    new text[128], name[64];
    text[0] = EOS;

    if(VoicePlayer[playerid][vpRadioActive] &&
       VoiceIsValidChannel(VoicePlayer[playerid][vpActiveChannel]))
    {
        VoiceGetChannelName(VoicePlayer[playerid][vpActiveChannel], name, sizeof(name));
        format(text, sizeof(text), "~r~* ~w~Funk ~y~%s", name);
    }
    else if(VoicePlayer[playerid][vpProxActive])
    {
        format(text, sizeof(text), "~y~* ~w~%s", VoiceRangeName[VoicePlayer[playerid][vpRange]]);
    }
    else
    {
        // Somebody else on a channel this player is attached to. The first one
        // found wins - half duplex means there is at most one per channel, and
        // hearing two channels at once is rare enough not to rank them.
        for(new ch = 0; ch < VOICE_STREAM_COUNT; ch++)
        {
            new speaker = VoiceChannelSpeaker[ch];
            if(speaker == INVALID_PLAYER_ID || speaker == playerid) continue;
            if(VoiceChannelStream[ch] == SV_NULL) continue;
            if(!SvHasListenerInStream(VoiceChannelStream[ch], playerid)) continue;

            VoiceGetChannelName(ch, name, sizeof(name));
            format(text, sizeof(text), "~r~* ~y~%s~w~: %s", name, SpielerName(speaker));
            break;
        }
    }

    if(text[0] == EOS)
    {
        if(VoiceIndicatorShown[playerid])
        {
            PlayerTextDrawHide(playerid, VoiceIndicator[playerid]);
            VoiceIndicatorShown[playerid] = false;
        }
        return 1;
    }

    PlayerTextDrawSetString(playerid, VoiceIndicator[playerid], text);
    if(!VoiceIndicatorShown[playerid])
    {
        PlayerTextDrawShow(playerid, VoiceIndicator[playerid]);
        VoiceIndicatorShown[playerid] = true;
    }
    return 1;
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

// Proximity concerns only the speaker: who is talking next to you is obvious
// from standing next to them, and from the plugin's own speaker list.
stock VoiceIndicateProximity(playerid, bool:active)
{
    #pragma unused active
    return VoiceRefreshIndicator(playerid);
}

// Radio concerns everybody on the channel.
stock VoiceIndicateRadio(speakerid, channel, bool:active)
{
    #pragma unused active

    VoiceRefreshIndicator(speakerid);

    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL) return 1;

    ForEachPlayer(i)
    {
        if(i == speakerid || IsPlayerNPC(i)) continue;
        if(!SvHasListenerInStream(VoiceChannelStream[channel], i)) continue;

        VoiceRefreshIndicator(i);
    }
    return 1;
}
