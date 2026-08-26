# Launcher-Pruefung

Prueft beim Verbinden, ob ein Spieler ueber den eigenen Launcher kommt und
seine Dateien auf dem aktuellen Stand sind.

**Im Auslieferungszustand ist das Modul aus.** Es ist vollstaendig gebaut und
getestet, aber solange `LAUNCHER_ENABLED` in `launcher_config.inc` auf `0`
steht, wird kein Byte davon mituebersetzt. Nachgewiesen: die erzeugte
`.amx` ist byteidentisch mit der ohne das Modul.

## Einschalten

Die Reihenfolge ist wichtig. Schritt 3 nicht ueberspringen.

1. **API aufsetzen** — siehe `tools/launcher/README.md`. Ohne laufende API
   hat das Modul nichts, was es fragen koennte.

2. **Verbinden** — in `launcher_config.inc` eintragen:
   ```pawn
   #define LAUNCHER_API_URL   "https://launcher.deinserver.de"
   #define LAUNCHER_API_KEY   "<derselbe Wert wie server_key in api_config.json>"
   ```
   Solange einer der beiden auf dem Auslieferungswert steht, weigert sich das
   Modul zu kicken - auch dann, wenn `LAUNCHER_ENFORCE` auf `1` steht. Das ist
   Absicht.

3. **Beobachten** — `LAUNCHER_ENABLED` auf `1`, `LAUNCHER_ENFORCE` auf `0`.
   Neu uebersetzen, Server starten. Jetzt wird geprueft und gezaehlt, aber
   niemand ausgesperrt. Nach ein paar Tagen `/launcherstatus` ansehen:

   ```
   Betriebsart: nur beobachten
   In Ordnung: 412 von 1150 (35 Prozent)
   Keine Sitzung: 731   Veraltet: 5   Fehler: 2   Ausnahme: 0
   Im Durchsetzbetrieb waeren bisher 738 Spieler gekickt worden.
   ```

   Die letzte Zeile ist die Entscheidungsgrundlage. Erst wenn du damit leben
   kannst, weiter.

4. **Durchsetzen** — `LAUNCHER_ENFORCE` auf `1`. Ab jetzt wird gekickt.

## Schalter

| Schalter | Standard | Bedeutung |
|---|---|---|
| `LAUNCHER_ENABLED` | `0` | Hauptschalter. `0` = nicht mituebersetzt. |
| `LAUNCHER_ENFORCE` | `0` | `0` = nur zaehlen, `1` = kicken |
| `LAUNCHER_API_URL` | Platzhalter | Basisadresse der API, `https` wird unterstuetzt |
| `LAUNCHER_API_KEY` | `BITTE-AENDERN` | muss zu `server_key` der API passen |
| `LAUNCHER_TIMEOUT_SEC` | `10` | Wartezeit auf die Antwort |
| `LAUNCHER_FAIL_CLOSED` | `0` | `0` = bei API-Ausfall durchlassen, `1` = kicken |
| `LAUNCHER_BYPASS_IPS` | `""` | IPs, die nie geprueft werden (Entwicklungsrechner) |
| `LAUNCHER_ADMIN_BYPASS_LEVEL` | `5` | eingeloggte Admins ab dieser Stufe bleiben drin |
| `LAUNCHER_ADMIN_LEVEL` | `2` | Stufe fuer `/launcherstatus` und `/launchercheck` |
| `LAUNCHER_LOG_AC` | `0` | Urteile zusaetzlich in die Anti-Cheat-Tabelle |

Zu `LAUNCHER_FAIL_CLOSED`: die Empfehlung ist `0`. Bei `1` legt ein Ausfall
deiner API den ganzen Server lahm - jeder Neuverbindende fliegt raus.

Zu `LAUNCHER_LOG_AC`: bei `1` und noch geringer Launcher-Verbreitung schreibt
das Modul eine Zeile pro Verbindung in `ac_log`. Danach zeigt `/acstats` fast
nur noch "Launcher-Pruefung" und die echten Cheaterkennungen gehen unter.
Die Zaehler in `/launcherstatus` und die Datei `Launcher_Pruefung.txt`
reichen zur Auswertung. Tatsaechliche Kicks landen ohnehin im Protokoll,
weil sie ueber `KickUser` laufen.

## Befehle

| Befehl | Wirkung |
|---|---|
| `/launcherstatus` | Konfiguration und Zaehler seit Serverstart |
| `/launchercheck [ID]` | Urteil, Manifestversion und Client eines Spielers |

Beide existieren nur bei `LAUNCHER_ENABLED 1`.

## Anbindung im Gamemode

Bereits eingebaut, drei Zeilen, jeweils in `#if LAUNCHER_ENABLED` gefasst:

| Ort | Aufruf |
|---|---|
| `OnGameModeInit` | `Launcher_OnGameModeInit();` |
| `OnPlayerConnect` | `Launcher_OnPlayerConnect(playerid);` |
| `OnPlayerDisconnect` | `Launcher_OnPlayerDisconnect(playerid);` |

## Wie weit das traegt

Die Bindung an die IP haelt: der Server sieht die echte Quelladresse der
laufenden Verbindung, und die kann fuer eine bestehende Sitzung nicht
gefaelscht werden.

Was nicht haelt: der Launcher laeuft auf fremder Hardware. Wer ihn
auseinandernimmt, kann die Dateipruefung entfernen und der API trotzdem ein
"alles in Ordnung" schicken. Das ist keine Luecke in diesem Modul, sondern die
Grundregel - man kann nicht beweisen, dass ein fremder Rechner ehrlich ist.

Der Zweck ist ein anderer: den normalen Weg vorgeben, veraltete
Installationen aussperren und dafuer sorgen, dass niemand mit fehlenden
Fahrzeugmodellen abstuerzt. Dafuer reicht es.

Wer den Aufwand fuer einen Faelscher hochtreiben will, kombiniert das mit
`SendClientCheck` - eine Stichprobe im Spielspeicher. Dann reicht es nicht
mehr, nur den Launcher zu faelschen.
