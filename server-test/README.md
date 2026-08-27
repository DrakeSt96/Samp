# Testpaket: Server startklar machen

Macht aus diesem Repository einen lauffähigen open.mp-Server — mit dem
aktuellen Stand des Gamemodes und dem Voicesystem.

Ein Befehl, dann fehlt nur noch die Datenbank.

> **Du mietest gerade einen Server?** Dann nimm nicht diese Seite, sondern
> **[ANLEITUNG.md](ANLEITUNG.md)** — die geht von der Bestellung beim Hoster
> bis zum ersten Spieler durch: Betriebssystem, Hardware, 32-Bit-Bibliotheken,
> MariaDB, Firewall, systemd-Dienst, Sicherung.

```powershell
# Windows, in PowerShell im Repository-Ordner
.\server-test\einrichten.ps1
```

```bash
# Linux
./server-test/einrichten.sh
```

## Was das Skript tut

| Schritt | |
|---|---|
| 1 | Lädt **open.mp v1.5.8.3079** von der offiziellen Veröffentlichung, prüft die SHA-256, entpackt `omp-server` und die 22 Komponenten |
| 2 | Lädt **sampvoice v3.2.0-omp**, prüft die SHA-256, legt es nach `components/` |
| 3 | Prüft `config.json` und warnt vor typischen Fehlern |
| 4 | Übersetzt `gamemodes/script.pwn` zu `script.amx` |
| 5 | Sagt dir, welche SQL-Dateien in welcher Reihenfolge müssen |
| 6 | Fertig |

Beide Prüfsummen sind fest im Skript eingetragen. Weicht eine ab, bricht das
Skript ab, statt etwas Unbekanntes zu installieren. Heruntergeladen wird
ausschließlich von `github.com`.

## Was du selbst machen musst

**1. Datenbank einspielen**, in dieser Reihenfolge:

```
Datenbank/samp_server.sql
gamemodes/modules/anticheat/ac_log.sql
gamemodes/modules/voice/voice_mutes.sql
```

Die beiden hinteren sind neu und legen die Tabellen für das Anti-Cheat-Protokoll
und die Voice-Stummschaltungen an. Ohne sie starten die Module trotzdem, nur
diese beiden Funktionen bleiben stumm.

**2. `config.json` ausfüllen.** Die Datei ist gitignoriert, weil dort das
RCON-Passwort und der MySQL-Zugang stehen. Beim ersten Lauf legt das Skript sie
aus `config.json.example` an — Zugangsdaten musst du eintragen.

**3. Eine vorhandene `server.cfg` umbenennen.** open.mp liest sie **nach**
`config.json` und überschreibt deren Werte stillschweigend.

## sampvoice ist eine Komponente, kein Plugin

Der häufigste Fehler, und er kostet Stunden:

```
components/sampvoice.dll      ← richtig
plugins/sampvoice.dll         ← falsch
"legacy_plugins": [ ..., "sampvoice" ]   ← falsch
```

Steht es unter `plugins/` oder in `legacy_plugins`, überspringt der Server es
mit einer Fehlermeldung, und **jeder `Sv*`-Aufruf im Script schlägt fehl** —
Laufzeitfehler 19, „File or function is not found", im Sekundentakt.

Das Skript legt es richtig ab und weigert sich zu starten, wenn `sampvoice`
fälschlich in `legacy_plugins` steht.

## Der Voiceport muss fest stehen

Der zweitteuerste Fehler. Fehlt `sampvoice.port` in der `config.json`, bindet
sich das Voiceteil an einen **zufälligen** Port, der sich bei jedem Neustart
ändert — im ersten Testlauf war es 40283. In keiner Firewall freizugeben, und
niemand hört etwas.

```jsonc
"sampvoice": { "port": 7778, "threads": 2, "updaterate": 10 },
```

Steht in `config.json.example` schon drin; das Skript warnt, wenn er fehlt.

## Für die Spieler

