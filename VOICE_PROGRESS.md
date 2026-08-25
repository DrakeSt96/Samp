# VOICE_PROGRESS.md

Gedächtnis des Voice-/Funksystems zwischen Sessions.
Gamemode: `gamemodes/script.pwn` (open.mp, ~90.700 Zeilen), Branch `claude/script-pwn-analysis-o9mnc7`.

---

## Status

| Phase | Inhalt | Status | Datum |
|-------|--------|--------|-------|
| 0 | Recon, kein Code | **abgeschlossen** | 2026-08-25 |
| 1 | Kern: Proximity | offen | |
| 2 | Funk | offen | |
| 3 | Admin, Missbrauchsschutz, UX | offen | |
| 4 | Lasttest (nur auf Zuruf) | nicht gestartet | |

---

## Blocker

### B-1 — Voice-Plugin-Binary fehlt (offen, muss ein Mensch erledigen)

`plugins/` enthält kein Voice-Plugin. Wichtiger noch: open.mp **blockiert das
Original-sampvoice aktiv**. In `Server/Source/plugin.cpp` bzw.
`PluginManager.cpp` steht `"sampvoice"` auf einer Blockliste, mit Verweis auf
den open.mp-Fork.

Es muss der Fork installiert werden:
`https://github.com/AmyrAhmady/sampvoice/releases` — der Build mit dem Suffix
`-omp`. Server-Binary nach `plugins/`, Eintrag in `config.json` unter
`pawn.legacy_plugins`. Der Client-Teil (`sampvoice.asi` + `sampvoice.dll`) muss
zusätzlich bei jedem Spieler ins GTA-Verzeichnis.

**Ich habe nur die Include-Datei installiert**
(`pawno/include/Gloabe Includes/sampvoice.inc`, aus dem Fork), keine Binary —
Binaries sind neue Dependencies, und die darf ich laut Autonomie-Regeln nicht
ohne Rückfrage hinzufügen. Der Code kompiliert trotzdem, weil Pawn Natives erst
zur Laufzeit auflöst. **Ohne die Plugin-Binary startet der Gamemode nicht** (der
Server bricht mit „Function not registered" ab, sobald ein `Sv*`-Native gerufen
wird).

Bis dahin lässt sich alles außer dem tatsächlichen Hörerlebnis prüfen.

---

## Phase 0 — Recon

### Verzeichnisstruktur und Build

```
gamemodes/script.pwn          Hauptgamemode, ~90.700 Zeilen, alles in einer Datei
gamemodes/modules/voice/      NEU, hier lebt der Voice-Code
pawno/include/                Include-Wurzel
pawno/include/ScriptInc.inc   Sammel-Include, zieht open.mp + alle Plugins
pawno/include/Gloabe Includes/  (sic, Tippfehler im Original) Plugin-Includes
plugins/                      Server-Plugins (.so/.dll)
filterscripts/                Filterscripts
npcmodes/                     NPC-Scripts
config.json                   open.mp-Konfiguration
```

Kompiliert wird mit `pawncc` gegen `pawno/include`. Die Datei ist
**ISO-8859-1 (Latin-1) mit CRLF** — jede Änderung muss dieses Encoding erhalten,
sonst zerschießt es die Umlaute in tausenden Spielertexten.

Prüfstand dieser Session: selbst gebauter `pawncc` 3.10.10.
Referenzstand vor Phase 1: **0 Fehler, 1168 Warnungen** (die Warnungen sind
Altlasten aus dem Originalscript, überwiegend `symbol is never used`).

### MySQL

- Wrapper: **BlueG MySQL R39-4** (`a_mysql.inc`)
- `mysql_function_query` ist ein **Makro**, kein Native
- Muster im Bestand:
  ```pawn
  format(query,sizeof(query),"SELECT ... FROM spieler WHERE Name = '%e'",name);
  mysql_function_query(dbhandle,query,true,"OnQueryFinish","ii",playerid,threadid);
  ```
- `%e` escaped korrekt, wird im Bestand inzwischen durchgängig benutzt
- Auslesen über `cache_get_field_content` / `cache_get_field_content_int`
- **Regel 6 ist im Bestand nicht durchgehend eingehalten** — mein Voice-Code
  prüft `cache_num_rows()` vor jedem Zugriff, ohne Ausnahme.

### Exaktes Schema (wörtlich abgeschrieben)

Tabelle **`spieler`** — relevante Spalten:

| Spalte | Bedeutung |
|--------|-----------|
| `Fraktion` | Fraktions-ID, 0 = keine |
| `FraktionsRang` | Rang innerhalb der Fraktion |
| `FraktionsURang` | Unterrang |
| `FLeaderRechte` | Leader-Flag |
| `FraktionsSperre` | Sperre für Fraktionsbeitritt |
| `FraktionsGehalt` | Gehalt |
| `pOrgMember` | Organisations-ID, 0 = keine |
| `pOrgLeader` | Organisations-ID, wenn Leader |
| `pParteiMember` | Partei-/Clan-ID, 0 = keine |
| `pParteiLeader` | Partei-/Clan-ID, wenn Leader |
| `pFirmaLeader` | Firmen-ID, wenn Leader |

Tabelle **`server_frakdefi`** — Fraktionsdefinition:

| Spalte | Bedeutung |
|--------|-----------|
| `fID` | Fraktions-ID |
| `F0` … `F6` | Rangnamen, Rang 0 bis 6 |
| `FrakMembers` | aktuelle Mitgliederzahl |
| `FrakLimit` | Mitgliederlimit |

Weitere Tabellen: **`server_oris`** (Organisationen), **`server_patei`**
(Parteien/Clans — der Tippfehler ist im Original, nicht meiner),
**`server_firmen`** (Firmen).

### Laufzeit-Speicher

Es gibt ein Spieler-Enum-Array `Spieler[MAX_PLAYERS][pInfo]`. Relevante Felder:

| Feld | Zeile | Inhalt |
|------|-------|--------|
| `pOrgLeader` | 1090 | Org-ID wenn Leader |
| `pOrgMember` | 1091 | Org-ID |
| `pParteiLeader` | 1092 | Partei-ID wenn Leader |
| `pParteiMember` | 1093 | Partei-ID |
| `pFraktion` | 1222 | Fraktions-ID |
| `pLeader` | 1232 | Leader-Flag |
| `pFraktRang` | 1233 | Rang |
| `pFraktURang` | 1234 | Unterrang |
| `pAdmin` | 1236 | Adminlevel |

Dazu `OrganisationsInfo` (ab Zeile 1501: `OrgCreatet`, `OrgName[32]`,
`OrgOwner[24]`, `OrgMotto[128]`, `OrgKasse`, `OrgMBeitrag`) und `ParteiInfo`
(ab Zeile 1524).

