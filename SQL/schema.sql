-- MySQL dump 10.13  Distrib 5.7.16, for Linux (x86_64)
--
-- Host: localhost    Database: development
-- ------------------------------------------------------
-- Server version	5.7.16-0ubuntu0.16.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bans`
--

DROP TABLE IF EXISTS `bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `cid` varchar(255) DEFAULT NULL,
  `reason` text NOT NULL,
  `job` varchar(255) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `time` datetime NOT NULL,
  `target_id` int(11) NOT NULL,
  `banned_by_id` int(11) NOT NULL,
  `expiration_time` datetime NOT NULL,

  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_time` datetime DEFAULT NULL,
  `unbanned_by_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bans_on_banned_by_id` (`banned_by_id`) USING BTREE,
  KEY `index_bans_on_target_id` (`target_id`) USING BTREE,
  KEY `index_bans_on_unbanned_by_id` (`unbanned_by_id`) USING BTREE,
  CONSTRAINT `fk_rails_20d480679b` FOREIGN KEY (`banned_by_id`) REFERENCES `players` (`id`),
  CONSTRAINT `fk_rails_62ac37e1e1` FOREIGN KEY (`target_id`) REFERENCES `players` (`id`),
  CONSTRAINT `fk_rails_a305c9e562` FOREIGN KEY (`unbanned_by_id`) REFERENCES `players` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `books`
--

DROP TABLE IF EXISTS `books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_books_on_author_id` (`author_id`),
  CONSTRAINT `fk_rails_53d51ce16a` FOREIGN KEY (`author_id`) REFERENCES `players` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(255) NOT NULL,
  `registered` date DEFAULT NULL,
  `first_seen` datetime NOT NULL,
  `last_seen` datetime NOT NULL,
  `ip` varchar(255) NOT NULL,
  `cid` varchar(255) NOT NULL,
  `rank` varchar(255) NOT NULL DEFAULT 'player',
  `flags` int(11) NOT NULL DEFAULT '0',
  `byond_version` varchar(255) NOT NULL,
  `country` varchar(255) NOT NULL,
  `VPN_check_white` tinyint(4) NOT NULL DEFAULT '0',
  `ip_related_ids` tinytext,
  `cid_related_ids` tinytext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_options`
--

DROP TABLE IF EXISTS `poll_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `poll_id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `min_value` int(11) DEFAULT NULL,
  `max_value` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_poll_options_on_poll_id` (`poll_id`),
  CONSTRAINT `fk_rails_aa85becb42` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_text_replies`
--

DROP TABLE IF EXISTS `poll_text_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_text_replies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime DEFAULT NULL,
  `poll_id` int(11) DEFAULT NULL,
  `player_id` int(11) DEFAULT NULL,
  `text` text,
  PRIMARY KEY (`id`),
  KEY `index_poll_text_replies_on_poll_id` (`poll_id`),
  KEY `index_poll_text_replies_on_player_id` (`player_id`),
  CONSTRAINT `fk_rails_0833f4df0b` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`),
  CONSTRAINT `fk_rails_ffc8df499f` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_votes`
--

DROP TABLE IF EXISTS `poll_votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `poll_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `option_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_poll_votes_on_poll_id` (`poll_id`),
  KEY `index_poll_votes_on_player_id` (`player_id`),
  KEY `index_poll_votes_on_option_id` (`option_id`),
  CONSTRAINT `fk_rails_826ebfbbb3` FOREIGN KEY (`option_id`) REFERENCES `poll_options` (`id`),
  CONSTRAINT `fk_rails_a3e5a3aede` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`),
  CONSTRAINT `fk_rails_a6e6974b7e` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `polls`
--

DROP TABLE IF EXISTS `polls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `polls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(16) NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `populations`
--

DROP TABLE IF EXISTS `populations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `populations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_count` int(11) NOT NULL,
  `admin_count` int(11) NOT NULL,
  `time` datetime NOT NULL,
  `server` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-01-21 10:28:19
