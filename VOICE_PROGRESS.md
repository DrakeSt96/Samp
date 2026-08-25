# VOICE_PROGRESS.md

Gedächtnis des Voice-/Funksystems zwischen Sessions.
Gamemode: `gamemodes/script.pwn` (open.mp, ~90.700 Zeilen), Branch `claude/script-pwn-analysis-o9mnc7`.

---

## Status

| Phase | Inhalt | Status | Datum |
|-------|--------|--------|-------|
| 0 | Recon, kein Code | **abgeschlossen** | 2026-08-25 |
| 1 | Kern: Proximity | **abgeschlossen** | 2026-08-25 |
| 2 | Funk | **abgeschlossen** | 2026-08-25 |
| 3 | Admin, Missbrauchsschutz, UX | **abgeschlossen** | 2026-08-25 |
| 4 | Lasttest (nur auf Zuruf) | nicht gestartet | |

Alle drei Bauphasen wurden auf ausdrückliche Anweisung in einer Sitzung
umgesetzt, statt wie im Ablauf vorgesehen eine pro Sitzung.

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

## Phase 1 — Proximity (abgeschlossen)

### Angelegte Dateien

| Datei | Inhalt |
|-------|--------|
| `gamemodes/modules/voice/voice.inc` | Sammel-Include, Reihenfolge bindend |
| `gamemodes/modules/voice/voice_config.inc` | Alle Werte an einer Stelle |
| `gamemodes/modules/voice/voice_core.inc` | Spielerzustand, Stream-Lebenszyklus, Watchdog |
| `gamemodes/modules/voice/voice_proximity.inc` | Distanzstufen, Push-to-Talk, Befehle |

Geändert: `pawno/include/ScriptInc.inc` (bindet `<sampvoice>` ein) und
`gamemodes/script.pwn` (ein `#include` plus je eine Zeile in sechs Callbacks).

### Entscheidungen und Begründung

**Ein `DynamicLocalStreamAtPlayer` je Spieler, nicht drei.** Der Blick in
`server/DynamicLocalStreamAtPlayer.cpp` des Plugins hat gezeigt, dass dieser
Streamtyp seine Zuhörer in `Tick()` selbst verwaltet: Distanz, Interior und
Virtual World werden dort in C++ geprüft und `maxPlayers` eingehalten. Der Plan
aus Phase 0, Zuhörer beim Sprechbeginn von Hand anzuhängen, war damit
überflüssig — und wäre langsamer und fehleranfälliger gewesen. Die drei
Distanzstufen ändern den Radius des einen Streams per
`SvUpdateDistanceForLStream`.

**Speaker nur solange die Taste gedrückt ist.** Der Client nimmt von sich aus
auf, sobald eine über `SvAddKey` registrierte Taste unten ist. Wohin das Audio
geht, entscheidet allein die Speaker-Anhängung auf dem Server. Ein gepatchter
Client kann also senden, was er will — ohne Speaker-Eintrag läuft es ins Leere.

**Aufsetzen erst nach dem Login.** `SvGetVersion()` liefert 0, bis der Client
seinen Handshake geschickt hat, und der Loginscreen ist voller Textdraws. Der
Watchdog holt einen späten Handshake alle fünf Sekunden nach.

**Bei Tod nur senden stoppen, Stream behalten.** Wer am Boden liegt, hört
weiter mit. Das Senden blockiert ohnehin über `PLAYER_STATE_WASTED`, `pDeath`
und `pFriedhof`.

---

## Phase 2 — Funk (abgeschlossen)

### Angelegte Dateien

| Datei | Inhalt |
|-------|--------|
| `gamemodes/modules/voice/voice_radio.inc` | Kanäle, Rechte, Halbduplex, Tastencallbacks |

### Entscheidungen und Begründung

**Kanal-IDs als flache Projektion.** 0–18 Fraktion, 20–28 Unternehmen, 30–33
Partei, 34 Admin. Die drei „Null-IDs" (0, 19, 29) bekommen keinen Stream. 32
GStreams, einmalig in `OnGameModeInit`. Die Zugehörigkeit wird bei jedem
Sendeversuch frisch aus `Spieler[][...]` gelesen — keine Parallelverwaltung,
kein Cache, der veralten kann.

**Live-Reaktion ohne Relog, ohne 37 Hooks.** Fraktion, Rang, Unternehmen und
Partei werden an 37 Stellen in `script.pwn` geschrieben. Alle zu hooken wäre
weder minimal noch verlässlich. Stattdessen zwei Wege:

