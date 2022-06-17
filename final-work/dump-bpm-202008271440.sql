-- MariaDB dump 10.17  Distrib 10.4.14-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: bpm
-- ------------------------------------------------------
-- Server version	10.4.14-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `owner` bigint(20) unsigned NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `name` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_closed` bit(1) NOT NULL DEFAULT b'0',
  `end_at` datetime DEFAULT NULL,
  `current_iteration` bigint(20) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `fk_project_owner__owner` (`owner`),
  KEY `project_current_iteration_idx` (`current_iteration`),
  CONSTRAINT `fk_project_owner__owner` FOREIGN KEY (`owner`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project`
--

LOCK TABLES `project` WRITE;
/*!40000 ALTER TABLE `project` DISABLE KEYS */;
INSERT INTO `project` VALUES (1,1,'2019-05-06 21:02:43','Музыкальный проигрователь',NULL,'\0','2020-05-06 21:02:43',1),(2,22,'2019-05-06 21:02:43','Чат бот',NULL,'','2020-05-06 21:02:43',1);
/*!40000 ALTER TABLE `project` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projectrole`
--

DROP TABLE IF EXISTS `projectrole`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projectrole` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `project_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_in_project` (`name`,`project_id`),
  KEY `fk_projectrole__project_id` (`project_id`),
  CONSTRAINT `fk_projectrole__project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projectrole`
--

LOCK TABLES `projectrole` WRITE;
/*!40000 ALTER TABLE `projectrole` DISABLE KEYS */;
INSERT INTO `projectrole` VALUES (3,'Бэк',1),(2,'Верстальщик',1),(5,'Владелец',1),(4,'Разраб БД',1),(1,'Тим лид',1);
/*!40000 ALTER TABLE `projectrole` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projectrow`
--

DROP TABLE IF EXISTS `projectrow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projectrow` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci DEFAULT 'New',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projectrow`
--

LOCK TABLES `projectrow` WRITE;
/*!40000 ALTER TABLE `projectrow` DISABLE KEYS */;
INSERT INTO `projectrow` VALUES (1,'Входящая'),(2,'В разработке'),(3,'Требует проверки'),(4,'Проверяется'),(5,'Завершена');
/*!40000 ALTER TABLE `projectrow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projecttags`
--

DROP TABLE IF EXISTS `projecttags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projecttags` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `project_id` bigint(20) unsigned NOT NULL,
  `tag_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_projecttags__tag_id` (`tag_id`),
  KEY `fk_projecttags__project_id` (`project_id`),
  CONSTRAINT `fk_projecttags__project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `fk_projecttags__tag_id` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projecttags`
--

LOCK TABLES `projecttags` WRITE;
/*!40000 ALTER TABLE `projecttags` DISABLE KEYS */;
INSERT INTO `projecttags` VALUES (1,1,1),(2,1,2);
/*!40000 ALTER TABLE `projecttags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (4,'cumque'),(9,'deserunt'),(10,'dignissimos'),(5,'fuga'),(7,'fugiat'),(1,'iure'),(8,'nam'),(3,'rerum'),(2,'sed'),(6,'totam');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taskcoperformer`
--

DROP TABLE IF EXISTS `taskcoperformer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taskcoperformer` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `taskproject_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_taskcoperformer__taskproject_id` (`taskproject_id`),
  KEY `fk_taskcoperformer__user_id` (`user_id`),
  CONSTRAINT `fk_taskcoperformer__taskproject_id` FOREIGN KEY (`taskproject_id`) REFERENCES `taskproject` (`id`),
  CONSTRAINT `fk_taskcoperformer__user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taskcoperformer`
--

LOCK TABLES `taskcoperformer` WRITE;
/*!40000 ALTER TABLE `taskcoperformer` DISABLE KEYS */;
INSERT INTO `taskcoperformer` VALUES (1,1,1);
/*!40000 ALTER TABLE `taskcoperformer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taskproject`
--

DROP TABLE IF EXISTS `taskproject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taskproject` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `projectrow_id` bigint(20) unsigned NOT NULL,
  `project_id` bigint(20) unsigned NOT NULL,
  `taskdirector` bigint(20) unsigned NOT NULL,
  `taskperformer` bigint(20) unsigned NOT NULL,
  `is_complete` bit(1) DEFAULT b'0',
  `is_checkoncomplete` bit(1) DEFAULT b'0',
  `result_url` varchar(204) COLLATE utf8_unicode_ci DEFAULT NULL,
  `update_at` datetime DEFAULT current_timestamp(),
  `end_at` datetime DEFAULT NULL,
  `iteration` bigint(20) unsigned NOT NULL,
  `tag_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_taskproject__projectrow_id` (`projectrow_id`),
  KEY `fk_taskproject__project_id` (`project_id`),
  KEY `fk_taskproject__taskdirector` (`taskdirector`),
  KEY `fk_taskproject__taskperformer` (`taskperformer`),
  CONSTRAINT `fk_taskproject__project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `fk_taskproject__projectrow_id` FOREIGN KEY (`projectrow_id`) REFERENCES `projectrow` (`id`),
  CONSTRAINT `fk_taskproject__taskdirector` FOREIGN KEY (`taskdirector`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_taskproject__taskperformer` FOREIGN KEY (`taskperformer`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taskproject`
--

LOCK TABLES `taskproject` WRITE;
/*!40000 ALTER TABLE `taskproject` DISABLE KEYS */;
INSERT INTO `taskproject` VALUES (1,'Проигрывание wav',NULL,1,1,1,22,'\0','',NULL,'2019-05-06 21:02:43','2020-05-06 21:02:43',4,1),(2,'Нарисовать скин',NULL,1,1,22,1,'\0','\0',NULL,'2019-05-06 21:02:43','2019-05-06 22:02:43',1,2),(3,'Обновить мдуль звука',NULL,1,1,3,22,'\0','',NULL,'2019-05-06 21:02:43','2019-05-06 21:02:43',1,3),(4,'Запрос списка радиостанций',NULL,4,2,23,21,'','',NULL,'2019-05-06 21:02:43','2019-05-06 21:02:43',1,1);
/*!40000 ALTER TABLE `taskproject` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `increase_project_iteration` BEFORE UPDATE 
    ON `taskproject` 
    FOR EACH ROW BEGIN
        IF NEW.iteration < OLD.iteration THEN
			SIGNAL SQLSTATE '40000' SET MESSAGE_TEXT = 'ERROR: taskiteration can\'t be decresed';
                    
        END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tasksprojectcomment`
--

DROP TABLE IF EXISTS `tasksprojectcomment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasksprojectcomment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `taskproject_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `update_at` datetime NOT NULL DEFAULT current_timestamp(),
  `message` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_message_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_tasksprojectcomment__taskproject_id` (`taskproject_id`),
  KEY `fk_tasksprojectcomment__user_id` (`user_id`),
  CONSTRAINT `fk_tasksprojectcomment__taskproject_id` FOREIGN KEY (`taskproject_id`) REFERENCES `taskproject` (`id`),
  CONSTRAINT `fk_tasksprojectcomment__user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasksprojectcomment`
--

LOCK TABLES `tasksprojectcomment` WRITE;
/*!40000 ALTER TABLE `tasksprojectcomment` DISABLE KEYS */;
INSERT INTO `tasksprojectcomment` VALUES (2,1,1,'2019-05-06 21:02:43','Нужно срочно запилить фичу!',NULL),(3,1,2,'2019-05-06 21:02:42','Уже !',1),(4,2,22,'2019-05-06 21:02:43','Кто рисует дизайн?',NULL);
/*!40000 ALTER TABLE `tasksprojectcomment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasktags`
--

DROP TABLE IF EXISTS `tasktags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasktags` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `taskproject_id` bigint(20) unsigned NOT NULL,
  `tag_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_tasktags__tag_id` (`tag_id`),
  KEY `fk_tasktags__taskproject_id` (`taskproject_id`),
  CONSTRAINT `fk_tasktags__tag_id` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`),
  CONSTRAINT `fk_tasktags__taskproject_id` FOREIGN KEY (`taskproject_id`) REFERENCES `taskproject` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasktags`
--

LOCK TABLES `tasktags` WRITE;
/*!40000 ALTER TABLE `tasktags` DISABLE KEYS */;
INSERT INTO `tasktags` VALUES (1,1,1),(2,1,2),(3,1,3),(4,2,3),(5,2,2),(6,2,4);
/*!40000 ALTER TABLE `tasktags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taskwatchers`
--

DROP TABLE IF EXISTS `taskwatchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taskwatchers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `taskproject_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_taskwatchers__taskproject_id` (`taskproject_id`),
  KEY `fk_taskwatchers__user_id` (`user_id`),
  CONSTRAINT `fk_taskwatchers__taskproject_id` FOREIGN KEY (`taskproject_id`) REFERENCES `taskproject` (`id`),
  CONSTRAINT `fk_taskwatchers__user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taskwatchers`
--

LOCK TABLES `taskwatchers` WRITE;
/*!40000 ALTER TABLE `taskwatchers` DISABLE KEYS */;
/*!40000 ALTER TABLE `taskwatchers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team`
--

DROP TABLE IF EXISTS `team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `owner_user_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `fk_team__owner_user_id` (`owner_user_id`),
  CONSTRAINT `fk_team__owner_user_id` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team`
--

LOCK TABLES `team` WRITE;
/*!40000 ALTER TABLE `team` DISABLE KEYS */;
INSERT INTO `team` VALUES (1,'9 отдел',1),(2,'Аутсорсеры',21);
/*!40000 ALTER TABLE `team` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teamcomposition`
--

DROP TABLE IF EXISTS `teamcomposition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teamcomposition` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `team_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `projectrole_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_teamcomposion__team_id` (`team_id`),
  KEY `fk_teamcomposion__user_id` (`user_id`),
  KEY `fk_teamcomposion__projectrole_id` (`projectrole_id`),
  CONSTRAINT `fk_teamcomposion__projectrole_id` FOREIGN KEY (`projectrole_id`) REFERENCES `projectrole` (`id`),
  CONSTRAINT `fk_teamcomposion__team_id` FOREIGN KEY (`team_id`) REFERENCES `team` (`id`),
  CONSTRAINT `fk_teamcomposion__user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teamcomposition`
--

LOCK TABLES `teamcomposition` WRITE;
/*!40000 ALTER TABLE `teamcomposition` DISABLE KEYS */;
INSERT INTO `teamcomposition` VALUES (2,1,1,5),(3,1,22,3),(4,1,21,2),(5,1,6,4),(6,1,10,1),(7,2,17,5),(8,2,19,3),(9,2,23,2),(10,2,24,4),(11,2,14,1);
/*!40000 ALTER TABLE `teamcomposition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teamproject`
--

DROP TABLE IF EXISTS `teamproject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teamproject` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `team_id` bigint(20) unsigned NOT NULL,
  `project_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_teamproject__team_id` (`team_id`),
  KEY `fk_teamproject__project_id` (`project_id`),
  CONSTRAINT `fk_teamproject__project_id` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`),
  CONSTRAINT `fk_teamproject__team_id` FOREIGN KEY (`team_id`) REFERENCES `team` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teamproject`
--

LOCK TABLES `teamproject` WRITE;
/*!40000 ALTER TABLE `teamproject` DISABLE KEYS */;
INSERT INTO `teamproject` VALUES (1,1,1),(2,2,2);
/*!40000 ALTER TABLE `teamproject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `user_conects_with_userdetail`
--

DROP TABLE IF EXISTS `user_conects_with_userdetail`;
/*!50001 DROP VIEW IF EXISTS `user_conects_with_userdetail`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `user_conects_with_userdetail` (
  `login` tinyint NOT NULL,
  `email` tinyint NOT NULL,
  `phone` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `value` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `user_contacts`
--

DROP TABLE IF EXISTS `user_contacts`;
/*!50001 DROP VIEW IF EXISTS `user_contacts`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `user_contacts` (
  `id` tinyint NOT NULL,
  `login` tinyint NOT NULL,
  `email` tinyint NOT NULL,
  `phone` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `usercustomfield`
--

DROP TABLE IF EXISTS `usercustomfield`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usercustomfield` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usercustomfield`
--

LOCK TABLES `usercustomfield` WRITE;
/*!40000 ALTER TABLE `usercustomfield` DISABLE KEYS */;
INSERT INTO `usercustomfield` VALUES (1,'github');
/*!40000 ALTER TABLE `usercustomfield` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userdetail`
--

DROP TABLE IF EXISTS `userdetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userdetail` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `usercustomfield_id` bigint(20) unsigned NOT NULL,
  `value` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_userdetail__user_id` (`user_id`),
  KEY `fk_userdetail__usercustomfield_id` (`usercustomfield_id`),
  CONSTRAINT `fk_userdetail__user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_userdetail__usercustomfield_id` FOREIGN KEY (`usercustomfield_id`) REFERENCES `usercustomfield` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userdetail`
--

LOCK TABLES `userdetail` WRITE;
/*!40000 ALTER TABLE `userdetail` DISABLE KEYS */;
INSERT INTO `userdetail` VALUES (1,1,1,'https://github.com/example1'),(2,2,1,'https://github.com/example1'),(3,3,1,'https://github.com/example1');
/*!40000 ALTER TABLE `userdetail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password_updated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `is_enabled` bit(1) NOT NULL DEFAULT b'0',
  `is_admin` bit(1) NOT NULL DEFAULT b'0',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `birthday` datetime DEFAULT NULL,
  `first_name` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `second_name` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `third_name` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(120) COLLATE utf8_unicode_ci NOT NULL,
  `phone` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `avatar` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login` (`login`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `users_phone_idx` (`phone`),
  KEY `users_email_idx` (`phone`),
  KEY `users_login_idx` (`login`),
  KEY `users_enabled_idx` (`is_enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'giles.thompson','bac66c4aa0b493251dc82fc7438df68f1f6b0074','2007-10-06 03:46:17','','','2010-01-30 00:59:33','2008-10-17 17:11:22','Paris','sit','totam','charlotte.bruen@example.com','(776)910-5443x283',NULL),(2,'sterling73','f9879363e65ff837e81eb28dc8729b0351b2add5','1988-11-10 12:05:44','','','2014-05-11 16:33:07','1978-04-20 13:26:44','Broderick','odio','natus','grimes.brent@example.com','411.354.1600x22618',NULL),(3,'uhodkiewicz','04b64904a19f61d18a54f61ddb575a8ea2474151','1972-07-23 14:00:37','','','1979-07-30 07:59:56','1984-12-08 14:17:46','Lorine','iure','et','cierra03@example.org','114.337.5103x67322',NULL),(4,'little.coty','d9247466ddac3756337de6cf9c6f94aeeab90c76','2019-05-06 21:02:43','','','1973-07-11 22:43:15','1990-04-04 09:43:35','Theodora','doloremque','at','bradtke.louvenia@example.com','+72(5)1251891085',NULL),(5,'eliane45','4da3cdaa75c6975143b70aa75784d3c3bfa7f3f9','2019-03-30 17:25:54','','','1982-07-04 14:10:19','2016-09-05 20:01:29','May','sint','est','ujakubowski@example.org','06754080025',NULL),(6,'shanahan.concepcion','dda09ce527c66699a2510c1da9fc1e2e5bb23721','2014-12-12 13:13:29','','','1984-10-26 13:57:22','1971-03-21 02:31:49','Emma','illo','aliquid','autumn.white@example.org','284-035-4323',NULL),(7,'orion12','bcff3d84ee30d4ccffaf7c9dcf84d3e22328b536','1997-02-13 16:36:21','','','2010-02-16 11:58:16','2019-07-07 11:34:55','Israel','expedita','et','randy.padberg@example.com','(460)185-7163',NULL),(8,'karl.gutkowski','60fdd9439d7f67ea302a229cb3a1cb1b62659ede','2018-08-09 21:44:56','','','1996-08-09 06:33:38','1971-03-18 13:09:50','Laurine','ut','adipisci','eulah18@example.net','(524)252-1078x695',NULL),(9,'freeda80','9a5d401069247e75f9e9d305b6d9f421f6caf396','2020-05-29 06:34:06','','','1995-01-20 03:50:09','1986-08-17 11:01:37','Brenda','harum','ad','jo.bernhard@example.net','1-778-281-2777',NULL),(10,'dhegmann','b36c2f9a918da1ce4943607ecbb8abf99fa8919f','2017-07-18 17:25:03','','','1997-10-19 08:44:39','2002-02-15 19:04:26','Leo','sit','exercitationem','carson.langworth@example.org','+99(5)6195414464',NULL),(11,'francesco.rohan','e2bd9119c1d187a1aa83f57a375db2f799702911','2012-08-04 03:32:24','','','2005-03-05 09:28:37','2002-06-28 14:30:03','Davon','quo','earum','mmitchell@example.com','1-873-839-6783x106',NULL),(12,'wolff.katelin','7eb18d73e21d4d85f34e7294776ba2f1e84c1db8','1985-09-22 21:02:11','','','1977-02-19 09:36:04','2008-10-29 01:54:47','Ashton','fugiat','deleniti','noe80@example.net','08191237116',NULL),(13,'harrison.marquardt','2d7b137204b5289bff01329356c0fb153b5cb41c','1970-03-08 10:18:10','','','1981-11-12 16:52:06','1995-04-16 07:11:50','Alanna','quia','adipisci','angelina.towne@example.com','1-784-881-9975',NULL),(14,'pkoss','addd87f5b0bc41fac14f34c4b84b7c88244940d6','1999-01-20 16:24:03','','','1988-08-28 15:41:14','1999-04-11 15:37:15','Zaria','beatae','cum','o\'hara.katrina@example.net','(347)215-8376',NULL),(15,'eusebio.walker','c5428622021738e0197eb85a8c375d31c8620005','1973-01-20 17:41:03','','','1985-03-26 02:23:28','1985-02-08 21:27:06','Birdie','totam','tenetur','fkoelpin@example.com','634-905-9891',NULL),(16,'dvolkman','a97982e34c77879dbca646d38fb56cc3f8c34c96','2015-04-15 07:05:44','','','1985-10-10 10:18:17','2014-07-15 14:38:58','Jayne','veritatis','amet','hegmann.albertha@example.com','01492482759',NULL),(17,'xschaefer','40ca7000674aceb4e65cf18fae19df1c68a89c6a','2018-12-13 13:40:35','','','1972-04-24 20:38:50','2009-12-16 09:12:48','Narciso','atque','voluptatem','tyshawn54@example.org','1-917-074-5567x962',NULL),(18,'greenholt.kendrick','de7eab3d4163342b6e339b7ebf0aa657e5b5152b','1982-09-11 05:06:41','','','2013-08-06 16:37:06','2011-11-22 15:42:56','Emil','qui','id','hershel.zulauf@example.com','1-030-367-1706',NULL),(19,'wdavis','f7cfc974f4e69005f468976153abfa5508721f0d','1984-02-29 20:29:46','','','2015-11-06 04:44:03','2005-01-26 01:15:29','Ova','hic','ea','nitzsche.maximo@example.org','197.688.2388',NULL),(20,'itzel66','da85c473a5e4e21f1622ab0c1cbd99a89839d92b','1983-11-05 04:02:14','','','2002-02-17 03:37:46','1987-08-08 06:11:27','Alfonzo','maiores','fugit','uriah54@example.net','395-131-3604',NULL),(21,'baylee.buckridge','240baebbc9920b473257078eb3ed7f1e1fdcf762','1993-10-02 05:43:46','','','1985-01-21 20:30:39','1982-01-29 10:45:19','Margarette','sit','eligendi','carlie33@example.net','110-890-4871',NULL),(22,'pstehr','eb22851ff6398464522338beca717ca85a33ff08','1983-11-15 04:41:39','','','1974-12-01 14:20:34','1970-05-13 18:11:49','Malcolm','quis','dolor','mohr.dylan@example.org','891.330.2128x6348',NULL),(23,'horace22','a334d957e7549d4fae8f731a98735d935ce52484','2011-05-28 19:15:40','','','2005-11-03 07:49:20','1991-10-08 17:36:41','Damien','optio','aperiam','west.antonietta@example.net','727-212-9851x29310',NULL),(24,'rippin.terrell','bbca840467dcf61db1601d381394d066f0e8f606','1988-10-15 18:45:00','','','1999-09-09 07:39:03','1994-09-05 06:32:53','Felipe','ut','aut','andreane.bashirian@example.net','(744)296-7374',NULL),(25,'ukulas','734997cc4e699adf85c8f643ffd7b6bb7f83e6d2','2000-02-17 15:41:20','','','2000-04-09 13:54:10','1992-12-09 23:06:01','Mable','est','ea','little.norberto@example.net','(916)287-4707',NULL),(26,'eblock','d9a847635bb795348e1e0db753afe3fdfda308e1','1976-08-26 07:18:10','','','1992-02-17 17:52:49','1996-10-07 10:06:54','Travis','tempore','ut','reinger.lilian@example.org','427.472.7624x82565',NULL),(27,'mcdermott.elisabeth','ae0573ed75ecb2b107d2e4f75cb02e85c6f393c0','1974-10-09 16:15:43','','','1994-03-09 02:14:09','2006-08-05 22:16:57','Peggie','doloribus','earum','otilia00@example.com','(491)504-2176',NULL),(28,'kunze.ike','85e29375c73d6fc35f357e19671fbcd52a91530d','1993-12-30 06:07:46','','','2013-03-14 00:10:52','1991-01-02 19:31:12','Jacky','ut','sit','wilton99@example.com','648-260-4815x978',NULL),(29,'oflatley','61cdf22db948d74a2968c10ee6a2874dad058509','2005-10-15 00:20:38','','','2016-09-05 06:19:14','1992-09-30 19:28:26','Hobart','sed','vel','kokuneva@example.com','835.730.9477',NULL),(30,'yost.carol','7543278ef078a0b8643d1f2a16dea87dc718fab2','1990-10-07 11:34:28','','','2002-12-22 15:50:57','1971-08-07 20:12:55','Iliana','animi','voluptatem','gunner.hane@example.org','(448)684-4651x9561',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'bpm'
--
/*!50003 DROP PROCEDURE IF EXISTS `decrease_project_iteration` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `decrease_project_iteration`(in project_id bigint unsigned)
BEGIN
	update project
	set current_iteration = current_iteration - 1 
	where id = @project_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `increase_project_iteration` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `increase_project_iteration`(in project_id bigint unsigned)
BEGIN
	update project
	set current_iteration = current_iteration + 1
	where id = @project_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `user_conects_with_userdetail`
--

/*!50001 DROP TABLE IF EXISTS `user_conects_with_userdetail`*/;
/*!50001 DROP VIEW IF EXISTS `user_conects_with_userdetail`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_conects_with_userdetail` AS select `u`.`login` AS `login`,`u`.`email` AS `email`,`u`.`phone` AS `phone`,`u3`.`name` AS `name`,`u2`.`value` AS `value` from (`usercustomfield` `u3` left join (`users` `u` left join `userdetail` `u2` on(`u`.`id` = `u2`.`user_id`)) on(`u2`.`usercustomfield_id` = `u3`.`id`)) order by `u`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_contacts`
--

/*!50001 DROP TABLE IF EXISTS `user_contacts`*/;
/*!50001 DROP VIEW IF EXISTS `user_contacts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_contacts` AS select `users`.`id` AS `id`,`users`.`login` AS `login`,`users`.`email` AS `email`,`users`.`phone` AS `phone` from `users` order by `users`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-08-27 14:40:29
