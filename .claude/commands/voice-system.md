---
description: Baut das Voice- und Funksystem (sampvoice) für den open.mp Gamemode in autonomen Phasen
---

# Voice- & Funksystem für open.mp

Du baust ein vollständiges Voice-Chat-System in diesen Gamemode: Proximity-Sprache plus Funk für Fraktionen, Organisationen und Clans. Ziel sind über 200 Slots, das MySQL-Fraktionssystem existiert bereits.

---

## Ablauf über mehrere Sessions

**Als Allererstes:** Lies `VOICE_PROGRESS.md` im Repo-Root.

- Datei existiert nicht → du bist in **Phase 0**, lege sie an.
- Datei existiert → sie sagt dir, welche Phase abgeschlossen ist und was ansteht.

Arbeite **genau eine Phase pro Session**. Nicht vorgreifen, nicht zwei Phasen in einem Rutsch.

Am Ende jeder Session aktualisierst du `VOICE_PROGRESS.md` mit:
- abgeschlossene Phase und Datum
- angelegte/geänderte Dateien mit einem Satz, was drin ist
- getroffene Architektur-Entscheidungen und die Begründung
- offene Punkte und alles, was der nächsten Session sonst fehlt
- **explizit:** was ein Mensch testen muss, bevor es weitergeht

Diese Datei ist dein einziges Gedächtnis zwischen Sessions. Schreib sie so, dass jemand ohne Kontext die nächste Phase starten kann.

---

## Autonomie-Regeln

**Du darfst ohne Rückfrage:**
- Dateien anlegen, ändern, löschen
- Branch anlegen (`feature/voice-phaseN`), committen, pushen
- Pull Request öffnen
- Den Gamemode kompilieren und Compilerfehler selbst beheben
- Bestehenden Code lesen, so viel du brauchst

**Du darfst NICHT ohne Rückfrage:**
- In `main`/`master` mergen
- Force-Push, History umschreiben, fremde Branches anfassen
- Irgendetwas an der Produktionsdatenbank ausführen
- Die Logik des bestehenden Fraktions- oder Clansystems verändern — du liest es aus, du baust es nicht um
- Neue Dependencies oder Plugins hinzufügen
- Bestehende Includes ersetzen oder Versionen hochziehen

**Bei Blockern:** Wenn dir etwas fehlt, das du dir nicht selbst erschließen kannst, rate nicht. Schreib den Blocker nach `VOICE_PROGRESS.md` unter `## Blocker`, arbeite so weit wie möglich drumherum weiter, und nenn ihn im Abschlussbericht der Session zuerst.

---

## Harte Architektur-Regeln

Diese gelten in jeder Phase und sind nicht verhandelbar.

1. **Rate keine Natives.** Lies die tatsächliche Include-Datei des Voice-Plugins (`sampvoice.inc` o.ä.) und benutze ausschließlich Natives, die dort wirklich stehen — mit der dort dokumentierten Signatur. Wenn eine Funktion, die du brauchst, nicht existiert, bau sie aus vorhandenen Natives, statt einen plausibel klingenden Namen zu erfinden.

2. **Streams einmalig anlegen.** Kanal-Streams werden bei `OnGameModeInit` erzeugt, danach werden Spieler nur noch attached und detached. Niemals einen Stream pro Spieler pro Kanal erzeugen — das rennt bei 200 Slots in die Stream-Limits des Plugins.

3. **Jeder erzeugte Stream braucht einen definierten Zerstörungspfad.** Kein Stream ohne zugehöriges Cleanup.

4. **Vollständiges Lifecycle-Cleanup.** Detach und Aufräumen mindestens bei: Disconnect, Tod, Fraktionswechsel, Clanwechsel, Rangänderung, Entlassung, Kick, Ban, Gamemode-Exit. Ein Spieler, der die Fraktion verlässt, darf keinen Funkkanal mehr hören.

5. **Keine Magic Numbers.** Alle Distanzen, Bitraten, Kanal-Limits, Cooldowns und Tastenbelegungen in eine zentrale Config-Datei (`voice_config.inc`). Ein Wert, eine Stelle.

6. **Jedes DB-Ergebnis wird geprüft.** `cache_num_rows` vor jedem Zugriff. Keine Annahme, dass eine Query etwas zurückgibt.

7. **Voice-Code lebt in eigenen Dateien.** Neuer Ordner `modules/voice/` oder passend zur bestehenden Struktur des Repos. Eingriffe in bestehende Dateien nur dort, wo Hooks nötig sind, und dann minimal.

8. **Deutsche Spielertexte, englische Bezeichner.** Variablen, Funktionen und Kommentare auf Englisch, alles was der Spieler liest auf Deutsch.

9. **Kompilieren vor jedem Commit.** Bricht der Compiler, wird nicht committet.

---

## Phasen

### Phase 0 — Recon, kein Code

Du schreibst in dieser Phase **keine Zeile Produktivcode**. Du erkundest.

