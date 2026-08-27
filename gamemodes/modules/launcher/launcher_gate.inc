/*
    launcher_gate.inc - Prueft beim Verbinden, ob der Spieler ueber den
    eigenen Launcher kommt und seine Dateien aktuell sind.

    Ablauf:
        1. OnPlayerConnect: der Server fragt per HTTP bei der eigenen API nach,
           ob fuer diese IP eine frische Launcher-Sitzung existiert.
        2. Die API antwortet mit einem Wort: OK, OUTDATED oder NOSESSION.
        3. Je nach Betriebsart wird das Ergebnis nur gezaehlt (LAUNCHER_ENFORCE 0)
           oder der Spieler gekickt (LAUNCHER_ENFORCE 1).

    Was das leistet und was nicht:
        Die Bindung an die IP haelt, weil der Server die echte Quelladresse der
        laufenden Verbindung sieht. Was NICHT haelt: der Launcher laeuft auf
        fremder Hardware. Wer ihn auseinandernimmt, kann der API auch mit
        falschen Dateien ein "alles in Ordnung" schicken. Das ist keine Luecke
        in diesem Modul, sondern die Grundregel - man kann nicht beweisen, dass
        ein fremder Rechner ehrlich ist. Der Zweck hier ist, den normalen Weg
        vorzugeben und veraltete Installationen auszusperren, nicht einen
        entschlossenen Angreifer aufzuhalten.

    Sicherheitsdetails, die leicht untergehen:
        - Zwischen Anfrage und Antwort kann der Spieler die Verbindung trennen
          und ein anderer denselben Slot bekommen. Darum traegt jede Anfrage
          eine laufende Nummer, die beim Rueckkommen verglichen wird.
        - Alles, was in den Anfragekoerper wandert, wird prozentkodiert -
          der API-Schluessel eingeschlossen. Ohne das zerlegt die Gegenseite
          einen Schluessel mit "+", "&" oder "%" falsch und die Pruefung
          scheitert fuer jeden Spieler.
        - Solange API-Adresse oder Schluessel auf dem Auslieferungswert stehen,
          weigert sich das Modul zu kicken, egal was in der Konfiguration steht.
*/

#if defined _launcher_gate_included
    #endinput
#endif
#define _launcher_gate_included

#if LAUNCHER_ENABLED

#if MAX_PLAYERS > 1024
    #error launcher_gate.inc: MAX_PLAYERS ueber 1024 - Indexpackung anpassen
#endif

// Urteile. Reihenfolge ist die Reihenfolge in /launcherstatus.
#define LG_UNGEPRUEFT       (0)
#define LG_LAEUFT           (1)
#define LG_OK               (2)
#define LG_VERALTET         (3)
#define LG_KEINE_SITZUNG    (4)
#define LG_FEHLER           (5)
#define LG_AUSNAHME         (6)
#define LG_ANZAHL_URTEILE   (7)

// Bitbreite der Spieler-ID im HTTP-Index. 10 Bit reichen bis 1023.
#define LG_PID_BITS         (10)
#define LG_PID_MASKE        (0x3FF)
#define LG_NONCE_MASKE      (0x1FFFFF)

new lgUrteil[MAX_PLAYERS];
new lgNonce[MAX_PLAYERS];
new lgManifest[MAX_PLAYERS];
new lgZaehler[LG_ANZAHL_URTEILE];
new lgLaufendeNummer = 0;

// Wird beim Start gesetzt. Nur wenn true, darf ueberhaupt gekickt werden.
new bool:lgDarfKicken = false;

// Urteil, wenn die API nicht antwortet oder Unsinn liefert. Als Konstante,
// damit der Uebersetzer keinen immer gleichen Ternaer stehen hat.
#if LAUNCHER_FAIL_CLOSED
    #define LG_BEI_FEHLER   LG_FEHLER
#else
    #define LG_BEI_FEHLER   LG_AUSNAHME
#endif

forward Launcher_OnHTTPResponse(lgIndex, responseCode, const daten[]);
forward Launcher_Timeout(playerid, nonce);

// ---------------------------------------------------------------------------
//  Hilfsfunktionen
// ---------------------------------------------------------------------------

