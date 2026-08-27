/*
    voice.inc - Sammel-Include des Voice-Moduls.

    Einbindung im Gamemode (genau eine Zeile, nach den globalen Deklarationen):

        #include "modules/voice/voice.inc"

    Die Plugin-Include <sampvoice> selbst wird in ScriptInc.inc geladen, weil
    sie zu den Plugin-Includes gehoert und nicht zum Modul.

    Reihenfolge ist bindend:
        config -> core -> proximity -> radio -> admin -> ui
*/

#if defined _voice_included
    #endinput
#endif
#define _voice_included

#include "voice_config.inc"
#include "voice_core.inc"
#include "voice_proximity.inc"
#include "voice_radio.inc"
#include "voice_admin.inc"
#include "voice_ui.inc"