Limits: `MAX_ORGANISATIONS` = 10, `MAX_PARTEI` = 5, Fraktionen 0–18 (18 echte,
0 = „Keine", ablesbar an den `case`-Zweigen in `FraktionsName()`).

**Daraus folgt der Kanalraum:** 19 + 10 + 5 = 34 Funkkanäle, plus 1
Admin-Durchsage = 35 GStreams, dazu bis zu 200 Proximity-Streams (einer je
verbundenem Spieler). Das Plugin erlaubt `kMaxStreams` = 4096 — passt mit
großem Abstand.

### Voice-Plugin

- Include installiert: `pawno/include/Gloabe Includes/sampvoice.inc`
- **Fork von AmyrAhmady, `SV_VERSION 11`** — nicht CyberMor v4. Die beiden APIs
  sind vollständig verschieden; v4-Beispiele aus dem Netz kompilieren hier nicht.
- Verwendete Natives (alle in der Include verifiziert):
  `SvInit`, `SvGetVersion`, `SvHasMicro`, `SvAddKey`, `SvRemoveAllKeys`,
  `SvCreateGStream`, `SvCreateDLStreamAtPlayer`, `SvUpdateDistanceForLStream`,
  `SvAttachListenerToStream`, `SvDetachListenerFromStream`,
  `SvHasListenerInStream`, `SvDetachAllListenersFromStream`,
  `SvAttachSpeakerToStream`, `SvDetachSpeakerFromStream`,
  `SvHasSpeakerInStream`, `SvDetachAllSpeakersFromStream`,
  `SvStreamParameterSet`, `SvDeleteStream`,
  `SvMutePlayerEnable`, `SvMutePlayerDisable`, `SvMutePlayerStatus`
- Callbacks: `OnPlayerActivationKeyPress(playerid, keyid)` /
  `OnPlayerActivationKeyRelease(playerid, keyid)`

### Tastatur

`OnPlayerKeyStateChange` belegt bereits `KEY_ANALOG_DOWN/LEFT/RIGHT/UP`,
`KEY_JUMP`, `KEY_N`, `KEY_WALK`, `KEY_YES`.

**Kein Konflikt:** sampvoice hört nicht auf SA-MP-Keys, sondern registriert über
`SvAddKey` echte Windows-Virtual-Key-Codes clientseitig. Y (0x59) und X (0x58)
sind in GTA nicht vorbelegt.

### UI und Admin

- Textdraws: `TextDrawCreate` / `PlayerText:CreatePlayerTextDraw` im Bestand
  reichlich vorhanden, Muster übernehme ich.
- Adminprüfung: `isPlayerAnAdmin(playerid, rang)` → `Spieler[playerid][pAdmin] >= rang`
- Logging: `stock Log(log[], text[])` schreibt in eine Datei unter `scriptfiles/`

### Hook-Punkte

Je genau ein `public` im Script, alle geeignet zum Anhängen:

| Callback | Zeile |
|----------|-------|
| `OnGameModeInit` | 5118 |
| `OnGameModeExit` | 11186 |
| `OnPlayerConnect` | 11236 |
| `OnPlayerDisconnect` | 11691 |
| `OnPlayerSpawn` | 12117 |
| `OnPlayerDeath` | 13408 |

---

## Umsetzungsplan Phase 1–3

Der Plan orientiert sich an dem, was oben tatsächlich vorgefunden wurde.

### Phase 1 — Proximity

Dateien:
- `gamemodes/modules/voice/voice_config.inc` — alle Werte (fertig)
- `gamemodes/modules/voice/voice_core.inc` — Per-Player-State, Stream-Lifecycle,
  zentrales Cleanup, Hook-Einstiegspunkte
- `gamemodes/modules/voice/voice_proximity.inc` — Distanzstufen, PTT, Befehle

Technik: pro verbundenem Spieler **ein** `SvCreateDLStreamAtPlayer(distance,
maxplayers, playerid)`. Distanzstufe wird nicht durch Neuanlegen des Streams
umgeschaltet, sondern durch `SvUpdateDistanceForLStream` — das ist der Grund,
warum ein Stream pro Spieler reicht statt drei.

Zuhörer kommen nicht statisch dran: sampvoice attached Zuhörer explizit. Beim
Sprechbeginn werden die Spieler in Reichweite (plus Sicherheitsmarge) attached,
beim Ende wieder detached. Das hält die Attach-Listen kurz und respektiert
`VOICE_PROXIMITY_MAX_LISTENERS`.

### Phase 2 — Funk

- 34 GStreams in `OnGameModeInit`, Index = flache Kanal-ID aus `voice_config.inc`
  (Fraktion 0–18, Org 19–28, Partei 29–33), Admin-Kanal 34
- Zugehörigkeit wird **ausgelesen**, nie gespiegelt: `VoiceGetPlayerChannels()`
  liest `Spieler[playerid][pFraktion]`, `[pOrgMember]`, `[pParteiMember]`
- „Live-Reaktion ohne Relog" über eine öffentliche Funktion
  `VoiceRefreshPlayer(playerid)`, die an den bestehenden Stellen für
  Beförderung / Entlassung / Wechsel aufgerufen wird — ein Einzeiler je Stelle,
  die Fraktionslogik selbst bleibt unangetastet (Autonomie-Regel).
- Halbduplex über `VoiceChannelSpeaker[channel]`; wer reindrückt, während belegt
  ist, bekommt „Kanal belegt".

### Phase 3 — Admin, Missbrauchsschutz, UX

- Mute dreistufig: global (`SvMutePlayerEnable` + DB), kanalbezogen
  (Bitmaske je Spieler), persönliches Ignorieren (Bitset Spieler×Spieler)
- Persistenz in neuer Tabelle `voice_mutes`, angelegt per mitgeliefertem SQL —
  **ich führe nichts gegen die Produktions-DB aus**, das SQL liegt als Datei bei
- Anti-Spam: `VOICE_COOLDOWN_MS`, `VOICE_SWITCH_COOLDOWN_MS`, Watchdog-Timer
  gegen festgeklebtes PTT (`VOICE_MAX_TALK_MS`)
- Textdraw „spricht gerade", Logging über das bestehende `Log()`

---

## Zu testen, bevor es weitergeht

Nichts — Phase 0 hat keinen Code produziert. Der einzige Handlungspunkt für
einen Menschen ist **Blocker B-1**: Plugin-Binary besorgen und installieren.
