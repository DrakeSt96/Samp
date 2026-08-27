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


# Obergrenzen. Alles hier drunter kommt von aussen und ist bis zur
# Signaturpruefung nicht vertrauenswuerdig.
MAX_MANIFEST = 8 * 1024 * 1024
MAX_ANTWORT = 4096


def holen(url, daten=None, timeout=30, grenze=MAX_MANIFEST):
    """Laedt hoechstens `grenze` Bytes. Ohne Obergrenze koennte ein
    uebernommener Server den Launcher mit einer endlosen Antwort auffressen -
    und zwar bevor irgendeine Signatur geprueft ist."""
    if daten is not None:
        daten = urllib.parse.urlencode(daten).encode("utf-8")
    anfrage = urllib.request.Request(url, data=daten)
    anfrage.add_header("User-Agent", "ServerLauncher/1.0")
    with urllib.request.urlopen(anfrage, timeout=timeout) as antwort:
        inhalt = antwort.read(grenze + 1)
    if len(inhalt) > grenze:
        raise ValueError("Antwort ueberschreitet %d Bytes" % grenze)
    return inhalt


def pfad_ist_sicher(rel):
    """Darf der Pfad aus dem Manifest so verwendet werden?

    Ein Eintrag wie ../../Windows/System32/... oder ein absoluter Pfad wuerde
    sonst aus dem Zielordner herauslaufen - os.path.join verwirft bei einem
    absoluten zweiten Teil den ersten komplett. Die Felder liegen zwar im
    signierten Bereich, aber die Signatur schuetzt nur vor Fremden, nicht vor
    einem uebernommenen Baurechner."""
    if not rel or rel.startswith(("/", "\\")):
        return False
    if ":" in rel:                       # C:/... oder C:\...
        return False
    teile = rel.replace("\\", "/").split("/")
    for t in teile:
        if t in ("", ".", ".."):
            return False
    return True


def zustand_lesen(ordner):
    """Zuletzt erfolgreich installierte Manifestversion."""
    try:
        with open(os.path.join(ordner, ".launcher_stand.json")) as f:
            return int(json.load(f).get("version", 0))
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        return 0