Finde heraus und dokumentiere in `VOICE_PROGRESS.md`:
- Verzeichnisstruktur, wo liegen Includes, wo Module, wie wird kompiliert
- Welcher MySQL-Wrapper wird benutzt, welche Version, wie sehen bestehende Queries aus
- **Exaktes Schema**: Tabellen und Spalten für Fraktionen, Organisationen, Clans, Ränge, Mitgliedschaften. Spaltennamen wörtlich abschreiben, nicht sinngemäß.
- Wie wird Fraktions- und Clanzugehörigkeit zur Laufzeit im Speicher gehalten? Gibt es ein `PlayerInfo`-Enum oder ähnliches?
- Ist das Voice-Plugin schon installiert? Wenn ja, welche Version, welche Include-Datei, welche Natives stehen zur Verfügung?
- Bestehendes Tastatur-Handling: wie werden Keys abgefragt, welche sind schon belegt?
- Bestehendes Textdraw- oder UI-System, das ich für die "spricht gerade"-Anzeige mitbenutzen kann
- Wie werden Admin-Rechte geprüft?

Danach schreibst du einen Umsetzungsplan für Phase 1 bis 3 in `VOICE_PROGRESS.md`, der sich an dem orientiert, was du wirklich vorgefunden hast — nicht an dem, was üblich wäre.

**Session endet hier.** Bericht ausgeben, nichts weiter.

---

### Phase 1 — Kern: Proximity

- Zentrale Stream-Verwaltung mit sauberem Lifecycle
- Per-Player-State für Voice (aktiver Kanal, Mute-Status, spricht gerade)
- Proximity mit drei Distanzstufen: Flüstern, Normal, Rufen — umschaltbar per Befehl oder Taste
- Push-to-Talk für Proximity
- Vollständiges Cleanup nach Regel 4
- `voice_config.inc` mit allen Werten
- Bitrate auf 16–24 kbps, nicht höher. Bei 200 Slots ist der Upstream der Flaschenhals, nicht die Klangqualität.

**Definition of Done:** Kompiliert sauber, Streams werden nachweislich wieder abgebaut, keine Magic Numbers, keine erfundenen Natives.

---

### Phase 2 — Funk

- Kanal-Abstraktion, die auf die **bestehenden** Fraktions-, Organisations- und Clan-IDs aus der DB mappt. Keine Parallelverwaltung.
- Rechte nach Rang: wer darf mithören, wer darf senden, wer darf auf mehreren Kanälen gleichzeitig sein
- **Halbduplex:** pro Kanal spricht genau einer. Wer reindrückt, während belegt ist, bekommt ein "Kanal belegt"-Signal. Das deckelt den Fan-out und ist das realistischere RP.
- Getrennte PTT-Taste für Funk, Funk hat Priorität über Proximity
- Mehrere Kanäle gleichzeitig hören, aktiver Sendekanal umschaltbar
- Frequenzsystem, falls das bestehende Script so etwas schon kennt — sonst kanalbasiert
- Harte Zuhörer-Obergrenze pro Kanal, konfigurierbar, Ausnahme nur für Admin-Durchsagen
- Live-Reaktion auf Änderungen im Fraktions-/Clansystem: Beförderung, Entlassung, Wechsel greifen sofort

**Definition of Done:** Kompiliert, Rechteprüfung greift bei jedem Sendeversuch, Halbduplex-Sperre funktioniert, DB-Änderungen wirken ohne Relog.

---

### Phase 3 — Admin, Missbrauchsschutz, UX

- Mute-System auf drei Ebenen: global durch Admin, kanalbezogen, persönliches Ignorieren einzelner Spieler
- Admin-Befehle: mute, unmute, Kanal abhören, Kanal sperren, serverweite Durchsage
- Anti-Spam: Cooldown pro Spieler, Rate-Limit auf Kanalwechsel, Schutz gegen Dauer-PTT
- Textdraw oder Chatanzeige, wer gerade spricht und auf welchem Kanal
- Logging aller Admin-Voice-Aktionen in die bestehende Logstruktur
- Persistenz der Mutes in der DB
- README für das Voice-Modul: alle Befehle, alle Config-Werte, Installationsschritte für den Client

**Definition of Done:** Kompiliert, Mutes überleben Relog, Admin-Aktionen sind geloggt, README ist vollständig.

---

### Phase 4 — optional, nur auf Zuruf

Lasttest-Harness und Bandbreiten-Messung. Nur starten, wenn ausdrücklich verlangt.

---

## Was du nicht verifizieren kannst

Sei darüber im Abschlussbericht jeder Session ehrlich.

Du kannst prüfen: dass es kompiliert, dass die Logik konsistent ist, dass Streams sauber auf- und abgebaut werden, dass Rechteprüfungen an jeder Stelle sitzen, dass DB-Zugriffe abgesichert sind.

Du kannst **nicht** prüfen: ob tatsächlich jemand etwas hört, ob die Distanzstufen sich im Spiel richtig anfühlen, ob es Echo, Jitter oder Aussetzer gibt, ob die Latenz erträglich ist, ob die Lautstärkeabstufung stimmt.

Schreib deshalb ans Ende jeder Session eine konkrete Testliste für einen Menschen: welche zwei bis drei Personen, an welcher Position, welche Taste, was sie hören müssten. Keine allgemeinen Hinweise, sondern durchführbare Schritte.

---

## Abschlussbericht jeder Session

1. Blocker zuerst, falls vorhanden
2. Was gebaut wurde, in drei bis fünf Sätzen
3. Geänderte Dateien
4. Getroffene Entscheidungen, die vom Plan abweichen, mit Begründung
5. Konkrete Testliste für den Menschen
6. Was Phase N+1 als Erstes tun sollte
