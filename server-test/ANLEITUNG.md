# Server aufsetzen — komplette Anleitung

Von der Bestellung beim Hoster bis zum ersten Spieler auf dem Server.

Alles hier ist auf **Ubuntu 24.04 LTS** einmal komplett durchgelaufen: der
Server startet, verbindet sich zur Datenbank, das Voicesystem bindet, die
Netzwerkports stehen. Die Zahlen weiter unten sind gemessen, nicht geschätzt.

---

## 1. Was du bestellst

### Betriebssystem: Ubuntu 24.04 LTS

**Nimm Ubuntu 24.04 LTS (Noble Numbat), 64 Bit.**

Der Grund ist unspektakulär und genau deshalb belastbar: der komplette Stapel
ist darauf durchgetestet worden. Server, alle 22 Komponenten, das Voiceplugin,
alle vier Legacy-Plugins, der Gamemode, die Datenbank — auf genau dieser
Version, Ende bis Ende.

Die drei Dinge, die die Wahl wirklich einschränken:

| Anforderung | Warum |
|---|---|
| **32-Bit-Bibliotheken verfügbar** | `omp-server` und *jede* `.so` sind `ELF 32-bit, Intel 80386`. Ohne 32-Bit-Laufzeit startet nichts. |
| **glibc ≥ 2.17** | Höchste Anforderung im ganzen Stapel. Jedes System ab ~2014 erfüllt das. |
| **Lange Sicherheitsunterstützung** | Ubuntu 24.04 bis 2029 (kostenlos), bis 2034 mit Ubuntu Pro. |

Was auch ginge: **Debian 12**. Gleiche Paketnamen, gleiche Bibliotheken,
Sicherheitsunterstützung bis Juni 2028. Ich habe es nicht getestet — Ubuntu
schon. Nimm im Zweifel das Getestete.

Was **nicht** geht: CentOS 7 (Ende erreicht), Alpine (musl statt glibc — die
Binärdateien starten schlicht nicht), Windows Server (teure Lizenz für
keinen Vorteil, und `pawncc` läuft auf Linux genauso).

### Hardware

Gemessen mit vollem Gamemode, angeschlossener Datenbank, `max_players: 500`,
null Spieler drauf:

| | gemessen |
|---|---|
| Arbeitsspeicher (Spitze) | **120 MB** |
| Prozessorlast im Leerlauf | **2,4 % eines Kerns** |
| Threads | 7 |
| Plattenplatz Serverordner | 165 MB |
| Datenbank frisch eingespielt | 0,2 MB |

**Arbeitsspeicher ist nicht dein Engpass.** Der Gamemode ist 10 MB Bytecode
und belegt keine 120 MB. Was zählt, ist etwas anderes:

> **Die Pawn-Hauptschleife läuft auf genau einem Kern.**
> Jeder Sync-Pakete, jeder Timer, jedes `OnPlayerUpdate` von jedem Spieler
> geht durch diesen einen Thread. Vier langsame Kerne sind für einen
> Rollenspielserver schlechter als zwei schnelle.

Danach bestellst du:

**Empfehlung für 200–500 Spieler:**

```
4 vCPU  —  DEDIZIERT, nicht geteilt  —  möglichst hoher Takt
8 GB RAM
40 GB NVMe
Standort Deutschland (Ping)
DDoS-Schutz inklusive
```

Die beiden Punkte, an denen billige Angebote scheitern:

1. **„vCPU" heißt oft „geteilt".** Auf überbuchten Knoten schwankt die
   Taktrate, und genau das merkst du als Ruckeln — nicht als niedrige
   Auslastung. Achte auf **dedizierte** Kerne.
2. **DDoS-Schutz.** Ein Gameserver mit offenem UDP-Port ist ein Ziel. Nicht
   irgendwann — sondern sobald jemand sauer ist. netcup, Hetzner und OVH haben
   ihn ohne Aufpreis, andere verlangen dafür Geld oder haben ihn gar nicht.

Konkrete Angebote, Stand August 2026, alle Preise inkl. 19 % MwSt. — Preise
ändern sich, prüf sie vor dem Bestellen selbst nach:

