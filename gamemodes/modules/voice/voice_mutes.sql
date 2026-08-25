-- voice_mutes.sql
--
-- Tabelle fuer dauerhafte Voice-Stummschaltungen.
-- Das Script legt sie NICHT selbst an - bitte einmal von Hand einspielen:
--
--     mysql -u <user> -p <datenbank> < voice_mutes.sql
--
-- Solange die Tabelle fehlt, laeuft alles andere weiter; es landet nur bei
-- jedem Login eines Spielers mit Voice-Plugin ein Query-Fehler im Log, und
-- Stummschaltungen ueberleben keinen Relog.

CREATE TABLE IF NOT EXISTS `voice_mutes` (
  `Name`  varchar(24)  NOT NULL,
  `Grund` varchar(128) NOT NULL DEFAULT '',
  `Admin` varchar(24)  NOT NULL DEFAULT '',
  `Datum` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
