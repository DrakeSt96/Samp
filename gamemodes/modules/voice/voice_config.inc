/*
    voice_config.inc - Central configuration for the voice and radio system.

    Rule: every distance, bitrate, limit, cooldown and key binding lives HERE.
    One value, one place. Do not hardcode any of these elsewhere.

    Plugin: sampvoice (open.mp fork by AmyrAhmady)
    https://github.com/AmyrAhmady/sampvoice/releases  (x.x.x-omp build)
*/

#if defined _voice_config_included
    #endinput
#endif
#define _voice_config_included

// ---------------------------------------------------------------------------
// Audio
// ---------------------------------------------------------------------------

// Bitrate in bits per second, passed to SvInit().
// 200 slots make upstream the bottleneck, not audio fidelity. Stay at or below
// 24000. 8000 is the plugin's own low-bandwidth setting.
#define VOICE_BITRATE                   (20000)

// ---------------------------------------------------------------------------
// Proximity distances (game units)
// ---------------------------------------------------------------------------

#define VOICE_DIST_WHISPER              (4.0)
#define VOICE_DIST_NORMAL               (14.0)
#define VOICE_DIST_SHOUT                (30.0)

// Range mode identifiers. Kept dense so they can index VoiceRangeName[].
#define VOICE_RANGE_WHISPER             (0)
#define VOICE_RANGE_NORMAL              (1)
#define VOICE_RANGE_SHOUT               (2)
#define VOICE_RANGE_COUNT               (3)

#define VOICE_RANGE_DEFAULT             VOICE_RANGE_NORMAL

// How many listeners a single proximity stream accepts. The plugin drops
// further listeners once this is reached, which caps the fan-out per speaker.
#define VOICE_PROXIMITY_MAX_LISTENERS   (40)

// ---------------------------------------------------------------------------
// Radio channels
// ---------------------------------------------------------------------------

// Channel groups. The offsets carve one flat channel id space out of the
// existing faction / organisation / party ids, so nothing is administered twice.
#define VOICE_CHANNEL_NONE              (-1)

#define VOICE_FACTION_COUNT             (19)    // ids 0..18, 0 = "Keine"
#define VOICE_ORG_COUNT                 (MAX_ORGANISATIONS)
#define VOICE_PARTY_COUNT               (MAX_PARTEI)

#define VOICE_CH_FACTION_BASE           (0)
#define VOICE_CH_ORG_BASE               (VOICE_CH_FACTION_BASE + VOICE_FACTION_COUNT)
#define VOICE_CH_PARTY_BASE             (VOICE_CH_ORG_BASE + VOICE_ORG_COUNT)
#define VOICE_CHANNEL_COUNT             (VOICE_CH_PARTY_BASE + VOICE_PARTY_COUNT)

// Admin-wide announcement channel, created on top of the mapped ones.
#define VOICE_CH_ADMIN                  (VOICE_CHANNEL_COUNT)
#define VOICE_STREAM_COUNT              (VOICE_CHANNEL_COUNT + 1)

// Hard listener ceiling per radio channel. Admin announcements are exempt.
#define VOICE_CHANNEL_MAX_LISTENERS     (60)
#define VOICE_ADMIN_MAX_LISTENERS       (MAX_PLAYERS)

// How many channels one player may monitor at the same time.
#define VOICE_MAX_MONITORED             (3)

// Faction rank from which a member may transmit. Lower ranks listen only.
// Organisations and parties have no rank system in this gamemode - there only
// membership exists - so this applies to faction channels only.
#define VOICE_RANK_TRANSMIT             (1)

// Mirror the requirement of the existing text radio /d for the voice radio:
// a member needs a radio (pFunkgeraet), sits in a faction vehicle of their own
// faction, or stands at a faction terminal. Set to 0 to let rank alone decide.
// Applies to faction channels only, organisations and parties have no such item.
#define VOICE_FACTION_REQUIRE_RADIO     (1)

// Admin level required for the voice admin commands.
#define VOICE_ADMIN_LEVEL               (2)
// Admin level required for the server-wide announcement.
#define VOICE_ADMIN_LEVEL_BROADCAST     (4)

// ---------------------------------------------------------------------------
// Push to talk (Windows virtual key codes, passed to SvAddKey)
// ---------------------------------------------------------------------------

#define VOICE_KEY_PROXIMITY             (0x59)  // Y
#define VOICE_KEY_RADIO                 (0x58)  // X

// ---------------------------------------------------------------------------
// Abuse protection
// ---------------------------------------------------------------------------

// Minimum gap between two transmissions of the same player, in milliseconds.
#define VOICE_COOLDOWN_MS               (400)

// Minimum gap between two channel switches, in milliseconds.
#define VOICE_SWITCH_COOLDOWN_MS        (1500)

// Longest single transmission before the player is cut off, in milliseconds.
// Guards against a taped-down push-to-talk key.
#define VOICE_MAX_TALK_MS               (45000)

// Interval of the watchdog timer that enforces VOICE_MAX_TALK_MS.
#define VOICE_WATCHDOG_INTERVAL_MS      (5000)

// ---------------------------------------------------------------------------
// User interface
// ---------------------------------------------------------------------------

// Chat colour of voice system messages. Matches the existing scheme.
#define VOICE_COLOR                     (0x33CCFFAA)

// Sound played when a channel is busy or a transmission is refused.
#define VOICE_SOUND_BUSY                (1085)

// Textdraw position of the "currently speaking" indicator.
#define VOICE_TD_POS_X                  (12.0)
#define VOICE_TD_POS_Y                  (330.0)

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

// Log file for admin voice actions, written through the gamemode's Log().
#define VOICE_LOG_FILE                  "Voice_Admin.txt"

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

// Table holding persistent global mutes. Created by voice_mutes.sql.
// The script never creates it - run the file against the database yourself.
#define VOICE_MUTE_TABLE                "voice_mutes"

// ---------------------------------------------------------------------------
// Bitset sizes - derived, do not tune by hand
// ---------------------------------------------------------------------------

#define VOICE_BITS_PER_CELL             (32)
// One bit per channel: which channels a player is muted on.
#define VOICE_MUTE_CELLS                ((VOICE_STREAM_COUNT + VOICE_BITS_PER_CELL - 1) / VOICE_BITS_PER_CELL)
// One bit per player: whom a player has personally ignored.
#define VOICE_IGNORE_CELLS              ((MAX_PLAYERS + VOICE_BITS_PER_CELL - 1) / VOICE_BITS_PER_CELL)
