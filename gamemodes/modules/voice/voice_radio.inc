/*
    voice_radio.inc - Funk fuer Fraktionen, Organisationen und Parteien.

    Channel model
    -------------
    The channel ids are not a second membership administration. They are a flat
    projection of the ids the gamemode already keeps:

        channel  0 .. 18   faction id            (Spieler[][pFraktion])
        channel 19 .. 28   VOICE_CH_ORG_BASE   + Spieler[][pOrgMember]
        channel 29 .. 33   VOICE_CH_PARTY_BASE + Spieler[][pParteiMember]
        channel 34         VOICE_CH_ADMIN, server wide announcement

    Faction 0 and organisation/party id 0 mean "none" in this gamemode, so those
    three slots exist in the array but never get a stream. Nothing is stored
    twice: entitlement is read out of Spieler[][...] every single time it is
    needed, never cached.

    One GStream per channel is created in OnGameModeInit and lives until
    OnGameModeExit. Players are attached and detached, streams are not.

    Half duplex
    -----------
    VoiceChannelSpeaker[] holds the one player who currently has the channel.
    Anybody else keying in gets a busy signal. Besides being the more realistic
    radio, this is what keeps the fan-out bounded: one speaker times at most
    VOICE_CHANNEL_MAX_LISTENERS listeners, no matter how many members a faction
    happens to have online.
*/

#if defined _voice_radio_included
    #endinput
#endif
#define _voice_radio_included

#if !defined _voice_core_included
    #error voice_radio.inc benoetigt voice_core.inc. Bitte voice.inc einbinden.
#endif

// ---------------------------------------------------------------------------
// Channel state
// ---------------------------------------------------------------------------

// GStream handle per channel, SV_NULL where no stream exists.
new VoiceChannelStream[VOICE_STREAM_COUNT];

// Half duplex: who is transmitting right now, INVALID_PLAYER_ID when free.
new VoiceChannelSpeaker[VOICE_STREAM_COUNT];

// Attached listeners per channel, kept in step with the attach/detach calls
// so the hard ceiling can be enforced without asking the plugin.
new VoiceChannelListeners[VOICE_STREAM_COUNT];

// Admin lock. A locked channel refuses every transmission except an admin's.
new bool:VoiceChannelLocked[VOICE_STREAM_COUNT];

// ---------------------------------------------------------------------------
// Channel helpers
// ---------------------------------------------------------------------------

stock bool:VoiceIsValidChannel(channel)
{
    return (channel >= 0 && channel < VOICE_STREAM_COUNT);
}

// Writes the German display name of a channel into name[].
stock VoiceGetChannelName(channel, name[], len)
{
    name[0] = EOS;
    if(!VoiceIsValidChannel(channel)) return 0;

    if(channel == VOICE_CH_ADMIN)
    {
        format(name, len, "Admin-Durchsage");
    }
    else if(channel >= VOICE_CH_PARTY_BASE)
    {
        new id = channel - VOICE_CH_PARTY_BASE;
        if(id > 0 && id < MAX_PARTEI && PartInfo[id][ParteiCreatet] == 1)
        {
            format(name, len, "Partei %s", PartInfo[id][ParteiName]);
        }
        else format(name, len, "Parteifunk %d", id);
    }
    else if(channel >= VOICE_CH_ORG_BASE)
    {
        new id = channel - VOICE_CH_ORG_BASE;
        if(id > 0 && id < MAX_ORGANISATIONS && OrgInfo[id][OrgCreatet] == 1)
        {
            format(name, len, "Unternehmen %s", OrgInfo[id][OrgName]);
        }
        else format(name, len, "Unternehmensfunk %d", id);
    }
    else
    {
        format(name, len, "%s", FraktionsName(channel));
    }
    return 1;
}

// ---------------------------------------------------------------------------
// Stream lifecycle
// ---------------------------------------------------------------------------

