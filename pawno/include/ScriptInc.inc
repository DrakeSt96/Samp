// Sammel-Include des Gamemodes - open.mp-Fassung.
//
// <open.mp> ersetzt das fruehere <a_samp>. Der Kompatibilitaets-Wrapper
// a_samp.inc existiert unter open.mp zwar noch, gibt aber eine Warnung aus
// und leitet ohnehin nur hierher weiter.
//
// Die Includes liegen in "Gloabe Includes". Beim Kompilieren muss dieses
// Verzeichnis im Include-Pfad stehen (in Qawno/Pawno unter Include-Verzeichnis
// eintragen, auf der Kommandozeile per -i).
#include <open.mp>

// Plugin-Includes
#include <a_mysql>        // MySQL R39-4 - NICHT auf R40+ aktualisieren, siehe OPENMP.md
#include <streamer>       // Streamer 2.9.6 - Plugin muss dieselbe Version haben
#include <sscanf2>
#include <md5>
#include <zcmd>
#include <sampvoice>    // sampvoice open.mp-Fork (AmyrAhmady), Server-Plugin erforderlich

// Projekteigene Includes
#include <AMC1>
#include <AlteSachenVomScript>
#include <CoL_Farben>
