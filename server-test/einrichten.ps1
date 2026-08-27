<#
    einrichten.ps1 - macht aus dem Repository einen startbereiten open.mp-Server.

    Laedt die Serverbinaerdateien und das Voice-Plugin von den offiziellen
    Veroeffentlichungen, prueft sie gegen feste Pruefsummen, packt sie an die
    richtigen Stellen und uebersetzt den Gamemode.

    Alles, was heruntergeladen wird, ist fremde Software - die Pruefsummen
    unten sind die der Dateien, die beim Zusammenstellen dieses Pakets geprueft
    wurden. Weicht eine ab, bricht das Skript ab, statt etwas Unbekanntes zu
    installieren.

    Aufruf in PowerShell, im Repository-Ordner:
        .\server-test\einrichten.ps1

    Falls Windows die Ausfuehrung blockiert, einmalig:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>

$ErrorActionPreference = "Stop"

$OmpVersion = "v1.5.8.3079"
$SvVersion  = "v3.2.0-omp"

$OmpUrl = "https://github.com/openmultiplayer/open.mp/releases/download/$OmpVersion/open.mp-win-x86.zip"
$OmpSha = "d1b5ea1d09e7de0f144bf0055183e3ceaad5ff8a0a8e791021141e8973f84e03"
$SvUrl  = "https://github.com/AmyrAhmady/sampvoice/releases/download/$SvVersion/sampvoice-win.zip"
$SvSha  = "f7128edab7cd11b2bae61bc6f390f58b7a8c38736ea9f6f64171494b4d485694"

$Wurzel = Split-Path -Parent $PSScriptRoot
$Tmp    = Join-Path ([System.IO.Path]::GetTempPath()) ("omp-setup-" + [guid]::NewGuid().ToString("N").Substring(0,8))
New-Item -ItemType Directory -Path $Tmp -Force | Out-Null

function Schritt($n, $t) { Write-Host ""; Write-Host "[$n/6] $t" -ForegroundColor White }
function Ok($t)     { Write-Host "      ok   $t"    -ForegroundColor Green }
function Warnung($t){ Write-Host "      !    $t"    -ForegroundColor Yellow }
function Fehler($t) { Write-Host "      FEHLER $t"  -ForegroundColor Red; Remove-Item -Recurse -Force $Tmp -EA SilentlyContinue; exit 1 }

function Pruefe-Sha($Datei, $Erwartet) {
    $ist = (Get-FileHash -Path $Datei -Algorithm SHA256).Hash.ToLower()
    if ($ist -ne $Erwartet) {
        Fehler "Pruefsumme von $(Split-Path -Leaf $Datei) stimmt nicht.`n      erwartet: $Erwartet`n      erhalten: $ist`n      Die Datei wurde NICHT installiert."
    }
}

Set-Location $Wurzel
Write-Host "Serververzeichnis: $Wurzel"

# --- 1 ---------------------------------------------------------------------
Schritt 1 "open.mp-Server holen ($OmpVersion)"
$ompZip = Join-Path $Tmp "omp.zip"
Invoke-WebRequest -Uri $OmpUrl -OutFile $ompZip -UseBasicParsing
Pruefe-Sha $ompZip $OmpSha; Ok "Pruefsumme stimmt"
$ompOut = Join-Path $Tmp "omp"
Expand-Archive -Path $ompZip -DestinationPath $ompOut -Force
$quelle = Join-Path $ompOut "Server"
if (-not (Test-Path $quelle)) { Fehler "Unerwarteter Archivaufbau" }
Copy-Item (Join-Path $quelle "omp-server.exe") -Destination $Wurzel -Force
New-Item -ItemType Directory -Path (Join-Path $Wurzel "components") -Force | Out-Null
# .pdb sind Debugdateien und werden nicht gebraucht
Get-ChildItem (Join-Path $quelle "components") -Filter *.dll |
    Copy-Item -Destination (Join-Path $Wurzel "components") -Force
$n = (Get-ChildItem (Join-Path $Wurzel "components") -Filter *.dll).Count
Ok "omp-server.exe und $n Komponenten installiert"
# Der Pawn-Compiler aus derselben Veroeffentlichung. Der in pawno\ ist
# 3.2.3664 von 2011 und kann die open.mp-Includes nicht uebersetzen:
# _open_mp.inc benutzt #pragma warning, das kennt erst 3.10.
$qawno = Join-Path $Wurzel "qawno"
New-Item -ItemType Directory -Path $qawno -Force | Out-Null
Copy-Item (Join-Path $quelle "qawno\pawncc.exe") -Destination $qawno -Force
Copy-Item (Join-Path $quelle "qawno\pawnc.dll")  -Destination $qawno -Force
Ok "qawno\pawncc.exe installiert (3.10.11)"

# --- 2 ---------------------------------------------------------------------
Schritt 2 "Voice-Plugin holen ($SvVersion)"
$svZip = Join-Path $Tmp "sv.zip"
Invoke-WebRequest -Uri $SvUrl -OutFile $svZip -UseBasicParsing
Pruefe-Sha $svZip $SvSha; Ok "Pruefsumme stimmt"
$svOut = Join-Path $Tmp "sv"
Expand-Archive -Path $svZip -DestinationPath $svOut -Force
Copy-Item (Join-Path $svOut "sampvoice.dll") -Destination (Join-Path $Wurzel "components") -Force
Ok "components\sampvoice.dll installiert"
Ok "sampvoice ist eine open.mp-KOMPONENTE, kein Legacy-Plugin -"
Ok "es gehoert nach components\ und NICHT in legacy_plugins."