// Called once from VoiceInitSystem. Rule 2: this is the only place channel
// streams are born.
//
// Organisation and party streams are created here as well, even though their
// names are only loaded from the database later. The plugin bakes the stream
// name into the creation packet and offers no rename, so renaming would mean
// destroying and recreating a stream at runtime. The name is cosmetic - it
// shows up in the client's speaker list - while the chat output uses the live
// name from OrgInfo/PartInfo. Not worth breaking rule 2 over.
stock VoiceCreateChannels()
{
    new name[64], label[80];

    for(new ch = 0; ch < VOICE_STREAM_COUNT; ch++)
    {
        VoiceChannelStream[ch]    = SV_NULL;
        VoiceChannelSpeaker[ch]   = INVALID_PLAYER_ID;
        VoiceChannelListeners[ch] = 0;
        VoiceChannelLocked[ch]    = false;

        // Faction 0 as well as organisation and party 0 mean "no membership".
        if(ch == VOICE_CH_FACTION_BASE) continue;
        if(ch == VOICE_CH_ORG_BASE)     continue;
        if(ch == VOICE_CH_PARTY_BASE)   continue;

        VoiceGetChannelName(ch, name, sizeof(name));
        format(label, sizeof(label), "Funk %s", name);

        VoiceChannelStream[ch] = SvCreateGStream(VOICE_COLOR, label);
        if(VoiceChannelStream[ch] == SV_NULL)
        {
            printf("[Voice] Funkkanal %d (%s) konnte nicht angelegt werden.", ch, name);
        }
    }

    printf("[Voice] %d Funkkanaele bereit (%d Fraktionen, %d Unternehmen, %d Parteien, 1 Admin).",
        VOICE_STREAM_COUNT - 3, VOICE_FACTION_COUNT - 1, VOICE_ORG_COUNT - 1, VOICE_PARTY_COUNT - 1);
    return 1;
}

// Called once from VoiceShutdownSystem. Rule 3: every stream has exactly one
// destruction path, this is it.
stock VoiceDestroyChannels()
{
    for(new ch = 0; ch < VOICE_STREAM_COUNT; ch++)
    {
        if(VoiceChannelStream[ch] != SV_NULL)
        {
            SvDeleteStream(VoiceChannelStream[ch]);
            VoiceChannelStream[ch] = SV_NULL;
        }
        VoiceChannelSpeaker[ch]   = INVALID_PLAYER_ID;
        VoiceChannelListeners[ch] = 0;
        VoiceChannelLocked[ch]    = false;
    }
    return 1;
}

// ---------------------------------------------------------------------------
// Entitlement - read out of the gamemode, never cached
// ---------------------------------------------------------------------------

// Fills channels[] with every channel this player may listen to and returns
// how many were written. The admin channel is not part of this: it is not a
// channel a player picks, it is handled separately.
stock VoiceGetEntitledChannels(playerid, channels[], maxChannels)
{
    new count = 0;

    if(count < maxChannels && Spieler[playerid][pFraktion] > 0 &&
       Spieler[playerid][pFraktion] < VOICE_FACTION_COUNT)
    {
        channels[count++] = VOICE_CH_FACTION_BASE + Spieler[playerid][pFraktion];
    }
    if(count < maxChannels && Spieler[playerid][pOrgMember] > 0 &&
       Spieler[playerid][pOrgMember] < VOICE_ORG_COUNT)
    {
        channels[count++] = VOICE_CH_ORG_BASE + Spieler[playerid][pOrgMember];
    }
    if(count < maxChannels && Spieler[playerid][pParteiMember] > 0 &&
       Spieler[playerid][pParteiMember] < VOICE_PARTY_COUNT)
    {
        channels[count++] = VOICE_CH_PARTY_BASE + Spieler[playerid][pParteiMember];
    }
    return count;
}

stock bool:VoiceIsEntitled(playerid, channel)
{
    if(!VoiceIsValidChannel(channel)) return false;

    if(channel == VOICE_CH_ADMIN)
    {
        return (isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL) == 1);
    }

    new channels[VOICE_MAX_MONITORED], count = VoiceGetEntitledChannels(playerid, channels, VOICE_MAX_MONITORED);
    for(new i = 0; i < count; i++)
    {
        if(channels[i] == channel) return true;
    }
    return false;
}