// Prozentkodierung nach RFC 3986 fuer Werte im Anfragekoerper.
//
// Warum nicht einfach Sonderzeichen ersetzen: der Koerper geht als
// application/x-www-form-urlencoded raus (open.mp setzt diesen Typ fest, siehe
// core_impl.hpp, HTTPAsyncIO::threadProc). Die Gegenseite zerlegt ihn mit
// parse_qs. Ein Wert mit '+' wird dort zum Leerzeichen, '%XX' wird dekodiert,
// '&' und '=' beginnen ein neues Feld. Ein mit "openssl rand -base64" erzeugter
// Schluessel enthaelt haeufig ein '+' - ungekodiert wuerde die Pruefung dann
// fuer JEDEN Spieler scheitern, obwohl beide Seiten zeichengleich konfiguriert
// sind. Kodieren loest das vollstaendig und verliert dabei nichts.
static stock Launcher_Kodieren(const quelle[], ziel[], groesse)
{
    new const hexziffern[] = "0123456789ABCDEF";
    new i = 0, n = 0, c;
    ziel[0] = EOS;
    while(quelle[i] != EOS && n < groesse - 1)
    {
        c = quelle[i] & 0xFF;
        if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')
        || c == '-' || c == '_' || c == '.' || c == '~')
        {
            ziel[n++] = c;
        }
        else
        {
            if(n + 3 > groesse - 1) break;
            ziel[n++] = '%';
            ziel[n++] = hexziffern[(c >> 4) & 0x0F];
            ziel[n++] = hexziffern[c & 0x0F];
        }
        i++;
    }
    ziel[n] = EOS;
    return n;
}

// Zerlegt eine Antwort wie "OK 17" in wort = "OK" und zahl = 17.
// Fehlt die Zahl, bleibt zahl auf 0. Rueckgabe: Laenge des Wortes.
static stock Launcher_AntwortZerlegen(const daten[], wort[], groesse, &zahl)
{
    new i = 0, n = 0;
    wort[0] = EOS;
    zahl = 0;

    while(daten[i] == ' ' || daten[i] == '\t' || daten[i] == '\r' || daten[i] == '\n') i++;
    while(daten[i] > ' ' && n < groesse - 1)
    {
        wort[n++] = daten[i++];
    }
    wort[n] = EOS;

    while(daten[i] == ' ' || daten[i] == '\t') i++;
    while(daten[i] >= '0' && daten[i] <= '9')
    {
        zahl = zahl * 10 + (daten[i] - '0');
        i++;
        if(zahl > 100000000) break;
    }
    return n;
}

// Steht die IP in LAUNCHER_BYPASS_IPS?
static stock bool:Launcher_IstAusnahme(const ip[])
{
    new const liste[] = LAUNCHER_BYPASS_IPS;
    if(liste[0] == EOS || ip[0] == EOS) return false;

    new pos = 0, teil[24], n;
    while(pos < sizeof(liste) && liste[pos] != EOS)
    {
        n = 0;
        while(liste[pos] != EOS && liste[pos] != ',' && n < sizeof(teil) - 1)
        {
            teil[n++] = liste[pos++];
        }
        teil[n] = EOS;
        if(n > 0 && !strcmp(teil, ip, false)) return true;
        while(liste[pos] == ',') pos++;
    }
    return false;
}

static stock Launcher_Merken(playerid, urteil)
{
    if(urteil < 0 || urteil >= LG_ANZAHL_URTEILE) return 0;
    lgUrteil[playerid] = urteil;
    lgZaehler[urteil]++;
    return 1;
}

// ---------------------------------------------------------------------------
//  Urteil umsetzen
// ---------------------------------------------------------------------------

static stock Launcher_Urteilen(playerid, urteil, const grundtext[], const detail[])
{
    Launcher_Merken(playerid, urteil);

    new zeile[256];
    format(zeile, sizeof(zeile), "%s (ID %d, IP %s): %s",
        SpielerName(playerid), playerid, SpielerIP(playerid), detail);
    Log("Launcher_Pruefung.txt", zeile);

    if(urteil == LG_OK || urteil == LG_AUSNAHME) return 1;

#if LAUNCHER_ENFORCE

    // Unvollstaendige Konfiguration: nur vermerken, niemanden anfassen.
    if(!lgDarfKicken)
    {
        #if LAUNCHER_LOG_AC
            AC_Melden(playerid, LAUNCHER_KICK_GRUND, detail, false);
        #endif
        return 1;
    }

    // Wer sich noch rechtzeitig als Admin einloggen konnte, bleibt drin.
    if(isPlayerAnAdmin(playerid, LAUNCHER_ADMIN_BYPASS_LEVEL)) return 1;

    SCM(playerid, SAMP_WEISS, grundtext);
    KickUser(playerid, "System", LAUNCHER_KICK_GRUND);

#else

    // Beobachtungsbetrieb: das Urteil steht im Zaehler und in
    // Launcher_Pruefung.txt. In die Anti-Cheat-Tabelle nur auf Wunsch, sonst
    // waere dort bald nichts anderes mehr zu sehen.
    #pragma unused grundtext
    #if LAUNCHER_LOG_AC
        AC_Melden(playerid, LAUNCHER_KICK_GRUND, detail, false);
    #endif

#endif
    return 1;
}

