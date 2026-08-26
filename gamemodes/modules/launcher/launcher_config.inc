/*
    launcher_config.inc - Alle Schalter des Launcher-Zwangs an einer Stelle.

    AUSLIEFERUNGSZUSTAND: alles aus. Solange LAUNCHER_ENABLED auf 0 steht,
    wird der komplette Modulcode nicht einmal mituebersetzt - der Gamemode
    verhaelt sich Byte fuer Byte wie vorher. Es gibt keinen Timer, keinen
    HTTP-Aufruf, keine zusaetzliche Variable.

    Einschalten in dieser Reihenfolge:
        1. API aufsetzen  (siehe tools/launcher/README.md)
        2. LAUNCHER_API_URL und LAUNCHER_API_KEY hier eintragen
        3. LAUNCHER_ENABLED auf 1, LAUNCHER_ENFORCE auf 0  -> nur beobachten
        4. Ein paar Tage laufen lassen, /launcherstatus ansehen
        5. Erst wenn die Zahlen stimmen: LAUNCHER_ENFORCE auf 1
*/

#if defined _launcher_config_included
    #endinput
#endif
#define _launcher_config_included

// ===========================================================================
//  1. HAUPTSCHALTER
// ===========================================================================

// 0 = komplett aus (Auslieferungszustand)
// 1 = an
#define LAUNCHER_ENABLED                0

// ===========================================================================
//  2. BETRIEBSART   (nur wirksam wenn LAUNCHER_ENABLED == 1)
// ===========================================================================

// 0 = nur beobachten. Jeder darf rein, das Ergebnis wird nur gezaehlt und
//     protokolliert. Damit siehst du, wie viele Spieler ueberhaupt schon
//     ueber den Launcher kaemen, ohne jemanden auszusperren.
// 1 = durchsetzen. Wer keine gueltige Launcher-Sitzung hat, wird gekickt.
//
// NIE direkt auf 1 stellen. Erst beobachten.
#define LAUNCHER_ENFORCE                0

// ===========================================================================
//  3. ANBINDUNG AN DIE API
// ===========================================================================

// Basisadresse der Pruef-API, OHNE Schraegstrich am Ende.
// https wird unterstuetzt (open.mp uebersetzt httplib mit OpenSSL).
#define LAUNCHER_API_URL                "https://launcher.example.invalid"

// Gemeinsames Geheimnis zwischen Server und API. Muss in beiden
// Konfigurationen identisch sein. Der Wert unten ist absichtlich unbrauchbar -
// solange er unveraendert ist, weigert sich das Modul zu kicken.
#define LAUNCHER_API_KEY                "BITTE-AENDERN"

// Sekunden, die auf die Antwort der API gewartet wird.
#define LAUNCHER_TIMEOUT_SEC            (10)

// Was passiert, wenn die API nicht antwortet oder einen Fehler liefert?
// 0 = durchlassen. Deine API faellt aus, der Server laeuft weiter.
// 1 = kicken. Sicherer, aber deine API wird damit zum Single Point of Failure.
//
// Empfehlung: 0. Ein Ausfall der API darf nicht den ganzen Server leeren.
#define LAUNCHER_FAIL_CLOSED            (0)

// ===========================================================================
//  4. AUSNAHMEN
// ===========================================================================

// IP-Adressen, die nie geprueft werden. Fuer deinen Entwicklungsrechner.
// Format: durch Komma getrennt, ohne Leerzeichen. Leer lassen heisst: keine
// Ausnahme. Beispiel: "127.0.0.1,84.13.22.9"
#define LAUNCHER_BYPASS_IPS             ""

// Adminstufe, ab der ein bereits eingeloggter Admin nicht gekickt wird.
// Greift nur, wenn der Admin sich vor dem Urteil einloggen konnte - verlass
// dich nicht darauf, nutze LAUNCHER_BYPASS_IPS.
#define LAUNCHER_ADMIN_BYPASS_LEVEL     (5)

// Adminstufe fuer /launcherstatus und /launchercheck.
#define LAUNCHER_ADMIN_LEVEL            (2)

// Sollen abgelehnte Pruefungen zusaetzlich in die Anti-Cheat-Tabelle?
// 0 = nein (empfohlen). Die Zaehler in /launcherstatus und die Datei
//     Launcher_Pruefung.txt reichen fuer die Auswertung voellig.
// 1 = ja. Achtung: solange kaum jemand den Launcher nutzt, ist das eine
//     Zeile pro Verbindung. Das verzerrt /acstats, weil "Launcher-
//     Pruefung" dann jede echte Cheaterkennung ueberdeckt.
//
// Unabhaengig davon landet jeder tatsaechliche Kick ueber KickUser
// ohnehin im Protokoll - das hier betrifft nur den Beobachtungsbetrieb.
#define LAUNCHER_LOG_AC                 0

// ===========================================================================
//  5. TEXTE AN DEN SPIELER
// ===========================================================================

#define LAUNCHER_MSG_NOSESSION          "Bitte verbinde dich ueber unseren Launcher."
#define LAUNCHER_MSG_OUTDATED           "Dein Launcher ist nicht auf dem aktuellen Stand. Bitte starte ihn neu."
#define LAUNCHER_MSG_ERROR              "Die Launcher-Pruefung ist fehlgeschlagen. Bitte versuche es erneut."

// Kickgrund, so wie er im Anti-Cheat-Protokoll landet.
#define LAUNCHER_KICK_GRUND             "Launcher-Pruefung"