# --- 3 ---------------------------------------------------------------------
Schritt 3 "Konfiguration pruefen"
$cfg = Join-Path $Wurzel "config.json"
if (-not (Test-Path $cfg)) {
    Copy-Item (Join-Path $Wurzel "config.json.example") -Destination $cfg
    Warnung "config.json aus der Vorlage angelegt."
    Warnung "RCON-Passwort und MySQL-Zugang MUESSEN noch eingetragen werden."
} else { Ok "config.json vorhanden" }

$cfgRoh = (Get-Content $cfg -Raw) -replace "`r?`n", ""
if ($cfgRoh -match '"legacy_plugins"\s*:\s*\[([^\]]*)\]' -and $Matches[1] -match 'sampvoice') {
    Fehler @'
sampvoice steht in legacy_plugins in der config.json.
      Das ist falsch: sampvoice ist eine KOMPONENTE, kein Plugin. Der Server
      ueberspringt es dort und alle Sv*-Befehle im Script schlagen fehl.
      Bitte den Eintrag "sampvoice" aus legacy_plugins entfernen.
'@
} else {
    Ok "legacy_plugins ist korrekt (ohne sampvoice)"
}
if ($cfgRoh -match '"sampvoice"\s*:\s*\{[^}]*"port"\s*:\s*[1-9]') {
    Ok "sampvoice.port ist fest gesetzt"
} else {
    Warnung 'In config.json fehlt ein fester Voiceport. Ohne ihn sucht sich'
    Warnung 'sampvoice bei JEDEM Start einen zufaelligen Port - der laesst sich'
    Warnung 'in keiner Firewall freigeben. Bitte ergaenzen:'
    Warnung '    "sampvoice": { "port": 7778, "threads": 2, "updaterate": 10 },'
}
if (Test-Path (Join-Path $Wurzel "server.cfg")) {
    Warnung "Eine server.cfg liegt hier. open.mp liest sie NACH config.json und"
    Warnung "ueberschreibt deren Werte stillschweigend. Bitte umbenennen."
}

# --- 4 ---------------------------------------------------------------------
Schritt 4 "Gamemode uebersetzen"
# NICHT pawno\pawncc.exe verwenden - das ist 3.2.3664 und scheitert an den
# open.mp-Includes. Nur der aus der open.mp-Veroeffentlichung taugt.
$pawncc = Join-Path $Wurzel "qawno\pawncc.exe"
if (-not (Test-Path $pawncc)) { Fehler "qawno\pawncc.exe fehlt - Schritt 1 ist nicht durchgelaufen." }
$inc1 = Join-Path $Wurzel "pawno\include"
$inc2 = Join-Path $Wurzel "pawno\include\Gloabe Includes"
$aus  = Join-Path $Wurzel "gamemodes\script.amx"
$log  = Join-Path $Wurzel "uebersetzen.log"
Remove-Item $aus -EA SilentlyContinue
# Volle Ausgabe in die Datei, auf den Bildschirm nur Fehler und eine
# Zusammenfassung. Warnungen werden nicht unterdrueckt, nur gebuendelt.
& $pawncc (Join-Path $Wurzel "gamemodes\script.pwn") "-i$inc1" "-i$inc2" "-o$aus" 2>&1 |
    Out-File -FilePath $log -Encoding utf8
$zeilen  = Get-Content $log -EA SilentlyContinue
$fehler  = @($zeilen | Where-Object { $_ -match ": (fatal )?error \d+" })
if ($fehler.Count -gt 0) {
    $fehler | Select-Object -First 20 | ForEach-Object { Write-Host "      $_" }
    Fehler "Uebersetzen fehlgeschlagen. Volle Ausgabe: uebersetzen.log"
}
if (-not (Test-Path $aus) -or (Get-Item $aus).Length -eq 0) {
    Fehler "Keine script.amx erzeugt. Siehe uebersetzen.log"
}
$warn = @($zeilen | Where-Object { $_ -match ": warning \d+" }).Count
Ok "gamemodes\script.amx ($((Get-Item $aus).Length) Bytes), 0 Fehler"
if ($warn -gt 0) {
    Warnung "$warn Warnungen - Bestand, kein Hindernis. Nachlesen: uebersetzen.log"
}

# --- 5 ---------------------------------------------------------------------
Schritt 5 "Datenbank"
Warnung "Wird NICHT automatisch eingespielt. Reihenfolge:"
Write-Host "         mysql -u USER -p DATENBANK < Datenbank\samp_server.sql"
Write-Host "         mysql -u USER -p DATENBANK < gamemodes\modules\anticheat\ac_log.sql"
Write-Host "         mysql -u USER -p DATENBANK < gamemodes\modules\voice\voice_mutes.sql"

# --- 6 ---------------------------------------------------------------------
Schritt 6 "Fertig"
Write-Host @"
      Starten mit:
          .\omp-server.exe

      Die Spieler brauchen zusaetzlich den sampvoice-CLIENT, sonst hoert
      und spricht niemand. Ohne Client laeuft der Server normal weiter -
      das Voice-Modul faengt das ab.
"@
Remove-Item -Recurse -Force $Tmp -EA SilentlyContinue
