/*
    launcher.inc - Sammel-Include des Launcher-Moduls.

    Einbindung im Gamemode (genau eine Zeile, nach den anderen Modulen, weil
    das Modul AC_Melden aus dem Anti-Cheat-Protokoll benutzt):

        #include "modules/launcher/launcher.inc"

    Dazu drei Aufrufe in den Callbacks:

        OnGameModeInit       ->  Launcher_OnGameModeInit();
        OnPlayerConnect      ->  Launcher_OnPlayerConnect(playerid);
        OnPlayerDisconnect   ->  Launcher_OnPlayerDisconnect(playerid);

    Diese drei Aufrufe duerfen dauerhaft stehen bleiben. Solange
    LAUNCHER_ENABLED in launcher_config.inc auf 0 steht, sind es leere
    Funktionen ohne jede Wirkung.

    Reihenfolge ist bindend:
        config -> gate -> admin
*/

#if defined _launcher_included
    #endinput
#endif
#define _launcher_included

#include "launcher_config.inc"
#include "launcher_gate.inc"
#include "launcher_admin.inc"
