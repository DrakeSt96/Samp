#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
api.py - die Pruefstelle zwischen Launcher und Spielserver.

Sie beantwortet genau zwei Fragen:

    POST /session   Der Launcher meldet: "Ich habe die Dateien geprueft, ich
                    bin auf Manifestversion N." Die Sitzung wird an die
                    Quelladresse der Anfrage gebunden und laeuft nach kurzer
                    Zeit ab.

    POST /verify    Der Spielserver fragt beim Verbinden: "Gibt es fuer diese
                    IP eine frische Sitzung?" Antwort ist ein Wort:
                        OK <version>        alles in Ordnung
                        OUTDATED <version>  Launcher zu alt
                        NOSESSION           keine gueltige Sitzung

Dazu:
    GET  /manifest  liefert das signierte Manifest aus
    GET  /health    Lebenszeichen

Warum die Bindung an die IP haelt: der Spielserver sieht die echte
Quelladresse der laufenden Verbindung, die kann fuer eine Sitzung nicht
gefaelscht werden. Warum sie trotzdem kein Beweis ist: der Launcher laeuft auf
fremder Hardware. Wer ihn auseinandernimmt, kann hier auch mit falschen
Dateien ein "alles in Ordnung" abliefern. Das ist die Grenze des Verfahrens
und laesst sich nicht wegprogrammieren - nur verteuern.

Start:
    python3 api.py --config api_config.json