// Whether the player may put a transmission on this channel. Listening is
// covered by VoiceIsEntitled, this adds the rank and equipment rules on top.
// reasonText stays empty when the refusal needs no chat line.
stock bool:VoiceMayTransmitOn(playerid, channel, reasonText[], reasonLen)
{
    reasonText[0] = EOS;

    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL)
    {
        strcat(reasonText, "Dieser Funkkanal existiert nicht.", reasonLen);
        return false;
    }
    if(!VoiceIsEntitled(playerid, channel))
    {
        strcat(reasonText, "Du gehoerst diesem Funkkanal nicht an.", reasonLen);
        return false;
    }

    // The gamemode's own speech blocks. Same set the text chats /d, /fc and
    // /partei use - a player who may not type there may not talk there either.
    if(Spieler[playerid][pMuted] == 1)
    {
        strcat(reasonText, "Du bist gemutet.", reasonLen);
        return false;
    }
    if(Spieler[playerid][pAWAYFROMKEYBOARD] == 1)
    {
        strcat(reasonText, "Du bist als abwesend markiert.", reasonLen);
        return false;
    }
    if(Spieler[playerid][pInPrison] == 1 || Spieler[playerid][pJailed] != 0)
    {
        strcat(reasonText, "Im Knast gibt es keinen Funk.", reasonLen);
        return false;
    }
    if(Spieler[playerid][pFriedhof] == 1 || Spieler[playerid][pDeath] == 1)
    {
        strcat(reasonText, "In deinem Zustand funkst du nicht.", reasonLen);
        return false;
    }
    if(Spieler[playerid][pTazerd] == 1 || Spieler[playerid][pCuffed] == 1)
    {
        strcat(reasonText, "Du kommst gerade nicht an dein Funkgeraet.", reasonLen);
        return false;
    }

    if(channel == VOICE_CH_ADMIN)
    {
        if(!isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL_BROADCAST))
        {
            strcat(reasonText, "Fuer Durchsagen fehlt dir das Adminlevel.", reasonLen);
            return false;
        }
    }
    else if(channel < VOICE_CH_ORG_BASE)
    {
        // Faction channel: rank decides who may transmit. Leaders always may.
        if(Spieler[playerid][pLeader] == 0 && Spieler[playerid][pFraktRang] < VOICE_RANK_TRANSMIT)
        {
            strcat(reasonText, "Dein Rang darf nur mithoeren, nicht senden.", reasonLen);
            return false;
        }

        #if VOICE_FACTION_REQUIRE_RADIO
        if(Spieler[playerid][pFunkgeraet] == 0 && !FraktionsAktenPCs(playerid))
        {
            new fv = IsAFraktionsVeh(playerid);
            if(fv == -1 || Fahrzeug[fv][Fraktion] != Spieler[playerid][pFraktion])
            {
                strcat(reasonText, "Du hast kein Funkgeraet dabei.", reasonLen);
                return false;
            }
        }
        #endif
    }

    // Channel mute - the middle tier between a global mute and a personal
    // ignore. Silences one player on one channel, elsewhere they still talk.
    if(VoiceIsChannelMuted(playerid, channel))
    {
        strcat(reasonText, "Auf diesem Funkkanal bist du stummgeschaltet.", reasonLen);
        return false;
    }

    // Admin lock. Admins can still talk on a channel they locked.
    if(VoiceChannelLocked[channel] && !isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL))
    {
        strcat(reasonText, "Dieser Funkkanal wurde gesperrt.", reasonLen);
        return false;
    }

    return true;
}

// ---------------------------------------------------------------------------
// Listener attachment
// ---------------------------------------------------------------------------

stock bool:VoiceIsMonitoring(playerid, channel)
{
    for(new s = 0; s < VOICE_MAX_MONITORED; s++)
    {
        if(VoicePlayer[playerid][vpMonitor][s] == channel) return true;
    }
    return false;
}

// Counts the listeners a channel really has. The cached counter can drift:
// when a client's plugin drops while the player stays connected, the plugin
// detaches them from every stream on its own and never tells the script. Left
// alone that would slowly push a channel over its ceiling and lock everybody
// out, so the exact count is taken before any refusal.
stock VoiceCountChannelListeners(channel)
{
    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL) return 0;

    new count = 0;
    ForEachPlayer(i)
    {
        if(SvHasListenerInStream(VoiceChannelStream[channel], i)) count++;
    }
    VoiceChannelListeners[channel] = count;
    return count;
}