1. `VoiceSyncChannelListeners()` prüft zu Beginn *jeder* Übertragung alle
   Zuhörer des Kanals gegen die aktuelle Mitgliedschaft. Wer entlassen wurde,
   hört das nächste Wort nicht mehr — und zwischen zwei Übertragungen gibt es
   nichts zu hören, also gibt es kein Fenster, in dem jemand etwas mitbekäme,
   das er nicht dürfte.
2. Der Watchdog vergleicht alle fünf Sekunden gegen einen Schnappschuss und
   räumt die Anhänge um.

`VoiceRefreshPlayer(playerid)` ist zusätzlich öffentlich — wer sofortige
Wirkung an einer bestimmten Stelle will, ruft dort diese eine Zeile auf. Die
Fraktionslogik selbst bleibt unangetastet.

**Rechte:** Fraktionsrang ab `VOICE_RANK_TRANSMIT` darf senden, Leader immer,
darunter nur mithören. Unternehmen und Parteien kennen im Gamemode keinen Rang,
dort entscheidet die Mitgliedschaft. Dazu dieselben Sperren wie beim
bestehenden Textfunk `/d` — gemutet, AFK, Knast, tot, getazert, gefesselt — und
über `VOICE_FACTION_REQUIRE_RADIO` auch dessen Funkgerät-Pflicht. Das ist
bewusst aus dem Bestand abgelesen und nicht neu erfunden.

**Kanalnamen von Unternehmen und Parteien bleiben generisch** in der
Sprecherliste des Clients. Das Plugin backt den Namen beim Anlegen in den
Stream und kennt kein Umbenennen; ein Umbenennen zur Laufzeit hieße Stream
löschen und neu anlegen, also Regel 2 brechen. Im Chat steht überall der echte,
aktuelle Name aus `OrgInfo`/`PartInfo`.

### Eigene Fehler, die die Nachkontrolle gefunden hat

- `VoiceChannelListeners[]` konnte nach oben driften: stürzt das Client-Plugin
  ab, während der Spieler verbunden bleibt, löst das Plugin ihn still von allen
  Streams. Der Kanal wäre langsam „voll" gelaufen und hätte alle ausgesperrt.
  Vor jeder Ablehnung wird jetzt exakt nachgezählt, und der Watchdog baut den
  Zustand solcher Spieler neu auf.
- `VoiceAttachToChannel()` hätte anhängen können, ohne einen freien
  Monitor-Slot zu haben — der Kanal wäre dann in keiner Buchführung
  aufgetaucht. Der Slot wird jetzt vorher belegt.

---

## Phase 3 — Admin, Missbrauchsschutz, UX (abgeschlossen)

### Angelegte Dateien

| Datei | Inhalt |
|-------|--------|
| `gamemodes/modules/voice/voice_admin.inc` | Mute-System, Adminbefehle, Logging, Datenbank |
| `gamemodes/modules/voice/voice_ui.inc` | „Spricht gerade"-Anzeige |
| `gamemodes/modules/voice/voice_mutes.sql` | Tabelle für dauerhafte Stummschaltungen |
| `gamemodes/modules/voice/README.md` | Befehle, alle Config-Werte, Installation |

### Entscheidungen und Begründung

**Drei Mute-Ebenen:** global (Plugin-Mute plus Datenbank), kanalbezogen
(Bitset je Spieler über die Kanäle), persönliches Ignorieren (Bitset je Spieler
über die Spieler).

**Das persönliche Ignorieren greift nur im Funk.** Proximity läuft über
`DynamicLocalStream`s, die ihre Zuhörer im Plugin selbst nach Distanz wählen
und jeden wieder anhängen, den das Script abhängt — nachgelesen in
`DynamicLocalStreamAtPlayer::Tick()`. Ein serverseitiges Ignorieren wäre dort
ein Halbfeature, das nach dem nächsten Plugin-Tick wieder aufgeht. Der einzige
Weg dahin wäre der Wechsel auf `StaticLocalStream` mit vollständiger
Zuhörerverwaltung in Pawn — bei 200 Slots die schlechtere Wahl. sampvoice
bringt für genau diesen Fall eine clientseitige Blacklist mit
(`client/BlackList.cpp`, im Plugin-Menü erreichbar), die überall wirkt. Darauf
verweisen `/vignore` und das README.

