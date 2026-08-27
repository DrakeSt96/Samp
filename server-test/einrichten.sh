#!/usr/bin/env bash
#
# einrichten.sh - macht aus dem Repository einen startbereiten open.mp-Server.
#
# Laedt die Serverbinaerdateien und das Voice-Plugin von den offiziellen
# Veroeffentlichungen, prueft sie gegen feste Pruefsummen, packt sie an die
# richtigen Stellen und uebersetzt den Gamemode.
#
# Alles, was heruntergeladen wird, ist fremde Software - die Pruefsummen unten
# sind die der Dateien, die ich beim Zusammenstellen dieses Pakets geprueft
# habe. Weicht eine ab, bricht das Skript ab, statt etwas Unbekanntes zu
# installieren.
#
#   ./server-test/einrichten.sh
#
set -euo pipefail

OMP_VERSION="v1.5.8.3079"
SV_VERSION="v3.2.0-omp"

OMP_URL="https://github.com/openmultiplayer/open.mp/releases/download/${OMP_VERSION}/open.mp-linux-x86.tar.gz"
OMP_SHA="5df708898cbbb97f6c299ad5c1ff663a52ad4d3d39b3d561f1fe08a32df424f4"
SV_URL="https://github.com/AmyrAhmady/sampvoice/releases/download/${SV_VERSION}/sampvoice-linux.zip"
SV_SHA="c67e1a035d4a37c1bf628b4ce837c8b765a73d469175fe3cfd4cd4209192a323"

WURZEL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

schritt() { printf '\n\033[1m[%s/6] %s\033[0m\n' "$1" "$2"; }
ok()      { printf '      \033[32mok\033[0m   %s\n' "$1"; }
warn()    { printf '      \033[33m!\033[0m    %s\n' "$1"; }
fehler()  { printf '      \033[31mFEHLER\033[0m %s\n' "$1"; exit 1; }

pruefe_sha() {
  local datei="$1" erwartet="$2"
  local ist; ist="$(sha256sum "$datei" | cut -d' ' -f1)"
  [ "$ist" = "$erwartet" ] || fehler "Pruefsumme von $(basename "$datei") stimmt nicht.
      erwartet: $erwartet
      erhalten: $ist
      Die Datei wurde NICHT installiert."
}

cd "$WURZEL"
echo "Serververzeichnis: $WURZEL"

# --- 1 ---------------------------------------------------------------------
schritt 1 "open.mp-Server holen (${OMP_VERSION})"
curl -fL --progress-bar -o "$TMP/omp.tar.gz" "$OMP_URL"
pruefe_sha "$TMP/omp.tar.gz" "$OMP_SHA"; ok "Pruefsumme stimmt"
mkdir -p "$TMP/omp" && tar -xzf "$TMP/omp.tar.gz" -C "$TMP/omp"
QUELLE="$TMP/omp/Server"
[ -d "$QUELLE" ] || fehler "Unerwarteter Archivaufbau"
cp "$QUELLE/omp-server" .
chmod +x omp-server
mkdir -p components && cp "$QUELLE/components/"*.so components/
ok "omp-server und $(ls components/*.so | wc -l) Komponenten installiert"

# --- 2 ---------------------------------------------------------------------
schritt 2 "Voice-Plugin holen (${SV_VERSION})"
curl -fL --progress-bar -o "$TMP/sv.zip" "$SV_URL"
pruefe_sha "$TMP/sv.zip" "$SV_SHA"; ok "Pruefsumme stimmt"
mkdir -p "$TMP/sv" && unzip -qo "$TMP/sv.zip" -d "$TMP/sv"
cp "$TMP/sv/sampvoice.so" components/
ok "components/sampvoice.so installiert"
ok "sampvoice ist eine open.mp-KOMPONENTE, kein Legacy-Plugin -"
ok "es gehoert nach components/ und NICHT in legacy_plugins."

# --- 3 ---------------------------------------------------------------------
schritt 3 "Konfiguration pruefen"
if [ ! -f config.json ]; then
  cp config.json.example config.json
  warn "config.json aus der Vorlage angelegt."
  warn "RCON-Passwort und MySQL-Zugang MUESSEN noch eingetragen werden."
else
  ok "config.json vorhanden"
fi
LEGACY_LISTE="$(tr -d '\n' < config.json \
  | sed -n 's/.*"legacy_plugins"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p')"
if printf '%s' "$LEGACY_LISTE" | grep -q 'sampvoice'; then
  fehler 'sampvoice steht in legacy_plugins in der config.json.
      Das ist falsch: sampvoice ist eine KOMPONENTE, kein Plugin. Der Server
      ueberspringt es dort und alle Sv*-Befehle im Script schlagen fehl.
      Bitte den Eintrag "sampvoice" aus legacy_plugins entfernen.'
else
  ok "legacy_plugins ist korrekt (ohne sampvoice)"
fi
if tr -d '\n' < config.json | grep -q '"sampvoice"[[:space:]]*:[[:space:]]*{[^}]*"port"[[:space:]]*:[[:space:]]*[1-9]'; then
  ok "sampvoice.port ist fest gesetzt"
else
  warn 'In config.json fehlt ein fester Voiceport. Ohne ihn sucht sich'
  warn 'sampvoice bei JEDEM Start einen zufaelligen Port - der laesst sich'
  warn 'in keiner Firewall freigeben. Bitte ergaenzen:'
  warn '    "sampvoice": { "port": 7778, "threads": 2, "updaterate": 10 },'
fi
if [ -f server.cfg ]; then
  warn "Eine server.cfg liegt hier. open.mp liest sie NACH config.json und"
  warn "ueberschreibt deren Werte stillschweigend. Bitte umbenennen."
fi

# --- 4 ---------------------------------------------------------------------
schritt 4 "Gamemode uebersetzen"
PAWNCC=""
for k in ./pawncc pawno/pawncc pawno/pawncc.exe; do
  [ -x "$k" ] && PAWNCC="$k" && break
done
if [ -n "$PAWNCC" ]; then
  "$PAWNCC" gamemodes/script.pwn \
    -i"pawno/include" -i"pawno/include/Gloabe Includes" \
    -o"gamemodes/script.amx" 2>&1 | grep -vE "^$|Pawn compiler|Copyright" || true
  [ -s gamemodes/script.amx ] || fehler "Uebersetzen fehlgeschlagen"
  ok "gamemodes/script.amx ($(stat -c%s gamemodes/script.amx) Bytes)"
else
  warn "Kein Pawn-Compiler fuer Linux gefunden."
  warn "Unter Windows uebersetzt pawno/pawncc.exe, sonst script.amx mitbringen."
fi

# --- 5 ---------------------------------------------------------------------
schritt 5 "Datenbank"
warn "Wird NICHT automatisch eingespielt. Reihenfolge:"
echo "         mysql -u USER -p DATENBANK < Datenbank/samp_server.sql"
echo "         mysql -u USER -p DATENBANK < gamemodes/modules/anticheat/ac_log.sql"
echo "         mysql -u USER -p DATENBANK < gamemodes/modules/voice/voice_mutes.sql"

# --- 6 ---------------------------------------------------------------------
schritt 6 "Fertig"
cat <<'ENDE'
      Starten mit:
          ./omp-server

      Die Spieler brauchen zusaetzlich den sampvoice-CLIENT, sonst hoert
      und spricht niemand. Ohne Client laeuft der Server normal weiter -
      das Voice-Modul faengt das ab.
ENDE