stock VoiceAttachToChannel(playerid, channel)
{
    if(!VoiceIsReady(playerid)) return 0;
    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL) return 0;
    if(SvHasListenerInStream(VoiceChannelStream[channel], playerid)) return 1;

    // Hard listener ceiling. Only the admin announcement is exempt, and even
    // there the plugin itself is the next limit, not this counter.
    new limit = (channel == VOICE_CH_ADMIN) ? VOICE_ADMIN_MAX_LISTENERS : VOICE_CHANNEL_MAX_LISTENERS;
    if(VoiceChannelListeners[channel] >= limit)
    {
        // Only refuse on a count that was just verified, never on a stale one.
        if(VoiceCountChannelListeners(channel) >= limit) return 0;
    }

    // A monitor slot has to be free first, otherwise the player would be
    // attached to a channel that no bookkeeping here knows about.
    new slot = -1;
    if(channel != VOICE_CH_ADMIN)
    {
        for(new s = 0; s < VOICE_MAX_MONITORED; s++)
        {
            if(VoicePlayer[playerid][vpMonitor][s] == VOICE_CHANNEL_NONE)
            {
                slot = s;
                break;
            }
        }
        if(slot == -1) return 0;
    }

    if(!SvAttachListenerToStream(VoiceChannelStream[channel], playerid)) return 0;

    VoiceChannelListeners[channel]++;

    if(channel == VOICE_CH_ADMIN)
    {
        VoicePlayer[playerid][vpOnAdminChannel] = true;
    }
    else
    {
        VoicePlayer[playerid][vpMonitor][slot] = channel;
    }
    return 1;
}

stock VoiceDetachFromChannel(playerid, channel)
{
    if(!VoiceIsValidChannel(channel)) return 0;

    // Never leave a channel while still holding it - the next speaker would
    // find it permanently busy.
    if(VoiceChannelSpeaker[channel] == playerid)
    {
        VoiceRadioStop(playerid, false);
    }

    if(VoiceChannelStream[channel] != SV_NULL &&
       SvHasListenerInStream(VoiceChannelStream[channel], playerid))
    {
        SvDetachListenerFromStream(VoiceChannelStream[channel], playerid);
        if(VoiceChannelListeners[channel] > 0) VoiceChannelListeners[channel]--;
    }

    if(channel == VOICE_CH_ADMIN)
    {
        VoicePlayer[playerid][vpOnAdminChannel] = false;
    }
    else
    {
        for(new s = 0; s < VOICE_MAX_MONITORED; s++)
        {
            if(VoicePlayer[playerid][vpMonitor][s] == channel)
            {
                VoicePlayer[playerid][vpMonitor][s] = VOICE_CHANNEL_NONE;
            }
        }
        if(VoicePlayer[playerid][vpListenIn] == channel)
        {
            VoicePlayer[playerid][vpListenIn] = VOICE_CHANNEL_NONE;
        }
    }

    if(VoicePlayer[playerid][vpActiveChannel] == channel)
    {
        VoicePlayer[playerid][vpActiveChannel] = VOICE_CHANNEL_NONE;
    }
    return 1;
}

// Rule 4: a player who leaves gives up every channel, in one place.
stock VoiceDetachFromAllChannels(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    for(new ch = 0; ch < VOICE_STREAM_COUNT; ch++)
    {
        if(VoiceChannelSpeaker[ch] == playerid)
        {
            VoiceChannelSpeaker[ch] = INVALID_PLAYER_ID;
        }
        if(VoiceChannelStream[ch] != SV_NULL &&
           SvHasListenerInStream(VoiceChannelStream[ch], playerid))
        {
            SvDetachListenerFromStream(VoiceChannelStream[ch], playerid);
            if(VoiceChannelListeners[ch] > 0) VoiceChannelListeners[ch]--;
        }
        if(VoiceChannelStream[ch] != SV_NULL &&
           SvHasSpeakerInStream(VoiceChannelStream[ch], playerid))
        {
            SvDetachSpeakerFromStream(VoiceChannelStream[ch], playerid);
        }
    }

    for(new s = 0; s < VOICE_MAX_MONITORED; s++)
    {
        VoicePlayer[playerid][vpMonitor][s] = VOICE_CHANNEL_NONE;
    }
    VoicePlayer[playerid][vpOnAdminChannel] = false;
    VoicePlayer[playerid][vpListenIn]       = VOICE_CHANNEL_NONE;
    VoicePlayer[playerid][vpActiveChannel]  = VOICE_CHANNEL_NONE;
    VoicePlayer[playerid][vpRadioActive]    = false;
    return 1;
}