Der Server allein reicht nicht: **jeder Spieler braucht den sampvoice-Client**,
sonst hört und spricht niemand. Der liegt bei denselben Veröffentlichungen wie
das Serverteil:

<https://github.com/AmyrAhmady/sampvoice/releases>

Ohne Client läuft der Server normal weiter — das Voice-Modul erkennt das und
schaltet für diesen Spieler ab.

## Was beim Testlauf herauskam

Inzwischen ist der Ablauf mit **echter Datenbank** komplett durchgelaufen —
MariaDB 10.11, alle drei SQL-Dateien eingespielt, 38 Tabellen:

```
Successfully loaded component sampvoice open.mp port (0.0.0.1)
[sv:dbg:main:Load] : creating 2 work threads...
[sv:dbg:network:bind] : voice server running on port 7798
 >> plugin.mysql: R39-4 successfully loaded.
[Voice] 32 Funkkanaele bereit (18 Fraktionen, 9 Unternehmen, 4 Parteien, 1 Admin)
[Voice] Sprachsystem bereit - 20000 Bit/s, Proximity bis 30.0 Einheiten
[IL]: Der Server hat erfolgreich der Verbindung zum MySQL Server hergstellt.
[IL]: Das Script wurde gesteartet und ist nun Online.
Script: Es wurden erfolgreich 100 Objekte geladen!
Legacy Network started on port 7799
```

Alle 22 Komponenten laden, alle vier Legacy-Plugins laden, der Gamemode
übersetzt fehlerfrei und **bleibt oben** — der frühere Abbruch kam nur von der
fehlenden Datenbank.

**Gemessen dabei** (voller Gamemode, `max_players: 500`, null Spieler):

| | |
|---|---|
| Arbeitsspeicher, Spitze | 120 MB |
| Prozessorlast im Leerlauf | 2,4 % eines Kerns |
| Threads | 7 |
| Offene Sockets | 2 × UDP, **kein TCP** |

**Was dabei aufgefallen ist:**

1. **Eine Tabelle fehlt im Schema.** `script.pwn:11116` liest
   `server_firmfahrzeuge`, `Datenbank/samp_server.sql` legt sie nicht an →
   Fehler 1146 beim Start, Firmenfahrzeuge werden nicht geladen.

2. **Eine abgeschnittene Abfrage.** `script.pwn:80063` endet mitten im
   `WHERE` → Fehler 1064. Feuert einmal beim Start und tut nichts.

3. **Die sieben Bots verbinden sich unter Linux nicht.** `ConnectNPC()`
   braucht ein externes `samp-npc`, und die Linux-Veröffentlichung von open.mp
   liefert keins mit — im Repository liegt nur `samp-npc.exe` für Windows.

4. **Streamer-Version passt nicht zum Include.** Das Plugin ist 2.6.1, das
   Include erwartet 2.9.6 (`Streamer_IncludeFileVersion = 0x296`). Entweder
   `plugins/streamer.*` auf 2.9.6 heben oder das Include zurücknehmen.

5. **Zwei Timer zeigen ins Leere.** `SetTimer("bot", ...)` in
   `script.pwn:11133` und `RotateFerrisWheel` — von letzterem gibt es nur ein
   `forward` in Zeile 588, keine Umsetzung.

6. **Absturz beim Herunterfahren.** Tritt weiterhin auf, wenn das Script die
   Abschaltung selbst auslöst. Beim Beenden per Signal aus dem laufenden
   Betrieb ist er nicht aufgetreten.

## Warum die Binärdateien nicht im Repository liegen

Sie werden heruntergeladen statt mitgeliefert:

- Der Server allein wäre 36 MB pro Version im Verlauf des Repositories.
- Du bekommst die geprüften Originale der Hersteller, nicht meine Kopie.
- Ein Versionswechsel ist eine geänderte Zeile im Skript, kein neuer Blob.

Alles, was das Skript anlegt, steht in `.gitignore` und landet nicht
versehentlich in einem Commit.