| Anbieter | Modell | Dedizierte Kerne | RAM | NVMe | pro Monat |
|---|---|---|---|---|---|
| **netcup** | RS 1000 G12, Root-Server | **4** | 8 GB ECC | 256 GB | **12,79 €** bei 12 Monaten<br>**17,70 €** monatlich kündbar |
| Hetzner | CCX13 | 2 | 8 GB | 80 GB | ≈ 51,16 € (42,99 € netto) |
| Hetzner | CCX23 | 4 | 16 GB | 160 GB | ≈ 102,33 € (85,99 € netto) |

**netcup gewinnt das derzeit deutlich** — doppelt so viele Kerne wie das
Hetzner-Gegenstück, dreimal so viel Platte, zu einem Drittel des Preises.
DDoS-Schutz ist bei netcup inklusive (bis 2 Tbit/s, Anexia DDoS Guard,
Filterung bis Layer 4), die Root-Server-Linie hat garantierte Kerne unter KVM,
und Nürnberg ist als Standort wählbar.

> **Achtung, das hat sich geändert:** Hetzner hat am **15. Juni 2026** die
> Preise der dedizierten CCX-Linie rund verdreifacht — CCX13 von 15,99 € auf
> 42,99 € netto, CCX23 von 31,49 € auf 85,99 €. Die geteilten CX-Linien stiegen
> nur moderat. Ältere Empfehlungen für Hetzner CCX stammen von vor diesem
> Datum. Bestandsserver behalten ihren Preis; eine Umstellung der Größe
> rechnet neu ab.

Beim Bestellen bei netcup zwei Sachen beachten:

1. **Standort ausdrücklich auf Nürnberg stellen.** Die Voreinstellung ist
   „Keine Präferenz Europa" und kann in Österreich oder den Niederlanden
   landen — das kostet deutsche Spieler Ping ohne Gegenwert.
2. **Dieses Image nehmen:** `Ubuntu 24.04.4 UEFI amd64` — Variante **Minimal**.

   * **24.04.4 statt 26.04:** Genau diese Punktversion ist durchgetestet. Auf
     26.04 ist nichts geprüft, insbesondere nicht, ob die vier
     `lib32`-Pakete dort genauso heißen. Unterstützung bis 2029 reicht;
     hochziehen geht später jederzeit.
   * **UEFI statt BIOS:** netcup stellt neue Images ohnehin auf UEFI um.
     Unserem Stapel ist es egal — also die Richtung nehmen, in die es geht.
   * **Minimal statt cloudimg:** Die cloudimg-Varianten erwarten cloud-init,
     also Provisionierung per Konfiguration. Du richtest von Hand nach dieser
     Anleitung ein; dafür ist das schlanke Image richtig.
   * **Nicht** die Variante `openclaw`: unbekannter Vorinstallationsstand.
     Auf einen Server mit Spielerdaten kommt nichts, was man nicht kennt.

### Drei Schalter im netcup-Panel

Im SCP gibt es unter den Servereinstellungen drei Felder, die leicht falsch
verstanden werden. Das Betriebssystem wählst du dort **nicht** — das passiert
in der Image-/Installationsverwaltung an anderer Stelle.

| Feld | Einstellung | Warum |
|---|---|---|
| **Betriebssystem-Optimierung** | `Linux` | Keine OS-Auswahl, sondern eine Hypervisor-Einstellung: welche Optimierungen der Wirt für deinen Gast fährt. `Linux (Legacy)` ist für alte Kernel ohne moderne virtio-Treiber — Ubuntu 24.04 hat Kernel 6.8, also nicht. |
| **Autostart** | **an** | Startet das Wirtssystem neu (Wartung), kommt dein Server nur damit von selbst wieder hoch. Sonst ist der Gameserver offline, bis du es merkst. |
| **UEFI-Boot** | **an** — vor der Installation | Muss zum Image passen: `Ubuntu 24.04.4 **UEFI** amd64` verlangt den Schalter an. Nachträglich umschalten macht den Server unbootbar. |

Autostart und `systemctl enable omp` aus Abschnitt&nbsp;9 ergeben zusammen eine
durchgehende Kette: Wirt startet → dein Server startet → MariaDB startet →
open.mp startet.

Falls doch einmal nichts bootet: dafür ist die **Fernwartungskonsole** da. Sie
rettet dich auch, wenn du dich mit `ufw` aus dem SSH aussperrst.

