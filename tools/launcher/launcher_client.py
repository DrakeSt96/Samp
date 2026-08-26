#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
launcher_client.py - der Ablauf, den der echte Launcher umsetzen muss.

Das hier ist kein fertiger Launcher mit Oberflaeche, sondern die vollstaendige
Logik dahinter, lauffaehig und testbar. Wer den Launcher in C#, Rust oder
Delphi baut, kann sich hier Schritt fuer Schritt daran entlanghangeln.

Ablauf:
    1. Manifest von der API holen
    2. Signatur gegen den fest eingebauten oeffentlichen Schluessel pruefen
    3. Lokalen Dateibestand mit dem Manifest vergleichen
    4. Fehlende oder abweichende Dateien nachladen und pruefen
    5. Sitzung bei der API anmelden
    6. Spiel starten

Wichtig zu Schritt 5: die Sitzung wird an die Adresse gebunden, von der die
Anfrage kommt. Launcher und Spiel muessen darum vom selben Rechner und ueber
dieselbe Verbindung laufen.

Aufruf:
    python3 launcher_client.py --api https://launcher.example.com \\
        --pub <oeffentlicher-schluessel-hex> --key <launcher-key> \\
        --ziel "C:/GTA San Andreas"
"""

import argparse
import hashlib
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ed25519_pur as ed
from manifest import signaturkoerper, sha256_datei


def holen(url, daten=None, timeout=30):
    if daten is not None:
        daten = urllib.parse.urlencode(daten).encode("utf-8")
    anfrage = urllib.request.Request(url, data=daten)
    anfrage.add_header("User-Agent", "ServerLauncher/1.0")
    with urllib.request.urlopen(anfrage, timeout=timeout) as antwort:
        return antwort.read()


def schritt(nr, text):
    print("[%d/6] %s" % (nr, text))


def main():
    p = argparse.ArgumentParser(description="Referenzablauf des Launchers")
    p.add_argument("--api", required=True, help="Basisadresse der API, ohne Schraegstrich am Ende")
    p.add_argument("--pub", required=True, help="Oeffentlicher Schluessel als Hex, fest im Launcher eingebaut")
    p.add_argument("--key", required=True, help="Gemeinsames Geheimnis fuer /session")
    p.add_argument("--ziel", required=True, help="Spielverzeichnis")
    p.add_argument("--hwid", default="", help="Kennung des Rechners, optional")
    p.add_argument("--nur-pruefen", action="store_true", help="nichts herunterladen, nur berichten")
    args = p.parse_args()

    basis = args.api.rstrip("/")

    # --- 1 ----------------------------------------------------------------
    schritt(1, "Manifest holen")
    try:
        roh = holen(basis + "/manifest")
    except (urllib.error.URLError, OSError) as e:
        print("    FEHLER: Manifest nicht erreichbar (%s)" % e)
        return 2
    m = json.loads(roh.decode("utf-8"))

    # --- 2 ----------------------------------------------------------------
    schritt(2, "Signatur pruefen")
    if "signatur" not in m:
        print("    FEHLER: Manifest ist nicht signiert. Abbruch.")
        return 2
    pk = bytes.fromhex(args.pub.strip())
    if not ed.pruefen(signaturkoerper(m), bytes.fromhex(m["signatur"]), pk):
        print("    FEHLER: Signatur ungueltig. Das Manifest stammt nicht von uns. Abbruch.")
        return 2
    print("    gueltig, Version %d, %d Dateien" % (m["version"], len(m["dateien"])))

    # --- 3 ----------------------------------------------------------------
    schritt(3, "Lokalen Bestand vergleichen")
    zielwurzel = os.path.join(args.ziel, m.get("zielordner", "modloader/Server"))
    fehlend, abweichend, ok = [], [], 0
    for e in m["dateien"]:
        lokal = os.path.join(zielwurzel, e["pfad"].replace("/", os.sep))
        if not os.path.exists(lokal):
            fehlend.append(e)
        elif os.path.getsize(lokal) != e["groesse"] or sha256_datei(lokal) != e["sha256"]:
            abweichend.append(e)
        else:
            ok += 1
    print("    in Ordnung: %d, fehlend: %d, abweichend: %d" % (ok, len(fehlend), len(abweichend)))

    zu_laden = fehlend + abweichend
    if args.nur_pruefen:
        print("    (--nur-pruefen: es wird nichts geladen)")
        return 0 if not zu_laden else 1

    # --- 4 ----------------------------------------------------------------
    schritt(4, "Fehlendes nachladen")
    if not zu_laden:
        print("    nichts zu tun")
    for e in zu_laden:
        url = m["basis_url"] + urllib.parse.quote(e["pfad"])
        lokal = os.path.join(zielwurzel, e["pfad"].replace("/", os.sep))
        os.makedirs(os.path.dirname(lokal), exist_ok=True)
        print("    lade %s (%.1f KB)" % (e["pfad"], e["groesse"] / 1024.0))
        try:
            inhalt = holen(url, timeout=120)
        except (urllib.error.URLError, OSError) as ex:
            print("    FEHLER beim Laden von %s: %s" % (e["pfad"], ex))
            return 2
        if hashlib.sha256(inhalt).hexdigest() != e["sha256"]:
            print("    FEHLER: %s stimmt nach dem Laden nicht mit dem Manifest ueberein." % e["pfad"])
            return 2
        # Erst vollstaendig daneben schreiben, dann umbenennen - ein Abbruch
        # hinterlaesst so keine halbe Datei, die beim naechsten Start als
        # vorhanden gilt.
        vorlaeufig = lokal + ".teil"
        with open(vorlaeufig, "wb") as f:
            f.write(inhalt)
        os.replace(vorlaeufig, lokal)

    # --- 5 ----------------------------------------------------------------
    schritt(5, "Sitzung anmelden")
    try:
        antwort = holen(basis + "/session", {
            "key": args.key,
            "manifest": m["version"],
            "hwid": args.hwid,
        }).decode("utf-8", "replace").strip()
    except (urllib.error.URLError, OSError) as e:
        print("    FEHLER: Anmeldung fehlgeschlagen (%s)" % e)
        return 2
    if not antwort.startswith("OK"):
        print("    FEHLER: API antwortete '%s'" % antwort)
        return 2
    teile = antwort.split()
    ttl = int(teile[1]) if len(teile) > 1 and teile[1].isdigit() else 0
    print("    angemeldet, gueltig fuer %d Sekunden" % ttl)

    # --- 6 ----------------------------------------------------------------
    schritt(6, "Spiel starten")
    print("    Ab hier startet der echte Launcher samp.exe beziehungsweise")
    print("    omp-launcher mit Serveradresse und Spielernamen. Wichtig: das")
    print("    muss innerhalb der %d Sekunden passieren, sonst ist die Sitzung" % ttl)
    print("    abgelaufen und der Server kickt.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