// ---------------------------------------------------------------------------
//  Einstiegspunkte aus dem Gamemode
// ---------------------------------------------------------------------------

stock Launcher_OnGameModeInit()
{
    for(new i = 0; i < LG_ANZAHL_URTEILE; i++) lgZaehler[i] = 0;

    new bool:schluesselGesetzt = (strcmp(LAUNCHER_API_KEY, "BITTE-AENDERN", true) != 0);
    new bool:adresseGesetzt    = (strfind(LAUNCHER_API_URL, "example.invalid", true) == -1)
                              && (strfind(LAUNCHER_API_URL, "http", true) == 0);

    lgDarfKicken = (schluesselGesetzt && adresseGesetzt);

    print("[Launcher] Modul uebersetzt und aktiv.");

    // Ein sehr langer Schluessel wuerde beim Kodieren abgeschnitten und damit
    // jede Pruefung scheitern lassen. Lieber einmal laut sagen.
    if(strlen(LAUNCHER_API_KEY) > 64)
    {
        print("[Launcher] WARNUNG: LAUNCHER_API_KEY ist laenger als 64 Zeichen und wird abgeschnitten.");
        lgDarfKicken = false;
    }
    if(!schluesselGesetzt) print("[Launcher] WARNUNG: LAUNCHER_API_KEY steht noch auf dem Auslieferungswert.");
    if(!adresseGesetzt)    print("[Launcher] WARNUNG: LAUNCHER_API_URL ist nicht gesetzt oder unvollstaendig.");

#if LAUNCHER_ENFORCE
    if(!lgDarfKicken)
    {
        print("[Launcher] LAUNCHER_ENFORCE steht auf 1, die Konfiguration ist aber unvollstaendig.");
        print("[Launcher] Es wird NIEMAND gekickt, bis Adresse und Schluessel stimmen.");
    }
    else
    {
        print("[Launcher] Betriebsart: durchsetzen - ungeprueft Verbundene werden gekickt.");
    }
#else
    print("[Launcher] Betriebsart: beobachten - es wird niemand gekickt.");
#endif
    return 1;
}

stock Launcher_OnPlayerConnect(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    lgUrteil[playerid]   = LG_UNGEPRUEFT;
    lgManifest[playerid] = 0;

    lgLaufendeNummer = (lgLaufendeNummer + 1) & LG_NONCE_MASKE;
    if(lgLaufendeNummer == 0) lgLaufendeNummer = 1;
    lgNonce[playerid] = lgLaufendeNummer;

    if(IsPlayerNPC(playerid)) return 0;

    new ip[24];
    format(ip, sizeof(ip), "%s", SpielerIP(playerid));

    if(Launcher_IstAusnahme(ip))
    {
        Launcher_Merken(playerid, LG_AUSNAHME);
        return 1;
    }

    new serialRoh[64], versionRoh[32];
    gpci(playerid, serialRoh, sizeof(serialRoh));
    GetPlayerVersion(playerid, versionRoh, sizeof(versionRoh));

    // Jeder Wert wird kodiert, der Schluessel eingeschlossen. Die Puffer sind
    // auf das Dreifache ausgelegt, weil ein Zeichen im schlimmsten Fall zu
    // "%XX" wird.
    new schluessel[3 * 64 + 1], ipEnc[3 * 16 + 1], serialEnc[3 * 64 + 1];
    new nameEnc[3 * (MAX_PLAYER_NAME + 1) + 1], versionEnc[3 * 32 + 1];
    Launcher_Kodieren(LAUNCHER_API_KEY, schluessel, sizeof(schluessel));
    Launcher_Kodieren(ip, ipEnc, sizeof(ipEnc));
    Launcher_Kodieren(serialRoh, serialEnc, sizeof(serialEnc));
    Launcher_Kodieren(SpielerName(playerid), nameEnc, sizeof(nameEnc));
    Launcher_Kodieren(versionRoh, versionEnc, sizeof(versionEnc));

    // Namen mit Praefix: "url", "data" und "index" stammen aus den Native-
    // Deklarationen und wuerden hier als Ueberdeckung gemeldet.
    new lgUrl[256], lgKoerper[1024];
    format(lgUrl, sizeof(lgUrl), "%s/verify", LAUNCHER_API_URL);
    format(lgKoerper, sizeof(lgKoerper), "key=%s&ip=%s&serial=%s&name=%s&ver=%s&omp=%d",
        schluessel, ipEnc, serialEnc, nameEnc, versionEnc, IsPlayerUsingOmp(playerid) ? 1 : 0);

    new lgIndex = (lgNonce[playerid] << LG_PID_BITS) | (playerid & LG_PID_MASKE);

    lgUrteil[playerid] = LG_LAEUFT;
    HTTP(lgIndex, HTTP_POST, lgUrl, lgKoerper, "Launcher_OnHTTPResponse");
    SetTimerEx("Launcher_Timeout", LAUNCHER_TIMEOUT_SEC * 1000, false, "ii", playerid, lgNonce[playerid]);
    return 1;
}