// Brings one player's channel attachments in line with their current
// membership. This is the entry point the gamemode may call after a promotion,
// a dismissal or a faction change to make it take effect at once; the watchdog
// calls it on its own when it notices such a change.
stock VoiceRefreshPlayer(playerid, bool:announce = true)
{
    if(!VoiceIsReady(playerid)) return 0;

    new entitled[VOICE_MAX_MONITORED];
    new count = VoiceGetEntitledChannels(playerid, entitled, VOICE_MAX_MONITORED);
    new lost = 0, gained = 0;

    // Leave everything that is no longer covered by the membership.
    for(new s = 0; s < VOICE_MAX_MONITORED; s++)
    {
        new ch = VoicePlayer[playerid][vpMonitor][s];
        if(ch == VOICE_CHANNEL_NONE) continue;

        new bool:stillEntitled = false;
        for(new i = 0; i < count; i++)
        {
            if(entitled[i] == ch) { stillEntitled = true; break; }
        }
        if(!stillEntitled)
        {
            VoiceDetachFromChannel(playerid, ch);
            lost++;
        }
    }

    // Join everything new.
    for(new i = 0; i < count; i++)
    {
        if(!VoiceIsMonitoring(playerid, entitled[i]))
        {
            if(VoiceAttachToChannel(playerid, entitled[i])) gained++;
        }
    }

    // Admin announcement channel follows the admin level.
    if(isPlayerAnAdmin(playerid, VOICE_ADMIN_LEVEL))
    {
        if(!VoicePlayer[playerid][vpOnAdminChannel]) VoiceAttachToChannel(playerid, VOICE_CH_ADMIN);
    }
    else if(VoicePlayer[playerid][vpOnAdminChannel])
    {
        VoiceDetachFromChannel(playerid, VOICE_CH_ADMIN);
    }

    // A transmit channel that is gone has to be replaced, otherwise the radio
    // key would keep pointing at a channel the player just left.
    if(VoicePlayer[playerid][vpActiveChannel] != VOICE_CHANNEL_NONE &&
       !VoiceIsEntitled(playerid, VoicePlayer[playerid][vpActiveChannel]))
    {
        VoicePlayer[playerid][vpActiveChannel] = VOICE_CHANNEL_NONE;
    }
    if(VoicePlayer[playerid][vpActiveChannel] == VOICE_CHANNEL_NONE && count > 0)
    {
        VoicePlayer[playerid][vpActiveChannel] = entitled[0];
    }

    // Snapshot for the watchdog. Taken last, so a refresh that ran into a
    // listener ceiling is retried on the next interval.
    VoicePlayer[playerid][vpSeenFraktion] = Spieler[playerid][pFraktion];
    VoicePlayer[playerid][vpSeenRang]     = Spieler[playerid][pFraktRang];
    VoicePlayer[playerid][vpSeenOrg]      = Spieler[playerid][pOrgMember];
    VoicePlayer[playerid][vpSeenPartei]   = Spieler[playerid][pParteiMember];

    if(announce && (lost || gained))
    {
        new msg[144], name[64];
        if(VoicePlayer[playerid][vpActiveChannel] != VOICE_CHANNEL_NONE)
        {
            VoiceGetChannelName(VoicePlayer[playerid][vpActiveChannel], name, sizeof(name));
            format(msg, sizeof(msg), "[Funk] Deine Funkkanaele wurden aktualisiert. Sendekanal: %s.", name);
        }
        else
        {
            format(msg, sizeof(msg), "[Funk] Du hast keinen Funkkanal mehr.");
        }
        SendClientMessage(playerid, VOICE_COLOR, msg);
    }
    return 1;
}

