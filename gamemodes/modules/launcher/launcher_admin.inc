/*
    launcher_admin.inc - Auswertung des Launcher-Zwangs im Spiel.

        /launcherstatus         Konfiguration und Zaehler seit Serverstart
        /launchercheck [ID]     Urteil zu einem einzelnen Spieler

    Beide Befehle existieren nur, wenn LAUNCHER_ENABLED auf 1 steht. Im
    Auslieferungszustand taucht kein zusaetzlicher Befehl im Server auf.
*/

#if defined _launcher_admin_included
    #endinput
#endif
#define _launcher_admin_included

#if LAUNCHER_ENABLED

// Konstante Texte, damit im Code kein immer gleicher Ternaer steht.
#if LAUNCHER_ENFORCE
    #define LG_TEXT_ART         "durchsetzen"
#else
    #define LG_TEXT_ART         "nur beobachten"
#endif
#if LAUNCHER_FAIL_CLOSED
    #define LG_TEXT_AUSFALL     "kicken"
#else
    #define LG_TEXT_AUSFALL     "durchlassen"
#endif

static stock Launcher_UrteilText(urteil)
{
    new s[32];
    switch(urteil)
    {
        case LG_UNGEPRUEFT:     s = "ungeprueft";
        case LG_LAEUFT:         s = "Anfrage laeuft";
        case LG_OK:             s = "in Ordnung";
        case LG_VERALTET:       s = "veraltet";
        case LG_KEINE_SITZUNG:  s = "keine Sitzung";
        case LG_FEHLER:         s = "Fehler";
        case LG_AUSNAHME:       s = "Ausnahme";
        default:                s = "unbekannt";
    }
    return s;
}

CMD:launcherstatus(playerid, params[])
{
    #pragma unused params
    if(!isPlayerAnAdmin(playerid, LAUNCHER_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new msg[144];

    SCM(playerid, SAMP_WEISS, "--- Launcher-Pruefung ---");

    format(msg, sizeof(msg), "Betriebsart: %s%s", LG_TEXT_ART,
        lgDarfKicken ? ("") : (" (gesperrt: Adresse oder Schluessel fehlen)"));
    SCM(playerid, SAMP_WEISS, msg);

    format(msg, sizeof(msg), "Bei Ausfall der API: %s, Wartezeit %d Sekunden",
        LG_TEXT_AUSFALL, LAUNCHER_TIMEOUT_SEC);
    SCM(playerid, SAMP_WEISS, msg);

    new gesamt = 0;
    for(new i = 0; i < LG_ANZAHL_URTEILE; i++) gesamt += lgZaehler[i];

    if(gesamt < 1)
    {
        SCM(playerid, SAMP_WEISS, "Noch keine Pruefung seit dem Serverstart.");
        return 1;
    }

    format(msg, sizeof(msg), "In Ordnung: %d von %d (%d Prozent)",
        lgZaehler[LG_OK], gesamt, (lgZaehler[LG_OK] * 100) / gesamt);
    SCM(playerid, SAMP_WEISS, msg);

    format(msg, sizeof(msg), "Keine Sitzung: %d   Veraltet: %d   Fehler: %d   Ausnahme: %d",
        lgZaehler[LG_KEINE_SITZUNG], lgZaehler[LG_VERALTET],
        lgZaehler[LG_FEHLER], lgZaehler[LG_AUSNAHME]);
    SCM(playerid, SAMP_WEISS, msg);

#if !LAUNCHER_ENFORCE
    format(msg, sizeof(msg), ""IINFO" Im Durchsetzbetrieb waeren bisher %d Spieler gekickt worden.",
        lgZaehler[LG_KEINE_SITZUNG] + lgZaehler[LG_VERALTET] + lgZaehler[LG_FEHLER]);
    SCM(playerid, SAMP_WEISS, msg);
#endif
    return 1;
}

CMD:launchercheck(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, LAUNCHER_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new ziel;
    if(isnull(params) || sscanf(params, "u", ziel))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" /launchercheck [Spieler-ID]");
    }
    if(!IsPlayerConnected(ziel) || IsPlayerNPC(ziel))
    {
        return SCM(playerid, SAMP_WEISS, ""IINFO" Dieser Spieler ist nicht online.");
    }

    new msg[144], version[32];
    GetPlayerVersion(ziel, version, sizeof(version));

    format(msg, sizeof(msg), "%s (ID %d): %s, Manifest %d",
        SpielerName(ziel), ziel, Launcher_UrteilText(lgUrteil[ziel]), lgManifest[ziel]);
    SCM(playerid, SAMP_WEISS, msg);

    format(msg, sizeof(msg), "Client: %s %s",
        IsPlayerUsingOmp(ziel) ? ("open.mp") : (IsPlayerUsingOfficialClient(ziel) ? ("SA-MP") : ("unbekannt")),
        version);
    SCM(playerid, SAMP_WEISS, msg);
    return 1;
}

#endif