stock Launcher_OnPlayerDisconnect(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    // Die laufende Nummer NICHT zuruecksetzen - eine noch unterwegs befindliche
    // Antwort soll den naechsten Spieler auf diesem Slot nicht treffen.
    lgUrteil[playerid]   = LG_UNGEPRUEFT;
    lgManifest[playerid] = 0;
    return 1;
}

stock Launcher_UrteilVon(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return LG_UNGEPRUEFT;
    return lgUrteil[playerid];
}

// ---------------------------------------------------------------------------
//  Rueckmeldungen
// ---------------------------------------------------------------------------

public Launcher_OnHTTPResponse(lgIndex, responseCode, const daten[])
{
    new playerid = lgIndex & LG_PID_MASKE;
    new nonce    = (lgIndex >> LG_PID_BITS) & LG_NONCE_MASKE;

    if(playerid < 0 || playerid >= MAX_PLAYERS)     return 0;
    if(!IsPlayerConnected(playerid))                return 0;
    if(lgNonce[playerid] != nonce)                  return 0;  // Slot neu belegt
    if(lgUrteil[playerid] != LG_LAEUFT)             return 0;  // schon entschieden

    new detail[160];

    if(responseCode != 200)
    {
        format(detail, sizeof(detail), "API antwortete mit Code %d", responseCode);
        Launcher_Urteilen(playerid,
            LG_BEI_FEHLER,
            LAUNCHER_MSG_ERROR, detail);
        return 1;
    }

    new wort[24], version;
    Launcher_AntwortZerlegen(daten, wort, sizeof(wort), version);
    lgManifest[playerid] = version;

    if(!strcmp(wort, "OK", true))
    {
        format(detail, sizeof(detail), "in Ordnung, Manifest %d", version);
        Launcher_Urteilen(playerid, LG_OK, "", detail);
    }
    else if(!strcmp(wort, "OUTDATED", true))
    {
        format(detail, sizeof(detail), "Launcher veraltet, verlangt wird Manifest %d", version);
        Launcher_Urteilen(playerid, LG_VERALTET, LAUNCHER_MSG_OUTDATED, detail);
    }
    else if(!strcmp(wort, "NOSESSION", true))
    {
        Launcher_Urteilen(playerid, LG_KEINE_SITZUNG, LAUNCHER_MSG_NOSESSION,
            "keine gueltige Launcher-Sitzung fuer diese IP");
    }
    else
    {
        format(detail, sizeof(detail), "unverstaendliche Antwort: %s", wort);
        Launcher_Urteilen(playerid,
            LG_BEI_FEHLER,
            LAUNCHER_MSG_ERROR, detail);
    }
    return 1;
}

public Launcher_Timeout(playerid, nonce)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS)     return 0;
    if(!IsPlayerConnected(playerid))                return 0;
    if(lgNonce[playerid] != nonce)                  return 0;
    if(lgUrteil[playerid] != LG_LAEUFT)             return 0;  // Antwort war schneller

    Launcher_Urteilen(playerid,
        LG_BEI_FEHLER,
        LAUNCHER_MSG_ERROR, "keine Antwort der API innerhalb der Wartezeit");
    return 1;
}

#else   // LAUNCHER_ENABLED == 0

// Ausgeschaltet. Die drei Einstiegspunkte werden im Gamemode selbst per
// #if LAUNCHER_ENABLED weggeschaltet, darum braucht es hier keine leeren
// Gegenstuecke. Ergebnis: im uebersetzten Programm steht keine einzige
// Anweisung, die es ohne dieses Modul nicht auch gaebe.
#define Launcher_UrteilVon(%0)              (0)

#endif
