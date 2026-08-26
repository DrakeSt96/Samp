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

    with open(sec, "w") as f:
        f.write(sk.hex() + "\n")
    os.chmod(sec, 0o600)
    with open(pub, "w") as f:
        f.write(pk.hex() + "\n")

    print("Geheimer Schluessel : %s   (Rechte 600, niemals weitergeben)" % sec)
    print("Oeffentlicher       : %s" % pub)
    print()
    print("Diesen Wert in den Launcher einbauen:")
    print("  %s" % pk.hex())
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
        with open(args.key) as f:
            sk = bytes.fromhex(f.read().strip())
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
    with open(args.pub) as f:
        pk = bytes.fromhex(f.read().strip())

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
