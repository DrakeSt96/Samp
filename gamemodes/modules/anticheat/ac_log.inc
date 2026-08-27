/*
    ac_log.inc - Anti-Cheat-Meldungen in eine Tabelle schreiben.

    Bisher landen alle Erkennungen ausschliesslich im Adminchat und in
    Textdateien. Damit laesst sich nicht beantworten, ob es ueberhaupt ein
    Cheaterproblem gibt, welcher Art es ist und ob eine Pruefung dauernd
    Fehlalarm schlaegt. Dieses Modul aendert daran genau eine Sache: jede
    Erkennung wird zusaetzlich in AC_LOG_TABLE geschrieben.

    Bewusst NICHT enthalten: neue Pruefungen, neue Bannregeln, veraendertes
    Verhalten. Das hier ist reine Beobachtung.

    Zu den erfassten Clientangaben, damit sie niemand ueberbewertet: Version,
    Seriennummer und die beiden Client-Kennzeichen stammen aus dem
    Verbindungspaket und werden vom Client selbst geschrieben - siehe
    Shared/NetCode/core.hpp im open.mp-Quelltext. Sie taugen als Indiz und zum
    Wiedererkennen, nicht als Beweis.
*/

#if defined _ac_log_included
    #endinput
#endif
#define _ac_log_included

// Tabelle. Wird von ac_log.sql angelegt - das Script legt nichts selbst an.
#define AC_LOG_TABLE                "ac_log"

// Adminlevel fuer die Auswertungsbefehle.
#define AC_LOG_ADMIN_LEVEL          (2)

// Wie viele Tage die Zusammenfassung standardmaessig zurueckblickt.
#define AC_LOG_SUMMARY_DAYS         (7)

// Wie viele Zeilen /aclog hoechstens ausgibt.
#define AC_LOG_LIST_LIMIT           (15)

forward AC_OnSummary(playerid, tage);
forward AC_OnList(playerid);

// ---------------------------------------------------------------------------
// Schreiben
// ---------------------------------------------------------------------------

// Der einzige Weg, eine Erkennung zu protokollieren.
// grund   - kurze Kategorie, dieselbe Schreibweise wie im Bann ("Speedhack")
// detail  - freier Text mit den Messwerten, darf leer sein
// gebannt - true bei Bann oder Kick, false bei blosser Verdachtsmeldung
stock AC_Melden(playerid, const grund[], const detail[], bool:gebannt)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 0;

    new serial[64], version[32], client[16];

    gpci(playerid, serial, sizeof(serial));
    GetPlayerVersion(playerid, version, sizeof(version));

    // Nur ein Indiz: der Client sagt das ueber sich selbst.
    if(IsPlayerUsingOmp(playerid))                  client = "open.mp";
    else if(IsPlayerUsingOfficialClient(playerid))  client = "SA-MP";
    else                                            client = "unbekannt";

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new query[700], none[1];
    new fmt[] = "INSERT INTO `" AC_LOG_TABLE "` \
(Name,IP,Serial,Client,Version,Grund,Detail,Gebannt,PosX,PosY,PosZ,Ping,Datum) \
VALUES ('%e','%e','%e','%e','%e','%e','%e','%d','%f','%f','%f','%d',NOW())";

    mysql_format(MySQL_R394, query, sizeof(query), fmt,
        SpielerName(playerid), SpielerIP(playerid), serial, client, version,
        grund, detail, gebannt ? 1 : 0, x, y, z, GetPlayerPing(playerid));

    mysql_tquery(MySQL_R394, query, none, none);
    return 1;
}

// ---------------------------------------------------------------------------
// Auswerten
// ---------------------------------------------------------------------------