**Admin-Mithören bekommt einen eigenen Zustandsplatz** (`vpListenIn`) statt
eines der drei Monitor-Slots. Sonst könnte ein Admin, der selbst in Fraktion,
Unternehmen und Partei ist, gar nicht mithören.

**Anzeige geht durch genau eine Funktion.** `VoiceRefreshIndicator()`
entscheidet nach fester Rangfolge, was ein Spieler sieht: eigener Funk >
eigener Nahbereich > fremder Funk > nichts.

### Eigene Fehler, die die Nachkontrolle gefunden hat

- Die erste Fassung der Anzeige hat pro Ereignis gezeichnet. Beendete jemand
  eine Funkübertragung, wurde die Anzeige *aller* Zuhörer versteckt — auch die
  eines Zuhörers, der selbst gerade im Nahbereich sprach. Deshalb jetzt eine
  Funktion mit Rangfolge statt Zeichnen pro Ereignis.
- `VoiceOnMuteLoad()` ist ein asynchroner Query-Callback. Zwischen Absenden und
  Antwort kann der Spieler gehen und die Slot-ID schon jemand anderem gehören —
  der wäre dann still und dauerhaft stummgeschaltet worden. Der Name reist
  jetzt mit der Query mit und wird beim Rücklauf verglichen.
- `mysql_function_query` ist ein Makro, das auf ein Stringliteral als
  Callback-Format matcht. Um Warnung 239 zu vermeiden, wird direkt
  `mysql_tquery` mit lokalen Arrays gerufen.

---

## Was nicht geprüft werden konnte

Geprüft ist: der Gamemode kompiliert (0 Fehler, 1168 Warnungen — exakt der
Stand vor dem Voice-System, das Modul bringt keine einzige neue Warnung mit),
jeder erzeugte Stream hat genau einen Zerstörungspfad, jede Rechteprüfung sitzt
vor dem Anhängen als Speaker, jeder Datenbankzugriff prüft `cache_num_rows`
beziehungsweise `cache_get_data` vor dem Lesen, und es wird keine Native
benutzt, die nicht in `sampvoice.inc` steht.

Nicht geprüft werden konnte — dafür fehlt die Plugin-Binary und fehlen
Menschen mit Mikrofon: ob tatsächlich jemand etwas hört, ob sich die drei
Distanzstufen im Spiel richtig anfühlen, ob es Echo, Jitter oder Aussetzer
gibt, ob die Latenz erträglich ist, ob 20 kbit/s bei voller Serverlast
reichen, und ob die Textdraw-Position mit dem restlichen HUD kollidiert.

---

## Testliste für einen Menschen

Voraussetzung: **Blocker B-1 ist erledigt** (Plugin-Binary im Server, `voice_mutes.sql`
eingespielt, Client-Dateien bei allen Testern installiert).

### T1 — Nahbereich, zwei Personen

*Personen:* A und B, beide eingeloggt und gespawnt.

1. A und B stellen sich direkt nebeneinander (unter 4 Meter).
2. A hält **Y** und spricht. → B hört A. Bei A steht links unten `* Normal`.
3. A tippt `/fluestern`, hält **Y**, spricht. → B hört A weiterhin.
4. B läuft rund 10 Meter weg. A hält **Y** und spricht. → **B hört nichts**
   (Flüstern reicht 4 Meter).
5. A tippt `/rufen`, hält **Y**, spricht. → B hört A wieder.
6. B läuft rund 40 Meter weg. A ruft. → B hört nichts mehr.
7. A tippt `/voice`, hält **Y**, spricht. → B hört nichts, A bekommt keine
   Anzeige. Nochmal `/voice` stellt es zurück.

### T2 — Fraktionsfunk, drei Personen

*Personen:* A und B in derselben Fraktion, A mit Rang ≥ 1, B mit Rang 0.
C in einer anderen Fraktion. Alle weit voneinander entfernt (über 30 Meter).

1. Alle drei tippen `/funkkanal`. → Jeder sieht **nur** seine eigenen Kanäle.
2. A hält **X** und spricht. → B hört A und sieht `* <Fraktion>: <A>`.
   **C hört nichts.**
3. B hält **X**. → B bekommt „Dein Rang darf nur mithoeren, nicht senden."
4. Während A noch **X** hält, drückt B **X**. → B bekommt „Kanal belegt — A
   spricht gerade." und einen Signalton.
