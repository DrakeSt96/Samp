#!/usr/bin/env python3
"""Zeigt, welche MySQL-Zugangsdaten in einer script.amx einbetoniert sind.

    python3 tools/amx_zugang_pruefen.py gamemodes/script.amx

Die Zugangsdaten landen beim Uebersetzen aus gamemodes/config.inc in der
AMX. Wer vergisst, nach einer Aenderung neu zu uebersetzen, bekommt beim
Start "MySQL ERROR! Der Server wird jetzt heruntergefahren" - obwohl die
Datenbank laeuft und das Passwort stimmt.

Das Passwort wird bewusst NICHT ausgegeben, nur ob eines gesetzt ist.
"""
import re
import struct
import sys


def zellen_auspacken(pfad):
    """Liest die AMX und gibt ihre Zellen als Zeichenkette zurueck.

    Ist die Datei kompakt kodiert (Header-Flag 0x04), wird sie zuerst
    entpackt: rueckwaerts lesen, 7 Bit je Byte, Fortsetzung im Bit 0x80
    des vorhergehenden Bytes, Vorzeichen in Bit 0x40.
    """
    d = open(pfad, 'rb').read()
    if len(d) < 32:
        raise SystemExit(f"{pfad}: zu klein fuer eine AMX")
    _, magic, _, _, flags, _, cod, _, _, _, _ = struct.unpack('<IHBBHHIIIIi', d[:32])
    if magic != 0xF1E0:
        raise SystemExit(f"{pfad}: keine AMX (Kennung 0x{magic:04X} statt 0xF1E0)")

    roh = d[cod:]
    if not flags & 0x04:
        zellen = [int.from_bytes(roh[i:i + 4], 'little') for i in range(0, len(roh) - 3, 4)]
    else:
        zellen = []
        i = len(roh)
        while i > 0:
            wert = schub = 0
            while True:
                i -= 1
                wert |= (roh[i] & 0x7F) << schub
                schub += 7
                if i == 0 or not roh[i - 1] & 0x80:
                    break
            if roh[i] & 0x40:
                while schub < 32:
                    wert |= 0xFF << schub
                    schub += 8
            zellen.append(wert & 0xFFFFFFFF)
        zellen.reverse()
    # Jede Zelle traegt ein Zeichen (unpacked strings)
    return bytes((z & 0xFF) if z < 256 and 32 <= (z & 0xFF) < 127 else 0 for z in zellen)


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    pfad = sys.argv[1]
    text = zellen_auspacken(pfad)

    fehlt = text.count(b'CONFIG_FEHLT')
    print(f"  Datei:  {pfad}")
    print()
    if fehlt:
        print("  ZUGANGSDATEN FEHLEN")
        print(f"  'CONFIG_FEHLT' steht {fehlt}x in der AMX.")
        print()
        print("  Die Datei wurde ohne ausgefuellte gamemodes/config.inc uebersetzt.")
        print("  Der Server startet damit und faehrt sich sofort wieder herunter:")
        print("      [IL]: MySQL ERROR! Der Server wird jetzt heruntergefahren!")
        print()
        print("  Beheben: gamemodes/config.inc ausfuellen, dann NEU UEBERSETZEN.")
        return 1

    # Host, Benutzer und Datenbank liegen als Zeichenketten dicht beieinander.
    kandidaten = [k.decode('latin-1') for k in re.findall(rb'[ -~]{3,64}', text)]
    treffer = [k for k in kandidaten
               if re.fullmatch(r'(localhost|[\d.]+|[A-Za-z][\w.-]*)', k) and len(k) <= 64]
    print("  Kein 'CONFIG_FEHLT' gefunden - es sind Zugangsdaten einkompiliert.")
    print()
    umfeld = re.search(rb'\[Script wird gestartet\]\.\.(.{0,120})', text, re.S)
    if umfeld:
        teile = [t for t in re.split(rb'\x00+', umfeld.group(1)) if 1 <= len(t) <= 64]
        namen = ['Host', 'Benutzer', 'Datenbank', 'Passwort']
        for name, wert in zip(namen, teile):
            gezeigt = '(gesetzt, wird nicht angezeigt)' if name == 'Passwort' else wert.decode('latin-1')
            print(f"    {name:<11} {gezeigt}")
    print()
    print("  Stimmen Host, Benutzer und Datenbank mit gamemodes/config.inc ueberein,")
    print("  ist die AMX aktuell.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