CMD:acstats(playerid, params[])
{
    if(!isPlayerAnAdmin(playerid, AC_LOG_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new tage = AC_LOG_SUMMARY_DAYS;
    if(!isnull(params))
    {
        if(sscanf(params, "d", tage) || tage < 1 || tage > 365)
        {
            return SCM(playerid, SAMP_WEISS, ""IINFO" /acstats [Tage] - Standard sind 7");
        }
    }

    new query[320], cb[] = "AC_OnSummary", cbfmt[] = "ii";
    new fmt[] = "SELECT Grund, COUNT(*) AS Anzahl, SUM(Gebannt) AS Baenne, \
COUNT(DISTINCT Name) AS Spieler FROM `" AC_LOG_TABLE "` \
WHERE Datum > DATE_SUB(NOW(), INTERVAL %d DAY) GROUP BY Grund ORDER BY Anzahl DESC";

    mysql_format(MySQL_R394, query, sizeof(query), fmt, tage);
    mysql_tquery(MySQL_R394, query, cb, cbfmt, playerid, tage);
    return 1;
}

public AC_OnSummary(playerid, tage)
{
    new rows, fields;
    cache_get_data(rows, fields, MySQL_R394);

    // Recht beim Ruecklauf erneut pruefen: zwischen Absenden und Antwort kann
    // der Admin gegangen sein und die Slot-ID jemand anderem gehoeren.
    if(!IsPlayerConnected(playerid)) return 1;
    if(!isPlayerAnAdmin(playerid, AC_LOG_ADMIN_LEVEL)) return 1;

    new msg[144];
    format(msg, sizeof(msg), "--- Anti-Cheat, letzte %d Tage ---", tage);
    SendClientMessage(playerid, SAMP_WEISS, msg);

    // Regel: erst die Zeilenzahl pruefen, dann lesen.
    if(rows < 1)
    {
        SendClientMessage(playerid, SAMP_WEISS, "Keine Eintraege. Entweder ist alles ruhig, oder die Tabelle fehlt noch (ac_log.sql).");
        return 1;
    }

    new grund[48], anzahl[12], baenne[12], spieler[12], gesamt = 0;
    for(new i = 0; i < rows; i++)
    {
        cache_get_field_content(i, "Grund",   grund,   MySQL_R394, sizeof(grund));
        cache_get_field_content(i, "Anzahl",  anzahl,  MySQL_R394, sizeof(anzahl));
        cache_get_field_content(i, "Baenne",  baenne,  MySQL_R394, sizeof(baenne));
        cache_get_field_content(i, "Spieler", spieler, MySQL_R394, sizeof(spieler));

        gesamt += strval(anzahl);

        format(msg, sizeof(msg), "%s: %s Meldungen von %s Spielern, davon %s mit Bann/Kick",
            grund, anzahl, spieler, baenne);
        SendClientMessage(playerid, SAMP_WEISS, msg);
    }

    format(msg, sizeof(msg), "Gesamt: %d Meldungen. /aclog zeigt die letzten einzeln.", gesamt);
    SendClientMessage(playerid, SAMP_WEISS, msg);
    return 1;
}

CMD:aclog(playerid, params[])
{
    #pragma unused params

    if(!isPlayerAnAdmin(playerid, AC_LOG_ADMIN_LEVEL)) return ADMIN_MSG(playerid);

    new query[220], cb[] = "AC_OnList", cbfmt[] = "i";
    new fmt[] = "SELECT Name, Grund, Detail, Gebannt, Client, Datum FROM `" AC_LOG_TABLE "` \
ORDER BY id DESC LIMIT %d";

    mysql_format(MySQL_R394, query, sizeof(query), fmt, AC_LOG_LIST_LIMIT);
    mysql_tquery(MySQL_R394, query, cb, cbfmt, playerid);
    return 1;
}

public AC_OnList(playerid)
{
    new rows, fields;
    cache_get_data(rows, fields, MySQL_R394);

    // Siehe AC_OnSummary: die Ausgabe enthaelt IP und Seriennummer.
    if(!IsPlayerConnected(playerid)) return 1;
    if(!isPlayerAnAdmin(playerid, AC_LOG_ADMIN_LEVEL)) return 1;

    SendClientMessage(playerid, SAMP_WEISS, "--- Letzte Anti-Cheat-Meldungen ---");

    if(rows < 1)
    {
        SendClientMessage(playerid, SAMP_WEISS, "Keine Eintraege vorhanden.");
        return 1;
    }

    new name[MAX_PLAYER_NAME+1], grund[48], detail[96], gebannt[4], client[16], datum[24], msg[220];
    for(new i = 0; i < rows; i++)
    {
        cache_get_field_content(i, "Name",    name,    MySQL_R394, sizeof(name));
        cache_get_field_content(i, "Grund",   grund,   MySQL_R394, sizeof(grund));
        cache_get_field_content(i, "Detail",  detail,  MySQL_R394, sizeof(detail));
        cache_get_field_content(i, "Gebannt", gebannt, MySQL_R394, sizeof(gebannt));
        cache_get_field_content(i, "Client",  client,  MySQL_R394, sizeof(client));
        cache_get_field_content(i, "Datum",   datum,   MySQL_R394, sizeof(datum));

        format(msg, sizeof(msg), "%s | %s | %s%s | %s%s",
            datum, name, grund,
            (strval(gebannt) != 0) ? (" [gebannt]") : (" [nur Verdacht]"),
            client,
            (detail[0] != EOS) ? (" | ") : (""));

        if(detail[0] != EOS) strcat(msg, detail, sizeof(msg));
        SendClientMessage(playerid, SAMP_WEISS, msg);
    }
    return 1;
}