// Brings the listeners a channel actually has in line with the listeners it
// should have, and repairs the cached counter along the way.
//
// Called at the start and at the end of every transmission. That is the only
// moment the attachment is observable at all - between two transmissions a
// channel carries no audio - which is what makes a dismissal or a promotion
// take effect without a relog: the dismissed member does not hear the next
// word spoken.
//
// speakerid, when given, is the player about to transmit. Listeners who have
// personally ignored them are left off the channel for the duration and are
// picked up again by the sync at the end of the transmission.
stock VoiceSyncChannelListeners(channel, speakerid = INVALID_PLAYER_ID)
{
    if(!VoiceIsValidChannel(channel) || VoiceChannelStream[channel] == SV_NULL) return 0;

    new count = 0;

    ForEachPlayer(i)
    {
        if(IsPlayerNPC(i)) continue;

        new bool:attached = SvHasListenerInStream(VoiceChannelStream[channel], i);
        new bool:wanted;

        if(channel == VOICE_CH_ADMIN)
        {
            wanted = VoicePlayer[i][vpOnAdminChannel] && isPlayerAnAdmin(i, VOICE_ADMIN_LEVEL) == 1;
        }
        else if(VoicePlayer[i][vpListenIn] == channel)
        {
            // Admin listening in. Still bound by the listener ceiling.
            wanted = (isPlayerAnAdmin(i, VOICE_ADMIN_LEVEL) == 1);
        }
        else
        {
            // vpMonitor is the record of intent, entitlement the right to it.
            wanted = VoiceIsMonitoring(i, channel) && VoiceIsEntitled(i, channel);
        }

        // Personal ignore, only for the player who is about to speak.
        if(wanted && speakerid != INVALID_PLAYER_ID && i != speakerid && VoiceIgnores(i, speakerid))
        {
            wanted = false;
        }

        if(wanted && !attached)
        {
            new limit = (channel == VOICE_CH_ADMIN) ? VOICE_ADMIN_MAX_LISTENERS : VOICE_CHANNEL_MAX_LISTENERS;
            if(count < limit && SvAttachListenerToStream(VoiceChannelStream[channel], i))
            {
                count++;
            }
        }
        else if(!wanted && attached)
        {
            SvDetachListenerFromStream(VoiceChannelStream[channel], i);
        }
        else if(attached)
        {
            count++;
        }
    }

    VoiceChannelListeners[channel] = count;
    return 1;
}

// ---------------------------------------------------------------------------
// Transmission
// ---------------------------------------------------------------------------

stock VoiceRadioStart(playerid)
{
    if(VoicePlayer[playerid][vpRadioActive]) return 0;

    new reason[96], msg[160];

    if(!VoiceMayTransmit(playerid, reason, sizeof(reason)))
    {
        if(reason[0] != EOS)
        {
            format(msg, sizeof(msg), "[Funk] %s", reason);
            SendClientMessage(playerid, VOICE_COLOR, msg);
        }
        return 0;
    }

    new channel = VoicePlayer[playerid][vpActiveChannel];
    if(channel == VOICE_CHANNEL_NONE)
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Funk] Du hast keinen Sendekanal gewaehlt. /funkkanal zeigt deine Kanaele.");
        return 0;
    }

    if(!VoiceMayTransmitOn(playerid, channel, reason, sizeof(reason)))
    {
        if(reason[0] != EOS)
        {
            format(msg, sizeof(msg), "[Funk] %s", reason);
            SendClientMessage(playerid, VOICE_COLOR, msg);
        }
        PlayerPlaySound(playerid, VOICE_SOUND_BUSY, 0.0, 0.0, 0.0);
        return 0;
    }

    // Half duplex: exactly one speaker per channel.
    if(VoiceChannelSpeaker[channel] != INVALID_PLAYER_ID &&
       VoiceChannelSpeaker[channel] != playerid)
    {
        new other = VoiceChannelSpeaker[channel];
        if(IsPlayerConnected(other))
        {
            format(msg, sizeof(msg), "[Funk] Kanal belegt - %s spricht gerade.", SpielerName(other));
            SendClientMessage(playerid, VOICE_COLOR, msg);
            PlayerPlaySound(playerid, VOICE_SOUND_BUSY, 0.0, 0.0, 0.0);
            return 0;
        }
        // Speaker vanished without releasing the channel: take it over.
        VoiceChannelSpeaker[channel] = INVALID_PLAYER_ID;
    }

    // Membership may have changed since the last transmission, and listeners
    // who ignore this speaker have to come off the channel. Doing it here means
    // a dismissed member never hears the next word.
    VoiceSyncChannelListeners(channel, playerid);

    // Radio outranks proximity: the same voice must not go out twice.
    if(VoicePlayer[playerid][vpProxActive])
    {
        VoiceProximityStop(playerid);
    }

    if(!SvAttachSpeakerToStream(VoiceChannelStream[channel], playerid))
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Funk] Der Funkkanal konnte nicht geoeffnet werden.");
        return 0;
    }

    VoiceChannelSpeaker[channel]         = playerid;
    VoicePlayer[playerid][vpRadioActive] = true;
    VoicePlayer[playerid][vpTalkStart]   = GetTickCount();
    VoiceIndicateRadio(playerid, channel, true);
    return 1;
}

