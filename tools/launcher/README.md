# Launcher-Werkzeuge

Alles, was neben dem Gamemode noetig ist, damit der Launcher-Zwang
funktioniert. Reines Python 3, **keine Fremdbibliotheken** — laeuft auf jedem
frisch aufgesetzten Server.

| Datei | Zweck |
|---|---|
| `ed25519_pur.py` | Signaturverfahren nach RFC 8032, in reinem Python |
| `manifest.py` | erzeugt und prueft das signierte Dateimanifest |
| `api.py` | die Pruefstelle zwischen Launcher und Spielserver |
| `launcher_client.py` | der vollstaendige Ablauf des Launchers, lauffaehig |

## Wie die Teile zusammenhaengen

```
   Launcher                    API                     Spielserver
      |                         |                           |
      |-- GET /manifest ------->|                           |
      |<-- signiertes JSON -----|                           |
      |                         |                           |
   [Signatur pruefen]           |                           |
   [Dateien vergleichen]        |                           |
   [Fehlendes laden]            |                           |
      |                         |                           |
      |-- POST /session ------->|                           |
      |   manifest=3            |  Sitzung an die           |
      |<-- OK 120 --------------|  Quell-IP binden          |
      |                         |                           |
   [Spiel starten] ------------------------------------->   |
                                |                           |
                                |<-- POST /verify ----------|
                                |    ip=<Quelladresse>      |
                                |--- OK 3 ----------------->|
                                |                      [durchlassen]
```

Der Kern: die Sitzung wird an die Adresse gebunden, von der die
Launcher-Anfrage kam. Der Spielserver sieht beim Verbinden dieselbe Adresse.
Wer nicht ueber den Launcher kommt, hat keine Sitzung.

## Einrichten

### 1. Schluesselpaar

```bash
python3 manifest.py keygen --out schluessel/
```

Der geheime Schluessel (`launcher_key.sec`, Rechte 600) bleibt auf deinem
Baurechner. Er gehoert **nicht** auf den Spielserver und **nicht** ins
Git-Repository. Der oeffentliche Schluessel wird fest in den Launcher
eingebaut.

### 2. Dateipack und Manifest

Leg die auszuliefernden Dateien so ab, wie sie beim Spieler landen sollen:

```
pack/
  modloader/MeinServer/bmwm3gtr.dff
  modloader/MeinServer/bmwm3gtr.txd
  ...
```

```bash
python3 manifest.py build \
    --quelle pack/ --version 3 \
    --basis-url https://cdn.deinserver.de/pack/ \
    --zielordner "modloader/MeinServer" \
    --key schluessel/launcher_key.sec \
    --out manifest.json
```

**`--version` bei jeder Aenderung hochzaehlen.** An dieser Zahl entscheidet
die API, ob ein Launcher aktuell ist.

### 3. API starten

```bash
python3 api.py --config api_config.json
```

Beim ersten Start wird eine Vorlage angelegt. Anzupassen:

| Feld | Bedeutung |
|---|---|
| `launcher_key` | Geheimnis fuer `POST /session`, im Launcher eingebaut |
| `server_key` | Geheimnis fuer `POST /verify`, entspricht `LAUNCHER_API_KEY` |
| `mindest_version` | ab welcher Manifestversion ein Launcher als aktuell gilt |
| `sitzung_ttl_sekunden` | wie lange zwischen Anmeldung und Verbinden liegen darf |
| `vertraue_proxy` / `proxy_ips` | nur setzen, wenn ein Reverse Proxy davor steht |

Zwei getrennte Schluessel sind Absicht: wer den Serverschluessel abgreift,
kann damit nur *fragen*, keine Sitzungen *anlegen*.

**Hinter einem Reverse Proxy** muss `vertraue_proxy` gesetzt und `proxy_ips`
gefuellt sein. Sonst sieht die API nur die Adresse des Proxys und bindet alle
Sitzungen an dieselbe IP — dann kommt jeder rein, sobald ein Einziger den
Launcher gestartet hat.

**HTTPS**: open.mp prueft das Serverzertifikat (`enable_server_certificate_
verification(true)`). Ein selbst ausgestelltes Zertifikat schlaegt fehl. Nimm
ein echtes, oder stell einen Reverse Proxy mit gueltigem Zertifikat davor.

### 4. Ablauf testen, bevor irgendetwas scharf geschaltet wird

```bash
python3 launcher_client.py \
    --api https://launcher.deinserver.de \
    --pub $(cat schluessel/launcher_key.pub) \
    --key <launcher_key> \
    --ziel "/pfad/zum/testspiel" --nur-pruefen
```

### 5. Gamemode

Siehe `gamemodes/modules/launcher/README.md`. Erst beobachten, dann
durchsetzen.

## Was der echte Launcher tun muss

`launcher_client.py` ist die vollstaendige Logik, nur ohne Oberflaeche. Wer
ihn in C#, Rust oder Delphi nachbaut, braucht genau diese sechs Schritte:

1. Manifest holen
2. **Signatur pruefen** — ohne gueltige Signatur abbrechen, nie fortfahren
3. lokale Dateien gegen Groesse und SHA-256 vergleichen
4. Unterschiede laden, jede Datei nach dem Laden erneut pruefen, erst dann
   an ihren Platz umbenennen
5. Sitzung anmelden
6. Spiel starten, innerhalb der Sitzungsdauer

Schritt 4 ist der Grund fuer die Datei `*.teil`: bricht der Download ab,
bleibt keine halbe Datei liegen, die beim naechsten Start als vorhanden gilt.

## Selbsttest

```bash
python3 ed25519_pur.py --selbsttest
```

Prueft gegen die Testvektoren aus RFC 8032 Abschnitt 7.1 und stellt sicher,
dass veraenderte Nachrichten und veraenderte Signaturen abgelehnt werden.

## Grenzen

Der Launcher laeuft auf dem Rechner des Spielers. Wer ihn dekompiliert, kann
die Dateipruefung ausbauen und der API trotzdem melden, alles sei in Ordnung.
Dagegen hilft dieses Verfahren nicht, und kein anderes auch — man kann nicht
beweisen, dass ein fremder Rechner ehrlich ist.

Was es leistet: es gibt den normalen Weg vor, haelt veraltete Installationen
draussen und verhindert, dass jemand mit fehlenden Fahrzeugmodellen abstuerzt.
Fuer den entschlossenen Einzelnen braucht es andere Mittel — etwa
`SendClientCheck` als Stichprobe im Spielspeicher, damit es nicht mehr reicht,
nur den Launcher zu faelschen.