**Zum Prozessor:** Der EPYC 9645 ist die dichte Zen-5c-Variante — 96 Kerne bei
2,3 GHz Basis und 3,7 GHz Boost. Dichte Kerne tauschen Takt gegen Anzahl, und
Takt ist genau das, worauf es bei der Single-Thread-Schleife ankommt. Für
diesen Gamemode reicht es trotzdem klar: Zen 5 hat hohe IPC, und gemessen sind
2,4 % eines Kerns im Leerlauf. Unter 500 echten Spielern habe ich es nicht
gemessen — das sage ich lieber dazu.

Contabo würde ich für einen Gameserver **nicht** nehmen: viel RAM fürs Geld,
aber schwache Einzelkernleistung und stark überbuchte Knoten — genau die
falsche Kombination für eine Single-Thread-Schleife. OVHs Standard-VPS-Linie
fällt aus einem anderen Grund raus: die vCores sind dort nicht dediziert.

**Größer bestellen bringt nichts.** Mehr Kerne machen die Pawn-Schleife nicht
schneller, und bei 120 MB gemessenem Verbrauch sind 8 GB schon reichlich
Reserve. Der Takt ist über die ganze Reihe derselbe.

**Monatlich oder Jahresvertrag?** Bei netcup kostet die monatliche Kündbarkeit
4,91 € Aufpreis. Der Break-even liegt bei 153,48 / 17,70 = **8,7 Monaten**:
länger als neun Monate, und der Jahresvertrag war billiger. Solange der Server
noch nie mit echten Spielern gelaufen ist, ist monatlich das Richtige — später
wechseln geht immer.

---

## 2. System vorbereiten

Nach dem Einloggen als `root`:

```bash
apt update && apt upgrade -y
```

### Die 32-Bit-Bibliotheken — der Schritt, den alle vergessen

Ohne diesen Schritt bekommst du beim Start nur:

```
bash: ./omp-server: No such file or directory
```

Eine Lüge des Loaders: die Datei ist da, aber `/lib/ld-linux.so.2` fehlt.

```bash
apt install -y libc6-i386 lib32stdc++6 lib32gcc-s1 lib32atomic1
```

Vier Pakete, mehr nicht. Das reicht für **alles**: Server, alle Komponenten,
sampvoice und alle vier Plugins. Der komplette Bedarf des Stapels:

```
ld-linux.so.2   libatomic.so.1   libc.so.6      libdl.so.2   libgcc_s.so.1
libm.so.6       libpthread.so.0  librt.so.1     libstdc++.so.6
```

`libmysqlclient` steht bewusst **nicht** dabei — das MySQL-Plugin ist
statisch gelinkt und braucht auf dem Server keine MySQL-Clientbibliothek.

> Du brauchst **kein** `dpkg --add-architecture i386`. Die vier `lib32`-Pakete
> tun dasselbe, ohne dir die halbe Paketverwaltung zu verdoppeln.

### Werkzeuge

```bash
apt install -y git curl unzip mariadb-server ufw
```

### Eigener Benutzer

Der Server hat keinen Grund, als `root` zu laufen.

```bash
adduser --disabled-password --gecos "" omp
```

---

## 3. Datenbank

```bash
systemctl enable --now mariadb
mariadb-secure-installation
```

Bei `mariadb-secure-installation`: Root-Passwort setzen, anonyme Benutzer weg,
Root-Login aus der Ferne aus, Testdatenbank weg. Viermal Enter für „ja".

Dann Datenbank und Benutzer anlegen — **ein eigener Benutzer, niemals `root`:**

```bash
mariadb -u root -p
```

