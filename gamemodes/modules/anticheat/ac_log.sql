-- ac_log.sql
--
-- Tabelle fuer die Anti-Cheat-Meldungen. Das Script legt sie NICHT selbst an,
-- bitte einmal von Hand einspielen:
--
--     mysql -u <user> -p <datenbank> < ac_log.sql
--
-- Solange sie fehlt, laeuft alles unveraendert weiter - es landet nur bei
-- jeder Erkennung ein Query-Fehler im Log, und /acstats bleibt leer.

CREATE TABLE IF NOT EXISTS `ac_log` (
  `id`      int(11)      NOT NULL AUTO_INCREMENT,
  `Name`    varchar(24)  NOT NULL DEFAULT '',
  `IP`      varchar(45)  NOT NULL DEFAULT '',
  `Serial`  varchar(64)  NOT NULL DEFAULT '',
  `Client`  varchar(16)  NOT NULL DEFAULT '',
  `Version` varchar(32)  NOT NULL DEFAULT '',
  `Grund`   varchar(48)  NOT NULL DEFAULT '',
  `Detail`  varchar(128) NOT NULL DEFAULT '',
  `Gebannt` tinyint(1)   NOT NULL DEFAULT 0,
  `PosX`    float        NOT NULL DEFAULT 0,
  `PosY`    float        NOT NULL DEFAULT 0,
  `PosZ`    float        NOT NULL DEFAULT 0,
  `Ping`    int(11)      NOT NULL DEFAULT 0,
  `Datum`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `Grund_Datum` (`Grund`,`Datum`),
  KEY `Name` (`Name`),
  KEY `Datum` (`Datum`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
