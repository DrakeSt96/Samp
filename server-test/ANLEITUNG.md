# open.mp-Server auf netcup — komplette Anleitung

Von der Bestellung bis zum ersten Spieler. Ein durchgehender Weg, in dieser
Reihenfolge abarbeitbar.

Alle Zahlen und Befehle hier sind auf **Ubuntu 24.04.4 LTS** durchgespielt: der
Server startet, verbindet sich zur Datenbank, das Voicesystem bindet, die
Netzwerkports stehen. Was ich nicht selbst ausgeführt habe, steht ausdrücklich
dabei.

---

# Teil 1 — Vorbereiten und bestellen

## 1. SSH-Schlüssel erzeugen (vor der Bestellung)

Mach das zuerst. netcup kann den Schlüssel **während der Installation** in den
Server legen — dann brauchst du nie ein Passwort-Login, und der häufigste
Angriffsweg auf einen frischen Server ist von vornherein zu.

Unter Windows in PowerShell (OpenSSH ist bei Windows 10/11 dabei):

```powershell
ssh-keygen -t ed25519 -C "gameserver"
```

Dreimal Enter (Standardpfad, Passphrase nach Belieben — eine Passphrase ist
sinnvoll). Danach liegen zwei Dateien in `C:\Users\DEINNAME\.ssh\`:

| Datei | |
|---|---|
| `id_ed25519` | **Der private Schlüssel. Bleibt bei dir. Niemals irgendwohin hochladen.** |
| `id_ed25519.pub` | Der öffentliche. Der kommt zu netcup. |

Inhalt des öffentlichen anzeigen — das ist eine einzige Zeile:

```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
```

## 2. Server bestellen

**RS 1000 G12** aus der **Root-Server**-Linie — nicht aus der VPS-Linie, dort
sind die Kerne geteilt.

```
4 vCPU, dediziert (AMD EPYC 9645)
8 GB DDR5 ECC
256 GB NVMe
Standort: Nuernberg          <- ausdruecklich waehlen!
```

**Der Standort ist die eine Stelle, an der man sich vertut.** Die Voreinstellung
heißt „Keine Präferenz Europa" und kann in Österreich oder den Niederlanden
landen. Für deutsche Spieler kostet das Ping ohne Gegenwert.

Laufzeit: 12 Monate für 12,79 €/Monat, monatlich kündbar für 17,70 €. Der
Break-even liegt bei `153,48 / 17,70 = 8,7 Monaten` — solange der Server noch
nie mit echten Spielern gelaufen ist, ist monatlich das Richtige.

## 3. Die zwei E-Mails

Nach der Bestellung kommen **zwei** Mails mit **getrennten** Zugängen:

| Portal | Adresse | Wofür |
|---|---|---|
| **CCP** | `ccp.netcup.net` | Bestellungen, Rechnungen, Vertrag |
| **SCP** | `servercontrolpanel.de` | Der Server selbst: Image, Konsole, Schalter |

Die Zugangsdaten sind voneinander unabhängig. Das SCP-Passwort wird im **CCP**
zurückgesetzt, nicht im SCP — merk dir das für den Tag, an dem du es brauchst.

Ab hier arbeitest du im **SCP**.

---

# Teil 2 — Server aufsetzen

## 4. SSH-Schlüssel im SCP hinterlegen

SCP → **Optionen → SSH-Schlüssel** → den Inhalt von `id_ed25519.pub` einfügen.

Einmal hinterlegt, kannst du ihn bei jeder Installation aus einer Auswahlliste
wählen, und er landet automatisch in `authorized_keys`.

## 5. Die drei Schalter — VOR der Installation

SCP → Servereinstellungen. Hier wählst du **nicht** das Betriebssystem, auch
wenn es so aussieht.

| Feld | Einstellung | Warum |
|---|---|---|
| **Betriebssystem-Optimierung** | `Linux` | Keine OS-Auswahl, sondern eine Hypervisor-Einstellung: welche Optimierungen der Wirt für deinen Gast fährt. `Linux (Legacy)` ist für alte Kernel ohne moderne virtio-Treiber — Ubuntu 24.04 hat Kernel 6.8, also nicht. |
| **Autostart** | **an** | Startet das Wirtssystem neu (Wartung), kommt dein Server nur damit von selbst wieder hoch. Sonst ist der Gameserver offline, bis du es merkst. |
| **UEFI-Boot** | **an** | Muss zum Image passen. **Nachträglich umschalten macht den Server unbootbar.** |

**Reihenfolge ist hier alles:** Schalter zuerst, Installation danach. Andersherum
kostet es einen Neuaufsetzer.

## 6. Ubuntu installieren

SCP → **Medien → Images**. Nimm genau dieses:

```
Ubuntu 24.04.4 UEFI amd64      Variante: Minimal
```

Und im selben Dialog **deinen SSH-Schlüssel auswählen**.

Warum genau dieses Image:

* **24.04.4, nicht 26.04** — genau diese Punktversion ist durchgetestet. Auf
  26.04 ist nichts geprüft, insbesondere nicht, ob die vier `lib32`-Pakete dort
  genauso heißen. Unterstützung bis 2029 reicht; hochziehen geht später.
* **UEFI, nicht BIOS** — passend zum Schalter aus Schritt 5, und netcup stellt
  neue Images ohnehin auf UEFI um.
* **Minimal, nicht cloudimg** — die cloudimg-Varianten erwarten cloud-init, also
  Provisionierung per Konfiguration. Du richtest von Hand ein.
* **Nicht `openclaw`** — unbekannter Vorinstallationsstand. Auf einen Server mit
  Spielerdaten kommt nichts, was man nicht kennt.

Die Installation dauert ein paar Minuten.

## 7. Erster Login

```powershell
ssh root@DEINE-SERVER-IP
```

Kommt keine Passwortabfrage, sondern du bist direkt drin: der Schlüssel sitzt.

---

# Teil 3 — Grundsystem

## 8. Härten, bevor irgendetwas anderes passiert

Der Server steht ab jetzt im Internet und wird binnen Minuten auf Port 22
abgeklopft. Das ist normal — solange kein Passwort-Login möglich ist, läuft es
ins Leere.

Passwort-Login abschalten — **nur, wenn der Schlüssel-Login eben funktioniert
hat.** Als eigene Datei, die **zuerst** einsortiert wird:

```bash
cat > /etc/ssh/sshd_config.d/00-haertung.conf <<'EOF'
PasswordAuthentication no
PermitRootLogin prohibit-password
KbdInteractiveAuthentication no
EOF
```

> ### Warum `00-` und keine Änderung an `sshd_config`
>
> In `/etc/ssh/sshd_config` steht in **Zeile 12**:
>
> ```
> Include /etc/ssh/sshd_config.d/*.conf
> ```
>
> Bei SSH gewinnt der **erste** Treffer für ein Schlüsselwort, nicht der letzte.
> Alles in der Hauptdatei steht *nach* dieser Zeile — eine Änderung dort wird
> also von jeder Drop-in-Datei überstimmt. Und die Drop-ins werden alphabetisch
> gelesen, `00-` gewinnt gegen alles andere. Gemessen:
>
> ```
> 01-hoster.conf (yes) + 99-haertung.conf (no)  ->  yes   Haertung wirkungslos
> 00-haertung.conf (no) + 01-hoster.conf (yes)  ->  no    greift
> ```

**Vor dem Neustart prüfen, was wirklich gelten wird:**

```bash
sshd -T | grep -E '^passwordauthentication|^permitrootlogin'
```

Muss `passwordauthentication no` und `permitrootlogin without-password`
ausgeben. Erst dann:

```bash
systemctl restart ssh
```

> **Und jetzt der wichtigste Satz der ganzen Anleitung:** lass das erste
> SSH-Fenster **offen** und öffne ein zweites zur Kontrolle. Erst wenn das
> zweite Fenster drin ist, darfst du das erste schließen. Sperrst du dich aus,
> kommst du über die **Fernwartungskonsole** im SCP wieder rein — aber der Umweg
> ist unnötig.

Zeitzone und Aktualisierungen:

```bash
timedatectl set-timezone Europe/Berlin
apt update && apt upgrade -y
apt install -y unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades
```

## 9. Die 32-Bit-Bibliotheken

**Der Schritt, den alle vergessen.** Ohne ihn bekommst du beim Serverstart nur:

```
bash: ./omp-server: No such file or directory
```

Eine Lüge des Loaders: die Datei ist da. Es fehlt `/lib/ld-linux.so.2`.

```bash
apt install -y libc6-i386 lib32stdc++6 lib32gcc-s1 lib32atomic1
```

Vier Pakete, mehr nicht. `omp-server` und **jede** `.so` im Stapel sind
`ELF 32-bit, Intel 80386`. Der komplette Bedarf:

```
ld-linux.so.2   libatomic.so.1   libc.so.6       libdl.so.2
libgcc_s.so.1   libm.so.6        libpthread.so.0 librt.so.1
libstdc++.so.6
```

`libmysqlclient` steht bewusst nicht dabei — das MySQL-Plugin ist statisch
gelinkt. Du brauchst auch **kein** `dpkg --add-architecture i386`; die vier
`lib32`-Pakete tun dasselbe, ohne die halbe Paketverwaltung zu verdoppeln.

## 10. Werkzeuge und ein eigener Benutzer

```bash
apt install -y git curl unzip nano mariadb-server ufw
adduser --disabled-password --gecos "" omp
```

Der Server hat keinen Grund, als `root` zu laufen.

> **`nano` ist bei der Minimal-Variante des Images nicht dabei** — und du hast
> in Schritt 06 bewusst die Minimal-Variante genommen. Ohne diese Zeile
> begrüßt dich später ein `bash: nano: command not found`. Es gibt auch keinen
> `vi` und keinen `vim`.

---

# Teil 4 — Datenbank

## 11. MariaDB einrichten

```bash
systemctl enable --now mariadb
mariadb-secure-installation
```

Root-Passwort setzen, anonyme Benutzer weg, Root-Login aus der Ferne aus,
Testdatenbank weg.

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

* `CHARACTER SET latin1` ist Absicht: der Gamemode ist durchgehend ISO-8859-1.
  Mit `utf8mb4` werden aus Umlauten Fragezeichen.
* Kein `GRANT ALL` — nachgeprüft: im ganzen Gamemode steht **kein einziges**
  `CREATE TABLE`, `ALTER TABLE` oder `DROP TABLE`. Zur Laufzeit braucht er
  diese Rechte nie.
* **Das Schema selbst spielst du deshalb in Schritt 14 als `root` ein**, nicht
  als `samp`. Der Anwendungsbenutzer bekommt nie DDL-Rechte, auch nicht
  vorübergehend.
* **Kein `root` als Serverbenutzer.** Nie.
* MariaDB steht unter Ubuntu schon auf `127.0.0.1`. Lass es so. Port 3306
  gehört nie ins Internet.

---

# Teil 5 — Den Gameserver aufsetzen

## 12. Repository holen und einrichten

Als Benutzer `omp`:

```bash
su - omp
git clone https://github.com/DrakeSt96/Samp.git samp
cd samp
git checkout claude/script-pwn-analysis-o9mnc7
./server-test/einrichten.sh
```

Das Skript lädt **open.mp v1.5.8.3079** und **sampvoice v3.2.0-omp** von den
offiziellen Veröffentlichungen, prüft beide gegen fest eingetragene
SHA-256-Summen, legt sie an die richtigen Stellen, installiert den passenden
**Pawn-Compiler 3.10.11** nach `qawno/` und übersetzt den Gamemode.

Stimmt eine Prüfsumme nicht, bricht es ab, statt etwas Unbekanntes zu
installieren.

> **sampvoice ist eine Komponente, kein Plugin.** Es gehört nach `components/`
> und **nicht** in `legacy_plugins`. Steht es falsch, überspringt der Server es
> und jeder `Sv*`-Aufruf im Script endet in Laufzeitfehler 19 im Sekundentakt.
> Das Skript legt es richtig ab und weigert sich zu starten, wenn es falsch in
> der Konfiguration steht.

## 13. Zugangsdaten eintragen

Zwei Dateien, beide von `.gitignore` ausgeschlossen. Sie dürfen nie in einem
Commit landen.

**`gamemodes/config.inc`** — der Datenbankzugang. Ganz ohne Editor, als `omp`:

```bash
cat > gamemodes/config.inc <<'EOF'
#define MySQL_Host      "127.0.0.1"
#define MySQL_User      "samp"
#define MySQL_Passwort  "DEIN-PASSWORT-AUS-SCHRITT-11"
#define MySQL_Datenbank "samp1"
EOF
cat gamemodes/config.inc
```

Mit Editor geht es genauso — `nano gamemodes/config.inc`, sofern du es in
Schritt 10 mitinstalliert hast.

Diese Werte werden **beim Übersetzen** in die `script.amx` eingebacken. Änderst
du sie später, musst du neu übersetzen.

**`config.json`** — die Serverkonfiguration:

```bash
nano config.json
```

```jsonc
{
    "name": "Dein Servername",
    "max_players": 500,
    "network":   { "port": 7777 },
    "sampvoice": { "port": 7778, "threads": 2, "updaterate": 10 },
    "rcon":      { "enable": false, "password": "LANGES-ZUFALLSPASSWORT" }
}
```

> ### `sampvoice.port` ist Pflicht
>
> Fehlt der Wert, macht sampvoice das hier (`server/NetHandler.cpp:162`):
>
> ```cpp
> if (_port == NULL) { bindAddr.sin_port = NULL; }   // das Betriebssystem wuerfelt
> ```
>
> Der Voiceport ist dann **bei jedem Neustart ein anderer**. Im ersten Testlauf
> war es 40283. Den kannst du in keiner Firewall freigeben, und die Spieler
> hören nichts.

`"rcon": { "enable": false }` ist die richtige Voreinstellung. RCON läuft über
UDP im Klartext.

**Falls eine `server.cfg` herumliegt: umbenennen.** open.mp liest sie **nach**
der `config.json` und überschreibt deren Werte kommentarlos.

## 14. Datenbank einspielen

Drei Dateien, **in dieser Reihenfolge** — und **als `root`**, nicht als `samp`:

```bash
exit                          # falls du als omp angemeldet bist
cd /home/omp/samp
mariadb samp1 < Datenbank/samp_server.sql
mariadb samp1 < gamemodes/modules/anticheat/ac_log.sql
mariadb samp1 < gamemodes/modules/voice/voice_mutes.sql
```

> ### Warum als root und nicht als samp
>
> Die SQL-Dateien **legen die Tabellen erst an** — sie brauchen `CREATE`,
> `DROP` und `INSERT`. Der Benutzer `samp` hat aus Schritt 11 bewusst nur die
> Betriebsrechte. Mit ihm bricht der Import sofort ab:
>
> ```
> ERROR 1142 (42000) at line 21: DROP command denied to user
>   'samp'@'localhost' for table `samp1`.`regeln`
> ```
>
> **Gib `samp` deswegen nicht mehr Rechte.** Das Schema gehört dem
> Administrator, der Anwendungsbenutzer schreibt nur Zeilen hinein. Nachgeprüft:
> im ganzen Gamemode steht **kein einziges** `CREATE TABLE`, `ALTER TABLE` oder
> `DROP TABLE` — zur Laufzeit braucht er die Rechte nie.
>
> Ein abgebrochener Versuch macht nichts kaputt: `samp_server.sql` beginnt mit
> `DROP TABLE IF EXISTS`, die anderen beiden mit `CREATE TABLE IF NOT EXISTS`.
> Der Neuversuch räumt selbst auf.

Danach stehen **38 Tabellen** in `samp1`:

```bash
mariadb -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='samp1';"
```

Die hinteren beiden legen die Tabellen für das Anti-Cheat-Protokoll und die
Voice-Stummschaltungen an. Ohne sie startet der Server trotzdem — nur diese
beiden Funktionen bleiben still.

## 15. Gamemode übersetzen

`einrichten.sh` hat das schon gemacht. Nach jeder Änderung an `config.inc` oder
am Script erneut:

```bash
cd ~/samp                # aus dem WURZELVERZEICHNIS, nicht aus gamemodes/
LD_LIBRARY_PATH=qawno qawno/pawncc gamemodes/script.pwn \
    -i"pawno/include" -i"pawno/include/Gloabe Includes" \
    -i"gamemodes/modules/voice" -i"gamemodes/modules/anticheat" \
    -i"gamemodes/modules/launcher" \
    -o"gamemodes/script.amx"
```

Ergebnis: rund 10 MB, **0 Fehler**, 346 Warnungen. Die Warnungen sind Bestand
und kein Hindernis — mehr dazu im Anhang.

### Vor dem Neustart prüfen, ob die Zugangsdaten drin sind

Der häufigste Stolperstein im Betrieb: `config.inc` geändert, das Übersetzen
vergessen. Der Server startet dann und fährt sich sofort wieder herunter,
obwohl die Datenbank läuft und das Passwort stimmt — denn die Zugangsdaten
kommen aus der **AMX**, nicht aus der `config.inc`.

```bash
python3 tools/amx_zugang_pruefen.py gamemodes/script.amx
```

Ausgabe im guten Fall:

```
Kein 'CONFIG_FEHLT' gefunden - es sind Zugangsdaten einkompiliert.

  Host        127.0.0.1
  Benutzer    samp
  Datenbank   samp1
  Passwort    (gesetzt, wird nicht angezeigt)
```

Und im schlechten:

```
ZUGANGSDATEN FEHLEN
'CONFIG_FEHLT' steht 4x in der AMX.
```

Das Passwort gibt das Werkzeug bewusst nicht aus — es zeigt nur, ob eines
gesetzt ist. Rückgabewert 1 bei fehlenden Daten, damit es sich in ein
Startskript einbauen lässt.

**Nicht `pawno/pawno.exe` benutzen.** Der Compiler in diesem Ordner ist 3.2.3664
von 2011 und scheitert an den open.mp-Includes.

### Auf dem Server übersetzen, nicht auf dem eigenen Rechner

Man kann den Gamemode unter Windows bauen und die `script.amx` hochladen — die
Datei ist plattformunabhängig. **Tu es trotzdem nicht.**

Die Zugangsdaten aus `config.inc` werden beim Übersetzen in die AMX
einbetoniert, und sie sind dort **im Klartext lesbar**. Die AMX ist zwar
kompakt kodiert (Header-Flag `0x04`), weshalb `strings` nichts findet — aber
das Auspacken ist keine Hürde. Nachgemacht an einer Testübersetzung mit dem
Passwort `Testpasswort123`:

```
...[Script wird gestartet]...127.0.0.1.samp.samp1.Testpasswort123...
```

Host, Benutzer, Datenbank und Passwort direkt nebeneinander. Rund zwanzig
Zeilen Python, kein Spezialwerkzeug.

Daraus folgen zwei Regeln:

| | |
|---|---|
| **Auf dem Server übersetzen** | Dann existieren die Zugangsdaten an genau einer Stelle — `config.inc` auf dem Server — und die AMX, die sie trägt, verlässt die Maschine nie. |
| **Die AMX gehört nie in ein Repository** | `gamemodes/*.amx` steht deshalb in `.gitignore`. Eine AMX auf GitHub ist ein veröffentlichtes Datenbankpasswort. |

Dasselbe gilt für jeden Weg, auf dem die AMX herumgereicht wird — Discord,
Cloudspeicher, USB-Stick.

### Dateien zum Server übertragen

Brauchst du früher oder später ohnehin. Aus PowerShell, mit demselben
Schlüssel wie `ssh`:

```powershell
scp "C:\Pfad\zur\datei" root@SERVER-IP:/home/omp/samp/gamemodes/
scp -r "C:\Pfad\zum\Ordner" root@SERVER-IP:/home/omp/samp/
scp root@SERVER-IP:/var/backups/samp/samp1-2026-08-27.sql.gz .
```

> **In ein neues PowerShell-Fenster auf dem PC**, nicht in die laufende
> SSH-Sitzung. `scp` kopiert von der Maschine, auf der du ihn tippst. Woran du
> siehst, wo du gerade bist:
>
> | Eingabeaufforderung | Maschine |
> |---|---|
> | `PS C:\Users\DEINNAME>` | dein PC |
> | `root@v2202...:~#` | der Server |
>
> Im Server getippt, sucht er `C:\Users\...` bei sich selbst, findet nichts und
> will sich bei sich selbst anmelden — dafuer hat er keinen Schluessel, daher
> `Permission denied (publickey)`.

Danach auf dem Server die Besitzrechte richten:

```bash
chown omp:omp /home/omp/samp/gamemodes/script.amx
```

---

# Teil 6 — In Betrieb nehmen

## 16. Firewall

Nachgesehen, was der Server tatsächlich aufmacht:

```
UNCONN   0.0.0.0:7777   users:(("omp-server",fd=10))    <- Spiel + Query
UNCONN   0.0.0.0:7778   users:(("omp-server",fd=5))     <- sampvoice
```

Zwei UDP-Sockets. **Kein einziger TCP-Listener.**

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp          # SSH - nicht aussperren!
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

Man liest oft, man müsse „7777 TCP und UDP" öffnen. Das ist falsch — RakNet ist
reines UDP.

## 17. Als Dienst einrichten

Als `root` — **komplett einfügen, von `cat` bis `EOF`**:

```bash
cat > /etc/systemd/system/omp.service <<'EOF'
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
EOF
```

`<<'EOF'` heißt: alles bis zur Zeile `EOF` wandert unverändert in die Datei.
Nach dem Einfügen kommt die Eingabeaufforderung stumm zurück — das ist richtig
so. Dann prüfen und starten:

```bash
systemd-analyze verify /etc/systemd/system/omp.service
systemctl daemon-reload
systemctl enable --now omp
journalctl -u omp -f
```

`systemd-analyze verify` darf nichts oder nur Belangloses ausgeben. Im
`journalctl` läuft das Log live mit; beenden mit `Strg+C`, der Server läuft
weiter.

`Requires=mariadb.service` ist wichtig: der Gamemode fährt sich selbst herunter,
wenn beim Start keine Datenbankverbindung zustande kommt. Zusammen mit
**Autostart** aus Schritt 5 ergibt das eine durchgehende Kette: Wirt startet →
dein Server startet → MariaDB startet → open.mp startet.

## 18. Der erste Start

Echte Ausgabe aus dem Testlauf, keine Vorlage:

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
Script: Es wurden erfolgreich 5094 Objekte geladen!
Legacy Network started on port 7777
```

**Die eine Zeile, auf die du schaust:** steht `voice server running on port 7778`
mit *deinem* Port da — nicht mit einer Zufallszahl —, dann sitzt die
Konfiguration.

## 19. Sicherung

Das Einzige, was nicht ersetzbar ist, ist die Datenbank. Alles andere ist ein
`git clone` und ein `einrichten.sh`.

`/etc/cron.daily/samp-sicherung`:

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

Sauberer als das Passwort in der Datei: eine `~/.my.cnf` mit `chmod 600`.

**Und dann spiel eine Sicherung einmal zurück.** Eine ungetestete Sicherung ist
keine. netcups **Snapshots** im SCP sind eine gute Ergänzung, aber kein Ersatz:
sie liegen auf derselben Infrastruktur.

## 20. Für die Spieler

**Jeder Spieler braucht den sampvoice-Client**, sonst hört und spricht niemand:

<https://github.com/AmyrAhmady/sampvoice/releases>

Ohne Client läuft der Server normal weiter — das Voice-Modul erkennt das und
schaltet für diesen Spieler ab. Verbinden können sich Clients der Versionen
**0.3.7 (4057)** und **0.3.DL (4062)**; andere weist open.mp ab.

---

# Anhang A — Was im Log auftaucht und kein Fehler deiner Installation ist

**1. Eine Tabelle fehlt im Schema.**
`Table 'samp1.server_firmfahrzeuge' doesn't exist` — Fehler 1146.
`script.pwn:11116` liest sie, `Datenbank/samp_server.sql` legt sie nicht an.
Folge: Firmenfahrzeuge werden nicht geladen. Der Rest läuft.

**2. Eine abgeschnittene Abfrage.** `script.pwn:80063` endet mitten im `WHERE`
→ Fehler 1064. Feuert einmal beim Start und tut nichts.

**3. Die sieben Bots verbinden sich nicht.** `Bot executable not found: samp-npc`.
`ConnectNPC()` braucht ein externes Programm, und die Linux-Veröffentlichung von
open.mp liefert keins mit. Entweder die Linux-`samp-npc` aus dem alten
SA-MP-Serverpaket dazulegen — oder auf open.mps eigene NPC-Funktionen umstellen,
die brauchen kein externes Programm.

**4. ~~Streamer-Version passt nicht zum Include.~~ Behoben.** Bis August 2026
war das Include 2.9.6 und das Plugin 2.6.1 — eingeführt bei der
open.mp-Portierung, die nur das Include tauschte. `CreateDynamicObject` übergibt
im 2.9.6-Include 14 Parameter, das 2.6.1-Plugin kennt 11 und lehnte **jeden**
Aufruf ab:

```
*** CreateDynamicObject: Expecting 11 parameter(s), but found 14
```

Gemessen an einem echten Serverlauf:

| | Parameterfehler | geladene Objekte |
|---|---:|---:|
| Plugin 2.6.1 | 5012 | 100 |
| Plugin 2.9.6 | **0** | **5094** |

Die Map war also praktisch leer. Seit `plugins/streamer.*` auf 2.9.6 steht,
passt es zusammen. Wer einen älteren Stand geklont hat: neu ziehen.

**5. Zwei Timer zeigen ins Leere.** `SetTimer("bot", ...)` in `script.pwn:11133`
und `RotateFerrisWheel` — von letzterem gibt es nur ein `forward` in Zeile 588.

**6. Die 346 Warnungen beim Übersetzen.** Sie kommen vom Compiler, nicht vom
Code: 3.10.10 meldet null, 3.10.11 meldet 346 bei identischem Quelltext.

| Anzahl | Warnung | |
|---:|---|---|
| 288 | 240 — assigned value is never used | Gibt es in 3.10.10 gar nicht |
| 44 | 213 — tag mismatch | `switch` über getypte Werte mit nackten Zahlen |
| 13 | 204 — symbol assigned a value that is never used | Tote Zuweisungen |
| 1 | 225 — unreachable code | |

Die 44 Tag-Warnungen sind geprüft: alle Zahlen treffen die richtige Konstante
(`case 4:` = `FIGHT_STYLE_NORMAL` = 4 und so weiter). Kein Zahlendreher.
**346 Hinweise, kein Problem.**

---

# Anhang B — Wenn etwas klemmt

| Lage | Weg |
|---|---|
| Aus SSH ausgesperrt | **Fernwartungskonsole** im SCP |
| Härtung wirkt nicht | `sshd -T` zeigt, was gilt. Datei muss `00-` heißen — erster Treffer gewinnt |
| `ERROR 1142 ... DROP command denied` | Schema als `root` einspielen, nicht als `samp` (Schritt 14) |
| Server bootet nicht | Fernwartungskonsole; danach **Rescue-System** im SCP |
| SCP-Passwort weg | Zurücksetzen im **CCP**, nicht im SCP |
| Nach Image-Wechsel kein Boot | Prüfen, ob **UEFI-Boot** zum Image passt |
| `./omp-server: No such file or directory` | Die vier `lib32`-Pakete fehlen (Schritt 9) |
| Jeder `Sv*`-Aufruf: Laufzeitfehler 19 | sampvoice liegt in `plugins/` statt `components/` |
| Voiceport bei jedem Start anders | `sampvoice.port` fehlt in `config.json` |
| `cannot read from file: "open.mp"` | Beide `-i`-Pfade fehlen, oder es lief der 3.2er-Compiler |
| `cannot read from file: "voice_config.inc"` | Die Modulordner fehlen im Suchpfad (Schritt 15) |
| `MySQL ERROR! Der Server wird jetzt heruntergefahren` | `python3 tools/amx_zugang_pruefen.py gamemodes/script.amx` sagt dir sofort, ob es an der AMX liegt. Sonst die Zugangsdaten mit `mariadb -u samp -p samp1 -e "SELECT 1"` testen |
| Dienst startet im Kreis, dann `start-limit-hit` | Fast immer dasselbe: kein Datenbankzugang. Der Gamemode fährt sich selbst herunter, `Restart=on-failure` startet neu, nach fünf Versuchen stoppt `StartLimitBurst` die Schleife |
| `code=dumped, status=11/SEGV` beim Herunterfahren | Bekannter Absturz beim Beenden, **Folge** und nicht Ursache. Im Log darüber steht der echte Grund |
| `CreateDynamicObject: Expecting 11 parameter(s), but found 14` | Streamer-Plugin ist zu alt. `plugins/streamer.*` muss 2.9.6 sein — neu ziehen |
| Map ist leer, nur ~100 Objekte laden | Dasselbe. Bei 2.9.6 sind es 5094 |
| `scp` sagt `Permission denied (publickey)` | Der Befehl wurde auf dem **Server** getippt statt auf dem PC. `scp` kopiert von der Maschine, auf der du ihn eingibst |
| `/etc/systemd/system/omp.service: No such file or directory` | Der Pfad wurde als Befehl eingegeben. Die Datei muss erst angelegt werden — `cat > … <<'EOF'` (Schritt 17) |
| `bash: nano: command not found` | Die Minimal-Variante des Images bringt keinen Editor mit. `apt install -y nano` als root — oder Dateien gleich per `cat > … <<'EOF'` schreiben |

---

# Anhang C — Warum netcup

Stand August 2026, alle Preise inkl. 19 % MwSt.:

| Anbieter | Modell | Dedizierte Kerne | RAM | NVMe | pro Monat |
|---|---|---|---|---|---|
| **netcup** | RS 1000 G12 | **4** | 8 GB ECC | 256 GB | **12,79 €** / **17,70 €** |
| Hetzner | CCX13 | 2 | 8 GB | 80 GB | ≈ 51,16 € |
| Hetzner | CCX23 | 4 | 16 GB | 160 GB | ≈ 102,33 € |

Doppelt so viele Kerne wie das Hetzner-Gegenstück, dreimal so viel Platte, zu
einem Drittel des Preises. DDoS-Schutz bis 2 Tbit/s ist inklusive.

**Das hat sich am 15. Juni 2026 geändert:** Hetzner hat die dedizierte CCX-Linie
rund verdreifacht. Ältere Empfehlungen für Hetzner CCX rechnen mit alten Preisen.

**Was die Hardware bestimmt:** Die Pawn-Hauptschleife läuft auf genau einem Kern.
Jedes Sync-Paket, jeder Timer, jedes `OnPlayerUpdate` geht durch diesen einen
Thread. Gemessen bei vollem Gamemode, angeschlossener Datenbank und
`max_players: 500`:

| | |
|---|---|
| Arbeitsspeicher, Spitze | **120 MB** |
| Prozessorlast im Leerlauf | **2,4 % eines Kerns** |
| Threads | 7 |
| Datenbank frisch | 0,2 MB |

Arbeitsspeicher ist nicht dein Engpass. **Größer bestellen bringt nichts** —
mehr Kerne machen die Schleife nicht schneller, und der Takt ist über die ganze
Reihe derselbe.

Der EPYC 9645 ist die dichte Zen-5c-Variante: 96 Kerne bei 2,3 GHz Basis und
3,7 GHz Boost. Dichte Kerne tauschen Takt gegen Anzahl. Für diesen Gamemode
reicht es klar — unter 500 echten Spielern ist es allerdings nicht gemessen.

---

# Checkliste

```
VORBEREITEN
[ ] SSH-Schluessel erzeugt (ssh-keygen -t ed25519)
[ ] RS 1000 G12 bestellt, Standort Nuernberg
[ ] Beide Mails da: CCP und SCP

SCP
[ ] SSH-Schluessel unter Optionen hinterlegt
[ ] Betriebssystem-Optimierung = Linux
[ ] Autostart = an
[ ] UEFI-Boot = an          <- VOR der Installation
[ ] Ubuntu 24.04.4 UEFI amd64 Minimal installiert, mit SSH-Schluessel
[ ] Login per Schluessel klappt

SYSTEM
[ ] PasswordAuthentication no, im zweiten Fenster geprueft
[ ] Zeitzone Europe/Berlin, apt upgrade, unattended-upgrades
[ ] libc6-i386 lib32stdc++6 lib32gcc-s1 lib32atomic1
[ ] git curl unzip mariadb-server ufw
[ ] Benutzer omp angelegt

DATENBANK
[ ] mariadb-secure-installation gelaufen
[ ] Datenbank samp1 (latin1) + Benutzer samp, kein root

GAMESERVER
[ ] Repository geklont, Branch ausgecheckt
[ ] ./server-test/einrichten.sh gelaufen
[ ] gamemodes/config.inc ausgefuellt
[ ] config.json: name, port, sampvoice.port, rcon
[ ] Drei SQL-Dateien ALS ROOT der Reihe nach -> 38 Tabellen
[ ] Neu uebersetzt nach der config.inc

BETRIEB
[ ] ufw: 22/tcp, 7777/udp, 7778/udp
[ ] omp.service eingerichtet und aktiviert
[ ] Log zeigt den festen Voiceport, nicht irgendeinen
[ ] Sicherung eingerichtet UND einmal zurueckgespielt
```