5. A hält **X** und **Y** gleichzeitig. → Es geht nur auf den Funk, nicht in
   den Nahbereich.
6. A hält **X** 50 Sekunden durchgehend. → Nach 45 Sekunden „Uebertragung
   automatisch beendet"; erst nach Loslassen und neu Drücken geht es weiter.

### T3 — Entlassung wirkt ohne Relog

*Personen:* A (Fraktionsleader), B (Mitglied), beide online, beide auf dem
Funkkanal.

1. A funkt, B hört mit. Bestätigen.
2. A entlässt B mit dem bestehenden Fraktionsbefehl. **B loggt sich nicht neu ein.**
3. A funkt sofort noch einmal. → **B hört nichts mehr.**
4. B tippt `/funkkanal`. → Der Fraktionskanal steht nicht mehr in der Liste.
5. Ist `VOICE_FACTION_REQUIRE_RADIO` auf 1: B wird wieder eingestellt, hat aber
   kein Funkgerät. B hält **X** → „Du hast kein Funkgeraet dabei." B setzt sich
   in ein Fraktionsfahrzeug → funken geht.

### T4 — Admin

*Personen:* Admin M (Level ≥ 2), Spieler A und B in einer gemeinsamen Fraktion.

1. M tippt `/vkanaele`. → Der Fraktionskanal steht mit ID und Zuhörerzahl da.
2. M tippt `/vabhoeren <ID>`. A funkt. → **M hört A**, obwohl M nicht in der
   Fraktion ist. Nochmal `/vabhoeren <ID>` beendet es.
3. M tippt `/vsperren <ID>`. A hält **X**. → „Dieser Funkkanal wurde gesperrt."
   Entsperren wiederholt den Befehl.
4. M tippt `/vmute A Testgrund`. A hält **Y**. → Nichts geht raus, A bekommt
   „Du bist stummgeschaltet. Grund: Testgrund".
5. **A verlässt den Server und kommt zurück.** A hält **Y**. → Immer noch
   stumm, Hinweis erscheint beim Verbinden. (Das ist der Test der Persistenz.)
6. M tippt `/vunmute A`. → A kann wieder sprechen; nach erneutem Relog ebenfalls.
7. `scriptfiles/Voice_Admin.txt` öffnen. → Alle Aktionen aus 2–6 stehen mit
   Zeitstempel und Adminnamen drin.

### T5 — Ignorieren

*Personen:* A und B in einer Fraktion.

1. B tippt `/vignore A`. A funkt. → **B hört A nicht**, andere Kanalmitglieder
   schon.
2. B tippt `/vignoreliste`. → A steht drin.
3. B tippt `/vignore A` erneut. A funkt. → B hört A wieder.
4. A stellt sich neben B und spricht im Nahbereich. → **B hört A trotzdem.**
   Das ist so gewollt; für den Nahbereich ist die Blacklist im sampvoice-Menü
   des Clients zuständig.

### T6 — Sauberes Aufräumen

1. Zehn Spieler mit Plugin verbinden und wieder trennen, mehrfach.
2. Serverkonsole ansehen. → Keine Meldung „Proximity-Stream konnte nicht
   angelegt werden", kein Speicherwachstum, keine Fehler vom Plugin.
3. `/gmx` oder Serverneustart. → Beim Hochfahren erscheint
   „[Voice] Sprachsystem bereit" und „[Voice] 32 Funkkanaele bereit".

---

## Was Phase 4 als Erstes tun sollte

Phase 4 (Lasttest-Harness und Bandbreitenmessung) ist ausdrücklich nur auf
Zuruf zu starten. Wenn sie kommt, wären das die ersten Schritte:

1. Tatsächliche Upstream-Rate je Sprecher bei `VOICE_BITRATE` = 20000 messen
   und gegen die Serveranbindung rechnen. Halbduplex deckelt den Fan-out auf
   `VOICE_CHANNEL_MAX_LISTENERS`, das ist die zu prüfende Rechnung.
2. Kosten von `DynamicLocalStreamAtPlayer::Tick()` bei 200 verbundenen
   Plugin-Clients messen — das ist der einzige Teil, der quadratisch mit der
   Spielerzahl wächst. `sampvoice.updaterate` ist die Stellschraube.
3. Erst danach über eine Anhebung von `VOICE_PROXIMITY_MAX_LISTENERS` oder der
   Bitrate entscheiden.