```sql
CREATE DATABASE samp1 CHARACTER SET latin1;
CREATE USER 'samp'@'localhost' IDENTIFIED BY 'HIER-EIN-LANGES-ZUFALLSPASSWORT';
GRANT SELECT, INSERT, UPDATE, DELETE ON samp1.* TO 'samp'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

`CHARACTER SET latin1` ist Absicht: der Gamemode ist durchgehend
ISO-8859-1. Mit `utf8mb4` werden aus Umlauten Fragezeichen.

Kein `GRANT ALL` — der Gamemode legt im Betrieb keine Tabellen an und braucht
weder `DROP` noch `ALTER`.

**MySQL bleibt auf `localhost`.** Der Standard von MariaDB unter Ubuntu ist
schon `bind-address = 127.0.0.1`. Lass ihn so. Port 3306 gehört nie ins
Internet.

---

## 4. Serverdateien holen

Als Benutzer `omp`:

```bash
su - omp
git clone <DEINE-REPOSITORY-URL> samp
cd samp
git checkout claude/script-pwn-analysis-o9mnc7
```

Dann das Einrichtungsskript. Es lädt open.mp und sampvoice von den offiziellen
Veröffentlichungen, prüft beide gegen fest eingetragene SHA-256-Summen und legt
sie an die richtigen Stellen:

```bash
./server-test/einrichten.sh
```

Stimmt eine Prüfsumme nicht, bricht es ab, statt etwas Unbekanntes zu
installieren.

---

## 5. Zugangsdaten eintragen

Zwei Dateien, beide von `.gitignore` ausgeschlossen — sie dürfen nie in einem
Commit landen.

### `gamemodes/config.inc` — der Datenbankzugang

```bash
cp gamemodes/config.inc.example gamemodes/config.inc
nano gamemodes/config.inc
```

```pawn
#define MySQL_Host      "127.0.0.1"
#define MySQL_User      "samp"
#define MySQL_Passwort  "DEIN-PASSWORT-VON-OBEN"
#define MySQL_Datenbank "samp1"
```

Diese Werte werden **beim Übersetzen** in die `script.amx` eingebacken. Änderst
du sie später, musst du neu übersetzen.

### `config.json` — die Serverkonfiguration

```bash
cp config.json.example config.json     # legt einrichten.sh sonst selbst an
nano config.json
```

Was du mindestens anfassen musst:

```jsonc
{
    "name": "Dein Servername",              // steht in der Serverliste
    "max_players": 500,
    "network": { "port": 7777 },
    "sampvoice": { "port": 7778, "threads": 2, "updaterate": 10 },
    "rcon": { "enable": false, "password": "LANGES-ZUFALLSPASSWORT" }
}
```

> ### `sampvoice.port` ist Pflicht
>
> Fehlt der Wert, macht sampvoice das hier
> (`server/NetHandler.cpp:162`):
>
> ```cpp
> if (_port == NULL) { bindAddr.sin_port = NULL; }   // → das Betriebssystem würfelt
> ```
>
> Der Voiceport ist dann **bei jedem Neustart ein anderer**. In meinem ersten
> Testlauf war es 40283. Den kannst du in keiner Firewall freigeben, und die
> Spieler hören nichts. Trag ihn fest ein.

`"rcon": { "enable": false }` ist die richtige Voreinstellung. RCON läuft über
UDP im Klartext — schalte es nur ein, wenn du es wirklich brauchst, und dann
mit einem Passwort, das nirgends sonst vorkommt.

### Falls eine `server.cfg` herumliegt: weg damit

```bash
mv server.cfg server.cfg.alt 2>/dev/null
```

open.mp liest die `server.cfg` **nach** der `config.json` und überschreibt
deren Werte kommentarlos. Du suchst sonst stundenlang, warum der Port nicht
stimmt.

---

## 6. Datenbank einspielen

Drei Dateien, **in dieser Reihenfolge**:

```bash
mariadb -u samp -p samp1 < Datenbank/samp_server.sql
mariadb -u samp -p samp1 < gamemodes/modules/anticheat/ac_log.sql
mariadb -u samp -p samp1 < gamemodes/modules/voice/voice_mutes.sql
```

Danach stehen **38 Tabellen** in `samp1`. Prüfen:

```bash
mariadb -u samp -p -N -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='samp1';"
```

Die hinteren beiden legen die Tabellen für das Anti-Cheat-Protokoll und die
Voice-Stummschaltungen an. Ohne sie startet der Server trotzdem — nur diese
beiden Funktionen bleiben still.

---

## 7. Gamemode übersetzen

```bash
./server-test/einrichten.sh
```

macht das mit. Von Hand:

```bash
cd ~/samp                     # WICHTIG: aus dem Wurzelverzeichnis, nicht aus gamemodes/
./pawncc gamemodes/script.pwn \
    -i"pawno/include" -i"pawno/include/Gloabe Includes" \
    -o"gamemodes/script.amx"
```

> **Aus dem Wurzelverzeichnis, nicht aus `gamemodes/`.** Der Compiler löst
> `#include "..."` relativ zum Aufrufort auf. Startest du ihn in `gamemodes/`,
> bekommst du
> `fatal error 100: cannot read from file: "voice_config.inc"`.