stock VoiceRadioStop(playerid, bool:fromKeyRelease = true)
{
    #pragma unused fromKeyRelease

    if(!VoicePlayer[playerid][vpRadioActive]) return 0;

    new channel = VoicePlayer[playerid][vpActiveChannel];

    if(VoiceIsValidChannel(channel) && VoiceChannelStream[channel] != SV_NULL)
    {
        SvDetachSpeakerFromStream(VoiceChannelStream[channel], playerid);
    }

    // Release the channel wherever this player still holds it. Going through
    // every channel covers the case of a switch that happened mid transmission.
    for(new ch = 0; ch < VOICE_STREAM_COUNT; ch++)
    {
        if(VoiceChannelSpeaker[ch] == playerid)
        {
            VoiceChannelSpeaker[ch] = INVALID_PLAYER_ID;
            if(VoiceChannelStream[ch] != SV_NULL &&
               SvHasSpeakerInStream(VoiceChannelStream[ch], playerid))
            {
                SvDetachSpeakerFromStream(VoiceChannelStream[ch], playerid);
            }
        }
    }

    VoicePlayer[playerid][vpRadioActive]  = false;
    VoicePlayer[playerid][vpTalkStart]    = 0;
    VoicePlayer[playerid][vpLastTalkEnd]  = GetTickCount();

    // Listeners that were left off because they ignore this speaker belong
    // back on the channel now that the transmission is over. The indicator has
    // to go before that, while the listener list still holds everybody who saw
    // it come up.
    if(VoiceIsValidChannel(channel))
    {
        VoiceIndicateRadio(playerid, channel, false);
        VoiceSyncChannelListeners(channel);
    }
    return 1;
}

// ---------------------------------------------------------------------------
// Channel switching
// ---------------------------------------------------------------------------

stock VoiceSetActiveChannel(playerid, channel)
{
    if(!VoiceIsReady(playerid)) return 0;

    if(!VoiceIsEntitled(playerid, channel))
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Funk] Diesen Funkkanal darfst du nicht benutzen.");
        return 0;
    }

    if(VoicePlayer[playerid][vpLastSwitch] != 0 &&
       (GetTickCount() - VoicePlayer[playerid][vpLastSwitch]) < VOICE_SWITCH_COOLDOWN_MS)
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Funk] Nicht so schnell umschalten.");
        return 0;
    }

    // Never switch out from under a running transmission.
    if(VoicePlayer[playerid][vpRadioActive])
    {
        VoiceRadioStop(playerid, false);
    }

    VoicePlayer[playerid][vpActiveChannel] = channel;
    VoicePlayer[playerid][vpLastSwitch]    = GetTickCount();

    // Switching to a channel implies listening to it.
    if(!VoiceIsMonitoring(playerid, channel) && channel != VOICE_CH_ADMIN)
    {
        VoiceAttachToChannel(playerid, channel);
    }

    new name[64], msg[128];
    VoiceGetChannelName(channel, name, sizeof(name));
    format(msg, sizeof(msg), "[Funk] Sendekanal: %s. X gedrueckt halten zum Funken.", name);
    SendClientMessage(playerid, VOICE_COLOR, msg);
    return 1;
}

// ---------------------------------------------------------------------------
// Plugin callbacks - both push to talk keys land here
// ---------------------------------------------------------------------------

public SV_VOID:OnPlayerActivationKeyPress(SV_UINT:playerid, SV_UINT:keyid)
{
    if(keyid == VOICE_KEY_RADIO)
    {
        VoiceRadioStart(playerid);
    }
    else if(keyid == VOICE_KEY_PROXIMITY)
    {
        // Radio has priority: while it is open, the proximity key does nothing.
        if(!VoicePlayer[playerid][vpRadioActive])
        {
            VoiceProximityStart(playerid);
        }
    }
    return;
}

