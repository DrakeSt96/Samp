# Voice- und Funksystem

Sprachchat für diesen open.mp-Gamemode: Proximity-Sprache plus Funk für
Fraktionen, Unternehmen und Parteien. Ausgelegt auf 200+ Slots.

Plugin: **sampvoice, open.mp-Fork von AmyrAhmady** — *nicht* das Original von
CyberMor. Die beiden haben unterschiedliche APIs, und open.mp blockiert das
Original beim Laden.

---

## Installation

### 1. Server

1. Binary holen: <https://github.com/AmyrAhmady/sampvoice/releases> — den Build
   mit dem Suffix `-omp`.
2. Serverdatei nach `plugins/` legen (`sampvoice.so` unter Linux,
   `sampvoice.dll` unter Windows).
3. In `config.json` eintragen:

   ```json
   "pawn": {
       "legacy_plugins": ["mysql", "streamer", "sscanf", "sampvoice"]
   }
   ```

   Der Eintrag muss zu den bereits vorhandenen dazu, nicht an ihre Stelle.
4. Optional in `config.json` unter `sampvoice`: `updaterate` steuert, wie oft
   das Plugin die Zuhörer der Proximity-Streams neu berechnet. Kleiner heißt
   reaktionsschneller und teurer.

**Ohne diese Binary startet der Gamemode nicht** — die `Sv*`-Natives sind dann
nicht registriert.

### 2. Datenbank

```
mysql -u <user> -p <datenbank> < gamemodes/modules/voice/voice_mutes.sql
```

Legt `voice_mutes` an. Fehlt die Tabelle, läuft alles weiter, aber jeder Login
schreibt einen Query-Fehler ins Log und Stummschaltungen überleben keinen Relog.

### 3. Client — jeder Spieler

1. Dieselbe Release-Seite, diesmal das Client-Paket.
2. `sampvoice.asi` und `sampvoice.dll` ins GTA-San-Andreas-Verzeichnis.
3. Im Spiel öffnet die Plugin-Taste das sampvoice-Menü: Mikrofon auswählen,
   Lautstärke setzen, einzelne Spieler auf die Blacklist setzen.

Wer das Plugin nicht hat, spielt normal weiter — er hört nur niemanden und wird
nicht gehört. Der Gamemode behandelt ihn wie jeden anderen Spieler.

### 4. Gamemode

Bereits erledigt, hier nur zur Nachvollziehbarkeit:

- `pawno/include/ScriptInc.inc` bindet `<sampvoice>` ein
- `gamemodes/script.pwn` bindet `"modules/voice/voice.inc"` ein und ruft in
  sechs Callbacks je eine Zeile auf: `OnGameModeInit`, `OnGameModeExit`,
  `OnPlayerConnect`, `OnPlayerDisconnect`, `OnPlayerSpawn`, `OnPlayerDeath`

---

## Befehle

### Spieler

| Befehl | Wirkung |
|--------|---------|
| **Y halten** | Im Nahbereich sprechen |
| **X halten** | Auf dem gewählten Kanal funken |
| `/reichweite [fluestern\|normal\|rufen]` | Sprechweite; ohne Angabe wird durchgeschaltet |
| `/fluestern`, `/rufen` | Direkt umschalten |
| `/voice` | Eigenen Sprachchat an- und ausschalten (hören bleibt) |
| `/funkkanal [Nr]` | Sendekanal wählen; ohne Nummer die eigene Kanalliste |
| `/funk` | Kurzform von `/funkkanal` |
| `/funkinfo` | Sendekanal, mitgehörte Kanäle, Zuhörerzahl |
| `/vignore [Spieler]` | Jemanden im Funk ausblenden (Umschalter) |
| `/vignoreliste` | Wen man ausgeblendet hat |
| `/voicehelp` | Diese Liste im Spiel |

### Admin

Ab Adminlevel `VOICE_ADMIN_LEVEL` (Standard 2), Durchsage ab
`VOICE_ADMIN_LEVEL_BROADCAST` (Standard 4).

| Befehl | Wirkung |
|--------|---------|
| `/vmute [Spieler] [Grund]` | Global stummschalten, überlebt Relog |
| `/vunmute [Spieler]` | Stummschaltung aufheben, auch aus der Datenbank |
| `/vkanalmute [Spieler]` | Auf dessen aktuellem Sendekanal stummschalten (Umschalter) |
| `/vabhoeren [Kanal-ID]` | Kanal mithören (Umschalter) |
| `/vsperren [Kanal-ID]` | Kanal sperren, nur Admins dürfen dann senden (Umschalter) |
| `/vkanaele` | Kanäle mit IDs, Zuhörerzahl und Sperrstatus |
| `/durchsage` | Auf den Admin-Durchsagekanal schalten (Umschalter) |

Jede Adminaktion landet in `scriptfiles/Voice_Admin.txt`.

---

## Kanäle

Die Kanal-IDs sind keine zweite Mitgliederverwaltung, sondern eine flache
Projektion der IDs, die der Gamemode ohnehin führt:

