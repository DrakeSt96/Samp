# -*- coding: utf-8 -*-
"""
Ed25519 in reinem Python, ohne Fremdbibliotheken.

Warum selbst gebaut: der Launcher und dieses Werkzeug sollen ohne pip-Pakete
laufen, damit die Signaturkette auch auf einem frisch aufgesetzten Rechner
funktioniert und niemand einer Abhaengigkeit vertrauen muss, die er nicht
geprueft hat.

Umsetzung nach RFC 8032. Bewusst die einfache, langsame Variante ohne
projektive Koordinaten - eine Signatur dauert Bruchteile einer Sekunde, und
signiert wird nur beim Erzeugen eines Manifests, nicht im laufenden Betrieb.

Korrektheit wird gegen die Testvektoren aus RFC 8032 Abschnitt 7.1 geprueft:
    python3 ed25519_pur.py --selbsttest
"""

import hashlib

b = 256
q = 2 ** 255 - 19
l = 2 ** 252 + 27742317777372353535851937790883648493


def _h(m):
    return hashlib.sha512(m).digest()


def _inv(x):
    return pow(x, q - 2, q)


d = -121665 * _inv(121666) % q
I = pow(2, (q - 1) // 4, q)


def _xrecover(y):
    xx = (y * y - 1) * _inv(d * y * y + 1)
    x = pow(xx, (q + 3) // 8, q)
    if (x * x - xx) % q != 0:
        x = (x * I) % q
    if x % 2 != 0:
        x = q - x
    return x


By = 4 * _inv(5) % q
Bx = _xrecover(By)
B = (Bx % q, By % q)


def _edwards(P, Q):
    x1, y1 = P
    x2, y2 = Q
    k = d * x1 * x2 * y1 * y2
    x3 = (x1 * y2 + x2 * y1) * _inv(1 + k)
    y3 = (y1 * y2 + x1 * x2) * _inv(1 - k)
    return (x3 % q, y3 % q)


def _scalarmult(P, e):
    # Iterativ statt rekursiv, damit tiefe Skalare nicht am Stacklimit scheitern.
    Q = (0, 1)
    while e > 0:
        if e & 1:
            Q = _edwards(Q, P)
        P = _edwards(P, P)
        e >>= 1
    return Q


def _bit(h, i):
    return (h[i // 8] >> (i % 8)) & 1


def _encodeint(y):
    return y.to_bytes(32, "little")


def _encodepoint(P):
    x, y = P
    return (y | ((x & 1) << 255)).to_bytes(32, "little")


def _decodeint(s):
    return int.from_bytes(s, "little")


def _decodepoint(s):
    v = int.from_bytes(s, "little")
    y = v & ((1 << 255) - 1)
    x = _xrecover(y)
    if x & 1 != (v >> 255) & 1:
        x = q - x
    P = (x, y)
    if not _auf_kurve(P):
        raise ValueError("Punkt liegt nicht auf der Kurve")
    return P


def _auf_kurve(P):
    x, y = P
    return (-x * x + y * y - 1 - d * x * x * y * y) % q == 0


def _geheimnis(sk):
    h = _h(sk)
    a = 2 ** (b - 2) + sum(2 ** i * _bit(h, i) for i in range(3, b - 2))
    return h, a


def oeffentlicher_schluessel(sk):
    """32 Byte geheimer Schluessel -> 32 Byte oeffentlicher Schluessel."""
    if len(sk) != 32:
        raise ValueError("geheimer Schluessel muss 32 Byte lang sein")
    _, a = _geheimnis(sk)
    return _encodepoint(_scalarmult(B, a))


def signieren(nachricht, sk, pk=None):
    """Erzeugt die 64 Byte lange Signatur."""
    if len(sk) != 32:
        raise ValueError("geheimer Schluessel muss 32 Byte lang sein")
    if pk is None:
        pk = oeffentlicher_schluessel(sk)
    h, a = _geheimnis(sk)
    r = _decodeint(_h(h[32:64] + nachricht)) % l
    R = _scalarmult(B, r)
    k = _decodeint(_h(_encodepoint(R) + pk + nachricht)) % l
    S = (r + k * a) % l
    return _encodepoint(R) + _encodeint(S)


def pruefen(nachricht, signatur, pk):
    """True, wenn die Signatur zum oeffentlichen Schluessel passt."""
    if len(signatur) != 64 or len(pk) != 32:
        return False
    try:
        R = _decodepoint(signatur[0:32])
        A = _decodepoint(pk)
    except ValueError:
        return False
    S = _decodeint(signatur[32:64])
    if S >= l:
        return False
    k = _decodeint(_h(signatur[0:32] + pk + nachricht)) % l
    return _scalarmult(B, S) == _edwards(R, _scalarmult(A, k))


# ---------------------------------------------------------------------------
#  Selbsttest gegen RFC 8032, Abschnitt 7.1
# ---------------------------------------------------------------------------

_VEKTOREN = [
    ("9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60",
     "d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a",
     "",
     "e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b"),
    ("4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb",
     "3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c",
     "72",
     "92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00"),
    ("c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7",
     "fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025",
     "af82",
     "6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a"),
]


def selbsttest():
    for i, (sk_hex, pk_hex, msg_hex, sig_hex) in enumerate(_VEKTOREN, 1):
        sk = bytes.fromhex(sk_hex)
        msg = bytes.fromhex(msg_hex)
        pk = oeffentlicher_schluessel(sk)
        assert pk == bytes.fromhex(pk_hex), "Vektor %d: oeffentlicher Schluessel falsch" % i
        sig = signieren(msg, sk, pk)
        assert sig == bytes.fromhex(sig_hex), "Vektor %d: Signatur falsch" % i
        assert pruefen(msg, sig, pk), "Vektor %d: eigene Signatur nicht anerkannt" % i
        assert not pruefen(msg + b"x", sig, pk), "Vektor %d: veraenderte Nachricht anerkannt" % i
        kaputt = bytearray(sig)
        kaputt[0] ^= 1
        assert not pruefen(msg, bytes(kaputt), pk), "Vektor %d: veraenderte Signatur anerkannt" % i
        print("Vektor %d: in Ordnung" % i)
    print("Alle %d RFC-8032-Testvektoren bestanden." % len(_VEKTOREN))


if __name__ == "__main__":
    import sys
    if "--selbsttest" in sys.argv:
        selbsttest()
    else:
        print(__doc__)
