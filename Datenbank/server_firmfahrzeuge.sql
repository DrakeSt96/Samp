--
-- Fehlende Tabelle server_firmfahrzeuge
--
-- script.pwn:11116 liest sie beim Start, Datenbank/samp_server.sql legt sie
-- nicht an. Ohne sie meldet der Server bei jedem Start:
--
--   MySQL-Fehler 1146 | Table 'DATENBANK.server_firmfahrzeuge' doesn't exist
--   [debug] Run time error 4: "Array index out of bounds" in sql_array2
--
-- und die Firmen werden nicht geladen.
--
-- Der Name ist irrefuehrend: die Tabelle enthaelt keine Fahrzeuge, sondern
-- die Firmen selbst. Die Fahrzeuge stehen in server_ffahrzeuge, die
-- Organisationen in server_firmen - drei verschiedene Dinge mit aehnlichen
-- Namen.
--
-- Die Spalten entsprechen enum FirmenSystemInfo (script.pwn:~2260) und dem
-- Ladeblock in sql_array2 unter case _SQL_FIRMEN_LOAD (script.pwn:~80796).
-- FirmaCreatet steht nicht in der Tabelle: der Ladecode setzt es fuer jede
-- gelesene Zeile selbst auf 1.
--
-- Einspielen als root:
--   mariadb DATENBANK < Datenbank/server_firmfahrzeuge.sql
--

CREATE TABLE IF NOT EXISTS `server_firmfahrzeuge` (
  `id`              int(11)     NOT NULL AUTO_INCREMENT,
  `FirmaAGesperrt`  int(11)     NOT NULL DEFAULT 0,
  `FirmaPGesperrt`  int(11)     NOT NULL DEFAULT 0,
  `FirmaStatus`     int(11)     NOT NULL DEFAULT 0,
  `FirmaGTyp`       int(11)     NOT NULL DEFAULT 0,
  `FirmaTyp`        int(11)     NOT NULL DEFAULT 0,
  `FirmaName`       varchar(32) NOT NULL DEFAULT '',
  `FirmaOwner`      varchar(24) NOT NULL DEFAULT '',
  `FirmaKasse`      int(11)     NOT NULL DEFAULT 0,
  `FirmaAktienMax`  int(11)     NOT NULL DEFAULT 0,
  `FirmaAktionVerf` int(11)     NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- ACHTUNG, Obergrenze: der Ladecode schreibt Zeile f nach Firma[f+1], und
-- Firma ist mit MAX_FIRMEN = 25 angelegt (gueltige Plaetze 0 bis 24). Ab der
-- 25. Zeile schreibt er ueber das Array hinaus. Die Tabelle darf deshalb
-- hoechstens 24 Zeilen enthalten.
--
