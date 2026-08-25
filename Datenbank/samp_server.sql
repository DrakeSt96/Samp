/*
Navicat MySQL Data Transfer

Source Server         : mysql
Source Server Version : 50505
Source Host           : localhost:3306
Source Database       : samp_server

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2017-01-11 21:58:29
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `regeln`
-- ----------------------------
DROP TABLE IF EXISTS `regeln`;
CREATE TABLE `regeln` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Kategorie` int(11) NOT NULL,
  `Titel` varchar(35) NOT NULL,
  `Inhalt` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of regeln
-- ----------------------------

-- ----------------------------
-- Table structure for `server_bans`
-- ----------------------------
DROP TABLE IF EXISTS `server_bans`;
CREATE TABLE `server_bans` (
  `IP` varchar(16) NOT NULL,
  `Grund` varchar(128) NOT NULL,
  `Name` varchar(24) NOT NULL,
  `Admin` varchar(24) NOT NULL,
  `Zeit` int(128) NOT NULL,
  `Uhrzeit` time NOT NULL,
  `Datum` date NOT NULL,
  PRIMARY KEY (`IP`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_bans
-- ----------------------------

-- ----------------------------
-- Table structure for `server_bizes`
-- ----------------------------
DROP TABLE IF EXISTS `server_bizes`;
CREATE TABLE `server_bizes` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `biz_Owned` int(2) NOT NULL,
  `biz_art` varchar(50) NOT NULL,
  `biz_preis` int(12) NOT NULL,
  `biz_level` int(12) NOT NULL,
  `biz_geldkasse` int(12) NOT NULL,
  `biz_locked` int(2) NOT NULL,
  `biz_besitzer` varchar(24) NOT NULL,
  `biz_teilhaber` varchar(24) NOT NULL,
  `biz_beschreibung` varchar(150) NOT NULL,
  `biz_artikel0` int(12) NOT NULL,
  `biz_artikel1` int(12) NOT NULL,
  `biz_artikel2` int(12) NOT NULL,
  `biz_artikel3` int(12) NOT NULL,
  `biz_artikel4` int(12) NOT NULL,
  `biz_artikel5` int(12) NOT NULL,
  `biz_artikel6` int(12) NOT NULL,
  `biz_artikel7` int(12) NOT NULL,
  `biz_artikel8` int(12) NOT NULL,
  `biz_artikel9` int(12) NOT NULL,
  `biz_artikel10` int(12) NOT NULL,
  `biz_artikel11` int(12) NOT NULL,
  `biz_artikel12` int(12) NOT NULL,
  `biz_artikel13` int(12) NOT NULL,
  `biz_artikel14` int(12) NOT NULL,
  `biz_x` float(10,4) NOT NULL,
  `biz_y` float(10,4) NOT NULL,
  `biz_z` float(10,4) NOT NULL,
  `biz_interior` int(4) NOT NULL,
  `rentbizvehiclemodelid` int(4) NOT NULL,
  `tPos0` float(10,4) NOT NULL,
  `tPos1` float(10,4) NOT NULL,
  `tPos2` float(10,4) NOT NULL,
  `tPos3` float(10,4) NOT NULL,
  `tPos4` float(10,4) NOT NULL,
  `tPos5` float(10,4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_bizes
-- ----------------------------
INSERT INTO `server_bizes` VALUES ('1', '0', '4', '462000', '6', '4492', '0', 'Niemand', 'Niemand', 'Sanandreas Straße', '6', '5', '7', '8', '10', '12', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1206.0743', '-914.1986', '43.3629', '3', '0', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000');
INSERT INTO `server_bizes` VALUES ('3', '1', '10', '1', '1', '601', '0', 'cryless', 'require', 'leckmich', '1000', '10000', '1000', '10000', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1580.6504', '-1149.3756', '23.8713', '0', '0', '1580.0381', '-1152.6486', '23.9062', '1577.2271', '-1155.3790', '23.9062');
INSERT INTO `server_bizes` VALUES ('2', '1', '10', '950000', '6', '3', '0', 'require', 'Niemand', 'Idlewood', '1', '1', '2', '3', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1928.9451', '-1776.3619', '13.5469', '0', '0', '1939.3035', '-1772.8678', '13.3828', '1944.2615', '-1772.5040', '13.3906');

-- ----------------------------
-- Table structure for `server_blitzer`
-- ----------------------------
DROP TABLE IF EXISTS `server_blitzer`;
CREATE TABLE `server_blitzer` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `sperreX` float(10,4) NOT NULL,
  `sperreY` float(10,4) NOT NULL,
  `sperreZ` float(10,4) NOT NULL,
  `BlitzerGeschwindigkeit` int(10) NOT NULL,
  `BlitzerOrt` varchar(128) NOT NULL,
  `HP` int(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_blitzer
-- ----------------------------
INSERT INTO `server_blitzer` VALUES ('7', '720.2401', '-1325.1697', '13.5391', '60', 'S.A.P.D Department', '100');
INSERT INTO `server_blitzer` VALUES ('8', '714.1896', '-1313.9647', '13.5391', '60', 'S.A.P.D Department', '100');

-- ----------------------------
-- Table structure for `server_bugmeldungen`
-- ----------------------------
DROP TABLE IF EXISTS `server_bugmeldungen`;
CREATE TABLE `server_bugmeldungen` (
  `id` int(100) NOT NULL AUTO_INCREMENT,
  `Writer` varchar(30) NOT NULL,
  `Text` varchar(256) NOT NULL,
  `Priorität` varchar(64) NOT NULL,
  `Tick` varchar(12) NOT NULL,
  `Uhrzeit` time NOT NULL,
  `Datum` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_bugmeldungen
-- ----------------------------
INSERT INTO `server_bugmeldungen` VALUES ('6', 'require', 'Farben für Polizei entfernen', 'Starker Fehler', 'NONE', '00:20:17', '2020-08-06');
INSERT INTO `server_bugmeldungen` VALUES ('8', 'require', 'Klingelton fixx musk', 'Schwerer Fehler', 'NONE', '00:20:17', '0000-00-00');
INSERT INTO `server_bugmeldungen` VALUES ('9', 'require', 'Fahrlerhrer', 'Schwerer Fehler', 'NONE', '00:20:17', '0000-00-00');

-- ----------------------------
-- Table structure for `server_drogen`
-- ----------------------------
DROP TABLE IF EXISTS `server_drogen`;
CREATE TABLE `server_drogen` (
  `pflanze` int(12) NOT NULL,
  `drgfraktid` int(3) NOT NULL,
  `drgArt` int(3) NOT NULL,
  `drgXpos` float(10,4) NOT NULL,
  `drgYpos` float(10,4) NOT NULL,
  `drgZpos` float(10,4) NOT NULL,
  `drginterior` int(5) NOT NULL,
  `drgvirtualworld` int(5) NOT NULL,
  `drgProduceDrugs` int(10) NOT NULL,
  `drgNextDrugsIn` int(128) NOT NULL,
  `drgWasserzustand` int(6) NOT NULL,
  `drgOwner` varchar(24) NOT NULL,
  PRIMARY KEY (`pflanze`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_drogen
-- ----------------------------

-- ----------------------------
-- Table structure for `server_ffahrzeuge`
-- ----------------------------
DROP TABLE IF EXISTS `server_ffahrzeuge`;
CREATE TABLE `server_ffahrzeuge` (
  `id` int(24) NOT NULL,
  `Fraktion` int(4) NOT NULL,
  `Rang` int(2) NOT NULL,
  `modelid` int(4) NOT NULL,
  `Farbe1` int(5) NOT NULL,
  `Farbe2` int(5) NOT NULL,
  `Paintjob` int(5) NOT NULL,
  `HP` float(10,4) NOT NULL,
  `posx` float(10,4) NOT NULL,
  `posy` float(10,4) NOT NULL,
  `posz` float(10,4) NOT NULL,
  `posa` float(10,4) NOT NULL,
  `Interior` int(3) NOT NULL,
  `VirtualWorld` int(6) NOT NULL,
  `Abgeschlossen` int(2) NOT NULL,
  `Abgeschleppt` int(2) NOT NULL,
  `AbgeschlepptPreis` int(8) NOT NULL,
  `AbgeschlepptGrund` varchar(128) NOT NULL,
  `Nummernschild` varchar(64) NOT NULL,
  `Neon` int(5) NOT NULL,
  `Spoiler` int(10) NOT NULL,
  `Hood` int(10) NOT NULL,
  `Roof` int(10) NOT NULL,
  `Sideskirt` int(10) NOT NULL,
  `Lamps` int(10) NOT NULL,
  `Nitro` int(10) NOT NULL,
  `Exhaust` int(10) NOT NULL,
  `Wheels` int(10) NOT NULL,
  `Stereo` int(10) NOT NULL,
  `Hydraulics` int(10) NOT NULL,
  `FrontBumper` int(10) NOT NULL,
  `RearBumper` int(10) NOT NULL,
  `VentRight` int(10) NOT NULL,
  `VentLeft` int(10) NOT NULL,
  `KaufPreis` int(10) NOT NULL,
  `FraktionsRang` int(10) NOT NULL,
  `Motorschaden` int(2) NOT NULL,
  `FailGas` int(2) NOT NULL,
  `Tank` float(10,4) NOT NULL,
  `Kilometerstand` int(64) NOT NULL,
  `KofferraumGanja` int(10) NOT NULL,
  `KofferraumKokain` int(10) NOT NULL,
  `KofferraumMaterials` int(10) NOT NULL,
  `KofferraumOpium` int(10) NOT NULL,
  `KofferraumLunchpakete` int(10) NOT NULL,
  `KofferraumC4` int(10) NOT NULL,
  `KofferraumWerkzeugkasten` int(10) NOT NULL,
  `KofferraumBenzinkanister` int(10) NOT NULL,
  `Handbremse` int(2) NOT NULL,
  `KofferraumSpice` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_ffahrzeuge
-- ----------------------------
INSERT INTO `server_ffahrzeuge` VALUES ('0', '11', '0', '525', '1', '22', '-1', '983.7895', '1130.8745', '-1696.5188', '13.1315', '359.7544', '0', '0', '0', '0', '0', '', 'SA-POD-0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '120.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('1', '11', '0', '525', '1', '22', '-1', '1000.0000', '1113.5114', '-1696.9399', '13.1380', '357.9387', '0', '0', '1', '0', '0', 'NONE', 'SA-POD-1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '120.0000', '63', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('2', '11', '0', '525', '1', '22', '-1', '350.0000', '1108.5363', '-1696.4900', '13.1325', '358.6047', '0', '0', '0', '0', '0', 'NONE', 'SA-POD-2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '0', '119.1900', '5288', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('3', '11', '0', '525', '1', '22', '-1', '1000.0000', '1126.4196', '-1697.1818', '13.1435', '0.1814', '0', '0', '0', '0', '0', 'NONE', 'SA-POD-3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '120.0000', '53', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('4', '11', '0', '525', '1', '22', '-1', '1000.0000', '1121.9846', '-1697.2916', '13.1329', '0.6748', '0', '0', '0', '0', '0', 'NONE', 'SA-POD-4', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '120.0000', '21', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('5', '11', '0', '525', '1', '22', '-1', '1000.0000', '1117.7283', '-1697.1195', '13.1351', '359.8658', '0', '0', '0', '0', '0', 'NONE', 'SA-POD-5', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '120.0000', '3012', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('6', '1', '0', '596', '79', '1', '-1', '1500.0000', '717.2939', '-1361.8625', '13.1924', '359.9604', '0', '0', '0', '0', '0', '', 'SA-PD-6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '30', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('7', '1', '0', '596', '79', '1', '-1', '1500.0000', '722.3020', '-1361.7910', '13.1975', '359.4732', '0', '0', '0', '0', '0', '', 'SA-PD-7', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '3619', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('8', '1', '0', '596', '79', '1', '-1', '1500.0000', '737.5580', '-1361.8514', '13.1925', '359.0887', '0', '0', '0', '0', '0', '', 'SA-PD-8', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '67', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('9', '1', '0', '596', '79', '1', '-1', '1500.0000', '702.1272', '-1361.5791', '13.1923', '0.1399', '0', '0', '0', '0', '0', '', 'SA-PD-9', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '24', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('10', '1', '0', '596', '79', '1', '-1', '1500.0000', '712.2587', '-1361.8723', '13.1932', '359.9657', '0', '0', '0', '0', '0', '', 'SA-PD-10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '2397', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('11', '1', '0', '596', '79', '1', '-1', '1500.0000', '707.3397', '-1361.8949', '13.1924', '0.1758', '0', '0', '0', '0', '0', '', 'SA-PD-11', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '24', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('12', '1', '0', '596', '79', '1', '-1', '1500.0000', '727.2031', '-1361.7834', '13.1928', '358.4522', '0', '0', '0', '0', '0', '', 'SA-PD-12', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '42', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('13', '1', '0', '596', '79', '1', '-1', '1500.0000', '732.2456', '-1361.7759', '13.1914', '0.1385', '0', '0', '0', '0', '0', '', 'SA-PD-13', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '38', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('14', '2', '0', '497', '0', '0', '-1', '1000.0000', '1567.8444', '-1652.4362', '28.3956', '93.9525', '0', '0', '1', '0', '0', '', 'SA-XX-14', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('15', '2', '0', '497', '0', '0', '-1', '1000.0000', '1565.9532', '-1697.2614', '28.3956', '89.8791', '0', '0', '1', '0', '0', '', 'SA-XX-15', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('16', '2', '0', '497', '0', '0', '-1', '1000.0000', '1550.5468', '-1707.4938', '28.3948', '90.5058', '0', '0', '1', '0', '0', '', 'SA-XX-16', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('17', '2', '0', '497', '0', '0', '-1', '1000.0000', '1551.4336', '-1643.9333', '28.4021', '92.3858', '0', '0', '1', '0', '0', '', 'SA-XX-17', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('18', '2', '0', '528', '0', '0', '-1', '4000.0000', '1595.6824', '-1711.2262', '5.8906', '1.2046', '0', '0', '1', '0', '0', '', 'SA-XX-18', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('19', '2', '0', '528', '0', '0', '-1', '4000.0000', '1591.5677', '-1712.2860', '5.8906', '359.6385', '0', '0', '0', '0', '0', '', 'SA-XX-19', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '12', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('20', '2', '0', '528', '0', '0', '-1', '4000.0000', '1587.5675', '-1711.3105', '5.9346', '1.2590', '0', '0', '1', '0', '0', '', 'SA-XX-20', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('21', '2', '0', '528', '0', '0', '-1', '4000.0000', '1583.5900', '-1711.2191', '5.9335', '0.8041', '0', '0', '0', '0', '0', '', 'SA-XX-21', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('22', '2', '0', '528', '0', '0', '-1', '4000.0000', '1578.8953', '-1711.5248', '5.8906', '0.9659', '0', '0', '1', '0', '0', '', 'SA-XX-22', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('23', '2', '0', '528', '0', '0', '-1', '4000.0000', '1574.6068', '-1712.0333', '5.9360', '359.7798', '0', '0', '0', '0', '0', '', 'SA-XX-23', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '22', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('24', '2', '0', '528', '0', '0', '-1', '4000.0000', '1570.4420', '-1711.7748', '5.8906', '3.4727', '0', '0', '1', '0', '0', '', 'SA-XX-24', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '65.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('25', '2', '0', '601', '0', '0', '-1', '4000.0000', '1562.3069', '-1712.3389', '5.8906', '359.2139', '0', '0', '1', '0', '0', '', 'SA-XX-25', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '200.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('26', '2', '0', '601', '0', '0', '-1', '4000.0000', '1566.3339', '-1712.7567', '5.8906', '356.3939', '0', '0', '1', '0', '0', '', 'SA-XX-26', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '200.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('27', '2', '0', '490', '0', '0', '-1', '2500.0000', '1602.6632', '-1700.1229', '6.0190', '90.1052', '0', '0', '0', '0', '0', '', 'SA-XX-27', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('28', '2', '0', '490', '0', '0', '-1', '2500.0000', '1602.5413', '-1696.1343', '6.0185', '91.1806', '0', '0', '0', '0', '0', '', 'SA-XX-28', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '16', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('29', '2', '0', '490', '0', '0', '-1', '2500.0000', '1602.5355', '-1691.7723', '6.0229', '88.5950', '0', '0', '1', '0', '0', '', 'SA-XX-29', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '8', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('30', '2', '0', '490', '0', '0', '-1', '2500.0000', '1602.3959', '-1687.9791', '6.0185', '90.1178', '0', '0', '0', '0', '0', '', 'SA-XX-30', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('31', '2', '0', '490', '0', '0', '-1', '2500.0000', '1602.6882', '-1683.8907', '5.8906', '90.3713', '0', '0', '1', '0', '0', '', 'SA-XX-31', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('32', '2', '0', '522', '0', '0', '-1', '1000.0000', '1586.3062', '-1670.4838', '5.4557', '270.9863', '0', '0', '1', '0', '0', '', 'SA-XX-32', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '17', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('33', '2', '0', '522', '0', '0', '-1', '1000.0000', '1586.1288', '-1673.3729', '5.4649', '273.6552', '0', '0', '0', '0', '0', '', 'SA-XX-33', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('34', '2', '0', '522', '0', '0', '-1', '1000.0000', '1582.9705', '-1671.9531', '5.4601', '272.5974', '0', '0', '0', '0', '0', '', 'SA-XX-34', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '5', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('35', '2', '0', '427', '0', '0', '-1', '3000.0000', '1585.3773', '-1667.6306', '5.8923', '271.3440', '0', '0', '0', '0', '0', '', 'SA-XX-35', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '200.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('36', '5', '0', '482', '234', '234', '-1', '1000.0000', '2473.3743', '-1694.5448', '13.5151', '359.1812', '0', '0', '1', '0', '0', '', 'SA-GSF-36', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '60.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('37', '5', '0', '468', '234', '234', '-1', '1000.0000', '2483.8162', '-1690.9745', '13.5164', '353.2509', '0', '0', '0', '0', '0', '', 'SA-GSF-37', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('38', '5', '0', '468', '234', '234', '-1', '1000.0000', '2482.8667', '-1691.9669', '13.1869', '354.0063', '0', '0', '0', '0', '0', '', 'SA-GSF-38', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('39', '5', '0', '468', '234', '234', '-1', '1000.0000', '2480.4895', '-1691.8022', '13.5195', '353.2509', '0', '0', '1', '0', '0', '', 'SA-GSF-39', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('40', '5', '0', '468', '234', '234', '-1', '1000.0000', '2481.6082', '-1691.8456', '13.5195', '353.2509', '0', '0', '1', '0', '0', '', 'SA-GSF-40', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('41', '5', '0', '412', '234', '234', '-1', '1000.0000', '2504.9211', '-1678.6974', '13.3790', '324.8427', '0', '0', '1', '0', '0', '', 'SA-GSF-41', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '40.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('42', '5', '0', '412', '234', '234', '-1', '1000.0000', '2508.8433', '-1667.3378', '13.3971', '19.6765', '0', '0', '1', '0', '0', '', 'SA-GSF-42', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '40.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('43', '5', '0', '567', '234', '234', '-1', '1000.0000', '2490.5552', '-1683.8586', '13.3366', '89.5271', '0', '0', '1', '0', '0', '', 'SA-GSF-43', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '40.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('44', '5', '0', '567', '234', '234', '-1', '1000.0000', '2470.0295', '-1671.2921', '13.3206', '9.6263', '0', '0', '1', '0', '0', '', 'SA-GSF-44', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '40.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('45', '16', '0', '560', '1', '1', '-1', '766.0000', '1259.7715', '-2016.6459', '59.4265', '181.8882', '0', '0', '0', '0', '0', '', 'SA-GLS-45', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '60.0000', '9466', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('46', '16', '0', '409', '1', '1', '-1', '1000.0000', '1277.4358', '-2032.1045', '58.9848', '177.9501', '0', '0', '1', '0', '0', '', 'SA-GLS-46', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '50.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('47', '16', '0', '490', '1', '1', '-1', '2500.0000', '1244.5361', '-2010.4506', '59.8619', '181.3965', '0', '0', '1', '0', '0', '', 'SA-GLS-47', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('48', '16', '0', '490', '1', '1', '-1', '2500.0000', '1249.7516', '-2010.5127', '59.7128', '183.5899', '0', '0', '1', '0', '0', '', 'SA-GLS-48', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('49', '16', '0', '490', '1', '1', '-1', '2500.0000', '1255.5555', '-2010.2682', '59.5469', '178.8899', '0', '0', '1', '0', '0', '', 'SA-GLS-49', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('50', '16', '0', '490', '1', '1', '-1', '2500.0000', '1261.6178', '-2010.2922', '59.3737', '180.4559', '0', '0', '1', '0', '0', '', 'SA-GLS-50', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('51', '16', '0', '490', '1', '1', '-1', '2500.0000', '1267.6038', '-2011.5201', '59.2026', '178.2631', '0', '0', '1', '0', '0', '', 'SA-GLS-51', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('52', '16', '0', '490', '1', '1', '-1', '2500.0000', '1274.0541', '-2011.6178', '59.0183', '180.7697', '0', '0', '1', '0', '0', '', 'SA-GLS-52', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '70.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('53', '16', '0', '523', '1', '1', '-1', '1000.0000', '1277.8413', '-2025.5508', '58.9537', '180.1427', '0', '0', '1', '0', '0', '', 'SA-GLS-53', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('54', '16', '0', '523', '1', '1', '-1', '1000.0000', '1277.3395', '-2037.7805', '59.0082', '177.9500', '0', '0', '1', '0', '0', '', 'SA-GLS-54', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '25.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('55', '16', '0', '497', '1', '1', '-1', '1000.0000', '1160.9579', '-2054.3804', '69.0078', '2.5048', '0', '0', '1', '0', '0', '', 'SA-GLS-55', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('56', '16', '0', '497', '1', '1', '-1', '1000.0000', '1145.0394', '-2054.8491', '69.0006', '359.6860', '0', '0', '1', '0', '0', '', 'SA-GLS-56', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('57', '16', '0', '497', '1', '1', '-1', '1000.0000', '1146.0389', '-2020.8772', '69.0078', '180.7933', '0', '0', '1', '0', '0', '', 'SA-GLS-57', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_ffahrzeuge` VALUES ('58', '16', '0', '497', '1', '1', '-1', '1000.0000', '1160.1554', '-2020.9286', '69.0006', '181.7333', '0', '0', '1', '0', '0', '', 'SA-GLS-58', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3500.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `server_firmen`
-- ----------------------------
DROP TABLE IF EXISTS `server_firmen`;
CREATE TABLE `server_firmen` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ParteiName` varchar(64) NOT NULL,
  `ParteiOwner` varchar(24) NOT NULL,
  `ParteiMotto` varchar(128) NOT NULL,
  `ParteiKasse` int(128) NOT NULL,
  `ParteiMBeitrag` int(18) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_firmen
-- ----------------------------

-- ----------------------------
-- Table structure for `server_fnachicht`
-- ----------------------------
DROP TABLE IF EXISTS `server_fnachicht`;
CREATE TABLE `server_fnachicht` (
  `fID` int(12) NOT NULL AUTO_INCREMENT,
  `Text` varchar(128) NOT NULL,
  PRIMARY KEY (`fID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_fnachicht
-- ----------------------------

-- ----------------------------
-- Table structure for `server_frakdefi`
-- ----------------------------
DROP TABLE IF EXISTS `server_frakdefi`;
CREATE TABLE `server_frakdefi` (
  `fID` int(5) NOT NULL,
  `Geld` int(100) NOT NULL,
  `Opium` int(100) NOT NULL,
  `Spice` int(100) NOT NULL,
  `Ganja` int(100) NOT NULL,
  `Kokain` int(100) NOT NULL,
  `C4` int(100) NOT NULL,
  `Materials` int(100) NOT NULL,
  `WaffenPack` int(100) NOT NULL,
  `WaffenSlots` int(100) NOT NULL,
  `Heal` int(100) NOT NULL,
  `HealSlots` int(100) NOT NULL,
  `Armour` int(100) NOT NULL,
  `ArmourSlots` int(100) NOT NULL,
  `HaveVBInvite` int(5) NOT NULL,
  `VBFraktion` int(5) NOT NULL,
  `F0` varchar(32) NOT NULL,
  `F1` varchar(32) NOT NULL,
  `F2` varchar(32) NOT NULL,
  `F3` varchar(32) NOT NULL,
  `F4` varchar(32) NOT NULL,
  `F5` varchar(32) NOT NULL,
  `F6` varchar(32) NOT NULL,
  `GFFID` int(3) NOT NULL,
  `GFOWNER` int(3) NOT NULL,
  `GFKILLS` int(3) NOT NULL,
  `GFDEATHS` int(3) NOT NULL,
  `FrakMembers` int(10) NOT NULL,
  `FrakLimit` int(10) NOT NULL,
  `GSKILLS` int(10) NOT NULL,
  PRIMARY KEY (`fID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_frakdefi
-- ----------------------------
INSERT INTO `server_frakdefi` VALUES ('0', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('1', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'Praktikant', 'Officer', 'Detective', 'Sergeant', 'Lieutenant', 'Captain', 'Sheriff', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('2', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'Special Agent in Education', 'Special Agent', 'Senior Special Agent', 'Supervisory Special Agent', 'Section Chief', 'Deputy Director', 'FIB Director', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('3', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('4', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('5', '50777', '0', '0', '0', '0', '0', '0', '1', '46', '1', '49', '1', '49', '0', '0', 'Newcomer', 'Thug', 'Homie', 'Soldier', 'Dealer', 'Big Homie', 'Big Boss', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('6', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('7', '256350', '0', '0', '0', '0', '0', '0', '1', '49', '1', '49', '1', '49', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('8', '105660', '0', '0', '0', '0', '0', '0', '1', '49', '1', '50', '1', '50', '0', '0', 'Frischling', 'Lehrling', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'Auftragskiller', 'Erfahrener Auftragskiller', 'Veteran Auftragskiller', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('9', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'Sako', 'Kobun', 'Oyabun', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('10', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('11', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'Praktikant', 'Lehrling', 'Abschlepper', 'Kontrolleur', 'Ausbilder', 'stellv. Ordnungsamt Direktor', 'Ordnungsamt Direktor', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('12', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('13', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('14', '50000', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'Lehrling', 'Lehrer', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'FOOl', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('15', '1431', '0', '0', '0', '0', '0', '0', '1', '49', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('16', '12511552', '0', '0', '0', '0', '0', '0', '1', '44', '1', '49', '1', '49', '0', '0', 'Innenminister', 'Außenminister', 'Finanzminister', 'Verteidigungsminister', 'Generalsekretär', 'Vize-Präsident', 'Präsident', '0', '0', '0', '0', '0', '6', '0');
INSERT INTO `server_frakdefi` VALUES ('17', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_frakdefi` VALUES ('18', '52455', '0', '0', '0', '0', '0', '0', '1', '50', '1', '50', '1', '50', '0', '0', 'R0[EINTRAGEN]', 'R1[EINTRAGEN]', 'R2[EINTRAGEN]', 'R3[EINTRAGEN]', 'R4[EINTRAGEN]', 'R5[EINTRAGEN]', 'R6[EINTRAGEN]', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `server_gangwars`
-- ----------------------------
DROP TABLE IF EXISTS `server_gangwars`;
CREATE TABLE `server_gangwars` (
  `GangZoneID` int(3) NOT NULL,
  `GangWarZoneOwner` int(5) NOT NULL,
  `GangWarZoneAttacker` int(5) NOT NULL,
  `War_OwnerPoints` int(4) NOT NULL,
  `War_AttackerPoints` int(4) NOT NULL,
  `War_Started` int(2) NOT NULL,
  `War_Time` int(12) NOT NULL,
  `War_Sperre` int(20) NOT NULL,
  PRIMARY KEY (`GangZoneID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_gangwars
-- ----------------------------
INSERT INTO `server_gangwars` VALUES ('0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('4', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('5', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('3', '7', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('8', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('10', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('11', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('12', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('13', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('6', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('7', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('2', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('1', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `server_gangwars` VALUES ('9', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `server_gutscheine`
-- ----------------------------
DROP TABLE IF EXISTS `server_gutscheine`;
CREATE TABLE `server_gutscheine` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `gutscheincode` varchar(16) NOT NULL,
  `gutscheinname` varchar(32) NOT NULL,
  `gutscheindes` varchar(64) NOT NULL,
  `gutscheintyp` int(8) NOT NULL,
  `gutscheinmenge` int(8) NOT NULL,
  `gutscheinanzahl` int(8) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_gutscheine
-- ----------------------------

-- ----------------------------
-- Table structure for `server_haus`
-- ----------------------------
DROP TABLE IF EXISTS `server_haus`;
CREATE TABLE `server_haus` (
  `id` int(30) NOT NULL AUTO_INCREMENT,
  `haus_besitzer` varchar(30) NOT NULL,
  `haus_Owned` int(30) NOT NULL,
  `haus_innenraum` int(30) NOT NULL,
  `haus_miete` int(30) NOT NULL,
  `haus_beschreibung` varchar(30) NOT NULL,
  `haus_locked` int(30) NOT NULL,
  `haus_slots` int(30) NOT NULL,
  `haus_eingemitetenzaehler` int(30) NOT NULL,
  `haus_x` float(30,4) NOT NULL,
  `haus_y` float(30,4) NOT NULL,
  `haus_z` float(30,4) NOT NULL,
  `haus_preis` int(30) NOT NULL,
  `haus_level` int(30) NOT NULL,
  `haus_geldkasse` int(30) NOT NULL,
  `haus_Opium` int(30) NOT NULL,
  `haus_c4` int(30) NOT NULL,
  `haus_Ganja` int(30) NOT NULL,
  `haus_Kokain` int(30) NOT NULL,
  `haus_materials` int(30) NOT NULL,
  `haus_heal` int(30) NOT NULL,
  `haus_armour` int(30) NOT NULL,
  `haus_hatheal` int(30) NOT NULL,
  `haus_hatarmour` int(30) NOT NULL,
  `hausgundumper` int(30) NOT NULL,
  `hausgun0` int(30) NOT NULL,
  `hausgun1` int(30) NOT NULL,
  `hausgun2` int(30) NOT NULL,
  `hausgun3` int(30) NOT NULL,
  `hausgun4` int(30) NOT NULL,
  `hausgun5` int(30) NOT NULL,
  `hausgun6` int(30) NOT NULL,
  `hausgun7` int(30) NOT NULL,
  `hausgun8` int(30) NOT NULL,
  `hausgun9` int(30) NOT NULL,
  `hausgun10` int(30) NOT NULL,
  `hausgun11` int(30) NOT NULL,
  `hausgun12` int(30) NOT NULL,
  `hausgunammo0` int(30) NOT NULL,
  `hausgunammo1` int(30) NOT NULL,
  `hausgunammo2` int(30) NOT NULL,
  `hausgunammo3` int(30) NOT NULL,
  `hausgunammo4` int(30) NOT NULL,
  `hausgunammo5` int(30) NOT NULL,
  `hausgunammo6` int(30) NOT NULL,
  `hausgunammo7` int(30) NOT NULL,
  `hausgunammo8` int(30) NOT NULL,
  `hausgunammo9` int(30) NOT NULL,
  `hausgunammo10` int(30) NOT NULL,
  `hausgunammo11` int(30) NOT NULL,
  `hausgunammo12` int(30) NOT NULL,
  `hausmull` int(30) NOT NULL,
  `haus_msg` varchar(190) NOT NULL,
  `haus_Spice` int(30) NOT NULL,
  `haus_mieterstatus` int(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=206 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_haus
-- ----------------------------
INSERT INTO `server_haus` VALUES ('1', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '653.5941', '-1713.9354', '14.7648', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('2', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '3', '0', '652.6663', '-1693.9280', '14.5436', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('3', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '657.2259', '-1652.6324', '15.4062', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('4', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '655.9391', '-1635.8651', '15.8617', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('5', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '3', '0', '653.2433', '-1619.8099', '15.0000', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('6', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '692.8666', '-1602.7744', '15.0469', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('7', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '2', '0', '761.4249', '-1564.1028', '13.8106', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('8', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '766.9208', '-1605.7948', '13.8039', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('9', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '771.5364', '-1510.7826', '13.5469', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('10', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '768.0638', '-1655.8925', '5.6094', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('11', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '782.7891', '-1464.4844', '13.5469', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('12', 'require', '1', '6', '650', 'Greengood Square', '0', '6', '0', '813.6889', '-1456.6761', '14.2266', '500000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '9', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('13', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '769.2272', '-1696.5129', '5.1554', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('14', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '769.2277', '-1745.8728', '13.0773', '30000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('15', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '2', '0', '768.9460', '-1726.3103', '13.4321', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('16', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '3', '0', '791.2956', '-1753.2141', '13.4605', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('17', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '910.3196', '-1802.6914', '13.8002', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('18', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '921.8430', '-1803.8745', '13.8379', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('19', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '933.5805', '-1805.1891', '13.8434', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('20', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '3', '0', '958.1011', '-1809.1793', '13.8814', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('21', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '969.7036', '-1812.0496', '13.8838', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('22', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '1', '0', '980.7994', '-1814.7856', '13.8886', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('23', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '1', '0', '992.7395', '-1817.6595', '13.8941', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('24', 'Niemand', '0', '4', '0', 'California Square', '1', '6', '0', '281.0415', '-1767.5640', '4.5441', '30000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('25', 'Niemand', '0', '1', '0', 'California Square', '1', '3', '0', '315.8131', '-1769.4313', '4.6218', '120000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('29', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '3', '0', '1284.8843', '-1067.4404', '31.6719', '150000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('26', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1242.2640', '-1099.3920', '27.9766', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('27', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '3', '0', '1284.7209', '-1089.9082', '28.2578', '150000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('28', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1241.9457', '-1076.5231', '31.5547', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('30', 'Niemand', '0', '6', '0', 'Wiener Straße', '1', '6', '0', '1325.9448', '-1067.0970', '31.5547', '160000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('31', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1183.4655', '-1075.9697', '31.6789', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('32', 'Niemand', '0', '7', '0', 'Wiener Straße', '1', '6', '0', '1326.2625', '-1091.1653', '27.9766', '160000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('33', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1183.4735', '-1098.8828', '28.2578', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('34', 'Niemand', '0', '3', '0', 'Wiener Straße', '1', '6', '0', '1142.1207', '-1093.3635', '28.1875', '150000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('35', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1141.8052', '-1070.0015', '31.7656', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('36', 'Niemand', '0', '13', '0', 'Wiener Straße', '1', '9', '0', '1128.0055', '-1022.3343', '34.9922', '350000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('37', 'Niemand', '0', '12', '0', 'Wiener Straße', '1', '9', '0', '1118.1300', '-1021.9852', '34.9922', '360000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('38', 'Niemand', '0', '3', '0', 'Wiener Straße', '1', '10', '0', '1103.1893', '-1092.5334', '28.4688', '150000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('39', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '1', '0', '1059.2114', '-1105.2023', '28.0451', '30000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('40', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1068.4227', '-1081.2739', '27.5623', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('41', 'Niemand', '0', '15', '0', 'Wiener Straße', '1', '10', '0', '1050.8658', '-1058.6420', '34.7966', '500000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('42', 'Niemand', '0', '15', '0', 'Wiener Straße', '1', '10', '0', '993.8118', '-1058.7506', '33.6995', '500000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('43', 'Niemand', '0', '16', '0', 'Kremser Straße', '1', '10', '0', '952.9988', '-909.8276', '45.7656', '2000000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('44', 'Niemand', '0', '0', '0', 'Kremser Straße', '1', '2', '0', '949.9005', '-987.8347', '38.7266', '15000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('45', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '2', '0', '827.7291', '-858.0173', '70.3308', '75000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('46', 'Niemand', '0', '6', '0', 'Mulholland Straße', '1', '9', '0', '937.8935', '-848.5638', '93.5952', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('47', 'Niemand', '0', '6', '0', 'Mulholland Straße', '1', '10', '0', '990.0935', '-828.4977', '95.4686', '350000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('48', 'Niemand', '0', '4', '0', 'Mulholland Straße', '1', '6', '0', '1034.9788', '-813.1246', '101.8516', '250000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('49', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '2', '0', '910.4537', '-817.5118', '103.1260', '85000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('50', 'Niemand', '0', '14', '0', 'Mulholland Straße', '1', '10', '0', '1093.6995', '-806.8652', '107.4205', '750000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('51', 'Niemand', '0', '16', '0', 'Mulholland Straße', '1', '10', '0', '1258.6138', '-785.4924', '92.0302', '100000000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('52', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '2', '0', '785.8171', '-828.6042', '70.2896', '95000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('53', 'Niemand', '0', '12', '0', 'Mulholland Straße', '1', '9', '0', '808.3196', '-759.5847', '76.5314', '190000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('54', 'Niemand', '0', '3', '0', 'Mulholland Straße', '1', '8', '0', '848.3461', '-745.4419', '94.9693', '120000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('55', 'Niemand', '0', '2', '0', 'Mulholland Straße', '1', '8', '0', '890.9747', '-783.2501', '101.3133', '138000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('56', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '867.5020', '-717.5826', '105.6797', '115000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('57', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '897.9315', '-677.1000', '116.8904', '215000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('58', 'Niemand', '0', '0', '0', 'Mulholland Straße', '1', '2', '0', '946.4074', '-710.6481', '122.6199', '75000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('59', 'Niemand', '0', '4', '0', 'Mulholland Straße', '1', '8', '0', '1044.9227', '-642.4952', '120.1172', '346000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('60', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '980.4362', '-677.2944', '121.9763', '3500000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('61', 'Niemand', '0', '15', '0', 'Mulholland Straße', '1', '10', '0', '1095.0524', '-647.7150', '113.6484', '90000000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('62', 'Niemand', '0', '14', '0', 'Mulholland Straße', '1', '9', '0', '1331.8572', '-632.6550', '109.1349', '60000000', '63', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('63', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '1442.6859', '-628.8326', '95.7186', '125000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('64', 'Niemand', '0', '7', '0', 'Mulholland Straße', '1', '10', '0', '1527.7361', '-772.4984', '80.5781', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('65', 'Niemand', '0', '4', '0', 'Mulholland Straße', '1', '8', '0', '1535.0353', '-800.1218', '72.8495', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('66', 'Niemand', '0', '12', '0', 'Mulholland Straße', '1', '8', '0', '1540.4696', '-851.4265', '64.3361', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('67', 'Niemand', '0', '3', '0', 'Mulholland Straße', '1', '8', '0', '1468.7467', '-906.1857', '54.8359', '260000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('68', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '1421.6915', '-886.2209', '50.6859', '75000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('69', 'Niemand', '0', '13', '0', 'Mulholland Straße', '1', '8', '0', '1410.6985', '-920.8022', '38.4219', '650000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('70', 'Niemand', '0', '3', '0', 'Mulholland Straße', '1', '8', '0', '1440.3536', '-926.0908', '39.6477', '650000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('71', 'Niemand', '0', '13', '0', 'Greengood Square', '1', '8', '0', '852.3550', '-1422.7932', '14.1231', '342000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('72', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '824.5870', '-1424.2039', '14.4989', '34000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('73', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '784.9837', '-1435.8538', '13.5469', '99000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('74', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '8', '0', '793.9760', '-1707.5431', '14.0382', '46000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('75', 'Niemand', '0', '3', '0', 'Greengood Square', '1', '8', '0', '794.6666', '-1691.3542', '14.4633', '26000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('76', 'Niemand', '0', '3', '0', 'Greengood Square', '1', '8', '0', '797.2369', '-1729.4843', '13.5469', '24000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('77', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2513.7483', '-1650.2804', '14.3557', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('78', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2498.4475', '-1642.2559', '14.1131', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('79', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2486.5339', '-1644.5338', '14.0772', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('80', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2469.5413', '-1646.3463', '13.7801', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('81', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2459.3276', '-1691.6593', '13.5477', '13000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('82', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2414.0176', '-1646.7888', '14.0119', '13000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('83', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2393.1479', '-1646.0363', '13.9051', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('84', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2408.8142', '-1674.9358', '14.3750', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('85', 'Niemand', '0', '0', '0', 'Grove Street', '1', '1', '0', '2363.0901', '-1643.9830', '13.5357', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('86', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2384.6841', '-1675.8313', '15.2457', '12000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('87', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2368.0437', '-1675.3440', '14.1682', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('88', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2326.8999', '-1682.1617', '14.9297', '22000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('89', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2327.0020', '-1716.8223', '14.2379', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('90', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2307.1277', '-1679.1986', '14.3316', '12000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('91', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2308.9138', '-1714.7253', '14.6496', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('92', 'Niemand', '0', '0', '0', 'Grove Street', '1', '1', '0', '2257.1328', '-1643.9451', '15.8082', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('93', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2282.3560', '-1641.2161', '15.8898', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('94', 'Niemand', '0', '0', '0', 'Grove Street', '1', '1', '0', '2244.5986', '-1637.6958', '16.2379', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('95', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2067.0710', '-1731.5629', '14.2066', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('96', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2066.2441', '-1717.2155', '14.1363', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('97', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2065.1003', '-1703.5635', '14.1484', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('98', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2066.7358', '-1656.6362', '14.1328', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('99', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2067.5615', '-1643.5394', '14.1363', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('100', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2067.7935', '-1628.7926', '14.2066', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('101', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2018.0426', '-1629.8270', '14.0426', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('102', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2013.5757', '-1656.4691', '14.1363', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('103', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2017.9028', '-1703.1775', '14.2344', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('104', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2016.5227', '-1641.7751', '14.1129', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('105', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2016.2004', '-1717.1681', '14.1250', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('106', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2015.3513', '-1732.7152', '14.2344', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('107', 'Niemand', '0', '2', '0', 'Idlewood Straße', '1', '4', '0', '1980.3756', '-1718.7545', '17.0301', '100000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('108', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '1980.9921', '-1682.6715', '17.0535', '100000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('109', 'Niemand', '0', '13', '0', 'Verona Beach Straße', '1', '9', '0', '936.8909', '-1612.7168', '14.9374', '250000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('110', 'Niemand', '0', '1', '0', 'Verona Beach Straße', '1', '3', '0', '965.0831', '-1612.6075', '14.9409', '55000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('111', 'Niemand', '0', '12', '0', 'Verona Beach Straße', '1', '8', '0', '986.5763', '-1624.2961', '14.9297', '250000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('112', 'Niemand', '0', '1', '0', 'Verone Beach Straße', '1', '3', '0', '985.9811', '-1704.2614', '14.9297', '55000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('113', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '1', '0', '841.4821', '-1471.5331', '14.2376', '290000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('114', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '3', '0', '822.5296', '-1505.5251', '14.3973', '100000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('115', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '849.5876', '-1519.9761', '14.3481', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('116', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '876.2101', '-1513.1217', '14.3477', '65000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('117', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '2', '0', '901.4821', '-1514.6725', '14.3641', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('118', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '898.5226', '-1472.8264', '14.3412', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('119', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '900.2149', '-1447.5356', '14.3708', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('120', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '1', '0', '1103.1127', '-1069.2068', '31.8899', '46000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('121', 'Niemand', '0', '7', '0', 'Richman Straße', '1', '6', '0', '298.6698', '-1338.5551', '53.4415', '650000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('122', 'Niemand', '0', '1', '0', 'Richman Straße', '1', '3', '0', '254.9700', '-1366.8037', '53.1094', '175000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('123', 'Niemand', '0', '1', '0', 'Richman Straße', '1', '3', '0', '228.2770', '-1405.0815', '51.6094', '165000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('125', 'Niemand', '0', '1', '0', 'Jefferson Straße', '1', '3', '0', '2149.8569', '-1433.7690', '26.0703', '80000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('124', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2150.9221', '-1419.0519', '25.9219', '42000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '1');
INSERT INTO `server_haus` VALUES ('126', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2152.2161', '-1446.5835', '26.1051', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('127', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2151.1853', '-1400.6086', '26.1285', '42000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('128', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2148.9377', '-1484.9384', '26.6240', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('129', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2146.7979', '-1470.4999', '26.0426', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('130', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2190.4441', '-1470.2930', '25.9141', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('131', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2191.5415', '-1455.9351', '25.8161', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('132', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2194.3506', '-1442.8679', '26.0738', '34000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('133', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2188.5464', '-1419.2816', '26.1562', '29000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('134', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2190.3250', '-1487.6007', '26.1051', '18000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('135', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2196.4038', '-1404.0100', '25.6183', '19000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('136', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2184.9172', '-1363.7052', '26.1598', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('137', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2202.8213', '-1363.6738', '26.1910', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('138', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2129.2405', '-1361.6880', '26.1363', '26000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('139', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2147.5815', '-1366.1200', '25.9723', '24000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('140', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2100.7593', '-1321.8923', '25.9531', '34000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('141', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2230.4651', '-1397.2404', '24.5738', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('142', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2126.4600', '-1320.8673', '26.6238', '28000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('143', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2243.5186', '-1397.2371', '24.5738', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('144', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2090.7874', '-1277.8345', '26.1797', '26000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('145', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2256.3972', '-1397.2432', '24.5738', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('146', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2110.9546', '-1278.9779', '25.8359', '32000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('147', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2263.9463', '-1469.3357', '24.3707', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('148', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2090.6833', '-1234.7411', '25.6887', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('149', 'Niemand', '0', '1', '0', 'Jefferson Straße', '1', '3', '0', '2111.0417', '-1244.1030', '25.8516', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('150', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2247.7317', '-1469.3442', '24.4801', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('151', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2232.5383', '-1469.3359', '24.5816', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('152', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2153.6987', '-1243.8043', '25.3672', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('153', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2191.6909', '-1238.9696', '24.1574', '16000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('154', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2209.7744', '-1240.2469', '24.4801', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('155', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2229.5754', '-1241.6102', '25.6562', '19000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('156', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2383.5312', '-1366.2057', '24.4914', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('157', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2249.9634', '-1238.9158', '25.8984', '42000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('158', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2389.7324', '-1346.2139', '25.0770', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('159', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2387.8635', '-1328.4189', '25.1242', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('160', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2388.4241', '-1279.6760', '25.1291', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('161', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2433.6040', '-1274.8860', '24.7567', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('162', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2434.8040', '-1289.2424', '25.3479', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('163', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2469.1743', '-1278.4819', '30.3664', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('164', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2433.9321', '-1303.6613', '25.3234', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('165', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2470.3677', '-1295.5081', '30.2332', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('166', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2433.9331', '-1320.9540', '25.3234', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('167', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2439.5901', '-1357.4602', '24.1015', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('168', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2439.5906', '-1338.6127', '24.1088', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('169', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2495.3291', '-1417.7258', '28.8375', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('170', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.3176', '-1424.5759', '29.0162', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('171', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2495.5000', '-1399.0879', '28.8394', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('172', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2495.3652', '-1383.6432', '28.8394', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('173', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2476.4319', '-1366.4862', '28.8348', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('174', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2473.3711', '-1375.9631', '28.8340', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('175', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.4036', '-1366.2089', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('176', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2492.2358', '-1375.9572', '28.8386', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('177', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.3501', '-1391.7085', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('178', 'Niemand', '0', '7', '0', 'East Los Santos', '1', '6', '0', '2482.7520', '-1293.3070', '30.2332', '45000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('179', 'Niemand', '0', '4', '0', 'East Los Santos', '1', '6', '0', '2483.9465', '-1280.1404', '30.4669', '34000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('180', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.3696', '-1391.7100', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('181', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.2910', '-1383.3748', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('182', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.3835', '-1410.3431', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('183', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.3152', '-1410.3431', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('184', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.3118', '-1398.8141', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('185', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.0184', '-1266.0590', '13.5469', '170000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('186', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.2053', '-1308.3438', '13.5469', '60000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('187', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.2191', '-1329.4446', '13.5391', '60000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('188', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.0360', '-1349.7491', '13.5469', '60000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('189', 'Niemand', '0', '1', '0', 'Comerce Straße', '1', '3', '0', '1378.2626', '-1753.0541', '14.1406', '150000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('190', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2095.3582', '-1145.4641', '26.5929', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('191', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2092.2400', '-1166.3966', '26.5859', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('192', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2022.8923', '-1120.2644', '26.4210', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('193', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2091.4065', '-1184.2963', '27.0571', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('194', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2000.1611', '-1114.0562', '27.1250', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('195', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1955.1239', '-1115.4489', '27.8305', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('196', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1921.3075', '-1115.1387', '27.0883', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('197', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1906.0126', '-1112.9474', '26.6641', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('198', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1885.8877', '-1113.6437', '26.2758', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('199', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '3', '0', '739.0222', '-1418.5122', '13.5234', '135000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('200', 'Niemand', '0', '1', '0', 'Marina Straße', '1', '3', '0', '685.5403', '-1421.9102', '14.7744', '115000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('202', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2524.7053', '-1658.7653', '15.8240', '12000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('201', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2522.9858', '-1679.3319', '15.4970', '12000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('203', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2514.3860', '-1691.5332', '14.0460', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus` VALUES ('204', 'Niemand', '0', '0', '0', '1', '1', '1', '0', '1259.8629', '-2024.7744', '59.4238', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');

-- ----------------------------
-- Table structure for `server_haus_copy`
-- ----------------------------
DROP TABLE IF EXISTS `server_haus_copy`;
CREATE TABLE `server_haus_copy` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `haus_besitzer` varchar(24) NOT NULL,
  `haus_Owned` int(2) NOT NULL,
  `haus_innenraum` int(2) NOT NULL,
  `haus_miete` int(8) NOT NULL,
  `haus_beschreibung` varchar(150) NOT NULL,
  `haus_locked` int(2) NOT NULL,
  `haus_slots` int(3) NOT NULL,
  `haus_eingemitetenzaehler` int(3) NOT NULL,
  `haus_x` float(10,4) NOT NULL,
  `haus_y` float(10,4) NOT NULL,
  `haus_z` float(10,4) NOT NULL,
  `haus_preis` int(12) NOT NULL,
  `haus_level` int(4) NOT NULL,
  `haus_geldkasse` int(12) NOT NULL,
  `haus_Opium` int(12) NOT NULL,
  `haus_c4` int(12) NOT NULL,
  `haus_Ganja` int(12) NOT NULL,
  `haus_Kokain` int(12) NOT NULL,
  `haus_materials` int(12) NOT NULL,
  `haus_heal` int(12) NOT NULL,
  `haus_armour` int(12) NOT NULL,
  `haus_hatheal` int(12) NOT NULL,
  `haus_hatarmour` int(12) NOT NULL,
  `hausgundumper` int(2) NOT NULL,
  `hausgun0` int(3) NOT NULL,
  `hausgun1` int(3) NOT NULL,
  `hausgun2` int(3) NOT NULL,
  `hausgun3` int(3) NOT NULL,
  `hausgun4` int(3) NOT NULL,
  `hausgun5` int(3) NOT NULL,
  `hausgun6` int(3) NOT NULL,
  `hausgun7` int(3) NOT NULL,
  `hausgun8` int(3) NOT NULL,
  `hausgun9` int(3) NOT NULL,
  `hausgun10` int(3) NOT NULL,
  `hausgun11` int(3) NOT NULL,
  `hausgun12` int(3) NOT NULL,
  `hausgunammo0` int(8) NOT NULL,
  `hausgunammo1` int(8) NOT NULL,
  `hausgunammo2` int(8) NOT NULL,
  `hausgunammo3` int(8) NOT NULL,
  `hausgunammo4` int(8) NOT NULL,
  `hausgunammo5` int(8) NOT NULL,
  `hausgunammo6` int(8) NOT NULL,
  `hausgunammo7` int(8) NOT NULL,
  `hausgunammo8` int(8) NOT NULL,
  `hausgunammo9` int(8) NOT NULL,
  `hausgunammo10` int(8) NOT NULL,
  `hausgunammo11` int(8) NOT NULL,
  `hausgunammo12` int(8) NOT NULL,
  `hausmull` int(3) NOT NULL,
  `haus_msg` varchar(150) NOT NULL,
  `haus_Spice` int(12) NOT NULL,
  `haus_mieterstatus` int(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=202 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_haus_copy
-- ----------------------------
INSERT INTO `server_haus_copy` VALUES ('1', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '653.5941', '-1713.9354', '14.7648', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('2', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '3', '0', '652.6663', '-1693.9280', '14.5436', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('3', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '657.2259', '-1652.6324', '15.4062', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('4', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '655.9391', '-1635.8651', '15.8617', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('5', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '3', '0', '653.2433', '-1619.8099', '15.0000', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('6', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '692.8666', '-1602.7744', '15.0469', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('7', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '2', '0', '761.4249', '-1564.1028', '13.8106', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('8', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '766.9208', '-1605.7948', '13.8039', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('9', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '771.5364', '-1510.7826', '13.5469', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('10', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '768.0638', '-1655.8925', '5.6094', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('11', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '782.7891', '-1464.4844', '13.5469', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('12', 'require', '1', '6', '650', 'Greengood Square', '1', '6', '0', '813.6889', '-1456.6761', '14.2266', '500000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('13', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '769.2272', '-1696.5129', '5.1554', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('14', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '769.2277', '-1745.8728', '13.0773', '30000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('15', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '2', '0', '768.9460', '-1726.3103', '13.4321', '30000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('16', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '3', '0', '791.2956', '-1753.2141', '13.4605', '30000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('17', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '910.3196', '-1802.6914', '13.8002', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('18', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '921.8430', '-1803.8745', '13.8379', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('19', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '933.5805', '-1805.1891', '13.8434', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('20', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '3', '0', '958.1011', '-1809.1793', '13.8814', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('21', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '2', '0', '969.7036', '-1812.0496', '13.8838', '20000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('22', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '1', '0', '980.7994', '-1814.7856', '13.8886', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('23', 'Niemand', '0', '0', '0', 'Walkenstein', '1', '1', '0', '992.7395', '-1817.6595', '13.8941', '20000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('24', 'Niemand', '0', '4', '0', 'California Square', '1', '6', '0', '281.0415', '-1767.5640', '4.5441', '30000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('25', 'Niemand', '0', '1', '0', 'California Square', '1', '3', '0', '315.8131', '-1769.4313', '4.6218', '120000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('29', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '3', '0', '1284.7209', '-1089.9082', '28.2578', '150000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('26', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1241.9457', '-1076.5231', '31.5547', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('27', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '3', '0', '1284.8843', '-1067.4404', '31.6719', '150000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('28', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1242.2640', '-1099.3920', '27.9766', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('30', 'Niemand', '0', '6', '0', 'Wiener Straße', '1', '6', '0', '1325.9448', '-1067.0970', '31.5547', '160000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('31', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1183.4655', '-1075.9697', '31.6789', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('32', 'Niemand', '0', '7', '0', 'Wiener Straße', '1', '6', '0', '1326.2625', '-1091.1653', '27.9766', '160000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('33', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1183.4735', '-1098.8828', '28.2578', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('34', 'Niemand', '0', '3', '0', 'Wiener Straße', '1', '6', '0', '1142.1207', '-1093.3635', '28.1875', '150000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('35', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1141.8052', '-1070.0015', '31.7656', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('36', 'Niemand', '0', '13', '0', 'Wiener Straße', '1', '9', '0', '1128.0055', '-1022.3343', '34.9922', '350000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('37', 'Niemand', '0', '12', '0', 'Wiener Straße', '1', '9', '0', '1118.1300', '-1021.9852', '34.9922', '360000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('38', 'Niemand', '0', '3', '0', 'Wiener Straße', '1', '10', '0', '1103.1893', '-1092.5334', '28.4688', '150000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('39', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '1', '0', '1059.2114', '-1105.2023', '28.0451', '30000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('40', 'Niemand', '0', '1', '0', 'Wiener Straße', '1', '3', '0', '1068.4227', '-1081.2739', '27.5623', '150000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('41', 'Niemand', '0', '15', '0', 'Wiener Straße', '1', '10', '0', '1050.8658', '-1058.6420', '34.7966', '500000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('42', 'Niemand', '0', '15', '0', 'Wiener Straße', '1', '10', '0', '993.8118', '-1058.7506', '33.6995', '500000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('43', 'Niemand', '0', '16', '0', 'Kremser Straße', '1', '10', '0', '952.9988', '-909.8276', '45.7656', '2000000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('44', 'Niemand', '0', '0', '0', 'Kremser Straße', '1', '2', '0', '949.9005', '-987.8347', '38.7266', '15000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('45', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '2', '0', '827.7291', '-858.0173', '70.3308', '75000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('46', 'Niemand', '0', '6', '0', 'Mulholland Straße', '1', '9', '0', '937.8935', '-848.5638', '93.5952', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('47', 'Niemand', '0', '6', '0', 'Mulholland Straße', '1', '10', '0', '990.0935', '-828.4977', '95.4686', '350000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('48', 'Niemand', '0', '4', '0', 'Mulholland Straße', '1', '6', '0', '1034.9788', '-813.1246', '101.8516', '250000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('49', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '2', '0', '910.4537', '-817.5118', '103.1260', '85000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('50', 'Niemand', '0', '14', '0', 'Mulholland Straße', '1', '10', '0', '1093.6995', '-806.8652', '107.4205', '750000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('51', 'Niemand', '0', '16', '0', 'Mulholland Straße', '1', '10', '0', '1258.6138', '-785.4924', '92.0302', '100000000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('52', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '2', '0', '785.8171', '-828.6042', '70.2896', '95000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('53', 'Niemand', '0', '12', '0', 'Mulholland Straße', '1', '9', '0', '808.3196', '-759.5847', '76.5314', '190000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('54', 'Niemand', '0', '3', '0', 'Mulholland Straße', '1', '8', '0', '848.3461', '-745.4419', '94.9693', '120000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('55', 'Niemand', '0', '2', '0', 'Mulholland Straße', '1', '8', '0', '890.9747', '-783.2501', '101.3133', '138000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('56', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '867.5020', '-717.5826', '105.6797', '115000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('57', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '897.9315', '-677.1000', '116.8904', '215000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('58', 'Niemand', '0', '0', '0', 'Mulholland Straße', '1', '2', '0', '946.4074', '-710.6481', '122.6199', '75000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('59', 'Niemand', '0', '4', '0', 'Mulholland Straße', '1', '8', '0', '1044.9227', '-642.4952', '120.1172', '346000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('60', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '980.4362', '-677.2944', '121.9763', '3500000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('61', 'Niemand', '0', '15', '0', 'Mulholland Straße', '1', '10', '0', '1095.0524', '-647.7150', '113.6484', '90000000', '10', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('62', 'Niemand', '0', '14', '0', 'Mulholland Straße', '1', '9', '0', '1331.8572', '-632.6550', '109.1349', '60000000', '63', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('63', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '1442.6859', '-628.8326', '95.7186', '125000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('64', 'Niemand', '0', '7', '0', 'Mulholland Straße', '1', '10', '0', '1527.7361', '-772.4984', '80.5781', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('65', 'Niemand', '0', '4', '0', 'Mulholland Straße', '1', '8', '0', '1535.0353', '-800.1218', '72.8495', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('66', 'Niemand', '0', '12', '0', 'Mulholland Straße', '1', '8', '0', '1540.4696', '-851.4265', '64.3361', '450000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('67', 'Niemand', '0', '3', '0', 'Mulholland Straße', '1', '8', '0', '1468.7467', '-906.1857', '54.8359', '260000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('68', 'Niemand', '0', '1', '0', 'Mulholland Straße', '1', '3', '0', '1421.6915', '-886.2209', '50.6859', '75000', '3', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('69', 'Niemand', '0', '13', '0', 'Mulholland Straße', '1', '8', '0', '1410.6985', '-920.8022', '38.4219', '650000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('70', 'Niemand', '0', '3', '0', 'Mulholland Straße', '1', '8', '0', '1440.3536', '-926.0908', '39.6477', '650000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('71', 'Niemand', '0', '13', '0', 'Greengood Square', '1', '8', '0', '852.3550', '-1422.7932', '14.1231', '342000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('72', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '824.5870', '-1424.2039', '14.4989', '34000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('73', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '784.9837', '-1435.8538', '13.5469', '99000', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('74', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '8', '0', '793.9760', '-1707.5431', '14.0382', '46000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('75', 'Niemand', '0', '3', '0', 'Greengood Square', '1', '8', '0', '794.6666', '-1691.3542', '14.4633', '26000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('76', 'Niemand', '0', '3', '0', 'Greengood Square', '1', '8', '0', '797.2369', '-1729.4843', '13.5469', '24000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('77', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2513.7483', '-1650.2804', '14.3557', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('78', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2498.4475', '-1642.2559', '14.1131', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('79', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2486.5339', '-1644.5338', '14.0772', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('80', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2469.5413', '-1646.3463', '13.7801', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('81', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2459.3276', '-1691.6593', '13.5477', '13000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('82', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2414.0176', '-1646.7888', '14.0119', '13000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('83', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2393.1479', '-1646.0363', '13.9051', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('84', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2408.8142', '-1674.9358', '14.3750', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('85', 'Niemand', '0', '0', '0', 'Grove Street', '1', '1', '0', '2363.0901', '-1643.9830', '13.5357', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('86', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2384.6841', '-1675.8313', '15.2457', '12000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('87', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2368.0437', '-1675.3440', '14.1682', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('88', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2326.8999', '-1682.1617', '14.9297', '22000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('89', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2327.0020', '-1716.8223', '14.2379', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('90', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2307.1277', '-1679.1986', '14.3316', '12000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('91', 'Niemand', '0', '0', '0', 'Grove Street', '1', '2', '0', '2308.9138', '-1714.7253', '14.6496', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('92', 'Niemand', '0', '0', '0', 'Grove Street', '1', '1', '0', '2257.1328', '-1643.9451', '15.8082', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('93', 'Niemand', '0', '0', '0', 'Grove Street', '1', '3', '0', '2282.3560', '-1641.2161', '15.8898', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('94', 'Niemand', '0', '0', '0', 'Grove Street', '1', '1', '0', '2244.5986', '-1637.6958', '16.2379', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('95', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2067.0710', '-1731.5629', '14.2066', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('96', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2066.2441', '-1717.2155', '14.1363', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('97', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2065.1003', '-1703.5635', '14.1484', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('98', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2066.7358', '-1656.6362', '14.1328', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('99', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2067.5615', '-1643.5394', '14.1363', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('100', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2067.7935', '-1628.7926', '14.2066', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('101', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2018.0426', '-1629.8270', '14.0426', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('102', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2013.5757', '-1656.4691', '14.1363', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('103', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2017.9028', '-1703.1775', '14.2344', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('104', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '3', '0', '2016.5227', '-1641.7751', '14.1129', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('105', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2016.2004', '-1717.1681', '14.1250', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('106', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '2015.3513', '-1732.7152', '14.2344', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('107', 'Niemand', '0', '2', '0', 'Idlewood Straße', '1', '4', '0', '1980.3756', '-1718.7545', '17.0301', '100000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('108', 'Niemand', '0', '0', '0', 'Idlewood Straße', '1', '1', '0', '1980.9921', '-1682.6715', '17.0535', '100000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('109', 'Niemand', '0', '13', '0', 'Verona Beach Straße', '1', '9', '0', '936.8909', '-1612.7168', '14.9374', '250000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('110', 'Niemand', '0', '1', '0', 'Verona Beach Straße', '1', '3', '0', '965.0831', '-1612.6075', '14.9409', '55000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('111', 'Niemand', '0', '12', '0', 'Verona Beach Straße', '1', '8', '0', '986.5763', '-1624.2961', '14.9297', '250000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('112', 'Niemand', '0', '1', '0', 'Verone Beach Straße', '1', '3', '0', '985.9811', '-1704.2614', '14.9297', '55000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('113', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '1', '0', '841.4821', '-1471.5331', '14.2376', '290000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('114', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '3', '0', '822.5296', '-1505.5251', '14.3973', '100000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('115', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '849.5876', '-1519.9761', '14.3481', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('116', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '2', '0', '876.2101', '-1513.1217', '14.3477', '65000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('117', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '2', '0', '901.4821', '-1514.6725', '14.3641', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('118', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '898.5226', '-1472.8264', '14.3412', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('119', 'Niemand', '0', '0', '0', 'Greengood Square', '1', '1', '0', '900.2149', '-1447.5356', '14.3708', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('120', 'Niemand', '0', '0', '0', 'Wiener Straße', '1', '1', '0', '1103.1127', '-1069.2068', '31.8899', '46000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('121', 'Niemand', '0', '7', '0', 'Richman Straße', '1', '6', '0', '298.6698', '-1338.5551', '53.4415', '650000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('122', 'Niemand', '0', '1', '0', 'Richman Straße', '1', '3', '0', '254.9700', '-1366.8037', '53.1094', '175000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('123', 'Niemand', '0', '1', '0', 'Richman Straße', '1', '3', '0', '228.2770', '-1405.0815', '51.6094', '165000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('125', 'Niemand', '0', '1', '0', 'Jefferson Straße', '1', '3', '0', '2149.8569', '-1433.7690', '26.0703', '80000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('124', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2150.9221', '-1419.0519', '25.9219', '42000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '1');
INSERT INTO `server_haus_copy` VALUES ('126', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2152.2161', '-1446.5835', '26.1051', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('127', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2151.1853', '-1400.6086', '26.1285', '42000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('128', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2148.9377', '-1484.9384', '26.6240', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('129', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2146.7979', '-1470.4999', '26.0426', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('130', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2190.4441', '-1470.2930', '25.9141', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('131', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2191.5415', '-1455.9351', '25.8161', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('132', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2194.3506', '-1442.8679', '26.0738', '34000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('133', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2188.5464', '-1419.2816', '26.1562', '29000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('134', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2190.3250', '-1487.6007', '26.1051', '18000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('135', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2196.4038', '-1404.0100', '25.6183', '19000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('136', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2184.9172', '-1363.7052', '26.1598', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('137', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2202.8213', '-1363.6738', '26.1910', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('138', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2129.2405', '-1361.6880', '26.1363', '26000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('139', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2147.5815', '-1366.1200', '25.9723', '24000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('140', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2100.7593', '-1321.8923', '25.9531', '34000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('141', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2230.4651', '-1397.2404', '24.5738', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('142', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2126.4600', '-1320.8673', '26.6238', '28000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('143', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2243.5186', '-1397.2371', '24.5738', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('144', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2090.7874', '-1277.8345', '26.1797', '26000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('145', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2256.3972', '-1397.2432', '24.5738', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('146', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2110.9546', '-1278.9779', '25.8359', '32000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('147', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2263.9463', '-1469.3357', '24.3707', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('148', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2090.6833', '-1234.7411', '25.6887', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('149', 'Niemand', '0', '1', '0', 'Jefferson Straße', '1', '3', '0', '2111.0417', '-1244.1030', '25.8516', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('150', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2247.7317', '-1469.3442', '24.4801', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('151', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2232.5383', '-1469.3359', '24.5816', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('152', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2153.6987', '-1243.8043', '25.3672', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('153', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2191.6909', '-1238.9696', '24.1574', '16000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('154', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2209.7744', '-1240.2469', '24.4801', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('155', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2229.5754', '-1241.6102', '25.6562', '19000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('156', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2383.5312', '-1366.2057', '24.4914', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('157', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2249.9634', '-1238.9158', '25.8984', '42000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('158', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2389.7324', '-1346.2139', '25.0770', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('159', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2387.8635', '-1328.4189', '25.1242', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('160', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2388.4241', '-1279.6760', '25.1291', '25000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('161', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2433.6040', '-1274.8860', '24.7567', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('162', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2434.8040', '-1289.2424', '25.3479', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('163', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2469.1743', '-1278.4819', '30.3664', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('164', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2433.9321', '-1303.6613', '25.3234', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('165', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2470.3677', '-1295.5081', '30.2332', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('166', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2433.9331', '-1320.9540', '25.3234', '15000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('167', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2439.5901', '-1357.4602', '24.1015', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('168', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2439.5906', '-1338.6127', '24.1088', '10000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('169', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2495.3291', '-1417.7258', '28.8375', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('170', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.3176', '-1424.5759', '29.0162', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('171', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2495.5000', '-1399.0879', '28.8394', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('172', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2495.3652', '-1383.6432', '28.8394', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('173', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2476.4319', '-1366.4862', '28.8348', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('174', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2473.3711', '-1375.9631', '28.8340', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('175', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.4036', '-1366.2089', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('176', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '1', '0', '2492.2358', '-1375.9572', '28.8386', '30000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('177', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.3501', '-1391.7085', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('178', 'Niemand', '0', '7', '0', 'East Los Santos', '1', '6', '0', '2482.7520', '-1293.3070', '30.2332', '45000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('179', 'Niemand', '0', '4', '0', 'East Los Santos', '1', '6', '0', '2483.9465', '-1280.1404', '30.4669', '34000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('180', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.3696', '-1391.7100', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('181', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.2910', '-1383.3748', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('182', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2495.3835', '-1410.3431', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('183', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.3152', '-1410.3431', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('184', 'Niemand', '0', '0', '0', 'East Los Santos', '1', '3', '0', '2476.3118', '-1398.8141', '29.3131', '20000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('185', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.0184', '-1266.0590', '13.5469', '170000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('186', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.2053', '-1308.3438', '13.5469', '60000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('187', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.2191', '-1329.4446', '13.5391', '60000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('188', 'Niemand', '0', '1', '0', 'Market Straße', '1', '3', '0', '1333.0360', '-1349.7491', '13.5469', '60000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('189', 'Niemand', '0', '1', '0', 'Comerce Straße', '1', '3', '0', '1378.2626', '-1753.0541', '14.1406', '150000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('190', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '1', '0', '2095.3582', '-1145.4641', '26.5929', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('191', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2092.2400', '-1166.3966', '26.5859', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('192', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2022.8923', '-1120.2644', '26.4210', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('193', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2091.4065', '-1184.2963', '27.0571', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('194', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '2000.1611', '-1114.0562', '27.1250', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('195', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1955.1239', '-1115.4489', '27.8305', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('196', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1921.3075', '-1115.1387', '27.0883', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('197', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1906.0126', '-1112.9474', '26.6641', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('198', 'Niemand', '0', '0', '0', 'Jefferson Straße', '1', '3', '0', '1885.8877', '-1113.6437', '26.2758', '35000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('199', 'Niemand', '0', '1', '0', 'Greengood Square', '1', '3', '0', '739.0222', '-1418.5122', '13.5234', '135000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('200', 'Niemand', '0', '1', '0', 'Marina Straße', '1', '3', '0', '685.5403', '-1421.9102', '14.7744', '115000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');
INSERT INTO `server_haus_copy` VALUES ('201', 'AdamRuzek', '1', '1', '0', 'Adamruzek', '1', '1', '0', '1098.3634', '-1704.8588', '13.5469', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Keine', '0', '0');

-- ----------------------------
-- Table structure for `server_hddbans`
-- ----------------------------
DROP TABLE IF EXISTS `server_hddbans`;
CREATE TABLE `server_hddbans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `IP` varchar(20) NOT NULL,
  `GPCI` varchar(45) NOT NULL,
  `name` varchar(24) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_hddbans
-- ----------------------------

-- ----------------------------
-- Table structure for `server_housemoebel`
-- ----------------------------
DROP TABLE IF EXISTS `server_housemoebel`;
CREATE TABLE `server_housemoebel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `haus_dbid` int(11) NOT NULL,
  `moebel_name` varchar(64) NOT NULL,
  `modelid` int(12) NOT NULL,
  `hmmodelpreis` int(11) NOT NULL,
  `hm_x` float(10,4) NOT NULL,
  `hm_y` float(10,4) NOT NULL,
  `hm_z` float(10,4) NOT NULL,
  `hm_rx` float(10,4) NOT NULL,
  `hm_ry` float(10,4) NOT NULL,
  `hm_rz` float(10,4) NOT NULL,
  `vworld` int(11) NOT NULL,
  `interior` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_housemoebel
-- ----------------------------

-- ----------------------------
-- Table structure for `server_maccounts`
-- ----------------------------
DROP TABLE IF EXISTS `server_maccounts`;
CREATE TABLE `server_maccounts` (
  `Name` varchar(24) NOT NULL,
  `Datum` date NOT NULL,
  `Uhrzeit` time NOT NULL,
  `Admin` varchar(24) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_maccounts
-- ----------------------------

-- ----------------------------
-- Table structure for `server_minen`
-- ----------------------------
DROP TABLE IF EXISTS `server_minen`;
CREATE TABLE `server_minen` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `sperreX` float(10,4) NOT NULL,
  `sperreY` float(10,4) NOT NULL,
  `sperreZ` float(10,4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_minen
-- ----------------------------

-- ----------------------------
-- Table structure for `server_netzwerk`
-- ----------------------------
DROP TABLE IF EXISTS `server_netzwerk`;
CREATE TABLE `server_netzwerk` (
  `id` int(12) NOT NULL,
  `X` float(10,4) NOT NULL,
  `Y` float(10,4) NOT NULL,
  `Z` float(10,4) NOT NULL,
  `HP` int(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_netzwerk
-- ----------------------------
INSERT INTO `server_netzwerk` VALUES ('0', '1694.6434', '-1043.7006', '23.9062', '62');
INSERT INTO `server_netzwerk` VALUES ('1', '591.8629', '-1807.2169', '6.0625', '80');

-- ----------------------------
-- Table structure for `server_oris`
-- ----------------------------
DROP TABLE IF EXISTS `server_oris`;
CREATE TABLE `server_oris` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `OrgName` varchar(64) NOT NULL,
  `OrgOwner` varchar(24) NOT NULL,
  `OrgMotto` varchar(128) NOT NULL,
  `OrgKasse` int(128) NOT NULL,
  `OrgMBeitrag` int(18) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_oris
-- ----------------------------
INSERT INTO `server_oris` VALUES ('1', 'Jake GmbH', 'Jake', 'Keins', '2670167', '0');
INSERT INTO `server_oris` VALUES ('2', 'require gmbh', 'require', 'wir helfen ihnen sehr gerne', '9473349', '0');
INSERT INTO `server_oris` VALUES ('3', 'HellsAngel', 'Bergustelo', 'Keins', '0', '0');
INSERT INTO `server_oris` VALUES ('4', 'cryless Entertainment', 'cryless', 'Keins', '0', '0');

-- ----------------------------
-- Table structure for `server_patei`
-- ----------------------------
DROP TABLE IF EXISTS `server_patei`;
CREATE TABLE `server_patei` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ParteiName` varchar(64) NOT NULL,
  `ParteiOwner` varchar(24) NOT NULL,
  `ParteiMotto` varchar(128) NOT NULL,
  `ParteiKasse` int(128) NOT NULL,
  `ParteiMBeitrag` int(18) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_patei
-- ----------------------------

-- ----------------------------
-- Table structure for `server_schwarzmarkt`
-- ----------------------------
DROP TABLE IF EXISTS `server_schwarzmarkt`;
CREATE TABLE `server_schwarzmarkt` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `sfraktid` int(4) NOT NULL,
  `sbdfraktid` int(4) NOT NULL,
  `sx` float(10,4) NOT NULL,
  `sy` float(10,4) NOT NULL,
  `sz` float(10,4) NOT NULL,
  `slocked` int(2) NOT NULL,
  `smaterials` int(18) NOT NULL,
  `swerbetext` varchar(128) NOT NULL,
  `sprice` int(18) NOT NULL,
  `skasse` int(18) NOT NULL,
  `sartikel0` int(18) NOT NULL,
  `sartikel1` int(18) NOT NULL,
  `sartikel2` int(18) NOT NULL,
  `sartikel3` int(18) NOT NULL,
  `sartikel4` int(18) NOT NULL,
  `sartikel5` int(18) NOT NULL,
  `sartikel6` int(18) NOT NULL,
  `sartikel7` int(18) NOT NULL,
  `sartikel8` int(18) NOT NULL,
  `sartikel9` int(18) NOT NULL,
  `sartikel10` int(18) NOT NULL,
  `sartikel11` int(18) NOT NULL,
  `sartikel12` int(18) NOT NULL,
  `sartikel13` int(18) NOT NULL,
  `sattackerfraktid` int(4) NOT NULL,
  `swarownerpoints` int(8) NOT NULL,
  `swarattackerpoints` int(8) NOT NULL,
  `swartime` int(128) NOT NULL,
  `swarsleep` int(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_schwarzmarkt
-- ----------------------------

-- ----------------------------
-- Table structure for `server_stuff`
-- ----------------------------
DROP TABLE IF EXISTS `server_stuff`;
CREATE TABLE `server_stuff` (
  `id` int(1) NOT NULL AUTO_INCREMENT,
  `ADPreis` int(20) NOT NULL,
  `PlayerRekord` int(20) NOT NULL,
  `Lottojackpot` int(20) NOT NULL,
  `RentVehsPreis` int(20) NOT NULL,
  `TerrorSpawn` int(3) NOT NULL,
  `Lohnsteuer` float(10,4) NOT NULL,
  `Kirchensteuer` float(10,4) NOT NULL,
  `Mwst` float(10,4) NOT NULL,
  `Grundsteuer` float(10,4) NOT NULL,
  `OamtStandGebuer` int(20) NOT NULL,
  `Solidsteuer` float(10,4) NOT NULL,
  `Reichensteuer` float(10,4) NOT NULL,
  `WLS` int(3) NOT NULL,
  `WSF` int(3) NOT NULL,
  `WLV` int(3) NOT NULL,
  `PreisLicCar` int(20) NOT NULL,
  `PreisLicBike` int(20) NOT NULL,
  `PreisLicRoller` int(20) NOT NULL,
  `PreisLicPlane` int(20) NOT NULL,
  `PreisLicHeli` int(20) NOT NULL,
  `PreisLicBoat` int(20) NOT NULL,
  `TerrorContractRang` int(2) NOT NULL,
  `FMeldePreis` int(20) NOT NULL,
  `NewspaperPreis` int(4) NOT NULL,
  `NewspaperText1` varchar(256) NOT NULL,
  `NewspaperText2` varchar(256) NOT NULL,
  `NewspaperText3` varchar(256) NOT NULL,
  `NewspaperText4` varchar(256) NOT NULL,
  `NewspaperText5` varchar(256) NOT NULL,
  `NewspaperText6` varchar(256) NOT NULL,
  `NewspaperText7` varchar(256) NOT NULL,
  `NewspaperText8` varchar(256) NOT NULL,
  `NewsPaperRealeased` int(12) NOT NULL,
  `NewsPaperLager1` int(12) NOT NULL,
  `NewsPaperLager2` int(12) NOT NULL,
  `EisenLagger1` int(12) NOT NULL,
  `EisenLagger2` int(12) NOT NULL,
  `Kartfahrer1` varchar(24) NOT NULL,
  `KartTime1` int(28) NOT NULL,
  `FreemanPrice` int(6) NOT NULL,
  `wHackPrice` int(6) NOT NULL,
  `SAPDpay` int(6) NOT NULL,
  `FBIpay` int(6) NOT NULL,
  `SAFDpay` int(6) NOT NULL,
  `ARMYpay` int(6) NOT NULL,
  `OAMTpay` int(6) NOT NULL,
  `GOVpay` int(6) NOT NULL,
  `WorkLessMoney` int(6) NOT NULL,
  `BlitzerToleranz` int(6) NOT NULL,
  `JobSperreFree` int(20) NOT NULL,
  `AngelLicPrice` int(20) NOT NULL,
  `PersoLicPrice` int(20) NOT NULL,
  `WeapPrice` int(20) NOT NULL,
  `ParkPrice` int(20) NOT NULL,
  `HolzLagger1` int(12) NOT NULL,
  `HolzLagger2` int(12) NOT NULL,
  `NextFreeHousekey` int(12) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_stuff
-- ----------------------------
INSERT INTO `server_stuff` VALUES ('1', '0', '0', '9969', '0', '1', '1.0000', '0.0000', '0.0000', '0.0000', '100', '0.0000', '0.0000', '9', '0', '6', '0', '0', '0', '0', '0', '0', '0', '250', '0', '', '', '', '', '', '', '', '', '0', '0', '0', '0', '0', 'Scarfars', '39', '0', '0', '450', '450', '450', '0', '450', '450', '430', '5', '160', '100', '35', '600', '50', '0', '0', '275');

-- ----------------------------
-- Table structure for `server_werbungsschilder`
-- ----------------------------
DROP TABLE IF EXISTS `server_werbungsschilder`;
CREATE TABLE `server_werbungsschilder` (
  `id` int(3) NOT NULL,
  `Text` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_werbungsschilder
-- ----------------------------
INSERT INTO `server_werbungsschilder` VALUES ('0', 'Willkommen-auf-unserem-Server');
INSERT INTO `server_werbungsschilder` VALUES ('1', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('2', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('3', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('4', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('8', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('6', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('10', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('11', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('12', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('13', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('5', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('15', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('16', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('7', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('18', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('9', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('17', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('19', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('21', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('14', 'Dieses Schild steht Frei!');
INSERT INTO `server_werbungsschilder` VALUES ('20', 'Dieses Schild steht Frei!');

-- ----------------------------
-- Table structure for `server_wobjecte`
-- ----------------------------
DROP TABLE IF EXISTS `server_wobjecte`;
CREATE TABLE `server_wobjecte` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ObjectID` int(10) NOT NULL,
  `sperreX` float(10,4) NOT NULL,
  `sperreY` float(10,4) NOT NULL,
  `sperreZ` float(10,4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of server_wobjecte
-- ----------------------------

-- ----------------------------
-- Table structure for `spieler`
-- ----------------------------
DROP TABLE IF EXISTS `spieler`;
CREATE TABLE `spieler` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(24) NOT NULL,
  `Online` int(2) NOT NULL,
  `Email` varchar(128) NOT NULL,
  `Passwort` varchar(64) NOT NULL,
  `Tutorial` int(2) NOT NULL,
  `Admin` int(2) NOT NULL,
  `Verwarnungen` int(2) NOT NULL,
  `FLeaderRechte` int(2) NOT NULL,
  `Fraktion` int(2) NOT NULL,
  `FraktionsRang` int(2) NOT NULL,
  `FraktionsURang` int(2) NOT NULL,
  `FraktionsSperre` int(2) NOT NULL,
  `FraktionsGehalt` int(6) NOT NULL,
  `Job` int(3) NOT NULL,
  `JobWarns` int(2) NOT NULL,
  `JobSperre` int(128) NOT NULL,
  `AbgefahreneJobCheckPoints` int(4) NOT NULL,
  `ArbeitslosenGeld` int(4) NOT NULL,
  `Geschlecht` int(4) NOT NULL,
  `SpielerAlter` int(4) NOT NULL,
  `Level` int(4) NOT NULL,
  `Geld` int(40) NOT NULL,
  `GWD` int(3) NOT NULL,
  `Zivinote` int(3) NOT NULL,
  `FAbteilung` int(3) NOT NULL,
  `Bankguthaben` int(40) NOT NULL,
  `BankPin` int(96) NOT NULL,
  `WantedSterne` int(2) NOT NULL,
  `WantedPunkte` int(2) NOT NULL,
  `Suspects` int(6) NOT NULL,
  `Wanted_Grund1` varchar(128) NOT NULL,
  `Wanted_Grund2` varchar(128) NOT NULL,
  `Wanted_Grund3` varchar(128) NOT NULL,
  `Wanted_Grund4` varchar(128) NOT NULL,
  `Wanted_Grund5` varchar(128) NOT NULL,
  `pWantedDeaths` int(10) NOT NULL,
  `pBuyTickets` int(10) NOT NULL,
  `pJailedCount` int(10) NOT NULL,
  `Crimes` int(3) NOT NULL,
  `STVOcrimes` int(2) NOT NULL,
  `KampfStyle` int(2) NOT NULL,
  `Handy` int(2) NOT NULL,
  `MobilTelefonFlat` int(2) NOT NULL,
  `Handycoins` int(3) NOT NULL,
  `MobilVertragBiz` int(4) NOT NULL,
  `HandyStatus` int(2) NOT NULL,
  `HandyAkku` float(4,2) NOT NULL,
  `HandyNummer` int(20) NOT NULL,
  `Handyflat` int(3) NOT NULL,
  `Handyflatbuyinbiz` int(40) NOT NULL,
  `Letzte_X` float(40,4) NOT NULL,
  `Letzte_Y` float(40,4) NOT NULL,
  `Letzte_Z` float(40,4) NOT NULL,
  `Letzte_Interior` int(3) NOT NULL,
  `Letzte_VirtualWorld` int(11) NOT NULL,
  `pSelectHome` int(3) NOT NULL,
  `HausMieter` int(3) NOT NULL,
  `Spawn` int(2) NOT NULL,
  `Hotel` int(2) NOT NULL,
  `Tod` int(2) NOT NULL,
  `Tot_X` float(40,4) NOT NULL,
  `Tot_Y` float(40,4) NOT NULL,
  `Tot_Z` float(40,4) NOT NULL,
  `Tot_Interior` int(3) NOT NULL,
  `Tot_VirtualWorld` int(11) NOT NULL,
  `TotZeit` int(4) NOT NULL,
  `Friedhof` int(2) NOT NULL,
  `FriedhofZeit` int(4) NOT NULL,
  `ImKnast` int(2) NOT NULL,
  `KnastZeit` int(4) NOT NULL,
  `KnastKaution` int(2) NOT NULL,
  `Muted` int(2) NOT NULL,
  `MuteZeit` int(4) NOT NULL,
  `ImPrison` int(2) NOT NULL,
  `PrisonCheckPointsAbgelaufen` int(6) NOT NULL,
  `PrisonCheckPointsGegeben` int(6) NOT NULL,
  `Morde` int(4) NOT NULL,
  `Tode` int(4) NOT NULL,
  `SkinID` int(3) NOT NULL,
  `FraktionSkinID` int(3) NOT NULL,
  `PaintBallKills` int(40) NOT NULL,
  `PaintBallTode` int(40) NOT NULL,
  `PaintBallRang` int(3) NOT NULL,
  `PaintBallBesuche` int(8) NOT NULL,
  `AngenommeneReports` int(6) NOT NULL,
  `KopfGeld` int(40) NOT NULL,
  `Bankkonto` int(2) NOT NULL,
  `pArmyPlaneOrder` int(2) NOT NULL,
  `pArmyHeliOrder` int(2) NOT NULL,
  `pArmyWaffenOrder` int(2) NOT NULL,
  `LevelUPKosten` int(40) NOT NULL,
  `RespectForLevelUp` int(6) NOT NULL,
  `RespectFromPayday` int(6) NOT NULL,
  `TimeAfterRegister` int(12) NOT NULL,
  `Time4Payday` int(3) NOT NULL,
  `HabGeworben` int(2) NOT NULL,
  `RpChat` int(3) NOT NULL,
  `pPremium` int(128) NOT NULL,
  `GeworbenerSpieler` varchar(24) NOT NULL,
  `TimeoutCrashExeorKick` int(3) NOT NULL,
  `PropertyClearTime` int(128) NOT NULL,
  `pScheinSperre` int(128) NOT NULL,
  `DigiHud` int(2) NOT NULL,
  `Bonus` int(2) NOT NULL,
  `pFirmaLeader` int(4) NOT NULL,
  `pFirmaMember` int(4) NOT NULL,
  `pOrgLeader` int(4) NOT NULL,
  `pOrgMember` int(4) NOT NULL,
  `pParteiLeader` int(4) NOT NULL,
  `pParteiMember` int(4) NOT NULL,
  `pLohn` int(12) NOT NULL,
  `WaitPerso` int(128) NOT NULL,
  `pMarried` varchar(24) NOT NULL,
  `pBuyClothes` int(6) NOT NULL,
  `pIll` int(40) NOT NULL,
  `pConterminatedTime` int(40) NOT NULL,
  `pBitchSkill` int(40) NOT NULL,
  `pBitchFuckCount` int(40) NOT NULL,
  `pMedicHealplayerSkill` int(40) NOT NULL,
  `pMedicHealCount` int(40) NOT NULL,
  `BG` int(2) NOT NULL DEFAULT '0',
  `AdminDescription` varchar(32) NOT NULL DEFAULT 'Keine Infomation',
  `Gutschein` int(2) NOT NULL,
  `pCoins` int(12) NOT NULL DEFAULT '0',
  `pDHitsound` int(2) NOT NULL,
  `spielercol` varchar(45) NOT NULL,
  `pTsIdent` varchar(45) NOT NULL,
  `E_JoinMessage` varchar(20) NOT NULL,
  `cLeben` int(20) NOT NULL,
  `cServerLeiste` int(20) NOT NULL,
  `cUpdate` int(20) NOT NULL,
  `cPickup` int(20) NOT NULL,
  `cFahrzeug` int(20) NOT NULL,
  `pNeuling` int(20) NOT NULL,
  `cSound` int(20) NOT NULL,
  `pTeleAnzeige` int(20) NOT NULL,
  `pRingTone` int(20) NOT NULL,
  `pHandyFortung` int(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler
-- ----------------------------
INSERT INTO `spieler` VALUES ('1', 'require', '0', '456@', '5690D363233FAB288D51E9B4B4C70EDB', '1', '8', '0', '1', '11', '6', '0', '0', '1600', '4', '0', '1484151859', '0', '0', '1', '792505036', '10', '78175', '0', '0', '0', '68163', '6122', '0', '0', '0', '-', '-', '-', '-', '-', '0', '1', '0', '0', '0', '4', '1', '0', '752', '0', '1', '19.49', '751958', '0', '0', '318.6693', '1117.7590', '1083.8828', '5', '12', '12', '0', '1', '0', '0', '582.2761', '-1840.0403', '5.4609', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3', '2', '29', '42', '0', '0', '0', '0', '2', '0', '1', '0', '0', '1', '8000', '30', '6', '58445', '1339', '1', '0', '1', 'Niemand', '0', '1485376774', '0', '0', '0', '0', '0', '2', '2', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '0', '1', '0', '1', '0', '2', '1');
INSERT INTO `spieler` VALUES ('11', 'cryless', '0', 'reminder@', '8C3C4B9295A3EA5F01405E0BD29C814E', '1', '7', '0', '0', '0', '0', '0', '0', '0', '9', '0', '1484080156', '0', '0', '1', '792522805', '20', '333483', '0', '0', '0', '4908', '604', '0', '0', '1', 'Cheater(6 WPS)', '-', '-', '-', '-', '0', '0', '0', '1', '1', '4', '1', '0', '149', '0', '1', '5.50', '1075291', '0', '0', '322.0511', '1120.6409', '1083.8828', '5', '12', '124', '0', '0', '0', '0', '578.6985', '-1838.9893', '5.4609', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '2', '3', '19', '0', '0', '0', '0', '0', '0', '10000', '1', '0', '0', '0', '16000', '60', '3', '81248', '1835', '1', '0', '1', 'Niemand', '0', '1485373091', '0', '0', '0', '0', '0', '4', '4', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1');
INSERT INTO `spieler` VALUES ('10', 'AdamRuzek', '0', 'AdamRuzek@', '527DCBCAD2CBFA69C2CBEB1CBC574484', '1', '7', '0', '1', '9', '6', '0', '0', '1600', '0', '0', '0', '0', '0', '1', '792519914', '1', '2117', '0', '0', '0', '222', '1337', '0', '0', '0', '-', '-', '-', '-', '-', '0', '0', '0', '0', '0', '4', '0', '0', '0', '0', '0', '0.00', '0', '0', '0', '1533.8612', '-1291.2191', '15.8116', '0', '0', '201', '0', '2', '0', '0', '0.0000', '0.0000', '0.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '19', '186', '0', '0', '0', '0', '1', '0', '1', '0', '0', '0', '800', '3', '0', '3126', '3126', '0', '0', '1', 'Niemand', '1', '1484940630', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '1', '1', '1', '0', '0', '0');
INSERT INTO `spieler` VALUES ('13', 'Raven', '0', 'testaccount@', '0EFFFC51D5E228E69BEC75545457B977', '1', '6', '0', '1', '1', '6', '0', '0', '1600', '0', '0', '0', '0', '0', '1', '792518788', '1', '2481', '0', '0', '0', '0', '0', '0', '0', '0', '-', '-', '-', '-', '-', '0', '0', '0', '0', '0', '4', '0', '0', '0', '0', '0', '0.00', '0', '0', '0', '1012.6846', '-1320.7036', '13.0866', '0', '0', '0', '0', '0', '0', '0', '0.0000', '0.0000', '0.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '19', '280', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '800', '3', '0', '1142', '1142', '0', '0', '1', 'Niemand', '0', '1484752194', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '1', '1', '1', '0', '0', '0');
INSERT INTO `spieler` VALUES ('12', 'Jeff_Hardy', '0', 'Jeff_Hardy@', '135BC85D9FA96E664B293FB952866A1B', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '887113638', '1', '2490', '0', '0', '0', '0', '0', '0', '0', '0', '-', '-', '-', '-', '-', '0', '0', '0', '0', '0', '4', '0', '0', '0', '0', '0', '0.00', '0', '0', '0', '1070.6154', '-1047.7620', '31.8472', '0', '0', '0', '0', '0', '0', '0', '0.0000', '0.0000', '0.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '23', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '800', '3', '0', '30', '30', '0', '0', '1', 'Niemand', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '1', '1', '1', '0', '0', '0');
INSERT INTO `spieler` VALUES ('14', 'Jake', '1', 'baum123@', 'FCB7929D2B37C0F31D38E95D34E9F0A9', '1', '7', '0', '1', '8', '6', '0', '0', '1600', '9', '0', '1484153495', '0', '0', '1', '792502056', '3', '59980', '0', '0', '0', '2960', '301', '0', '0', '0', '-', '-', '-', '-', '-', '0', '0', '0', '0', '0', '4', '2', '0', '0', '0', '0', '83.20', '1068097', '0', '0', '301.9699', '300.3623', '999.1484', '4', '0', '0', '0', '2', '0', '0', '0.0000', '0.0000', '0.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '2', '0', '17', '165', '0', '0', '0', '0', '0', '0', '1', '0', '0', '1', '2400', '9', '1', '14445', '1599', '0', '0', '1', 'Niemand', '0', '1485356813', '0', '0', '0', '0', '0', '1', '1', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '1', '1', '1', '0', '0', '0');
INSERT INTO `spieler` VALUES ('15', 'require2', '0', '@', 'B51E8DBEBD4BA8A8F342190A4B9F08D7', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '792532510', '1', '2490', '0', '0', '0', '0', '0', '0', '0', '0', '-', '-', '-', '-', '-', '0', '0', '0', '0', '0', '4', '0', '0', '0', '0', '0', '0.00', '0', '0', '0', '545.2557', '-1803.8796', '6.0625', '0', '0', '0', '0', '0', '0', '0', '0.0000', '0.0000', '0.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '800', '3', '0', '24', '24', '0', '0', '1', 'Niemand', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '0', '1', '1', '1', '1', '1', '1', '0', '0', '0');
INSERT INTO `spieler` VALUES ('16', 'Bergustelo', '0', ' @@@@@@@', '88AA04FC83F8B00465B43A1A5BAC8E78', '1', '7', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '22', '1', '9492897', '0', '0', '0', '0', '0', '0', '3', '1', 'Adminfahrzeug diebstahl(5 WPS)', '-', '-', '-', '-', '0', '0', '0', '1', '0', '4', '1', '0', '0', '0', '0', '99.99', '828158', '0', '0', '570.8112', '-1830.9717', '5.6328', '0', '0', '0', '0', '0', '0', '0', '0.0000', '0.0000', '0.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '17', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '800', '3', '1', '4403', '803', '0', '0', '1', 'Niemand', '0', '1485353160', '0', '0', '0', '0', '0', '3', '3', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '0', '1', '0', '1', '0', '0');
INSERT INTO `spieler` VALUES ('17', 'Colore', '0', '@@@@@@@', 'D89E6C08C963F2AEF2B78C7C5E9C1BA2', '1', '5', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '16', '1', '600000', '0', '0', '0', '0', '0', '0', '0', '0', '-', '-', '-', '-', '-', '0', '0', '0', '0', '0', '4', '0', '0', '0', '0', '0', '0.00', '0', '0', '0', '583.1443', '-1830.0142', '5.7720', '0', '0', '0', '0', '0', '0', '0', '582.2761', '-1840.0403', '5.4609', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '3', '2', '6', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1', '800', '3', '0', '53', '53', '0', '0', '1', 'Niemand', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'Niemand', '-1', '0', '0', '0', '0', '0', '0', '0', 'Keine Infomation', '0', '0', '0', '', '', '', '1', '1', '1', '1', '0', '1', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_adventskalender`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_adventskalender`;
CREATE TABLE `spieler_adventskalender` (
  `Name` varchar(24) NOT NULL,
  `ADVENT_1` int(10) NOT NULL,
  `ADVENT_2` int(10) NOT NULL,
  `ADVENT_3` int(10) NOT NULL,
  `ADVENT_4` int(10) NOT NULL,
  `ADVENT_5` int(10) NOT NULL,
  `ADVENT_6` int(10) NOT NULL,
  `ADVENT_7` int(10) NOT NULL,
  `ADVENT_8` int(10) NOT NULL,
  `ADVENT_9` int(10) NOT NULL,
  `ADVENT_10` int(10) NOT NULL,
  `ADVENT_11` int(10) NOT NULL,
  `ADVENT_12` int(10) NOT NULL,
  `ADVENT_13` int(10) NOT NULL,
  `ADVENT_14` int(10) NOT NULL,
  `ADVENT_15` int(10) NOT NULL,
  `ADVENT_16` int(10) NOT NULL,
  `ADVENT_17` int(10) NOT NULL,
  `ADVENT_18` int(10) NOT NULL,
  `ADVENT_19` int(10) NOT NULL,
  `ADVENT_20` int(10) NOT NULL,
  `ADVENT_21` int(10) NOT NULL,
  `ADVENT_22` int(10) NOT NULL,
  `ADVENT_23` int(10) NOT NULL,
  `ADVENT_24` int(10) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_adventskalender
-- ----------------------------

-- ----------------------------
-- Table structure for `spieler_alogin`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_alogin`;
CREATE TABLE `spieler_alogin` (
  `Name` varchar(24) NOT NULL,
  `IP` varchar(16) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_alogin
-- ----------------------------

-- ----------------------------
-- Table structure for `spieler_bsafe`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_bsafe`;
CREATE TABLE `spieler_bsafe` (
  `Name` varchar(24) NOT NULL,
  `safetresor` int(2) NOT NULL,
  `ganja` int(10) NOT NULL,
  `kokain` int(10) NOT NULL,
  `opium` int(10) NOT NULL,
  `materials` int(10) NOT NULL,
  `c4` int(10) NOT NULL,
  `lunchpaket` int(10) NOT NULL,
  `matspackete` int(10) NOT NULL,
  `bier` int(10) NOT NULL,
  `zigaretten` int(10) NOT NULL,
  `werkzeugkaesten` int(10) NOT NULL,
  `benzinkanister` int(10) NOT NULL,
  `koeder` int(10) NOT NULL,
  `kondome` int(10) NOT NULL,
  `duenger` int(10) NOT NULL,
  `spice` int(10) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_bsafe
-- ----------------------------
INSERT INTO `spieler_bsafe` VALUES ('require', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('AdamRuzek', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('cryless', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('Jeff_Hardy', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('Raven', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('Jake', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('require2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('Bergustelo', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_bsafe` VALUES ('Colore', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_fahrzeuge`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_fahrzeuge`;
CREATE TABLE `spieler_fahrzeuge` (
  `id` int(30) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `slot` int(30) NOT NULL,
  `modelid` int(30) NOT NULL,
  `x` float(30,4) NOT NULL,
  `y` float(30,4) NOT NULL,
  `z` float(30,4) NOT NULL,
  `a` float(30,4) NOT NULL,
  `interior` int(30) NOT NULL,
  `world` int(30) NOT NULL,
  `cc1` int(30) NOT NULL,
  `cc2` int(30) NOT NULL,
  `paintjob` int(30) NOT NULL,
  `vehhp` float(30,4) NOT NULL,
  `abgeschlossen` int(30) NOT NULL,
  `t1` int(30) NOT NULL,
  `t2` int(30) NOT NULL,
  `t3` int(30) NOT NULL,
  `t4` int(30) NOT NULL,
  `t5` int(30) NOT NULL,
  `t6` int(30) NOT NULL,
  `t7` int(30) NOT NULL,
  `t8` int(30) NOT NULL,
  `t9` int(30) NOT NULL,
  `t10` int(30) NOT NULL,
  `t11` int(30) NOT NULL,
  `t12` int(30) NOT NULL,
  `t13` int(30) NOT NULL,
  `t14` int(30) NOT NULL,
  `angemeldet` int(30) NOT NULL,
  `atime` int(30) NOT NULL,
  `atAnmeldung` int(30) NOT NULL,
  `preis` int(30) NOT NULL,
  `nummernschild` varchar(30) NOT NULL,
  `neon` int(30) NOT NULL,
  `motordown` int(30) NOT NULL,
  `failgas` int(30) NOT NULL,
  `tank` float(30,4) NOT NULL,
  `km` int(30) NOT NULL,
  `towed` int(30) NOT NULL,
  `towedfreeprice` int(30) NOT NULL,
  `towedreason` varchar(30) NOT NULL,
  `kganja` int(30) NOT NULL,
  `kkokain` int(30) NOT NULL,
  `kopium` int(30) NOT NULL,
  `kmats` int(30) NOT NULL,
  `klunch` int(30) NOT NULL,
  `kc4` int(30) NOT NULL,
  `kwkanister` int(30) NOT NULL,
  `kkanister` int(30) NOT NULL,
  `handbrake` int(30) NOT NULL,
  `kspice` int(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_fahrzeuge
-- ----------------------------
INSERT INTO `spieler_fahrzeuge` VALUES ('8', 'cryless', '1', '522', '559.0925', '-1813.7820', '6.0734', '264.3838', '0', '0', '0', '0', '0', '1000.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'N/A', '0', '0', '0', '0.0000', '0', '0', '0', 'NONE', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fahrzeuge` VALUES ('2', 'cryless', '0', '411', '-2651.7109', '262.6178', '4.3281', '256.7777', '0', '0', '182', '208', '-1', '983.8483', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'N/A', '0', '0', '0', '70.0000', '1083', '0', '0', '', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fahrzeuge` VALUES ('7', 'require', '0', '560', '545.3311', '-1764.7466', '5.4534', '178.7153', '0', '0', '1', '1', '-1', '1000.0000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'N/A', '0', '0', '0', '60.0000', '59', '0', '0', '', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fahrzeuge` VALUES ('11', 'cryless', '2', '560', '584.4431', '-1830.1871', '5.7912', '205.3844', '0', '0', '0', '0', '0', '1000.0000', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'N/A', '0', '0', '0', '0.0000', '0', '0', '0', 'NONE', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fahrzeuge` VALUES ('10', 'require', '1', '560', '1110.0104', '-1677.1499', '13.0904', '266.4390', '0', '0', '1', '1', '-1', '1000.0000', '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 'N/A', '0', '0', '0', '60.0000', '0', '1', '500', 'pech | cryless', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_fishe`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_fishe`;
CREATE TABLE `spieler_fishe` (
  `Name` varchar(24) NOT NULL,
  `FishID0` int(3) NOT NULL,
  `FishID1` int(3) NOT NULL,
  `FishID2` int(3) NOT NULL,
  `FishID3` int(3) NOT NULL,
  `FishID4` int(3) NOT NULL,
  `FishID5` int(3) NOT NULL,
  `Fishweight0` int(10) NOT NULL,
  `Fishweight1` int(10) NOT NULL,
  `Fishweight2` int(10) NOT NULL,
  `Fishweight3` int(10) NOT NULL,
  `Fishweight4` int(10) NOT NULL,
  `Fishweight5` int(10) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_fishe
-- ----------------------------
INSERT INTO `spieler_fishe` VALUES ('require', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('AdamRuzek', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('cryless', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('Jeff_Hardy', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('Raven', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('Jake', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('require2', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('Bergustelo', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_fishe` VALUES ('Colore', '0', '-1', '-1', '-1', '-1', '-1', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_koffer`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_koffer`;
CREATE TABLE `spieler_koffer` (
  `Name` varchar(24) NOT NULL,
  `Slot0` int(10) NOT NULL,
  `Slot1` int(10) NOT NULL,
  `Slot2` int(10) NOT NULL,
  `Slot3` int(10) NOT NULL,
  `Slot4` int(10) NOT NULL,
  `Slot5` int(10) NOT NULL,
  `Slot6` int(10) NOT NULL,
  `Slot7` int(10) NOT NULL,
  `Slot8` int(10) NOT NULL,
  `Slot9` int(10) NOT NULL,
  `Slot10` int(10) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_koffer
-- ----------------------------
INSERT INTO `spieler_koffer` VALUES ('require', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('AdamRuzek', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('cryless', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('Jeff_Hardy', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('Raven', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('Jake', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('require2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('Bergustelo', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_koffer` VALUES ('Colore', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_scheine`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_scheine`;
CREATE TABLE `spieler_scheine` (
  `Name` varchar(24) NOT NULL,
  `car` int(2) NOT NULL,
  `bike` int(2) NOT NULL,
  `roller` int(2) NOT NULL,
  `boat` int(2) NOT NULL,
  `plane` int(2) NOT NULL,
  `helicopter` int(2) NOT NULL,
  `weapon` int(2) NOT NULL,
  `fishing` int(2) NOT NULL,
  `personality` int(2) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_scheine
-- ----------------------------
INSERT INTO `spieler_scheine` VALUES ('require', '1', '1', '1', '1', '1', '1', '3', '1', '1');
INSERT INTO `spieler_scheine` VALUES ('AdamRuzek', '1', '1', '1', '1', '1', '1', '3', '1', '1');
INSERT INTO `spieler_scheine` VALUES ('cryless', '1', '1', '1', '1', '1', '1', '3', '1', '1');
INSERT INTO `spieler_scheine` VALUES ('Jeff_Hardy', '0', '0', '1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_scheine` VALUES ('Raven', '1', '1', '1', '1', '1', '1', '3', '1', '1');
INSERT INTO `spieler_scheine` VALUES ('Jake', '1', '1', '1', '1', '1', '1', '3', '1', '1');
INSERT INTO `spieler_scheine` VALUES ('require2', '0', '0', '1', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_scheine` VALUES ('Bergustelo', '1', '1', '1', '1', '1', '1', '3', '1', '1');
INSERT INTO `spieler_scheine` VALUES ('Colore', '1', '1', '1', '1', '1', '1', '3', '1', '1');

-- ----------------------------
-- Table structure for `spieler_schwarzeliste`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_schwarzeliste`;
CREATE TABLE `spieler_schwarzeliste` (
  `Name` varchar(24) NOT NULL,
  `blacklist0` int(4) NOT NULL,
  `blacklistreason0` int(4) NOT NULL,
  `blacklist1` int(4) NOT NULL,
  `blacklistreason1` int(4) NOT NULL,
  `blacklist2` int(4) NOT NULL,
  `blacklistreason2` int(4) NOT NULL,
  `blacklist3` int(4) NOT NULL,
  `blacklistreason3` int(4) NOT NULL,
  `blacklist4` int(4) NOT NULL,
  `blacklistreason4` int(4) NOT NULL,
  `blacklist5` int(4) NOT NULL,
  `blacklistreason5` int(4) NOT NULL,
  `blacklist6` int(4) NOT NULL,
  `blacklistreason6` int(4) NOT NULL,
  `blacklist7` int(4) NOT NULL,
  `blacklistreason7` int(4) NOT NULL,
  `blacklist8` int(4) NOT NULL,
  `blacklistreason8` int(4) NOT NULL,
  `blacklist9` int(4) NOT NULL,
  `blacklistreason9` int(4) NOT NULL,
  `blacklist10` int(4) NOT NULL,
  `blacklistreason10` int(4) NOT NULL,
  `blacklist11` int(4) NOT NULL,
  `blacklistreason11` int(4) NOT NULL,
  `blacklist12` int(4) NOT NULL,
  `blacklistreason12` int(4) NOT NULL,
  `blacklist13` int(4) NOT NULL,
  `blacklistreason13` int(4) NOT NULL,
  `blacklist14` int(4) NOT NULL,
  `blacklistreason14` int(4) NOT NULL,
  `blacklist15` int(4) NOT NULL,
  `blacklistreason15` int(4) NOT NULL,
  `blacklist16` int(4) NOT NULL,
  `blacklistreason16` int(4) NOT NULL,
  `blacklist17` int(4) NOT NULL,
  `blacklistreason17` int(4) NOT NULL,
  `blacklist18` int(4) NOT NULL,
  `blacklistreason18` int(4) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_schwarzeliste
-- ----------------------------
INSERT INTO `spieler_schwarzeliste` VALUES ('require', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('AdamRuzek', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('cryless', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('Jeff_Hardy', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('Raven', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('Jake', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('require2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('Bergustelo', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_schwarzeliste` VALUES ('Colore', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_tasche`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_tasche`;
CREATE TABLE `spieler_tasche` (
  `Name` varchar(24) NOT NULL,
  `c4` int(10) NOT NULL,
  `materials` int(10) NOT NULL,
  `material_packs` int(10) NOT NULL,
  `lunchpackets` int(10) NOT NULL,
  `navi` int(10) NOT NULL,
  `helm` int(10) NOT NULL,
  `angel` int(10) NOT NULL,
  `angelkoeder` int(10) NOT NULL,
  `repairboxxes` int(10) NOT NULL,
  `refillgalons` int(10) NOT NULL,
  `koffer` int(10) NOT NULL,
  `zigarrets` int(10) NOT NULL,
  `alcohol` int(10) NOT NULL,
  `ganja` int(10) NOT NULL,
  `kokain` int(10) NOT NULL,
  `opium` int(10) NOT NULL,
  `ganjaseats` int(10) NOT NULL,
  `kokainseats` int(10) NOT NULL,
  `opiumseats` int(10) NOT NULL,
  `callbook` int(10) NOT NULL,
  `condoms` int(10) NOT NULL,
  `duenger` int(10) NOT NULL,
  `spice` int(10) NOT NULL,
  `spiceseats` int(10) NOT NULL,
  `lunchpakets` int(10) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_tasche
-- ----------------------------
INSERT INTO `spieler_tasche` VALUES ('require', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '66666', '66666', '0', '6316', '5435', '66586', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('AdamRuzek', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1000', '0', '0', '100', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('cryless', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '2000', '0', '0', '1940', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('Jeff_Hardy', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('Raven', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('Jake', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('require2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('Bergustelo', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_tasche` VALUES ('Colore', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for `spieler_waffen`
-- ----------------------------
DROP TABLE IF EXISTS `spieler_waffen`;
CREATE TABLE `spieler_waffen` (
  `Name` varchar(24) NOT NULL,
  `Waffen0` int(3) NOT NULL,
  `Waffen1` int(3) NOT NULL,
  `Waffen2` int(3) NOT NULL,
  `Waffen3` int(3) NOT NULL,
  `Waffen4` int(3) NOT NULL,
  `Waffen5` int(3) NOT NULL,
  `Waffen6` int(3) NOT NULL,
  `Waffen7` int(3) NOT NULL,
  `Waffen8` int(3) NOT NULL,
  `Waffen9` int(3) NOT NULL,
  `Waffen10` int(3) NOT NULL,
  `Waffen11` int(3) NOT NULL,
  `Waffen12` int(3) NOT NULL,
  `Ammo0` int(10) NOT NULL,
  `Ammo1` int(10) NOT NULL,
  `Ammo2` int(10) NOT NULL,
  `Ammo3` int(10) NOT NULL,
  `Ammo4` int(10) NOT NULL,
  `Ammo5` int(10) NOT NULL,
  `Ammo6` int(10) NOT NULL,
  `Ammo7` int(10) NOT NULL,
  `Ammo8` int(10) NOT NULL,
  `Ammo9` int(10) NOT NULL,
  `Ammo10` int(10) NOT NULL,
  `Ammo11` int(10) NOT NULL,
  `Ammo12` int(10) NOT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of spieler_waffen
-- ----------------------------
INSERT INTO `spieler_waffen` VALUES ('require', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('AdamRuzek', '0', '0', '0', '0', '0', '0', '0', '0', '0', '41', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '249', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('cryless', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('Raven', '0', '3', '24', '0', '29', '0', '0', '0', '0', '41', '0', '0', '0', '0', '0', '499', '0', '500', '0', '0', '0', '0', '1250', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('Jeff_Hardy', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('Jake', '0', '0', '24', '0', '29', '31', '0', '0', '0', '0', '0', '0', '0', '0', '0', '29', '0', '40', '497', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('require2', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('Bergustelo', '0', '0', '24', '0', '0', '31', '0', '0', '0', '0', '0', '0', '0', '0', '0', '866', '0', '0', '4862', '0', '0', '0', '0', '0', '0', '0');
INSERT INTO `spieler_waffen` VALUES ('Colore', '0', '0', '24', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '280', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0');
