@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo   Gamemode uebersetzen
echo   ====================
echo.

if not exist "qawno\pawncc.exe" (
    echo   FEHLER: qawno\pawncc.exe fehlt.
    echo.
    echo   Der Compiler im Ordner pawno\ ist 3.2.3664 von 2011 und zu alt
    echo   fuer die open.mp-Includes. Den richtigen holt:
    echo.
    echo       powershell -ExecutionPolicy Bypass -File server-test\einrichten.ps1
    echo.
    pause
    exit /b 1
)

if not exist "gamemodes\script.pwn" (
    echo   FEHLER: gamemodes\script.pwn nicht gefunden.
    echo   Diese Datei gehoert ins Wurzelverzeichnis des Repositories,
    echo   und dort gehoert auch diese .bat hin.
    echo.
    pause
    exit /b 1
)

if exist "gamemodes\script.amx" del "gamemodes\script.amx"

echo   Uebersetze gamemodes\script.pwn - das dauert etwa eine Minute ...
echo.

qawno\pawncc.exe gamemodes\script.pwn -i"pawno\include" -i"pawno\include\Gloabe Includes" -o"gamemodes\script.amx" > uebersetzen.log 2>&1

rem Reine Textsuche, kein /R: findstr behandelt /C: je nach Windows-Fassung
rem auch mit /R als Text, dann waeren Zeichenklassen wirkungslos.
rem ": error " trifft "... : error 017: ...", ": fatal error " die andere Form.
findstr /C:": error " /C:": fatal error " uebersetzen.log >nul
if not errorlevel 1 (
    echo   FEHLGESCHLAGEN. Diese Fehler stehen im Weg:
    echo.
    findstr /C:": error " /C:": fatal error " uebersetzen.log
    echo.
    echo   Volle Ausgabe: uebersetzen.log
    echo.
    pause
    exit /b 1
)

if not exist "gamemodes\script.amx" (
    echo   FEHLGESCHLAGEN: keine script.amx erzeugt.
    echo   Volle Ausgabe: uebersetzen.log
    echo.
    pause
    exit /b 1
)

set GROESSE=0
for %%A in ("gamemodes\script.amx") do set GROESSE=%%~zA
set WARN=0
for /f %%W in ('findstr /C:": warning " uebersetzen.log ^| find /c /v ""') do set WARN=%%W

echo   FERTIG
echo.
echo   gamemodes\script.amx   -   !GROESSE! Bytes, 0 Fehler
echo   !WARN! Warnungen - Bestand, kein Hindernis. Nachlesen: uebersetzen.log
echo.
echo   Die script.amx kannst du so auf den Linux-Server legen,
echo   sie ist plattformunabhaengig.
echo.
pause
