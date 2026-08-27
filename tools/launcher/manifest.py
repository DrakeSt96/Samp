#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
manifest.py - erzeugt und prueft das signierte Dateimanifest.

Das Manifest ist die Wahrheit darueber, welche Dateien ein Spieler haben muss.
Der Launcher laedt es, vergleicht mit dem, was lokal liegt, und laedt die
Unterschiede nach. Die Signatur stellt sicher, dass unterwegs niemand ein
eigenes Manifest untergeschoben hat - auch dann nicht, wenn dein CDN
kompromittiert ist.

Benutzung:

    # einmalig: Schluesselpaar erzeugen
    python3 manifest.py keygen --out schluessel/

    # bei jeder Aenderung am Dateipack: Version hochzaehlen und neu bauen
    python3 manifest.py build --quelle pack/ --version 3 \\
        --basis-url https://cdn.example.com/pack/ \\
        --key schluessel/launcher_key.sec --out manifest.json

    # gegenpruefen
    python3 manifest.py verify --manifest manifest.json --pub schluessel/launcher_key.pub

Die geheime Schluesseldatei gehoert NICHT auf den Spielserver und NICHT in das
Git-Repository. Nur der oeffentliche Schluessel wird in den Launcher eingebaut.
"""

import argparse
import hashlib
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ed25519_pur as ed


def sha256_datei(pfad, block=1024 * 1024):
    h = hashlib.sha256()
    with open(pfad, "rb") as f:
        while True:
            stueck = f.read(block)
            if not stueck:
                break
            h.update(stueck)
    return h.hexdigest()


MARKE_SEC = "ed25519-secret"
MARKE_PUB = "ed25519-public"


def schluessel_schreiben(pfad, marke, roh, force):
    """Schreibt eine Schluesseldatei mit Typmarke.

    Der geheime Schluessel wird mit os.open und Rechten 600 angelegt, nicht
    erst geschrieben und danach per chmod eingeschraenkt. Sonst steht er
    zwischen open() und chmod() mit 0644 auf der Platte - wer ihn in diesem
    Fenster oeffnet, behaelt den Lesezugriff auch nach dem chmod."""
    geheim = (marke == MARKE_SEC)
    inhalt = "%s:%s\n" % (marke, roh.hex())
    flags = os.O_WRONLY | os.O_CREAT | (os.O_TRUNC if force else os.O_EXCL)
    fd = os.open(pfad, flags, 0o600 if geheim else 0o644)
    try:
        os.write(fd, inhalt.encode("ascii"))
    finally:
        os.close(fd)


def schluessel_lesen(pfad, erwartete_marke):
    """Liest eine Schluesseldatei und prueft ihren Typ.

    Ohne Typmarke waeren .sec und .pub nicht unterscheidbar - beide sind 64
    Hexzeichen. Wer versehentlich den oeffentlichen Schluessel an --key
    uebergibt, bekaeme ein Manifest, das mit einem voellig anderen
    Schluesselpaar signiert ist, und die Meldung 'Signiert: ja' dazu. Der
    Fehler faellt erst auf, wenn draussen kein Launcher mehr startet."""
    with open(pfad) as f:
        text = f.read().strip()
    if ":" not in text:
        raise ValueError(
            "%s traegt keine Typmarke. Erwartet wird '%s:<hex>'. "
            "Alte Schluesseldateien bitte mit 'keygen' neu erzeugen." % (pfad, erwartete_marke))
    marke, _, hexteil = text.partition(":")
    marke = marke.strip()
    hexteil = hexteil.strip()
    if marke != erwartete_marke:
        raise ValueError("%s enthaelt einen '%s'-Schluessel, erwartet wird '%s'."
                         % (pfad, marke, erwartete_marke))
    roh = bytes.fromhex(hexteil)
    if len(roh) != 32:
        raise ValueError("%s: Schluessel ist %d statt 32 Byte lang." % (pfad, len(roh)))
    return roh


def kanonisch(daten):
    """Feste Darstellung fuer die Signatur - Reihenfolge und Trennzeichen fix."""
    return json.dumps(daten, sort_keys=True, separators=(",", ":"),
                      ensure_ascii=True).encode("utf-8")


def signaturkoerper(m):
    kopie = dict(m)
    kopie.pop("signatur", None)
    return kanonisch(kopie)


def cmd_keygen(args):
    os.makedirs(args.out, exist_ok=True)
    sk = os.urandom(32)
    pk = ed.oeffentlicher_schluessel(sk)

    sec = os.path.join(args.out, "launcher_key.sec")
    pub = os.path.join(args.out, "launcher_key.pub")
    if os.path.exists(sec) and not args.force:
        print("FEHLER: %s existiert bereits. Mit --force ueberschreiben." % sec)
        return 1

    try:
        schluessel_schreiben(sec, MARKE_SEC, sk, args.force)
        schluessel_schreiben(pub, MARKE_PUB, pk, True)
    except FileExistsError:
        print("FEHLER: %s existiert bereits. Mit --force ueberschreiben." % sec)
        return 1

    print("Geheimer Schluessel : %s   (Rechte 600, niemals weitergeben)" % sec)
    print("Oeffentlicher       : %s" % pub)
    print()
    print("Diesen Wert in den Launcher einbauen:")
    print("  %s" % pk.hex())
    print()
    print("Beide Dateien tragen eine Typmarke, damit sie nicht verwechselt")
    print("werden koennen - 'build --key' nimmt nur die .sec an.")
    return 0


def cmd_build(args):
    if not os.path.isdir(args.quelle):
        print("FEHLER: %s ist kein Verzeichnis" % args.quelle)
        return 1

    dateien = []
    gesamt = 0
    for wurzel, _, namen in os.walk(args.quelle):
        for name in sorted(namen):
            voll = os.path.join(wurzel, name)
            rel = os.path.relpath(voll, args.quelle).replace(os.sep, "/")
            groesse = os.path.getsize(voll)
            gesamt += groesse
            dateien.append({
                "pfad": rel,
                "groesse": groesse,
                "sha256": sha256_datei(voll),
            })
    dateien.sort(key=lambda e: e["pfad"])

    manifest = {
        "version": args.version,
        "erzeugt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "basis_url": args.basis_url.rstrip("/") + "/",
        "zielordner": args.zielordner,
        "dateien": dateien,
    }

    if args.key:
        try:
            sk = schluessel_lesen(args.key, MARKE_SEC)
        except (OSError, ValueError) as e:
            print("FEHLER: %s" % e)
            return 1
        manifest["signatur"] = ed.signieren(signaturkoerper(manifest), sk).hex()
    else:
        print("WARNUNG: ohne --key wird das Manifest NICHT signiert.")

    with open(args.out, "w") as f:
        json.dump(manifest, f, indent=2, sort_keys=True)
        f.write("\n")

    print("Manifest %s geschrieben." % args.out)
    print("  Version    : %d" % args.version)
    print("  Dateien    : %d" % len(dateien))
    print("  Gesamtgroesse: %.1f MB" % (gesamt / 1048576.0))
    print("  Signiert   : %s" % ("ja" if args.key else "NEIN"))
    return 0


def cmd_verify(args):
    with open(args.manifest) as f:
        m = json.load(f)
    if "signatur" not in m:
        print("FEHLER: Manifest traegt keine Signatur.")
        return 1
    try:
        pk = schluessel_lesen(args.pub, MARKE_PUB)
    except (OSError, ValueError) as e:
        print("FEHLER: %s" % e)
        return 1

    ok = ed.pruefen(signaturkoerper(m), bytes.fromhex(m["signatur"]), pk)
    print("Signatur: %s" % ("gueltig" if ok else "UNGUELTIG"))
    if not ok:
        return 1
    print("Version %d, %d Dateien, erzeugt %s" % (m["version"], len(m["dateien"]), m["erzeugt"]))
    return 0


def main():
    p = argparse.ArgumentParser(description="Signiertes Dateimanifest fuer den Launcher")
    sub = p.add_subparsers(dest="befehl", required=True)

    a = sub.add_parser("keygen", help="Schluesselpaar erzeugen")
    a.add_argument("--out", default="schluessel")
    a.add_argument("--force", action="store_true")
    a.set_defaults(func=cmd_keygen)

    b = sub.add_parser("build", help="Manifest aus einem Ordner bauen")
    b.add_argument("--quelle", required=True, help="Ordner mit den auszuliefernden Dateien")
    b.add_argument("--version", type=int, required=True, help="Manifestversion, bei jeder Aenderung hochzaehlen")
    b.add_argument("--basis-url", required=True, help="URL, unter der die Dateien liegen")
    b.add_argument("--zielordner", default="modloader/Server", help="Wohin der Launcher installiert")
    b.add_argument("--key", help="Datei mit dem geheimen Schluessel")
    b.add_argument("--out", default="manifest.json")
    b.set_defaults(func=cmd_build)

    c = sub.add_parser("verify", help="Signatur eines Manifests pruefen")
    c.add_argument("--manifest", required=True)
    c.add_argument("--pub", required=True)
    c.set_defaults(func=cmd_verify)

    args = p.parse_args()
    sys.exit(args.func(args))


if __name__ == "__main__":
    main()