Ergebnis: `gamemodes/script.amx`, rund 10 MB, **null Fehler, null Warnungen**.

---

## 8. Firewall

Hier wird es angenehm kurz, weil ich nachgesehen habe, was der Server
tatsächlich aufmacht:

```
UNCONN   0.0.0.0:7777   users:(("omp-server",fd=10))    ← Spiel + Query
UNCONN   0.0.0.0:7778   users:(("omp-server",fd=5))     ← sampvoice
```

Zwei UDP-Sockets. **Kein einziger TCP-Listener.**

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp          # SSH — nicht aussperren!
ufw allow 7777/udp        # Spiel und Serverliste
ufw allow 7778/udp        # Voicechat
ufw enable
```

| Port | Protokoll | Richtung | Wofür |
|---|---|---|---|
| 7777 | **UDP** | rein | Spielverkehr *und* Serverbrowser-Abfrage |
| 7778 | **UDP** | rein | sampvoice |
| 22 | TCP | rein | SSH |
| 443 | TCP | **raus** | Eintrag in der Serverliste (`api.open.mp`) |
| 3306 | TCP | **gar nicht** | MySQL bleibt auf localhost |

Du liest oft, man müsse „7777 TCP und UDP" öffnen. Das ist falsch — RakNet
ist reines UDP. TCP 7777 offen zu haben bringt nichts außer einer Zeile mehr
in der Angriffsfläche.

---

## 9. Als Dienst einrichten

`/etc/systemd/system/omp.service` (als `root` anlegen):

```ini
[Unit]
Description=open.mp Rollenspielserver
After=network-online.target mariadb.service
Wants=network-online.target
Requires=mariadb.service
StartLimitIntervalSec=300
StartLimitBurst=5

[Service]
Type=simple
User=omp
Group=omp
WorkingDirectory=/home/omp/samp
ExecStart=/home/omp/samp/omp-server
Restart=on-failure
RestartSec=10

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectKernelTunables=true
ProtectControlGroups=true
RestrictSUIDSGID=true
LimitNOFILE=16384

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now omp
systemctl status omp
journalctl -u omp -f
```

`Requires=mariadb.service` ist wichtig: der Gamemode fährt sich selbst
herunter, wenn beim Start keine Datenbankverbindung zustande kommt. Ohne die
Abhängigkeit verlierst du nach jedem Neustart des Wirtssystems ein Wettrennen.

`StartLimitBurst=5` verhindert, dass er bei kaputter Datenbank endlos
neustartet.

---

## 10. Was beim ersten Start herauskommt

So sieht ein geglückter Start aus — das ist echte Ausgabe, keine Vorlage:

```
Loading component sampvoice.so
	Successfully loaded component sampvoice open.mp port (0.0.0.1)
[sv:dbg:main:Load] : creating 2 work threads...
[sv:dbg:network:bind] : voice server running on port 7778
Loading plugin: mysql
 >> plugin.mysql: R39-4 successfully loaded.
