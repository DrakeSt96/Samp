# Testpaket: Server startklar machen

Macht aus diesem Repository einen lauffähigen open.mp-Server — mit dem
aktuellen Stand des Gamemodes und dem Voicesystem.

Ein Befehl, dann fehlt nur noch die Datenbank.

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

## Für die Spieler

Der Server allein reicht nicht: **jeder Spieler braucht den sampvoice-Client**,
sonst hört und spricht niemand. Der liegt bei denselben Veröffentlichungen wie
das Serverteil:

<https://github.com/AmyrAhmady/sampvoice/releases>

Ohne Client läuft der Server normal weiter — das Voice-Modul erkennt das und
schaltet für diesen Spieler ab.

## Was beim Testlauf herauskam

Der Ablauf ist auf Linux einmal komplett durchgespielt worden. Ergebnis:

**Läuft:**

```
Successfully loaded component sampvoice open.mp port (0.0.0.1)
[sv:dbg:network:bind] : voice server running on port 40283
[Voice] 32 Funkkanaele bereit (18 Fraktionen, 9 Unternehmen, 4 Parteien, 1 Admin)
[Voice] Sprachsystem bereit - 20000 Bit/s, Proximity bis 30.0 Einheiten
Legacy Network started on port 7777
```

Alle 22 Komponenten laden, alle vier Legacy-Plugins laden, der Gamemode
übersetzt und startet, **null Laufzeitfehler**. Danach bricht der Start ab,
weil es hier keine MySQL-Datenbank gibt — das ist das vorgesehene Verhalten
deines Scripts.

**Drei Sachen, die dabei aufgefallen sind:**

1. **Streamer-Version passt nicht zum Include.** Das Plugin ist 2.6.1, das
   Include erwartet 2.9.6 (`Streamer_IncludeFileVersion = 0x296`). Der Server
   warnt beim Start. Ein Streamer, der nicht zum Include passt, kann sich in
   Randfällen anders verhalten als erwartet — entweder `plugins/streamer.*`
   auf 2.9.6 heben oder das Include auf 2.6.1 zurücknehmen.

2. **Zwei Timer zeigen ins Leere.** `SetTimer("bot", ...)` in `script.pwn:11133`
   und `RotateFerrisWheel` — von letzterem gibt es nur ein `forward` in
   Zeile 588, keine Umsetzung. Beide erzeugen beim Start eine Warnung und tun
   nichts. Harmlos, aber unnötig.

3. **Absturz beim Herunterfahren.** Nachdem das Script wegen der fehlenden
   Datenbank die Abschaltung ausgelöst hat und alle Plugins sauber entladen
   waren, endet der Prozess mit einem Speicherzugriffsfehler. Ob das auch bei
   einem normalen Herunterfahren mit funktionierender Datenbank passiert, ist
   damit nicht gesagt — beobachten.

## Warum die Binärdateien nicht im Repository liegen

Sie werden heruntergeladen statt mitgeliefert:

- Der Server allein wäre 36 MB pro Version im Verlauf des Repositories.
- Du bekommst die geprüften Originale der Hersteller, nicht meine Kopie.
- Ein Versionswechsel ist eine geänderte Zeile im Skript, kein neuer Blob.

Alles, was das Skript anlegt, steht in `.gitignore` und landet nicht
versehentlich in einem Commit.