public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid, SV_UINT:keyid)
{
    if(keyid == VOICE_KEY_RADIO)
    {
        VoiceRadioStop(playerid);
    }
    else if(keyid == VOICE_KEY_PROXIMITY)
    {
        VoiceProximityStop(playerid);
    }

    // The watchdog cut-off is lifted by a real key release only, so a taped
    // down key cannot simply carry on after being cut.
    VoicePlayer[playerid][vpCutOff] = false;
    return;
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

CMD:funkkanal(playerid, params[])
{
    if(!VoiceIsReady(playerid))
    {
        return SendClientMessage(playerid, VOICE_COLOR, "[Funk] Dein Voice-Plugin ist nicht verbunden.");
    }

    new entitled[VOICE_MAX_MONITORED];
    new count = VoiceGetEntitledChannels(playerid, entitled, VOICE_MAX_MONITORED);

    if(count == 0)
    {
        return SendClientMessage(playerid, VOICE_COLOR, "[Funk] Du gehoerst keiner Fraktion, keinem Unternehmen und keiner Partei an.");
    }

    new name[64], msg[160];

    if(isnull(params))
    {
        SendClientMessage(playerid, VOICE_COLOR, "--- Deine Funkkanaele ---");
        for(new i = 0; i < count; i++)
        {
            VoiceGetChannelName(entitled[i], name, sizeof(name));
            format(msg, sizeof(msg), "%d) %s%s", i + 1, name,
                (entitled[i] == VoicePlayer[playerid][vpActiveChannel]) ? (" - Sendekanal") : (""));
            SendClientMessage(playerid, VOICE_COLOR, msg);
        }
        SendClientMessage(playerid, VOICE_COLOR, "/funkkanal [Nummer] waehlt den Sendekanal.");
        return 1;
    }

    new choice;
    if(sscanf(params, "d", choice) || choice < 1 || choice > count)
    {
        format(msg, sizeof(msg), "[Funk] Benutzung: /funkkanal [1-%d]", count);
        return SendClientMessage(playerid, VOICE_COLOR, msg);
    }

    VoiceSetActiveChannel(playerid, entitled[choice - 1]);
    return 1;
}

CMD:funk(playerid, params[])
{
    return cmd_funkkanal(playerid, params);
}

CMD:funkinfo(playerid, params[])
{
    #pragma unused params

    if(!VoiceIsReady(playerid))
    {
        return SendClientMessage(playerid, VOICE_COLOR, "[Funk] Dein Voice-Plugin ist nicht verbunden.");
    }

    new name[64], msg[160];

    if(VoicePlayer[playerid][vpActiveChannel] == VOICE_CHANNEL_NONE)
    {
        SendClientMessage(playerid, VOICE_COLOR, "[Funk] Kein Sendekanal gewaehlt.");
    }
    else
    {
        VoiceGetChannelName(VoicePlayer[playerid][vpActiveChannel], name, sizeof(name));
        format(msg, sizeof(msg), "[Funk] Sendekanal: %s (%d von %d Zuhoerern).",
            name,
            VoiceChannelListeners[VoicePlayer[playerid][vpActiveChannel]],
            VOICE_CHANNEL_MAX_LISTENERS);
        SendClientMessage(playerid, VOICE_COLOR, msg);
    }

    SendClientMessage(playerid, VOICE_COLOR, "Mitgehoerte Kanaele:");
    for(new s = 0; s < VOICE_MAX_MONITORED; s++)
    {
        if(VoicePlayer[playerid][vpMonitor][s] == VOICE_CHANNEL_NONE) continue;
        VoiceGetChannelName(VoicePlayer[playerid][vpMonitor][s], name, sizeof(name));
        format(msg, sizeof(msg), " - %s", name);
        SendClientMessage(playerid, VOICE_COLOR, msg);
    }
    if(VoicePlayer[playerid][vpOnAdminChannel])
    {
        SendClientMessage(playerid, VOICE_COLOR, " - Admin-Durchsage");
    }
    return 1;
}