[Voice] 32 Funkkanaele bereit (18 Fraktionen, 9 Unternehmen, 4 Parteien, 1 Admin).
[Voice] Sprachsystem bereit - 20000 Bit/s, Proximity bis 30.0 Einheiten.
[IL]: Der Server hat erfolgreich der Verbindung zum MySQL Server hergstellt.
[IL]: Das Script wurde gesteartet und ist nun Online.
Script: Es wurden erfolgreich 100 Objekte geladen!
Legacy Network started on port 7777
```

Steht `voice server running on port 7778` mit **deinem** Port da — nicht mit
einer Zufallszahl —, dann sitzt die Konfiguration.

---

## 11. Was du beim ersten Start trotzdem im Log findest

Ehrlichkeitshalber: das hier taucht auf und ist **kein** Fehler deiner
Installation, sondern Bestand des Scripts.

**1. Eine Tabelle fehlt im Schema.**

```
MySQL-Fehler 1146 | Table 'samp1.server_firmfahrzeuge' doesn't exist
```

`script.pwn:11116` liest sie, `Datenbank/samp_server.sql` legt sie nicht an.
Folge: Firmenfahrzeuge werden nicht geladen. Der Rest läuft.

**2. Eine abgeschnittene Abfrage.**

```
MySQL-Fehler 1064 | ... near '' at line 1 | SELECT * FROM LoS_account_main WHERE
```

`script.pwn:80063` — die Abfrage endet mitten im `WHERE`. Sie feuert einmal
beim Start, tut nichts und erzeugt diesen Fehler. Alter Bestand.

**3. Die sieben Bots verbinden sich unter Linux nicht.**

```
Warning: Bot executable not found: samp-npc
```

Der Gamemode ruft siebenmal `ConnectNPC()` auf — `[BOT]Bank`, `[BOT]Bank2`,
`[BOT]BSN`, `[BOT]HandyLaden`, `[BOT]Stadthalle1`, `[BOT]Stadthalle2`,
`[BOT]Tutorial`. Das braucht ein externes Programm `samp-npc`, und die
Linux-Veröffentlichung von open.mp **liefert keins mit** (im Repository liegt
nur `samp-npc.exe` für Windows).

Zwei Wege: die Linux-`samp-npc` aus dem alten SA-MP-Serverpaket dazulegen —
oder auf die eigenen NPC-Funktionen von open.mp umstellen, die brauchen kein
externes Programm. open.mp warnt beim Start ohnehin schon, dass `ConnectNPC()`
ausläuft.

**4. Streamer-Version passt nicht zum Include.**

Das Plugin ist 2.6.1, das Include erwartet 2.9.6. In Randfällen kann sich das
anders verhalten als erwartet. Entweder `plugins/streamer.*` auf 2.9.6 heben
oder das Include auf 2.6.1 zurücknehmen.

---

## 12. Für die Spieler

Der Server allein reicht nicht. **Jeder Spieler braucht den
sampvoice-Client**, sonst hört und spricht niemand:

<https://github.com/AmyrAhmady/sampvoice/releases>

Ohne Client läuft der Server normal weiter — das Voice-Modul erkennt das und
schaltet für diesen Spieler ab.

Verbinden können sich Clients der Versionen **0.3.7 (4057)** und
**0.3.DL (4062)**. Andere weist open.mp ab.

---

## 13. Sicherung

Das Einzige, was nicht ersetzbar ist, ist die Datenbank. Alles andere ist ein
`git clone` und ein `einrichten.sh`.

`/etc/cron.daily/samp-sicherung`, ausführbar machen:

```bash
#!/bin/sh
ZIEL=/var/backups/samp
mkdir -p "$ZIEL"
mariadb-dump --single-transaction --quick -u samp -pPASSWORT samp1 \
  | gzip > "$ZIEL/samp1-$(date +%F).sql.gz"
find "$ZIEL" -name 'samp1-*.sql.gz' -mtime +14 -delete
```

```bash
chmod 700 /etc/cron.daily/samp-sicherung
chmod 600 /etc/cron.daily/samp-sicherung   # das Passwort steht drin
```

Sauberer als das Passwort in der Datei: eine `~/.my.cnf` mit `chmod 600` und
`-p` weglassen.

**Und dann spiel eine Sicherung einmal zurück.** Eine ungetestete Sicherung
ist keine.

---

## Checkliste

```
[ ] Server bestellt: Ubuntu 24.04 LTS, dedizierte vCPU, DDoS-Schutz
[ ] apt install libc6-i386 lib32stdc++6 lib32gcc-s1 lib32atomic1
[ ] apt install git curl unzip mariadb-server ufw
[ ] mariadb-secure-installation gelaufen
[ ] Datenbank samp1 (latin1) + eigener Benutzer, kein root
[ ] Repository geklont, Branch ausgecheckt
[ ] ./server-test/einrichten.sh gelaufen
[ ] gamemodes/config.inc ausgefüllt
[ ] config.json: name, port, sampvoice.port, rcon
[ ] server.cfg umbenannt, falls vorhanden
[ ] Drei SQL-Dateien in der richtigen Reihenfolge -> 38 Tabellen
[ ] Gamemode übersetzt (aus dem Wurzelverzeichnis!)
[ ] ufw: 22/tcp, 7777/udp, 7778/udp
[ ] omp.service eingerichtet und aktiviert
[ ] Log zeigt den festen Voiceport, nicht irgendeinen
[ ] Sicherung eingerichtet UND einmal zurückgespielt
```