def zustand_schreiben(ordner, version):
    try:
        os.makedirs(ordner, exist_ok=True)
        with open(os.path.join(ordner, ".launcher_stand.json"), "w") as f:
            json.dump({"version": int(version)}, f)
    except OSError:
        pass


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
        roh = holen(basis + "/manifest", grenze=MAX_MANIFEST)
    except (urllib.error.URLError, OSError, ValueError) as e:
        print("    FEHLER: Manifest nicht erreichbar oder zu gross (%s)" % e)
        return 2
    # Alles ab hier ist noch ungeprueft. Nichts davon darf den Launcher mit
    # einem Traceback beenden - der Nutzer soll eine Meldung sehen, keinen
    # Stapelabzug.
    try:
        m = json.loads(roh.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as e:
        print("    FEHLER: Manifest ist kein gueltiges JSON (%s)" % e)
        return 2
    if not isinstance(m, dict):
        print("    FEHLER: Manifest hat nicht die erwartete Form.")
        return 2

    # --- 2 ----------------------------------------------------------------
    schritt(2, "Signatur pruefen")
    if not isinstance(m.get("signatur"), str):
        print("    FEHLER: Manifest ist nicht signiert. Abbruch.")
        return 2
    try:
        # --pub nimmt sowohl den blanken Hexwert als auch den Inhalt einer
        # .pub-Datei mit Typmarke ("ed25519-public:<hex>").
        pubtext = args.pub.strip()
        if ":" in pubtext:
            marke, _, pubtext = pubtext.partition(":")
            if marke.strip() != "ed25519-public":
                print("    FEHLER: --pub ist kein oeffentlicher Schluessel (Marke '%s')." % marke.strip())
                return 2
            pubtext = pubtext.strip()
        pk = bytes.fromhex(pubtext)
        sig = bytes.fromhex(m["signatur"])
    except ValueError:
        print("    FEHLER: Signatur oder Schluessel ist kein gueltiger Hexwert. Abbruch.")
        return 2
    try:
        gueltig = ed.pruefen(signaturkoerper(m), sig, pk)
    except (ValueError, TypeError) as e:
        print("    FEHLER: Signatur nicht auswertbar (%s). Abbruch." % e)
        return 2
    if not gueltig:
        print("    FEHLER: Signatur ungueltig. Das Manifest stammt nicht von uns. Abbruch.")
        return 2

    # Ab hier ist der Inhalt beglaubigt, aber noch nicht auf Form geprueft.
    try:
        version = int(m["version"])
        dateien = m["dateien"]
        basis_url = str(m["basis_url"])
        assert isinstance(dateien, list)
    except (KeyError, ValueError, TypeError, AssertionError):
        print("    FEHLER: Signiertes Manifest ist unvollstaendig. Abbruch.")
        return 2
    print("    gueltig, Version %d, %d Dateien" % (version, len(dateien)))

    # --- #4: Rueckstufung verhindern --------------------------------------
    zielordner_roh = str(m.get("zielordner", "modloader/Server"))
    if not pfad_ist_sicher(zielordner_roh):
        print("    FEHLER: Zielordner '%s' im Manifest ist unzulaessig. Abbruch." % zielordner_roh)
        return 2
    installiert = zustand_lesen(args.ziel)
    if version < installiert:
        print("    FEHLER: Das Manifest ist aelter als das installierte (%d < %d)."
              % (version, installiert))
        print("    Eine Rueckstufung wird abgelehnt - ein alter, gueltig signierter")
        print("    Stand koennte laengst behobene Fehler zurueckbringen.")
        return 2

    # --- 3 ----------------------------------------------------------------
    schritt(3, "Lokalen Bestand vergleichen")
    zielwurzel = os.path.join(args.ziel, zielordner_roh.replace("/", os.sep))
    fehlend, abweichend, ok = [], [], 0
    for e in dateien:
        if not isinstance(e, dict) or not pfad_ist_sicher(str(e.get("pfad", ""))):
            print("    FEHLER: unzulaessiger Pfad im Manifest: %r. Abbruch." % (e.get("pfad") if isinstance(e, dict) else e))
            return 2
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
        url = basis_url + urllib.parse.quote(e["pfad"])
        lokal = os.path.join(zielwurzel, e["pfad"].replace("/", os.sep))
        os.makedirs(os.path.dirname(lokal), exist_ok=True)
        print("    lade %s (%.1f KB)" % (e["pfad"], e["groesse"] / 1024.0))
        try:
            # Die erwartete Groesse steht im signierten Manifest - mehr als das
            # braucht niemand zu senden.
            inhalt = holen(url, timeout=120, grenze=int(e["groesse"]))
        except (urllib.error.URLError, OSError, ValueError) as ex:
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
            "manifest": version,
            "hwid": args.hwid,
        }, grenze=MAX_ANTWORT).decode("utf-8", "replace").strip()
    except (urllib.error.URLError, OSError) as e:
        print("    FEHLER: Anmeldung fehlgeschlagen (%s)" % e)
        return 2
    if not antwort.startswith("OK"):
        print("    FEHLER: API antwortete '%s'" % antwort)
        return 2
    teile = antwort.split()
    ttl = int(teile[1]) if len(teile) > 1 and teile[1].isdigit() else 0
    print("    angemeldet, gueltig fuer %d Sekunden" % ttl)
    zustand_schreiben(args.ziel, version)

    # --- 6 ----------------------------------------------------------------
    schritt(6, "Spiel starten")
    print("    Ab hier startet der echte Launcher samp.exe beziehungsweise")
    print("    omp-launcher mit Serveradresse und Spielernamen. Wichtig: das")
    print("    muss innerhalb der %d Sekunden passieren, sonst ist die Sitzung" % ttl)
    print("    abgelaufen und der Server kickt.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
