# Umstieg auf open.mp

Das Gamemode ist auf open.mp portiert. Diese Datei beschreibt, was dafür geändert
wurde und was du noch tun musst, damit der Server läuft.

Der Stand kompiliert fehlerfrei (Pawn 3.10.10, 0 Fehler, 1168 Warnungen — alle
geprüft und folgenlos, siehe unten).

---

## 1. Was du herunterladen musst

Ohne diese drei Dateien startet der Server nicht oder verhält sich falsch.
**Alle Binärdateien müssen 32-Bit (x86) sein** — die Plugins sind es.

| Was | Woher | Wohin | Pflicht |
|---|---|---|---|
| open.mp-Server | [Releases](https://github.com/openmultiplayer/open.mp/releases) — `open.mp-linux-x86.tar.gz` bzw. `open.mp-win-x86.zip` | Serverwurzel | ja |
| Streamer **2.9.6** | [Release v2.9.6](https://github.com/samp-incognito/samp-streamer-plugin/releases/tag/v2.9.6) | `plugins/streamer.so` bzw. `.dll` | **ja** |
| CrashDetect 4.22 | [open.mp-Fork](https://github.com/AmyrAhmady/samp-plugin-crashdetect/releases/tag/v4.22) | `plugins/crashdetect.so` bzw. `.dll` | empfohlen |

**Der Streamer ist Pflicht.** Im Repository lag Version 2.6.1, das Gamemode wird
jetzt gegen den 2.9.6-Include kompiliert. Bei den Erzeugungsfunktionen kamen
Parameter dazu; mit dem alten Plugin würden alle 4.644 `CreateDynamicObject`-,
185 `CreateDynamic3DTextLabel`- und 173 `CreateDynamicPickup`-Aufrufe abgewiesen.
Die alte Datei wirklich **ersetzen**, nicht danebenlegen.

Bereits erledigt: `plugins/mysql.so` war gegen `libmysqlclient_r.so.16`
(MySQL-5.1-Ära) gelinkt und hätte auf keinem aktuellen Linux geladen. Sie wurde
durch die statisch gelinkte Fassung ersetzt (die alte liegt als
`mysql.so.dynamisch-alt` daneben). Unter Windows bleibt `mysql.dll` richtig;
dort wird zusätzlich das Microsoft VC++ Redistributable (x86) gebraucht.

---

## 2. Konfiguration

open.mp nutzt `config.json` statt `server.cfg`.

```
cp config.json.example config.json
```

Danach in `config.json` das RCON-Passwort eintragen. Die Datei ist per
`.gitignore` ausgeschlossen, weil sie dieses Passwort enthält.

Drei Fallstricke:

- **Eine vorhandene `server.cfg` gewinnt.** open.mp liest sie *nach* der
  `config.json` und überschreibt deren Werte stillschweigend. Die alte Datei
  wurde deshalb zu `server.cfg.samp-alt` umbenannt. Lass sie umbenannt.
- **Die Typen sind streng.** `1000` und `1000.0` sind nicht dasselbe. Ein
  falscher Typ wird kommentarlos auf den Standardwert zurückgesetzt, ein
  Syntaxfehler verwirft die ganze Datei zugunsten der Werkseinstellungen.
- **Die Datei muss UTF-8 sein.** Der Servername enthält Sonderzeichen.

Bewusst abweichend vom alten Stand gesetzt: `rcon.enable` steht auf `false`
(das ist die Fernsteuerung über das Netz, nicht `/rcon login` im Spiel), und
`artwork.enable` auf `false` — sonst startet open.mp zusätzlich einen
HTTP-Server, den SA-MP nie hatte.

---

## 3. Kompilieren

Die open.mp-Includes liegen bereits in `pawno/include/Gloabe Includes/`.
Die früheren SA-MP-Includes wurden nach `_samp_alt/` verschoben, falls du
nochmal vergleichen willst.

Im Compiler (Qawno oder Pawno) müssen beide Include-Verzeichnisse eingetragen
sein: `pawno/include` und `pawno/include/Gloabe Includes`.

Auf der Kommandozeile:

```
pawncc gamemodes/script.pwn -i"pawno/include" -i"pawno/include/Gloabe Includes"
```

Für die Umstellungsphase empfiehlt sich `-d3`: dann liefert CrashDetect bei
Abstürzen Zeilennummern. Für den Dauerbetrieb wieder ohne — CrashDetect kostet
spürbar Leistung und ist laut eigenem README für Live-Server nicht gedacht.

---

## 4. Was am Gamemode geändert wurde

**Callback-Signaturen.** Acht Callbacks haben in open.mp typisierte Parameter
(`WEAPON:`, `PLAYER_STATE:`, `KEY:`, `BULLET_HIT_TYPE:`, `CLICK_SOURCE:`,
`EDIT_RESPONSE:`). `OnPlayerGiveDamage` hat zusätzlich einen `bodypart`-Parameter
bekommen.

**Funktionen, die open.mp inzwischen selbst mitbringt.** Die Deklarationen von
`gpci` und `IsValidVehicle` im Gamemode entfallen. Drei eigene Implementierungen
(`GetVehicleDriver`, `RemovePlayerWeapon`, `GetWeaponSlot`) kollidierten mit
neuen nativen Funktionen; sie heißen jetzt `Script_*` und arbeiten unverändert
weiter. Das war die konservative Wahl: `GetWeaponSlot` dient im Gamemode als
Array-Index für den Waffenschrank, und dort muss die alte Slot-Zuordnung gelten.

**Amerikanische Schreibweisen.** 267 Aufrufe wie `TextDrawColor` heißen in
open.mp `TextDrawColour`. Umgestellt statt per `#define` stummgeschaltet.

**Zahlen zu benannten Konstanten.** 378 Stellen, an denen rohe Zahlen an
typisierte Parameter gingen: `TextDrawFont(td, 1)` ist jetzt
`TextDrawFont(td, TEXT_DRAW_FONT_1)`, `SetPlayerRaceCheckpoint(p, 0, …)` ist
`CP_TYPE_GROUND_NORMAL`, und so weiter.

**Wahrheitswerte.** 1.062 Stellen, an denen `0`/`1` an `bool:`-Parameter ging,
nutzen jetzt `false`/`true` — betrifft vor allem `TogglePlayerControllable`,
`ApplyAnimation` und die Timer.

---

## 5. Fehler, die beim Portieren aufgefallen sind

Diese waren schon vorher da und sind jetzt behoben:

- **Kampfstil „Elbow" wurde nie angezeigt.** Zwei `switch`-Blöcke prüften
  `case 26`, der richtige Wert ist 16. Der Zweig konnte nie greifen. In einem
  der Blöcke fehlte zusätzlich der `default`-Fall, sodass die Variable bei
  unbekanntem Stil uninitialisiert blieb.
- **19 `format()`-Aufrufe mit zu wenigen Argumenten.** Unter SA-MP kam
  Speichermüll heraus, unter open.mp bricht die Formatierung ab und liefert
  einen **leeren String**. Betroffen waren unter anderem die Meldung beim
  Verlassen einer Firma oder Partei, die Automatenlisten und die
  Drogenabnahme. Teils fehlte ein Argument, teils war ein Prozentzeichen als
  Text gemeint und hätte `%%` heißen müssen.
- **Eigenes `#define SPECIAL_ACTION_PISSING`** verdeckte die typisierte
  open.mp-Konstante. Entfernt.

---

## 6. Verhaltensunterschiede, die du kennen solltest

**Dialogtexte über 8192 Zeichen.** open.mp verwirft solche Texte komplett,
SA-MP reichte sie durch und der Client schnitt ab. Das Gamemode befüllt bei der
Unternehmens- und der Bankautomatenliste Puffer bis 9.500 Zeichen. Der
Dialog-Wrapper `SPD_Safe` kappt jetzt bei 4.000 Zeichen — das liegt sicher unter
dem clientseitigen Limit von 4.096. Ohne diese Kappung kämen die Dialoge unter
open.mp **leer** an.

**Bullbar-Tuning.** open.mp hat zwei neue Tuning-Slots (14 = Front-Bullbar,
15 = Rear-Bullbar); in SA-MP lagen diese Teile auf den Stoßstangen-Slots 10
und 11. Das Speichersystem kannte nur 0–13 und hätte sie stillschweigend
verworfen. Sie werden jetzt auf die Stoßstangen-Felder gelegt — das entspricht
dem bisherigen SA-MP-Verhalten. Wer Bullbar und Stoßstange getrennt speichern
will, braucht zwei zusätzliche Datenbankspalten.

**HDD-Bans.** `gpci` berechnet in open.mp nach demselben Verfahren, gibt aber
die Stringlänge zurück statt 1/0 (wird im Gamemode nirgends ausgewertet) und
formatiert möglicherweise anders. Ob die vorhandenen Einträge in
`server_hddbans` weiter greifen, lässt sich nur am laufenden Server prüfen:
einen Testspieler verbinden lassen und `/gethdd` mit den Altdaten vergleichen.
Falls die Schreibweise abweicht, einmalig angleichen:
```sql
UPDATE server_hddbans SET GPCI = UPPER(TRIM(LEADING '0' FROM GPCI));
```

**Kick und Ban** wirken verzögert: die Verbindung ist sofort tot, aber
`OnPlayerDisconnect` kommt erst im nächsten Servertick.

**NPCs** funktionieren weiter. `ConnectNPC` gilt als veraltet, wird aber
unterstützt. Nötig sind die `samp-npc`-Binärdatei und `max_bots` ≥ 7 (steht in
der Konfiguration auf 10).

---

## 7. MySQL — wichtig

**Das MySQL-Plugin darf nicht auf R40 oder neuer aktualisiert werden.**

Das Gamemode nutzt die R39-API an rund 660 Stellen. Ab R40 heißen die Funktionen
anders und `mysql_connect` hat Datenbank und Passwort **vertauscht** — ein
Upgrade würde stillschweigend die falsche Datenbank ansprechen.

Sicher ist ein Wechsel auf **R39-6** (gleiche Funktionsliste, nur Fehlerbehebungen):
[Release R39-6](https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R39-6).
Das vorhandene `a_mysql.inc` kann dabei unverändert bleiben.

---

## 8. Zu den verbleibenden Warnungen

1.168 Warnungen klingt viel, ist aber weniger als vorher unter SA-MP (2.800).
open.mp hat const-korrekte Funktionen, wodurch allein 1.652 Meldungen wegfallen.

- **1.045 × Warnung 239** (Textliteral an nicht-`const`-Parameter): stammen aus
  gamemode-eigenen Hilfsfunktionen, waren schon unter SA-MP da, folgenlos.
- **99 × Warnung 213** (Typ-Mismatch): neu unter open.mp. Alle 75 Fundstellen
  wurden einzeln gegen beide Include-Sätze geprüft — kein einziger Wert weicht
  ab, keine Parameterreihenfolge ist vertauscht. Rein kosmetisch.
- Der Rest (22 × 214, je 1–2 × 218/208/237) ist ebenfalls folgenlos.

Eine Blindstelle bleibt: Pawn prüft Typen in `switch`/`case` **nicht**. Der
Elbow-Fehler oben stammt genau daher. Alle `switch`-Blöcke über typisierte
open.mp-Rückgabewerte wurden deshalb von Hand durchgesehen; außer diesem einen
war nichts zu finden.

---

## 9. Vor dem ersten Livebetrieb

1. Server mit `-d3` kompiliert starten und das Log auf
   `String formatted incorrectly` prüfen — das meldet open.mp bei fehlerhaften
   `format()`-Aufrufen selbst.
2. Registrierung, Login und Admindienst durchspielen.
3. Die langen Dialoge öffnen (Unternehmensliste, Bankautomatenliste) und prüfen,
   ob Inhalt ankommt.
4. Ein Fahrzeug tunen, Server neu starten, Tuning prüfen.
5. `/gethdd` gegen die Einträge in `server_hddbans` vergleichen.

Ein Laufzeittest war hier nicht möglich — der Server ist eine Windows-Binärdatei,
in dieser Umgebung ließ sich nur kompilieren. Alle Aussagen stützen sich auf
Quelltext, Compiler und den open.mp-Serverquellcode.