| ID | Kanal | Quelle |
|----|-------|--------|
| 0 | *(unbenutzt, „keine Fraktion")* | — |
| 1–18 | Fraktionsfunk | `Spieler[][pFraktion]` |
| 19 | *(unbenutzt)* | — |
| 20–28 | Unternehmensfunk | `Spieler[][pOrgMember]` |
| 29 | *(unbenutzt)* | — |
| 30–33 | Parteifunk | `Spieler[][pParteiMember]` |
| 34 | Admin-Durchsage | Adminlevel |

Die Zugehörigkeit wird bei **jedem** Sendeversuch frisch aus dem Speicher
gelesen, nie zwischengespeichert. Eine Beförderung oder Entlassung wirkt damit
ohne Relog: zu Beginn jeder Übertragung prüft das System alle Zuhörer des
Kanals gegen die aktuelle Mitgliedschaft. Wer entlassen wurde, hört das nächste
Wort nicht mehr — und zwischen zwei Übertragungen gibt es nichts zu hören.
Zusätzlich vergleicht ein Watchdog alle fünf Sekunden Fraktion, Rang,
Unternehmen und Partei gegen einen Schnappschuss und räumt die Anhänge um.

**Halbduplex:** pro Kanal spricht genau einer. Wer reindrückt, während belegt
ist, bekommt eine Chatzeile und einen Signalton. Das ist nicht nur das
realistischere RP, sondern auch die Fan-out-Bremse — ein Sender mal höchstens
`VOICE_CHANNEL_MAX_LISTENERS` Zuhörer, egal wie groß die Fraktion ist.

### Wer darf senden

- **Fraktionsfunk:** Rang ab `VOICE_RANK_TRANSMIT`, Leader immer. Darunter nur
  mithören. Mit `VOICE_FACTION_REQUIRE_RADIO` zusätzlich dieselbe
  Ausrüstungspflicht wie beim bestehenden Textfunk `/d`: Funkgerät dabei, in
  einem Fraktionsfahrzeug der eigenen Fraktion sitzend, oder an einem
  Fraktionsterminal stehend.
- **Unternehmen und Parteien:** Der Gamemode kennt dort keinen Rang, nur
  Mitgliedschaft — also darf jedes Mitglied senden.
- **Überall:** dieselben Sperren wie im Textchat — gemutet, AFK, Knast,
  tot, getazert, gefesselt.

---

## Stummschaltung — drei Ebenen

| Ebene | Wer setzt sie | Reichweite | Persistenz |
|-------|---------------|------------|-----------|
| Global | Admin (`/vmute`) | Überall, der Client nimmt gar nicht erst auf | Datenbank |
| Kanal | Admin (`/vkanalmute`) | Ein Kanal, sonst redet der Spieler weiter | Nur im Speicher |
| Ignorieren | Spieler selbst (`/vignore`) | Funkkanäle | Nur im Speicher |

**Das persönliche Ignorieren greift nicht im Nahbereich.** Proximity-Streams
suchen sich ihre Zuhörer im Plugin selbst nach Distanz, Interior und Virtual
World aus und hängen jeden wieder an, den das Script abhängt. Dafür bringt
sampvoice seine eigene, clientseitige Blacklist mit — im Plugin-Menü einen
Spieler auswählen und sperren. Die wirkt überall, auch im Nahbereich, und
überlebt den Serverwechsel.

---

## Konfiguration

Alle Werte in `voice_config.inc`. Ein Wert, eine Stelle — nichts davon steht
irgendwo sonst im Code.

### Audio

| Define | Standard | Bedeutung |
|--------|----------|-----------|
| `VOICE_BITRATE` | 20000 | Bit/s. Bei 200 Slots ist der Upstream der Flaschenhals, nicht die Klangqualität. 16000–24000 ist der sinnvolle Bereich. |

### Nahbereich

| Define | Standard | Bedeutung |
|--------|----------|-----------|
| `VOICE_DIST_WHISPER` | 4.0 | Flüstern, Radius in Spieleinheiten |
| `VOICE_DIST_NORMAL` | 14.0 | Normal |
| `VOICE_DIST_SHOUT` | 30.0 | Rufen |
| `VOICE_RANGE_DEFAULT` | Normal | Stufe beim Verbinden |
| `VOICE_PROXIMITY_MAX_LISTENERS` | 40 | Wie viele einen einzelnen Sprecher gleichzeitig hören |

### Funk

| Define | Standard | Bedeutung |
|--------|----------|-----------|
| `VOICE_CHANNEL_MAX_LISTENERS` | 60 | Harte Obergrenze je Kanal |
| `VOICE_ADMIN_MAX_LISTENERS` | `MAX_PLAYERS` | Ausnahme für die Durchsage |
| `VOICE_MAX_MONITORED` | 3 | Wie viele Kanäle gleichzeitig gehört werden |
| `VOICE_RANK_TRANSMIT` | 1 | Fraktionsrang ab dem gesendet werden darf |
| `VOICE_FACTION_REQUIRE_RADIO` | 1 | Funkgerät-Pflicht wie bei `/d`. 0 = nur der Rang entscheidet. |
| `VOICE_ADMIN_LEVEL` | 2 | Adminlevel für die Voice-Adminbefehle |
| `VOICE_ADMIN_LEVEL_BROADCAST` | 4 | Adminlevel für `/durchsage` |

### Tasten

| Define | Standard | Bedeutung |
|--------|----------|-----------|
| `VOICE_KEY_PROXIMITY` | `0x59` (Y) | Push-to-Talk Nahbereich |
| `VOICE_KEY_RADIO` | `0x58` (X) | Push-to-Talk Funk |

Das sind Windows-Virtual-Key-Codes, keine SA-MP-`KEY_*`-Konstanten — sampvoice
fragt sie clientseitig direkt ab. Deshalb kollidieren sie auch nicht mit dem
`OnPlayerKeyStateChange` des Gamemodes.

### Missbrauchsschutz

| Define | Standard | Bedeutung |
|--------|----------|-----------|
| `VOICE_COOLDOWN_MS` | 400 | Mindestabstand zwischen zwei Übertragungen. Greift still — 400 ms merkt niemand, eine Chatzeile darüber schon. |
| `VOICE_SWITCH_COOLDOWN_MS` | 1500 | Mindestabstand zwischen zwei Kanalwechseln |
| `VOICE_MAX_TALK_MS` | 45000 | Danach wird abgeschnitten. Gegen festgeklebte Sprechtaste. |
| `VOICE_WATCHDOG_INTERVAL_MS` | 5000 | Takt des Watchdogs |

### Oberfläche und Logging

| Define | Standard | Bedeutung |
|--------|----------|-----------|
| `VOICE_COLOR` | `0x33CCFFAA` | Chatfarbe und Streamfarbe |
| `VOICE_SOUND_BUSY` | 1085 | Signalton bei „Kanal belegt" |
| `VOICE_TD_POS_X/Y` | 12.0 / 330.0 | Position der „spricht gerade"-Anzeige |
| `VOICE_LOG_FILE` | `Voice_Admin.txt` | Logdatei der Adminaktionen |
| `VOICE_MUTE_TABLE` | `voice_mutes` | Tabelle der dauerhaften Stummschaltungen |

---

## Aufbau

| Datei | Inhalt |
|-------|--------|
| `voice.inc` | Sammel-Include, Reihenfolge ist bindend |
| `voice_config.inc` | Alle Werte |
| `voice_core.inc` | Spielerzustand, Stream-Lebenszyklus, Mute-Speicher, Watchdog |
| `voice_proximity.inc` | Distanzstufen, Push-to-Talk, Spielerbefehle |
| `voice_radio.inc` | Kanäle, Rechte, Halbduplex, Tastencallbacks |
| `voice_admin.inc` | Mute-System, Adminbefehle, Logging, Datenbank |
| `voice_ui.inc` | „Spricht gerade"-Anzeige |
| `voice_mutes.sql` | Tabelle für dauerhafte Stummschaltungen |

### Streams

- **Nahbereich:** ein `DynamicLocalStreamAtPlayer` je Spieler *mit Plugin*,
  einmalig beim Handshake angelegt, beim Disconnect gelöscht. Die Zuhörer
  verwaltet das Plugin selbst. Die drei Distanzstufen erzeugen keine drei
  Streams, sondern ändern den Radius des einen per `SvUpdateDistanceForLStream`.
- **Funk:** 32 `GStream`s, einmalig in `OnGameModeInit`, gelöscht in
  `OnGameModeExit`. Spieler werden nur an- und abgehängt.

Bei 200 Slots sind das höchstens 232 Streams. Das Plugin erlaubt 4096.

Ein Spieler ist immer nur so lange **Speaker** eines Streams, wie die Taste
gedrückt ist. Ein gepatchter Client kann zwar Sprachpakete schicken, die laufen
aber ins Leere: der Server reicht Audio ausschließlich entlang der Streams
weiter, in denen der Absender als Speaker eingetragen ist.

---

## Bekannte Grenzen

- **Persönliches Ignorieren wirkt nur im Funk**, nicht im Nahbereich — siehe
  oben. Für den Nahbereich ist die clientseitige Blacklist des Plugins das
  richtige Werkzeug.
- **Kanalnamen von Unternehmen und Parteien** stehen in der Sprecherliste des
  Clients generisch als „Unternehmensfunk 3" statt mit dem echten Namen. Das
  Plugin backt den Namen beim Anlegen in den Stream und kennt kein Umbenennen;
  ein Umbenennen zur Laufzeit hieße Stream löschen und neu anlegen. Im Chat und
  in `/funkinfo` steht überall der echte, aktuelle Name.
- **Kanal-Stummschaltungen und Ignorierlisten überleben keinen Neustart.** Nur
  die globale Stummschaltung liegt in der Datenbank.
- **Ein Spieler ohne Mikrofon** wird beim Verbinden einmal darauf hingewiesen
  und kann alles hören, aber nichts senden.
