-- ---------------------------------------------------------------------
-- Migration: breitere Passwort-Spalte fuer laengere Salts
-- ---------------------------------------------------------------------
-- Hintergrund
--   Passwoerter werden seit dem Sicherheitsfix als <Salt><MD5> gespeichert.
--   Der MD5 belegt davon fest 32 Zeichen. Die Spalte spieler.Passwort ist
--   34 Zeichen breit, es bleiben also nur 2 Zeichen fuer den Salt.
--   Das genuegt, um identische Passwoerter unterscheidbar zu machen und
--   fertige Rainbow-Tables zu entwerten, ist aber knapp bemessen.
--
-- Wirkung
--   Nach diesem ALTER TABLE passen 32 Zeichen Salt in die Spalte.
--
-- Reihenfolge - bitte genau einhalten
--   1. Datenbank sichern.
--   2. Dieses Skript einspielen.
--   3. ERST DANACH in gamemodes/config.inc die beiden Zeilen
--        #define SCRIPT_PW_COLLEN  (64)
--        #define SCRIPT_PW_SALTLEN (32)
--      einkommentieren und das Gamemode neu kompilieren.
--
--   Wird Schritt 3 vor Schritt 2 ausgefuehrt, schneidet MySQL den Hash
--   beim Speichern ab und neu gesetzte Passwoerter funktionieren nicht
--   mehr. Umgekehrt ist die Reihenfolge gefahrlos.
--
-- Bestandsaccounts
--   Bleiben unveraendert gueltig. Alte Eintraege (genau 32 Zeichen, ohne
--   Salt) werden beim naechsten erfolgreichen Login automatisch auf das
--   neue Format umgeschrieben. Es wird niemand ausgesperrt.
-- ---------------------------------------------------------------------

ALTER TABLE `spieler` MODIFY `Passwort` varchar(64) NOT NULL;

-- Kontrolle: zeigt, wie viele Accounts noch im alten Format liegen.
-- Die Zahl sinkt von selbst, sobald sich die Spieler wieder anmelden.
SELECT
    SUM(CHAR_LENGTH(Passwort) = 32) AS altes_format,
    SUM(CHAR_LENGTH(Passwort) > 32) AS neues_format,
    COUNT(*)                        AS gesamt
FROM `spieler`;