Hinter einem Reverse Proxy MUSS vertraue_proxy gesetzt und proxy_ips gefuellt
sein, sonst sieht die API nur die Adresse des Proxys und bindet alle Sitzungen
an dieselbe IP.
"""

import argparse
import hmac
import json
import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

STANDARD_CONFIG = {
    "bind": "0.0.0.0",
    "port": 8080,
    "launcher_key": "BITTE-AENDERN-LAUNCHER",
    "server_key": "BITTE-AENDERN-SERVER",
    "aktuelle_version": 1,
    "mindest_version": 1,
    "sitzung_ttl_sekunden": 120,
    "manifest_datei": "manifest.json",
    "vertraue_proxy": False,
    "proxy_ips": [],
    "max_sitzungen": 20000,
    "log_datei": "api.log",
}

MAX_KOERPER = 8192


class Sitzungen:
    """IP -> Sitzung. Im Speicher, mit Ablauf. Bewusst ohne Datenbank."""

    def __init__(self, ttl, obergrenze):
        self._d = {}
        self._lock = threading.Lock()
        self._ttl = ttl
        self._max = obergrenze

    def setzen(self, ip, version, hwid):
        jetzt = time.time()
        with self._lock:
            if len(self._d) > self._max:
                self._aufraeumen(jetzt)
            if len(self._d) > self._max:
                return False
            self._d[ip] = {"version": version, "hwid": hwid, "zeit": jetzt}
            return True

    def holen(self, ip):
        jetzt = time.time()
        with self._lock:
            e = self._d.get(ip)
            if e is None:
                return None
            if jetzt - e["zeit"] > self._ttl:
                del self._d[ip]
                return None
            return dict(e)

    def _aufraeumen(self, jetzt):
        tot = [k for k, v in self._d.items() if jetzt - v["zeit"] > self._ttl]
        for k in tot:
            del self._d[k]

    def anzahl(self):
        with self._lock:
            self._aufraeumen(time.time())
            return len(self._d)


class Handler(BaseHTTPRequestHandler):
    server_version = "LauncherAPI/1.0"
    protocol_version = "HTTP/1.1"

    # -- Hilfsmittel --------------------------------------------------------

    def _cfg(self):
        return self.server.cfg

    def _antwort(self, code, text, typ="text/plain; charset=utf-8"):
        roh = text.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", typ)
        self.send_header("Content-Length", str(len(roh)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(roh)

    def _quelladresse(self):
        direkt = self.client_address[0]
        cfg = self._cfg()
        if cfg["vertraue_proxy"] and direkt in cfg["proxy_ips"]:
            xff = self.headers.get("X-Forwarded-For", "")
            if xff:
                # Der letzte Eintrag ist der, den unser Proxy gesehen hat.
                return xff.split(",")[-1].strip()
        return direkt

    def _formular(self):
        try:
            laenge = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            return None
        if laenge <= 0 or laenge > MAX_KOERPER:
            return None
        roh = self.rfile.read(laenge).decode("utf-8", "replace")
        return {k: v[0] for k, v in parse_qs(roh, keep_blank_values=True).items()}

    def _schluessel_stimmt(self, geliefert, erwartet):
        if not geliefert or not erwartet:
            return False
        return hmac.compare_digest(str(geliefert), str(erwartet))

    def log_message(self, fmt, *args):
        # Standardausgabe der Bibliothek unterdruecken, wir loggen selbst.
        pass

    def _log(self, zeile):
        stempel = time.strftime("%Y-%m-%d %H:%M:%S")
        text = "[%s] %s" % (stempel, zeile)
        print(text, flush=True)
        pfad = self._cfg().get("log_datei")
        if pfad:
            try:
                with open(pfad, "a") as f:
                    f.write(text + "\n")
            except OSError:
                pass

    # -- Endpunkte ----------------------------------------------------------

    def do_GET(self):
        pfad = urlparse(self.path).path
        if pfad == "/health":
            self._antwort(200, "OK %d Sitzungen" % self.server.sitzungen.anzahl())
        elif pfad == "/manifest":
            datei = self._cfg()["manifest_datei"]
            try:
                with open(datei, "rb") as f:
                    roh = f.read()
            except OSError:
                self._antwort(503, "Manifest nicht verfuegbar")
                return
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(roh)))
            self.end_headers()
            self.wfile.write(roh)
        else:
            self._antwort(404, "unbekannt")

    def do_POST(self):
        pfad = urlparse(self.path).path
        if pfad == "/session":
            self._session()
        elif pfad == "/verify":
            self._verify()
        else:
            self._antwort(404, "unbekannt")

    def _session(self):
        cfg = self._cfg()
        f = self._formular()
        if f is None:
            self._antwort(400, "FEHLER Koerper")
            return
        if not self._schluessel_stimmt(f.get("key"), cfg["launcher_key"]):
            self._log("session ABGELEHNT von %s: falscher Schluessel" % self.client_address[0])
            self._antwort(403, "FEHLER Schluessel")
            return

        try:
            version = int(f.get("manifest", "0"))
        except ValueError:
            version = 0

        ip = self._quelladresse()
        hwid = (f.get("hwid", "") or "")[:64]

        if not self.server.sitzungen.setzen(ip, version, hwid):
            self._log("session ABGELEHNT von %s: Obergrenze erreicht" % ip)
            self._antwort(503, "FEHLER Auslastung")
            return

        self._log("session OK ip=%s manifest=%d" % (ip, version))
        self._antwort(200, "OK %d" % cfg["sitzung_ttl_sekunden"])

    def _verify(self):
        cfg = self._cfg()
        f = self._formular()
        if f is None:
            self._antwort(400, "FEHLER")
            return
        if not self._schluessel_stimmt(f.get("key"), cfg["server_key"]):
            self._log("verify ABGELEHNT von %s: falscher Schluessel" % self.client_address[0])
            self._antwort(403, "FEHLER")
            return

        ip = (f.get("ip", "") or "")[:45]
        name = (f.get("name", "") or "")[:24]
        sitzung = self.server.sitzungen.holen(ip)

        if sitzung is None:
            self._log("verify NOSESSION ip=%s name=%s" % (ip, name))
            self._antwort(200, "NOSESSION")
            return

        if sitzung["version"] < cfg["mindest_version"]:
            self._log("verify OUTDATED ip=%s name=%s hat=%d braucht=%d"
                      % (ip, name, sitzung["version"], cfg["mindest_version"]))
            self._antwort(200, "OUTDATED %d" % cfg["mindest_version"])
            return

        self._log("verify OK ip=%s name=%s manifest=%d" % (ip, name, sitzung["version"]))
        self._antwort(200, "OK %d" % sitzung["version"])


def config_laden(pfad):
    cfg = dict(STANDARD_CONFIG)
    if pfad and os.path.exists(pfad):
        with open(pfad) as f:
            cfg.update(json.load(f))
    elif pfad:
        with open(pfad, "w") as f:
            json.dump(cfg, f, indent=2, sort_keys=True)
            f.write("\n")
        print("Vorlage %s angelegt. Bitte die beiden Schluessel aendern." % pfad)
    return cfg


def main():
    p = argparse.ArgumentParser(description="Pruefstelle fuer den Launcher-Zwang")
    p.add_argument("--config", default="api_config.json")
    args = p.parse_args()

    cfg = config_laden(args.config)

    for name in ("launcher_key", "server_key"):
        if str(cfg[name]).startswith("BITTE-AENDERN"):
            print("FEHLER: %s steht noch auf dem Auslieferungswert." % name)
            sys.exit(1)
    if cfg["vertraue_proxy"] and not cfg["proxy_ips"]:
        print("FEHLER: vertraue_proxy ist gesetzt, proxy_ips ist aber leer.")
        sys.exit(1)

    srv = ThreadingHTTPServer((cfg["bind"], cfg["port"]), Handler)
    srv.cfg = cfg
    srv.sitzungen = Sitzungen(cfg["sitzung_ttl_sekunden"], cfg["max_sitzungen"])

    print("Launcher-API laeuft auf %s:%d" % (cfg["bind"], cfg["port"]))
    print("  Mindestversion des Manifests: %d" % cfg["mindest_version"])
    print("  Sitzungsdauer: %d Sekunden" % cfg["sitzung_ttl_sekunden"])
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\nbeendet")


if __name__ == "__main__":
    main()
