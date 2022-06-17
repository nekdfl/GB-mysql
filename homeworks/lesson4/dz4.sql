DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамиль', -- COMMENT на случай, если имя неочевидное
    age INT UNSIGNED  NOT NULL,
    email VARCHAR(120) UNIQUE,
    password_hash VARCHAR(200), -- 123456 => vzx;clvgkajrpo9udfxvsldkrn24l5456345t
    phone BIGINT UNSIGNED UNIQUE, 
    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'юзеры';

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
    is_active BIT NOT NULL,
    photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
    id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
    -- id SERIAL, -- изменили на составной ключ (initiator_user_id, target_user_id)
    initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM('requested', 'approved', 'unfriended', 'declined'),
    -- `status` TINYINT(1) UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
    requested_at DATETIME DEFAULT NOW(),
    confirmed_at DATETIME ON UPDATE NOW(), -- можно будет даже не упоминать это поле при обновлении
    
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id),
    CHECK (initiator_user_id <> target_user_id)
);
-- чтобы пользователь сам себе не отправил запрос в друзья
ALTER TABLE friend_requests 
ADD CHECK(initiator_user_id <> target_user_id);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
    id SERIAL,
    name VARCHAR(150),
    admin_user_id BIGINT UNSIGNED NOT NULL,
    
    INDEX communities_name_idx(name), -- индексу можно давать свое имя (communities_name_idx)
    foreign key (admin_user_id) references users(id)
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
    user_id BIGINT UNSIGNED NOT NULL,
    community_id BIGINT UNSIGNED NOT NULL,
  
    PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
    id SERIAL,
    `name` ENUM('txt', 'mp3', 'jpeg', 'ogg'), -- записей мало, поэтому в индексе нет необходимости
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
    id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    body text,
    filename VARCHAR(255),
    -- file blob,       
    size INT,
    metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
    id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW()

    -- PRIMARY KEY (user_id, media_id) 
    -- можно было и так вместо id в качестве PK
    -- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

-- намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)

);

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
    `id` SERIAL,
    `name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
    id SERIAL,
    `album_id` BIGINT unsigned NOT NULL,
    `media_id` BIGINT unsigned NOT NULL,

    FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_fk 
FOREIGN KEY (media_id) REFERENCES vk.media(id);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_fk_1 
FOREIGN KEY (user_id) REFERENCES vk.users(id);


-- -------------------------------
/**
* поля created_at внес, как дань логики  анализа "когда было совершенно то или иное действие "
* по привычке всем текстовы полям выставил длину поля 50 символов. Для однострочников хватит на все случаи жизни.
*/

-- основаня таблица приложения
DROP TABLE IF EXISTS `application`; -- удалить если есть
CREATE TABLE `application` ( -- создаем таблицу приложения
    id SERIAL PRIMARY KEY, -- добавляем первичный ключ BIGINT UNSIGNED DEFAULT NULL AI PK
    app_name varchar (50), -- название приложения
    app_description  TEXT, -- описание 
    app_url varchar(2048), -- путь к приложению (оно же во фрейме открыватся, а самое приложение имеет свой сервер)
    permission set ('friends', 'photo', 'music list', 'user personal data', 'gps'),
    created_at DATETIME DEFAULT NOW(), -- дата создания приложения
    updated_at DATETIME DEFAULT NOW(), -- дата внесения изменений в описание приложения
    version varchar (20) -- версия приложения. Может быть "1.2.3.4 alpha"
) comment  "all application of VK";

-- таблица установленных приложений пользователя
DROP TABLE IF EXISTS `user_apps`; -- удалить если есть
CREATE TABLE `user_apps` ( -- создаем таблицу приложние-пользователь
    installed_at DATETIME DEFAULT NOW(), -- дата установки
    application_id BIGINT UNSIGNED DEFAULT NULL, -- id приложения
    user_id BIGINT UNSIGNED DEFAULT NULL, -- id пользователя
    PRIMARY KEY (application_id, user_id), -- составной главный ключ. Для одного пользователя можно установить одно приложение только раз. Пользователь не может установить себе 2 копии приложения
    FOREIGN KEY (application_id) REFERENCES application(id), -- внешний ключ на приложения
    FOREIGN KEY (user_id) REFERENCES users(id) -- внешний ключ на пользователя
) comment "installed applications for user";

-- детальная информация о пользователе, которой нет в певой таблице - расширение одели пользователя
DROP TABLE IF EXISTS `user_details`; -- удалить если есть
CREATE TABLE `user_details` (  -- создать таблицу списка интересов пользователя
    id SERIAL PRIMARY KEY,  -- BIU N AI PK 
    user_id BIGINT UNSIGNED DEFAULT NULL, -- id пользователя
    user_nikname varchar(50) UNIQUE, -- уникальный nikname пользователя; Поле конечно будет тяжеловатым, но не представляю как еще сделать уникальное имя пользователя
    activities text, -- текстовое поле, чтобы как в вк сам пользователь через "," все сам писал как хотел
    interest text, -- текстовое поле, чтобы как в вк сам пользователь через "," все сам писал как хотел
    music text, -- текстовое поле, чтобы как в вк сам пользователь через "," все сам писал как хотел
    cinema text, -- текстовое поле, чтобы как в вк сам пользователь через "," все сам писал как хотел
    teleshow text, -- текстовое поле, чтобы как в вк сам пользователь через "," все сам писал как хотел
    books text,
    games text, 
    quotes text,
    about text,
    cellphone varchar(50), -- поле для телефона текстового формата. Валидность данных пусть фронтенд котролирует, у него JS, а мы только храним инфу...
    created_at DATETIME DEFAULT NOW(), -- дата добавления
    FOREIGN KEY (user_id) REFERENCES users(id) -- внешний ключ, ссылка на пользователя
) comment "list of user's interests"; 




ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE -- (значение по умолчанию)
    ON DELETE restrict; -- (значение по умолчанию)

ALTER TABLE `profiles` ADD CONSTRAINT fk_photo_id
    FOREIGN KEY (photo_id) REFERENCES media(id)

-- ЗАПОЛНЕНИЕ ДАННЫМИ

-- Generation time: Thu, 30 Jul 2020 19:44:41 +0000
-- Host: mysql.hostinger.ro
-- DB name: u574849695_25
/*!40030 SET NAMES UTF8 */;
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP TABLE IF EXISTS `communities`;
CREATE TABLE `communities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8_unicode_ci DEFAULT NULL,
  `admin_user_id` bigint(20) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `communities_name_idx` (`name`),
  KEY `admin_user_id` (`admin_user_id`),
  CONSTRAINT `communities_ibfk_1` FOREIGN KEY (`admin_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `communities` VALUES ('1','id','1'),
('2','voluptas','2'),
('3','quia','3'),
('4','delectus','4'),
('5','aut','5'),
('6','asperiores','6'),
('7','nemo','7'),
('8','minus','8'),
('9','minus','9'),
('10','aut','10'),
('11','non','1'),
('12','cum','2'),
('13','aut','3'),
('14','perferendis','4'),
('15','alias','5'),
('16','corporis','6'),
('17','eos','7'),
('18','exercitationem','8'),
('19','exercitationem','9'),
('20','molestias','10'),
('21','quia','1'),
('22','ipsa','2'),
('23','nesciunt','3'),
('24','aut','4'),
('25','repellat','5'),
('26','nobis','6'),
('27','a','7'),
('28','et','8'),
('29','saepe','9'),
('30','hic','10'),
('31','eos','1'),
('32','qui','2'),
('33','voluptatem','3'),
('34','velit','4'),
('35','consequatur','5'),
('36','officia','6'),
('37','quibusdam','7'),
('38','ipsam','8'),
('39','ipsam','9'),
('40','exercitationem','10'),
('41','qui','1'),
('42','ipsam','2'),
('43','et','3'),
('44','hic','4'),
('45','voluptatem','5'),
('46','rem','6'),
('47','atque','7'),
('48','enim','8'),
('49','id','9'),
('50','minima','10'),
('51','sed','1'),
('52','qui','2'),
('53','voluptas','3'),
('54','consequatur','4'),
('55','assumenda','5'),
('56','rerum','6'),
('57','fugit','7'),
('58','ut','8'),
('59','non','9'),
('60','numquam','10'),
('61','voluptatem','1'),
('62','qui','2'),
('63','consequatur','3'),
('64','est','4'),
('65','in','5'),
('66','eveniet','6'),
('67','sit','7'),
('68','pariatur','8'),
('69','ipsum','9'),
('70','aut','10'),
('71','odit','1'),
('72','magni','2'),
('73','non','3'),
('74','impedit','4'),
('75','et','5'),
('76','nesciunt','6'),
('77','sed','7'),
('78','in','8'),
('79','ut','9'),
('80','voluptatibus','10'),
('81','aut','1'),
('82','iusto','2'),
('83','quos','3'),
('84','sed','4'),
('85','molestias','5'),
('86','voluptatem','6'),
('87','nulla','7'),
('88','nihil','8'),
('89','quam','9'),
('90','et','10'),
('91','qui','1'),
('92','quis','2'),
('93','deserunt','3'),
('94','repellat','4'),
('95','qui','5'),
('96','non','6'),
('97','dolor','7'),
('98','cumque','8'),
('99','dolore','9'),
('100','veniam','10'); 


DROP TABLE IF EXISTS `friend_requests`;
CREATE TABLE `friend_requests` (
  `initiator_user_id` bigint(20) unsigned NOT NULL,
  `target_user_id` bigint(20) unsigned NOT NULL,
  `status` enum('requested','approved','unfriended','declined') COLLATE utf8_unicode_ci DEFAULT NULL,
  `requested_at` datetime DEFAULT current_timestamp(),
  `confirmed_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`initiator_user_id`,`target_user_id`),
  KEY `target_user_id` (`target_user_id`),
  CONSTRAINT `friend_requests_ibfk_1` FOREIGN KEY (`initiator_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `friend_requests_ibfk_2` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`initiator_user_id` <> `target_user_id`),
  CONSTRAINT `CONSTRAINT_2` CHECK (`initiator_user_id` <> `target_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `media_id` bigint(20) unsigned NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  UNIQUE KEY `id` (`id`),
  KEY `user_id` (`user_id`),
  KEY `media_id` (`media_id`),
  CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `likes` VALUES ('1','1','1','1974-06-06 04:27:27'),
('2','2','2','1972-01-19 23:37:50'),
('3','3','3','1974-01-30 23:01:43'),
('4','4','4','1985-05-01 07:28:17'),
('5','5','5','1986-02-15 02:53:54'),
('6','6','6','2012-11-07 08:33:43'),
('7','7','7','2000-01-02 04:23:20'),
('8','8','8','1983-08-19 04:12:19'),
('9','9','9','1977-10-29 21:33:10'),
('10','10','10','2007-10-31 19:04:44'),
('11','1','11','1997-01-27 17:23:15'),
('12','2','12','2003-04-29 03:15:59'),
('13','3','13','2000-10-12 08:13:14'),
('14','4','14','2016-06-14 12:12:30'),
('15','5','15','2019-06-01 20:35:22'),
('16','6','16','1998-12-01 13:39:27'),
('17','7','17','1985-11-11 14:54:07'),
('18','8','18','1997-03-15 10:36:22'),
('19','9','19','1977-09-17 03:01:28'),
('20','10','20','2011-06-04 03:05:22'),
('21','1','21','2015-10-08 06:50:16'),
('22','2','22','2008-04-23 09:54:39'),
('23','3','23','1986-04-27 14:56:03'),
('24','4','24','1988-12-03 18:14:17'),
('25','5','25','2003-09-07 00:02:55'),
('26','6','26','1993-06-20 08:04:28'),
('27','7','27','1985-04-13 12:35:57'),
('28','8','28','1973-06-25 22:58:17'),
('29','9','29','2008-05-02 09:08:23'),
('30','10','30','2014-03-06 03:15:20'),
('31','1','31','1989-06-15 14:19:35'),
('32','2','32','1975-12-23 21:47:23'),
('33','3','33','2014-02-21 22:43:35'),
('34','4','34','1986-09-08 06:00:57'),
('35','5','35','1976-08-16 07:26:28'),
('36','6','36','1995-06-06 16:46:35'),
('37','7','37','1971-01-07 17:12:11'),
('38','8','38','2002-08-30 02:51:00'),
('39','9','39','2016-07-20 02:33:33'),
('40','10','40','2000-05-31 15:19:33'),
('41','1','41','1990-03-20 14:04:08'),
('42','2','42','1988-03-10 12:22:31'),
('43','3','43','1991-11-11 22:44:50'),
('44','4','44','2009-09-15 00:24:49'),
('45','5','45','1978-09-26 08:44:00'),
('46','6','46','2013-04-15 05:35:35'),
('47','7','47','1974-02-20 19:28:11'),
('48','8','48','1979-12-28 03:57:47'),
('49','9','49','2005-07-11 19:32:41'),
('50','10','50','1992-05-14 22:45:18'),
('51','1','51','1993-01-01 12:41:19'),
('52','2','52','1982-11-09 14:58:03'),
('53','3','53','1995-09-07 02:45:42'),
('54','4','54','1974-03-05 02:26:30'),
('55','5','55','1971-12-16 03:23:41'),
('56','6','56','1985-07-27 14:52:50'),
('57','7','57','2010-07-02 04:53:43'),
('58','8','58','1998-02-03 09:05:38'),
('59','9','59','1993-12-21 12:00:58'),
('60','10','60','1977-10-19 00:15:06'),
('61','1','61','1973-01-21 06:57:17'),
('62','2','62','1994-09-07 06:13:46'),
('63','3','63','1978-02-21 10:50:26'),
('64','4','64','2020-02-03 20:58:57'),
('65','5','65','2012-07-23 16:44:55'),
('66','6','66','2009-10-26 07:51:13'),
('67','7','67','1987-08-21 03:39:20'),
('68','8','68','1974-05-31 10:21:39'),
('69','9','69','2011-05-03 13:15:01'),
('70','10','70','2014-04-13 05:10:50'),
('71','1','71','2019-03-08 02:50:23'),
('72','2','72','1972-11-14 09:05:55'),
('73','3','73','2000-10-24 10:41:06'),
('74','4','74','1983-05-03 13:57:20'),
('75','5','75','2000-12-04 22:31:41'),
('76','6','76','2000-10-22 00:50:59'),
('77','7','77','1971-04-04 07:40:21'),
('78','8','78','2020-01-06 20:38:22'),
('79','9','79','1974-08-28 15:31:41'),
('80','10','80','1992-09-30 00:08:34'),
('81','1','81','2018-07-28 05:17:48'),
('82','2','82','2014-02-11 20:17:45'),
('83','3','83','2007-05-09 02:11:23'),
('84','4','84','1987-02-16 20:21:41'),
('85','5','85','1993-03-11 09:45:07'),
('86','6','86','1982-09-21 15:49:30'),
('87','7','87','1994-11-22 03:06:48'),
('88','8','88','2010-02-18 01:04:53'),
('89','9','89','1998-05-04 14:21:42'),
('90','10','90','2012-02-21 12:15:31'),
('91','1','91','1973-07-30 02:17:46'),
('92','2','92','2017-08-17 22:20:23'),
('93','3','93','1976-11-10 23:33:14'),
('94','4','94','1989-05-27 05:35:05'),
('95','5','95','1980-07-29 23:58:00'),
('96','6','96','1976-11-05 07:46:21'),
('97','7','97','2012-09-02 18:15:30'),
('98','8','98','1984-10-08 16:51:06'),
('99','9','99','1982-11-15 07:14:08'),
('100','10','100','1984-03-18 23:34:14'); 


DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `media_type_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `body` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  UNIQUE KEY `id` (`id`),
  KEY `user_id` (`user_id`),
  KEY `media_type_id` (`media_type_id`),
  CONSTRAINT `media_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `media_ibfk_2` FOREIGN KEY (`media_type_id`) REFERENCES `media_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `media` VALUES ('1','1','1','Mollitia quis debitis non sed ut nulla porro sit. Sint autem velit animi quia repellendus. Quo ut qui adipisci enim similique.','explicabo','0',NULL,'1988-09-25 02:45:42','1974-05-18 20:32:48'),
('2','2','2','Qui dolores amet sed. Et autem assumenda quia ab perspiciatis eaque. Voluptas adipisci ratione quo temporibus voluptatum similique. Distinctio nobis a placeat velit dicta.','ea','814496',NULL,'2012-11-18 13:17:30','1971-11-09 10:58:26'),
('3','3','3','Nulla omnis corporis sit sapiente. Doloribus quia dolore molestias quos debitis. At reprehenderit est adipisci dolorem repellat recusandae molestiae. Enim expedita molestiae qui perspiciatis numquam atque eum iste.','est','5000',NULL,'2013-02-10 18:02:21','1977-02-28 12:04:34'),
('4','4','4','Vel illo eligendi dignissimos ipsam qui iusto. Quia laboriosam quis quis dolores quo libero ratione in. Cum et eveniet enim at. Id enim sint sunt harum aut. Nemo delectus et quia ea voluptatibus.','quisquam','99',NULL,'1984-11-12 14:00:30','2008-03-03 04:57:48'),
('5','5','5','Voluptatum nisi id qui natus quia recusandae. Minus consectetur tempora ex at impedit. Corrupti quos nostrum ut amet autem ut. Ea quod unde in ipsam.','placeat','78871024',NULL,'2012-12-10 04:42:07','1995-03-13 09:34:52'),
('6','6','6','Consequatur eos et autem explicabo accusantium qui modi. Excepturi maxime perferendis voluptatem et nesciunt. Deserunt aut sint corrupti ducimus quasi voluptate. Iusto repudiandae soluta neque excepturi sit assumenda animi.','sit','98883',NULL,'2009-08-23 18:33:18','1978-10-07 17:30:45'),
('7','7','7','Nemo et corrupti quasi veniam tempore distinctio. Nobis recusandae sequi voluptatem sunt neque. Esse eaque vel doloremque saepe. Velit impedit architecto voluptatem quod similique eum et.','perspiciatis','92229778',NULL,'1982-03-27 08:44:49','1970-02-18 21:24:14'),
('8','8','8','Odio maiores ut dolorum et animi exercitationem tempore. Sunt consectetur id quia minus. Ratione tempore rem aut hic. Quos dolores vel hic voluptatem totam repellendus consequuntur.','distinctio','29',NULL,'2018-07-17 19:59:59','2013-07-26 17:41:38'),
('9','9','9','Molestiae fugit vero voluptas reprehenderit dolor. Odio nihil aut voluptas eum. Odio consectetur voluptas quas.','ratione','29',NULL,'2016-06-27 06:21:36','1986-06-22 05:19:31'),
('10','10','10','A illum deserunt non dolor voluptatem praesentium et. Rem et explicabo est earum dolor totam et. Recusandae est ut aspernatur totam consequuntur ut.','qui','5676',NULL,'2003-07-06 16:58:03','2003-05-29 17:21:15'),
('11','11','1','Molestias deserunt est et. In sequi nostrum dolore molestiae id possimus eligendi. Ipsum commodi aspernatur vitae et rem.','et','7',NULL,'1976-03-31 21:13:33','1983-01-26 10:48:10'),
('12','12','2','Voluptas qui tempore totam provident aut et aut. Corrupti necessitatibus quia quidem aut dolor. Debitis in minima adipisci esse inventore. Rerum velit fugit quae odit.','quas','54598528',NULL,'1999-11-15 21:12:36','2019-08-22 04:22:10'),
('13','13','3','Soluta aut quia a dolores. Minima labore omnis placeat doloremque quas ut. Autem natus non esse ea est. Voluptates assumenda fugiat minima qui et ea est.','non','5',NULL,'1974-12-09 08:35:30','1995-09-17 06:08:38'),
('14','14','4','Nihil necessitatibus excepturi ad dolore. Voluptatem rem nostrum laborum omnis. Nemo veniam a et quam.','quas','4849980',NULL,'2009-06-08 08:22:37','2010-10-27 16:54:28'),
('15','15','5','Dignissimos voluptas quas qui repudiandae molestiae incidunt. Est quia aliquid ullam a animi autem ut nobis. Sit ut omnis quis iure quam consequatur.','ut','95092994',NULL,'2015-11-07 13:38:00','2007-11-12 13:03:08'),
('16','16','6','Et assumenda et non aliquid ab. Laudantium voluptatem quis iure nostrum nihil. Velit odio sit nobis doloremque autem enim. Perferendis aut eligendi odit consequatur soluta.','labore','1',NULL,'1977-11-08 23:03:44','1993-11-18 04:32:25'),
('17','17','7','Officia doloremque et deleniti placeat eos et quia eius. Quasi modi consectetur fugit dolor quisquam sapiente cum. Quia aut repudiandae iste nostrum ullam dolorem.','enim','543',NULL,'1971-04-03 10:01:02','2012-12-19 14:45:18'),
('18','18','8','Accusamus alias praesentium autem molestias quo dolorum. Autem eum consequatur provident officia fuga sit. Asperiores ut dolores porro ipsa fugit sunt. Necessitatibus molestias et eos officiis odio.','eos','692604',NULL,'2010-08-03 09:07:54','1984-07-22 23:47:03'),
('19','19','9','Nostrum sint modi rerum magnam dolor aut. Alias occaecati beatae vel. Repellendus est quis doloribus non enim culpa minus.','libero','84550',NULL,'1980-06-18 18:58:58','2012-10-04 22:37:34'),
('20','20','10','Saepe magni tempore nihil vitae est. Aut id ut id id ut nobis numquam. Possimus iusto magnam delectus et tempora voluptate eos. Est molestias enim doloribus velit et natus.','nemo','0',NULL,'2010-07-05 06:31:50','2017-09-05 10:00:58'),
('21','21','1','Veniam odio voluptas vitae. Recusandae laboriosam rem magnam rerum consequuntur quod ratione. Expedita autem quas nihil.','excepturi','537588194',NULL,'2010-05-15 07:48:40','2005-09-04 01:50:11'),
('22','22','2','Et nihil nostrum dicta autem voluptatem voluptatum. Et aliquam consectetur enim sed minus autem. Facere magni quisquam delectus sunt nemo dolores. Vel quidem recusandae est corporis vero mollitia voluptate.','nobis','6297543',NULL,'1979-08-30 08:55:33','1986-02-04 20:04:34'),
('23','23','3','Delectus repudiandae dignissimos pariatur atque. Est quisquam iure hic ut commodi in. Aut soluta et voluptatum molestiae explicabo minus cupiditate. Non harum amet qui dolores corporis dolores et.','ducimus','898151311',NULL,'2002-05-07 03:44:12','1972-12-31 04:17:37'),
('24','24','4','Iusto eos aut rem quod. Consequatur laborum et libero ex. Voluptas in dignissimos ullam consequatur voluptate magnam. Ullam voluptatem et aut. Quia hic deleniti sit iste sed.','totam','678887472',NULL,'2011-01-09 19:30:23','2008-03-13 04:53:54'),
('25','25','5','Neque qui quis aperiam enim itaque. Impedit et facere et rerum quia labore. Dolorem est sequi ullam voluptatem sed repudiandae accusamus. Rerum itaque ut cum porro.','perferendis','9247606',NULL,'1980-05-23 03:03:32','2019-02-19 19:53:06'),
('26','26','6','Totam porro molestiae aut pariatur expedita vero qui sunt. Adipisci nesciunt omnis facilis asperiores laudantium. At dolor repudiandae quibusdam asperiores et beatae.','tenetur','111',NULL,'2006-09-04 13:35:37','2000-09-09 00:30:32'),
('27','27','7','Quisquam laboriosam nulla et est numquam eum. Modi vitae at et. Ex et harum optio temporibus et accusamus.','et','71553',NULL,'1996-04-25 16:52:21','2016-05-02 19:09:07'),
('28','28','8','Tempora quia possimus est quia. Ut iste blanditiis est sint repellendus. Quis ut ex dolor officia animi quasi quis. Possimus eaque atque aut a.','tempora','2',NULL,'1974-08-04 10:20:26','2015-01-11 21:21:04'),
('29','29','9','Accusamus exercitationem est eos quae ut voluptate sed. Iste aut voluptatem nemo sunt. Autem sint necessitatibus quas.','et','58352',NULL,'1984-11-14 15:09:22','1991-12-16 05:19:23'),
('30','30','10','Natus ut ipsum sunt voluptatibus blanditiis. Culpa a sed debitis iste tempore. Consequatur in dolorem eos recusandae aut enim. Dolorem sed qui earum sapiente.','est','83262',NULL,'2011-08-03 09:05:07','1980-06-22 10:22:51'),
('31','31','1','Dolorum magni et aut velit recusandae nemo. Ea illum a eos consequatur. Molestias quia non et et non modi praesentium. Et fugit deserunt maiores unde non qui. Qui nobis incidunt sit soluta.','consequatur','48',NULL,'2016-12-26 20:58:48','1979-04-14 03:41:04'),
('32','32','2','Natus dolorem et a aut. Quidem aliquam eum vitae eos sunt dolores. Omnis nostrum tempora rerum aliquid vitae mollitia. Eius voluptas quaerat consequatur.','consequuntur','3',NULL,'2013-03-27 19:26:57','2013-08-02 04:52:26'),
('33','33','3','Nisi ut eum voluptate et quasi iusto. Voluptatem qui consequatur maxime incidunt et possimus suscipit. Porro temporibus eveniet corporis non et. Voluptatem earum voluptas debitis repudiandae nisi cum. Sed voluptatum non culpa in qui eos aliquam.','voluptatem','1423',NULL,'1989-08-04 12:36:20','1986-12-22 18:10:51'),
('34','34','4','Incidunt sint nihil beatae facilis assumenda quia. Et eveniet consequatur nemo officia. Voluptatem non enim dolor et sequi dolorem.','enim','135501142',NULL,'1980-06-25 19:16:30','2010-11-15 18:04:54'),
('35','35','5','Quibusdam repudiandae sunt molestiae vel. Repellendus ea iure id omnis excepturi qui. Quia tempora id quos ea dolores eos.','non','770',NULL,'1987-05-13 12:37:27','2009-04-27 18:59:10'),
('36','36','6','Qui velit in rerum amet ipsa. Labore id ea doloribus neque laborum. Quos eum quas corrupti dolorem consequuntur. Doloremque beatae sequi voluptas consequuntur qui sunt.','labore','57',NULL,'1995-11-07 02:59:38','1974-09-04 17:01:37'),
('37','37','7','Consectetur doloribus doloribus cupiditate deserunt occaecati omnis. Aliquam et illo distinctio vel dolor. Sint est aliquid atque consequatur et nobis vel.','impedit','673310',NULL,'1992-06-17 00:22:00','1991-07-22 00:29:31'),
('38','38','8','Quas maxime voluptatem ipsum voluptas. Optio rerum neque nihil impedit quae eos.','qui','44',NULL,'1984-12-09 02:52:34','2003-06-11 13:27:38'),
('39','39','9','Veniam ut omnis voluptatem necessitatibus. In dolorum molestiae est amet. Aperiam suscipit odio ea vel laborum atque.','at','45424',NULL,'1978-01-06 18:44:57','2019-05-06 16:16:56'),
('40','40','10','Quia repellendus eos est a rerum in. Quis incidunt rerum illo. Vel non qui quia architecto perspiciatis.','consequatur','47566',NULL,'1997-02-14 17:52:42','1982-06-04 17:10:30'),
('41','41','1','Tempora ducimus quis aut. Nam aut tempore odit tempora.','architecto','5482',NULL,'1978-02-06 04:01:53','2010-12-19 17:40:04'),
('42','42','2','Tenetur excepturi neque et. Quia voluptate aperiam est dicta laboriosam fugiat. Modi modi qui nemo doloribus. Nostrum nemo nihil laborum eligendi neque.','at','0',NULL,'1999-08-21 09:58:06','1998-09-28 09:36:58'),
('43','43','3','Aut ea soluta corporis. Sequi eius et explicabo laudantium.','blanditiis','794139955',NULL,'1995-09-09 01:27:27','2006-09-11 21:41:56'),
('44','44','4','Adipisci qui ea et dolorem. Tempore et velit dolore quae eum id sunt. Occaecati aliquid sed eveniet commodi laborum et sit omnis. Et voluptas quaerat assumenda voluptatem aspernatur eveniet illum sequi.','atque','14504',NULL,'1988-02-22 01:07:01','1992-06-09 05:51:33'),
('45','45','5','Qui quia perferendis et. Numquam est ut eos quia qui voluptatem recusandae. Doloremque maiores minima veritatis placeat qui illum. Magni corporis ullam totam et.','quisquam','221956',NULL,'1979-08-02 03:40:56','2012-06-28 00:26:55'),
('46','46','6','Voluptatibus eligendi velit dolores dignissimos laboriosam. Animi quia quo beatae temporibus et. Aut eaque alias iusto possimus quod officiis a atque. Eos officiis culpa ut nihil quae consequatur animi soluta.','soluta','974677',NULL,'1975-01-31 09:27:16','2004-04-18 08:30:21'),
('47','47','7','Est consequatur et et qui rerum inventore molestiae. Vel illum itaque voluptates sint ea accusamus corrupti numquam. Et et ut necessitatibus ut quasi quo. Natus aliquam libero quaerat hic.','quo','8',NULL,'2017-03-04 12:22:44','1987-09-08 15:20:44'),
('48','48','8','Corporis commodi aut reprehenderit cum quaerat. Et suscipit cum quae similique. Eos possimus tempora harum asperiores qui beatae ducimus.','non','7',NULL,'2017-09-20 16:45:13','2005-07-12 16:54:50'),
('49','49','9','Molestiae dolorum culpa architecto harum quasi. At et est rerum ab. Culpa ducimus ut eos perspiciatis qui quod est ab. Reiciendis eos sunt et rem minus nostrum.','quia','8367',NULL,'2004-07-09 09:53:57','1985-01-25 11:24:55'),
('50','50','10','Voluptatem est autem est. Aspernatur soluta tempore alias. Qui autem sunt quasi repudiandae cupiditate enim et. Quod similique doloremque veniam architecto cumque magni sint et.','officia','9765',NULL,'2019-04-26 21:38:16','1980-06-04 04:20:17'),
('51','51','1','Officiis animi et quia et. Laboriosam neque sit atque est sit molestias. Quasi aut maiores veniam commodi in.','repellendus','395',NULL,'1979-08-29 00:22:04','2003-04-07 04:50:09'),
('52','52','2','Aspernatur non eum aliquam sequi cumque. Iure voluptatem minima eligendi. Et ut qui ipsum. Veniam illo magni aperiam quas nulla.','dicta','0',NULL,'2001-12-28 18:20:40','1994-04-10 02:33:28'),
('53','53','3','Soluta dicta quisquam hic est assumenda. Et explicabo repellat repellendus optio recusandae aliquid quisquam. Aut numquam possimus repellendus quidem sapiente ea vitae.','qui','62',NULL,'1999-03-24 11:22:25','2019-11-24 09:20:21'),
('54','54','4','Ex corrupti error et vero. Sit sint ut velit numquam tenetur. Tempore voluptatem vel magnam sed amet velit.','sed','586275438',NULL,'1973-06-23 04:07:43','1999-08-04 16:18:12'),
('55','55','5','Voluptatem est repellendus rem est eveniet nam. Recusandae labore velit culpa ut ducimus explicabo consequatur. Sed perferendis odit illo ut. Officiis vel rem fugiat cupiditate corporis et porro vero.','quas','2',NULL,'1989-10-05 16:38:52','1981-01-19 17:19:19'),
('56','56','6','Et accusantium omnis minima neque et. Omnis occaecati omnis neque similique occaecati. Autem repudiandae unde maiores. Omnis ut ducimus sint assumenda architecto.','et','4870',NULL,'1994-04-16 10:38:58','2019-11-16 01:25:09'),
('57','57','7','Labore nostrum repellendus culpa nihil sit quia. Fugit praesentium suscipit doloremque sint consectetur quia. Provident eius libero qui quia quibusdam dolores nemo.','voluptas','35465179',NULL,'1991-12-12 08:06:06','2014-10-17 00:42:28'),
('58','58','8','Quidem magnam veniam culpa iusto. Praesentium expedita accusamus dolorem sed doloremque. Corrupti nobis esse enim ipsum voluptas placeat autem. Doloribus cumque et maxime ad et sit.','ab','59641957',NULL,'2011-08-21 08:36:19','1990-12-15 23:41:45'),
('59','59','9','Occaecati quod rem adipisci at ipsam. Distinctio ipsum facilis eaque iste dolorem eligendi asperiores. Vitae facere fugit veritatis tempora voluptatem. Assumenda qui harum asperiores adipisci quibusdam. Deserunt debitis vel sed incidunt asperiores quam alias.','provident','102399708',NULL,'1976-03-07 14:19:43','2003-01-31 02:36:37'),
('60','60','10','Illum quia libero ipsum ea non aperiam quasi. Doloremque et autem accusamus. Quia eos dolorem mollitia aut est error. Quo est maiores facere.','quis','2270359',NULL,'2012-08-16 04:44:38','2007-01-20 02:48:06'),
('61','61','1','Atque dolores deserunt in reprehenderit odio aut. Voluptates harum repudiandae sit assumenda laborum sed vero. Quasi quo enim illo quis rem. Mollitia voluptatem natus id enim voluptas necessitatibus.','dicta','797',NULL,'1999-12-23 04:05:16','2020-01-19 13:27:52'),
('62','62','2','Sint omnis eveniet molestias similique rerum nihil. Quisquam tempore error sunt eveniet corrupti. Minima ea nihil facere et. Voluptate et quidem cupiditate non est nobis.','alias','4668',NULL,'2007-08-12 23:14:20','2001-06-22 01:08:28'),
('63','63','3','Cupiditate inventore aliquid veritatis occaecati laudantium qui. Eum ut porro quaerat et omnis voluptatum perferendis. Voluptate est dicta velit error recusandae voluptates.','nihil','7634799',NULL,'1998-11-18 01:19:44','1992-10-09 23:39:23'),
('64','64','4','Ea tempore odio repellat. Dolor et blanditiis cum explicabo sed et neque. Minima aut neque porro voluptatibus consequatur iusto. Repellendus est et aliquam enim est nam.','esse','465',NULL,'2012-02-01 07:15:07','1975-11-09 13:30:44'),
('65','65','5','Voluptatem laborum consequatur perferendis non laboriosam et. Dolores voluptatem natus porro et quaerat aut. Cumque accusantium inventore consequatur et commodi quasi suscipit eos. Est ad qui ut et.','aliquam','0',NULL,'1985-08-13 09:19:25','2020-03-12 01:44:09'),
('66','66','6','Iure esse et doloremque nihil aliquid placeat sunt. Impedit esse accusamus est molestiae tempora dolores. Quisquam consectetur debitis voluptas illum. Veritatis quasi non molestias distinctio saepe culpa.','cum','5116',NULL,'1977-09-28 06:06:01','2018-03-19 03:43:12'),
('67','67','7','Aliquam minus molestiae facere et sint. Esse architecto vel consequuntur corrupti ut officiis laborum. Perferendis ut aut magni at. Voluptas mollitia qui dolore rerum dolores perspiciatis architecto sit.','quo','569121',NULL,'1988-08-20 13:02:44','2013-01-31 03:25:23'),
('68','68','8','Cum adipisci numquam nihil eum corporis est. Sit eos explicabo consequatur. Voluptatem at animi esse pariatur vero dolor. Nisi accusamus eaque consequuntur omnis.','voluptatem','26043149',NULL,'1993-02-08 18:33:12','1971-12-21 12:43:01'),
('69','69','9','Est dolorem veritatis tenetur harum a inventore quo et. Vitae et omnis nostrum doloribus sunt adipisci. Est iste aut harum sapiente ut veritatis omnis. Minima aut maxime ut nihil.','voluptatem','45881184',NULL,'1975-08-13 19:22:04','1989-10-31 22:59:52'),
('70','70','10','Fugiat libero nulla porro cumque tenetur sed. Dolores maiores qui qui fuga et non ex. Laboriosam officiis perspiciatis quis quaerat est pariatur esse.','temporibus','482859',NULL,'1970-11-25 17:16:47','2010-12-31 09:53:18'),
('71','71','1','Autem atque iusto velit dolor voluptates omnis labore. Culpa sunt vero laudantium quasi nemo illum voluptatum eum. Officia ut maiores est soluta.','quisquam','219455262',NULL,'1974-06-03 13:08:27','1984-01-01 23:48:45'),
('72','72','2','Rerum aspernatur et dolorum. Sed aperiam pariatur et sint.','at','5939',NULL,'2018-04-24 17:21:22','1997-02-19 14:17:06'),
('73','73','3','Veniam perspiciatis perspiciatis est et ad sed beatae consequatur. Occaecati vitae quidem necessitatibus molestiae harum tenetur sit. Aspernatur corporis quod architecto saepe dolores repellat amet. Molestiae dolores dolores ipsa facere.','qui','420903',NULL,'1980-07-14 21:02:10','1989-01-30 23:36:01'),
('74','74','4','Numquam explicabo veritatis quos dolore deserunt perspiciatis quia. Similique tempore ad quaerat vel nemo. Ipsam cupiditate repudiandae voluptate enim.','molestiae','754',NULL,'2014-05-25 00:52:12','2016-07-23 16:00:16'),
('75','75','5','Magnam iure omnis hic fugit quia hic voluptas. Autem non id dolorem odit magnam. Repellendus occaecati tempore est aperiam sunt officiis. Odit velit fugiat voluptates autem asperiores voluptatibus dolorem quisquam.','laudantium','718047771',NULL,'2017-04-18 14:06:18','2011-05-15 15:24:22'),
('76','76','6','Placeat ut magnam accusamus voluptatem. Est nobis quisquam ut minus. Qui doloribus voluptas saepe autem sed commodi voluptatibus.','minima','44411335',NULL,'1991-03-30 13:26:01','2013-02-16 18:37:17'),
('77','77','7','Dolorum dicta magni debitis facere. Aut voluptatum similique consequuntur nihil sunt et. Cum consequatur hic laborum ut voluptatem. Ut excepturi suscipit qui est eaque iusto.','omnis','941',NULL,'2010-09-30 07:38:26','2016-04-11 16:34:00'),
('78','78','8','Quam earum velit autem expedita ratione. Velit numquam sit tenetur. Quia quia suscipit dolor quia error facere.','omnis','852',NULL,'1998-02-07 00:16:41','2019-05-02 21:57:26'),
('79','79','9','Assumenda et harum quia dolorum vel consequatur tenetur. Quam architecto et ea ut ducimus animi. Aut a est in quam.','vero','8306879',NULL,'1976-12-28 05:34:07','1981-10-28 07:50:48'),
('80','80','10','Ex odio atque vero ipsam officiis aut. Ea consequatur aut reprehenderit quia fuga voluptas. Aut dolores laborum alias earum eveniet. Voluptatem alias consequatur ipsa deserunt.','dignissimos','6433',NULL,'1991-03-05 15:19:20','2012-01-16 20:00:27'),
('81','81','1','Ut natus enim sint debitis suscipit rem sit est. Consequatur qui quia molestias ex et ad. Velit corporis amet blanditiis odio nihil eos.','quisquam','963375204',NULL,'1991-03-01 23:07:31','1980-07-06 06:28:24'),
('82','82','2','Nemo est quia quaerat quod aut ea. Aspernatur est reprehenderit tempore maiores quasi id. Voluptatum repudiandae quisquam nihil in at iste. Exercitationem dignissimos vel dicta illum.','eos','10846',NULL,'2012-04-21 07:21:18','2005-12-21 06:25:07'),
('83','83','3','Ut fuga inventore ducimus eos sunt accusantium. Officiis cumque quo quas reprehenderit debitis velit facere. Id libero explicabo ratione fuga ut id adipisci.','natus','20',NULL,'1972-11-04 02:30:00','1984-03-09 22:12:29'),
('84','84','4','Et quidem ipsum quia odio dolorum praesentium quis. Totam est magni occaecati enim aut tempore. Accusantium aut molestiae nobis nulla.','veritatis','0',NULL,'1979-01-20 08:27:36','2005-07-06 03:12:03'),
('85','85','5','Inventore reprehenderit eos aut. Saepe distinctio doloremque et tempore. Voluptates atque maxime delectus. Architecto sit omnis molestiae necessitatibus excepturi et non aut.','reiciendis','603',NULL,'2013-06-01 07:21:25','2015-12-31 12:01:33'),
('86','86','6','Saepe in aut omnis voluptatem assumenda non. Ipsum fugit veritatis dolorem. Quas adipisci nemo aut voluptates sed cumque et. Repellat est quia quos cumque in excepturi at.','ut','833',NULL,'1998-09-02 12:49:24','1993-01-26 19:21:15'),
('87','87','7','Quas consequatur consequatur labore ut eius veniam. Illo molestiae nam tempore inventore ex. Voluptas sed ratione veritatis non natus quia sed.','corrupti','84',NULL,'2015-07-14 03:12:49','2018-10-11 03:44:58'),
('88','88','8','Mollitia doloribus deleniti laudantium voluptas. Alias id error quis in.','accusantium','571626',NULL,'1995-10-13 18:22:02','1985-06-07 16:28:51'),
('89','89','9','Praesentium quia non veritatis quisquam et maxime. Suscipit itaque aut quasi quis alias voluptatem et. Molestiae quia ut odio voluptas.','maxime','0',NULL,'1975-06-04 18:45:12','2001-11-23 03:16:05'),
('90','90','10','Repudiandae quisquam vel quasi ullam et. Quia minus aut nihil repellendus ducimus voluptas debitis. Saepe similique expedita reprehenderit maiores.','quia','1',NULL,'2019-07-14 06:24:02','2015-11-18 15:11:14'),
('91','91','1','Aperiam eaque fugit consequatur omnis quis voluptatem. Quo vitae quo illum quo. Quam omnis et molestias enim aut deleniti. Temporibus animi labore non ducimus et.','veniam','408',NULL,'1977-07-19 18:01:50','1992-06-12 00:09:31'),
('92','92','2','Magni placeat ut placeat cumque sit aspernatur. Minima explicabo dolor exercitationem voluptatem molestiae ducimus suscipit. Animi a nihil voluptatem dolorum nesciunt eum.','cum','1776941',NULL,'2010-07-27 16:43:27','1975-07-30 03:29:07'),
('93','93','3','Recusandae laboriosam modi rerum qui est dolor. Maxime consequatur corporis quisquam possimus. Facilis dolores dignissimos molestiae.','adipisci','0',NULL,'2007-02-23 09:55:40','2007-06-01 20:50:43'),
('94','94','4','Rerum sed maxime consequatur omnis. Dolor nisi quia voluptas blanditiis corporis saepe expedita.','ut','13774749',NULL,'1990-07-11 01:34:10','1993-02-14 04:29:05'),
('95','95','5','Tempore eaque voluptas doloribus corporis rem totam corporis. Omnis tempore repudiandae dolores. Aut tenetur autem dolorem.','praesentium','86395',NULL,'1995-08-25 09:22:07','1989-10-19 07:52:20'),
('96','96','6','Autem architecto optio dolor libero. Quia deleniti aut in ut et.','excepturi','840923',NULL,'1974-02-18 20:29:27','1985-04-19 20:50:19'),
('97','97','7','Odio aliquam porro et saepe harum. Ducimus amet dolorem error maiores veniam enim ut. Est quidem sint qui quo quo id qui. Eum est aut in libero assumenda quisquam culpa provident.','nobis','872',NULL,'2002-05-06 18:09:20','1991-01-29 06:10:22'),
('98','98','8','Accusamus aut dolor in. Eum sed voluptas eum perferendis vitae fugiat accusamus. Exercitationem ut ut nam et. Consectetur velit rerum at aspernatur fugiat eum.','placeat','0',NULL,'2007-05-24 03:36:37','2015-08-14 15:52:07'),
('99','99','9','Quaerat harum expedita dolores temporibus aut repudiandae. Placeat quidem a id autem nulla laborum distinctio. Consequatur eos voluptatibus earum nobis.','unde','891',NULL,'1988-02-02 02:06:08','1982-05-25 03:45:54'),
('100','100','10','Voluptas sit est voluptatem enim. Dolores recusandae ratione nesciunt. Necessitatibus magnam perferendis nulla odit.','est','0',NULL,'1996-02-05 03:05:36','1974-07-09 12:19:22'); 


DROP TABLE IF EXISTS `media_types`;
CREATE TABLE `media_types` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` enum('txt','mp3','jpeg','ogg') COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `media_types` VALUES ('1','mp3','1971-07-08 04:19:40','1976-11-27 14:07:44'),
('2','ogg','1973-01-11 12:13:37','2012-09-28 21:54:14'),
('3','ogg','2018-11-25 09:13:17','2019-01-20 01:17:00'),
('4','jpeg','1986-01-16 23:20:11','2016-04-15 21:20:55'),
('5','jpeg','2011-04-08 22:13:56','2016-12-07 11:37:09'),
('6','txt','1974-10-12 13:05:36','1971-10-02 15:49:27'),
('7','ogg','1983-10-26 10:34:35','2007-12-25 21:36:20'),
('8','txt','2018-04-17 11:00:23','1990-12-30 08:50:52'),
('9','jpeg','1981-05-28 21:02:24','2003-05-24 01:29:04'),
('10','ogg','1979-05-14 04:55:28','1994-04-20 02:26:35'),
('11','mp3','1975-06-28 03:06:07','1976-12-06 04:31:54'),
('12','txt','1993-09-27 20:18:53','2019-09-22 16:33:35'),
('13','ogg','1986-02-17 07:07:10','1971-04-08 10:24:21'),
('14','ogg','1988-03-25 20:14:13','1999-01-23 22:58:14'),
('15','ogg','1975-01-21 19:32:59','1978-05-14 08:49:12'),
('16','jpeg','2006-07-09 21:44:58','1986-05-14 02:17:14'),
('17','mp3','1997-08-30 15:39:32','1998-10-06 22:52:08'),
('18','mp3','1972-08-08 10:10:57','1981-05-20 04:50:54'),
('19','txt','1970-04-22 17:57:08','2018-11-15 13:07:40'),
('20','txt','1977-08-17 20:29:20','1986-01-24 18:02:23'),
('21','ogg','1992-07-11 17:59:24','2017-12-13 14:36:43'),
('22','ogg','1982-07-29 09:58:46','1971-05-19 12:07:48'),
('23','txt','2005-12-04 05:25:19','2004-09-01 09:30:22'),
('24','mp3','2016-05-29 16:36:31','2000-02-24 09:40:08'),
('25','mp3','1974-01-12 20:29:16','2005-05-02 11:50:03'),
('26','jpeg','2001-04-08 00:38:25','1972-04-19 13:15:08'),
('27','mp3','1990-07-28 05:08:45','1984-10-09 19:35:59'),
('28','ogg','2002-07-16 23:25:17','1994-09-06 20:52:09'),
('29','txt','1992-01-04 08:27:10','1996-01-27 23:23:57'),
('30','txt','2007-11-02 10:40:57','1980-11-30 03:43:24'),
('31','mp3','2018-05-04 18:44:09','1992-12-26 23:19:27'),
('32','txt','2006-11-02 06:28:15','1999-09-04 19:13:07'),
('33','txt','2002-11-11 07:57:00','2008-01-26 15:24:43'),
('34','mp3','2004-10-02 14:20:39','1978-04-20 01:59:18'),
('35','mp3','1984-04-14 04:29:00','1997-05-15 09:26:07'),
('36','ogg','1981-09-28 23:01:16','1988-02-28 07:54:54'),
('37','txt','1991-11-07 06:56:25','1972-02-20 15:24:01'),
('38','jpeg','2000-04-06 02:46:06','1993-11-05 02:40:43'),
('39','jpeg','1990-09-25 09:50:50','2005-11-23 22:12:30'),
('40','jpeg','1998-05-20 21:36:35','1970-12-23 23:55:50'),
('41','txt','2014-05-08 23:59:34','2017-09-09 16:56:35'),
('42','ogg','1974-01-02 04:06:30','1988-07-26 08:17:41'),
('43','mp3','2013-02-28 14:36:20','1999-10-13 09:07:06'),
('44','txt','2012-12-13 15:10:55','1984-06-03 09:40:38'),
('45','mp3','2000-01-15 11:51:45','1977-09-30 22:55:59'),
('46','txt','2016-04-01 04:00:37','1982-09-10 08:05:21'),
('47','ogg','1998-01-29 23:51:11','1989-09-02 15:25:00'),
('48','mp3','1998-05-13 10:19:55','2003-10-27 01:41:13'),
('49','mp3','1993-02-24 04:08:48','2005-11-06 23:30:59'),
('50','txt','2002-02-14 09:25:22','1994-07-17 06:41:54'),
('51','jpeg','2018-08-13 05:53:43','2002-05-21 05:27:39'),
('52','txt','2011-01-03 09:49:52','2009-04-22 02:22:10'),
('53','mp3','2019-11-16 04:55:52','2009-04-26 02:25:40'),
('54','mp3','2017-06-09 19:15:25','2003-05-28 22:14:59'),
('55','ogg','1973-09-03 21:43:49','1975-08-13 15:50:54'),
('56','txt','2015-06-15 19:38:48','2018-05-25 07:56:18'),
('57','txt','1998-04-06 11:35:16','1996-07-16 09:34:11'),
('58','jpeg','1972-02-09 05:46:31','2015-09-06 03:16:15'),
('59','jpeg','2002-06-03 20:47:29','2017-03-08 20:04:42'),
('60','txt','2010-03-19 13:25:05','1985-12-10 16:27:04'),
('61','ogg','1996-06-18 05:52:13','2001-04-30 14:16:27'),
('62','jpeg','1983-12-18 22:36:52','2002-07-29 10:11:24'),
('63','ogg','2002-04-14 00:18:10','2019-08-02 17:18:10'),
('64','txt','2001-12-03 11:45:28','1982-10-03 05:58:44'),
('65','ogg','1987-03-15 03:52:42','2001-09-07 04:27:54'),
('66','txt','1977-04-06 04:18:22','1984-10-08 11:05:01'),
('67','jpeg','2001-01-17 10:49:31','1996-03-05 16:40:59'),
('68','txt','2007-06-29 00:29:43','1996-07-25 05:36:51'),
('69','mp3','1984-03-15 07:07:07','2001-06-18 02:16:23'),
('70','jpeg','2003-12-16 06:31:18','1970-05-06 08:06:58'),
('71','ogg','1981-03-26 14:29:01','1987-04-23 02:10:23'),
('72','jpeg','1987-12-01 13:57:53','2020-05-07 02:10:00'),
('73','mp3','1993-03-28 12:06:24','1979-03-30 20:02:17'),
('74','ogg','1984-08-25 14:07:13','2009-02-07 18:02:37'),
('75','jpeg','2020-02-17 20:37:27','1971-12-03 14:34:11'),
('76','mp3','1999-12-03 16:38:21','2007-07-03 20:40:57'),
('77','ogg','1979-07-31 03:56:20','2004-05-17 07:08:22'),
('78','ogg','2002-06-25 11:32:17','1993-08-01 03:19:15'),
('79','jpeg','1984-09-27 08:57:22','1993-07-25 17:27:24'),
('80','txt','1997-09-06 03:28:10','1970-06-08 08:40:47'),
('81','ogg','2008-09-03 02:01:44','2006-12-27 22:39:07'),
('82','mp3','1982-11-11 16:53:23','1976-12-14 05:26:11'),
('83','mp3','1995-07-26 07:52:37','1971-05-03 01:58:02'),
('84','mp3','2010-03-30 01:16:54','1986-04-07 02:55:32'),
('85','mp3','1981-05-14 19:45:00','1988-12-06 05:37:52'),
('86','ogg','1982-09-28 03:10:11','1980-03-11 15:50:06'),
('87','mp3','1982-06-17 11:55:56','2015-05-07 22:30:17'),
('88','txt','1984-08-06 15:04:43','1976-09-16 21:14:24'),
('89','mp3','2008-09-05 23:48:13','2015-09-15 15:38:01'),
('90','ogg','1994-10-25 13:21:12','1994-05-11 22:31:52'),
('91','jpeg','2016-01-14 07:25:51','1996-11-19 15:53:48'),
('92','jpeg','1995-01-03 03:00:19','2006-07-07 14:57:21'),
('93','ogg','2015-02-19 15:49:18','2003-09-25 01:53:00'),
('94','txt','2009-12-02 21:51:14','1974-12-24 01:42:31'),
('95','ogg','2016-12-17 19:49:25','2000-07-03 02:30:32'),
('96','txt','1993-07-12 07:50:25','1972-01-06 09:39:20'),
('97','ogg','1984-10-21 04:03:23','1988-06-24 18:07:27'),
('98','jpeg','2007-06-15 21:08:07','2017-05-22 03:21:56'),
('99','txt','2007-09-20 06:25:25','2011-06-15 04:03:54'),
('100','txt','2018-11-21 09:44:48','1999-08-09 05:32:34'); 


DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint(20) unsigned NOT NULL,
  `to_user_id` bigint(20) unsigned NOT NULL,
  `body` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  UNIQUE KEY `id` (`id`),
  KEY `from_user_id` (`from_user_id`),
  KEY `to_user_id` (`to_user_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `messages` VALUES ('1','1','1','Ullam inventore quas nostrum eius aut. Nemo et rerum iusto error eos. Natus qui quia incidunt tempore dolore aut commodi eos. Quia aut ut corporis eum reprehenderit voluptas repudiandae.','2015-08-25 15:35:32'),
('2','2','2','In minima distinctio et rem voluptatem modi. Dolores fugit aut voluptas dolorem. Ex et dolorem rerum ut. Eligendi ut accusamus voluptas nostrum.','2008-06-23 13:14:52'),
('3','3','3','Nostrum ipsa sed maxime tenetur cumque. Odio voluptatum sed voluptas.','1995-03-27 04:56:07'),
('4','4','4','Eaque facilis incidunt cumque ea saepe delectus et. Officiis qui asperiores rerum enim nesciunt dolor cum minus.','2005-11-06 09:04:40'),
('5','5','5','Atque sed eos nesciunt ut maiores molestiae mollitia. Recusandae aut voluptatem et nobis est reprehenderit voluptates. Aperiam blanditiis reiciendis quia recusandae qui quae esse eaque.','1994-09-21 20:32:16'),
('6','6','6','Sed beatae sint vero architecto dolores. Non velit rerum quasi aperiam. Neque est maiores impedit sequi. Voluptates facilis et sed at et non accusantium fugit.','1995-06-29 07:29:14'),
('7','7','7','Molestias unde fuga consequatur eaque tenetur. Perspiciatis quis at ut voluptatem molestiae et. Autem voluptatibus nihil eum placeat et. Fuga ullam libero laborum et qui alias velit eius.','2001-01-13 06:10:14'),
('8','8','8','Dolore et eum voluptatem. Quis architecto ea nostrum voluptatem et quis. Beatae et velit porro voluptas.','1972-05-19 13:28:09'),
('9','9','9','Et distinctio nihil dolor. Ratione repudiandae esse aut consequuntur neque voluptatem unde. Qui recusandae odit et et totam rerum facere.','1991-04-15 09:49:21'),
('10','10','10','Officia dolorem consequatur adipisci nam dolore similique. Distinctio quis quo at ea possimus et. Id quibusdam eos et aliquid repellendus in omnis atque.','2001-07-18 08:11:50'),
('11','1','1','Excepturi ab ad possimus voluptatum nihil. Aut cum totam velit placeat. Assumenda sit ea qui doloribus alias ut eos nihil.','1990-09-18 23:11:30'),
('12','2','2','Neque est ad magni. Sunt officia nostrum rem aut. Molestiae velit non velit voluptate.','1988-01-08 20:56:07'),
('13','3','3','Inventore voluptas dolorem beatae qui. Officiis labore rerum magnam dignissimos. Est tempora omnis repudiandae et expedita.','2007-07-07 02:47:04'),
('14','4','4','Sed soluta quia fugit ducimus. Qui libero illum unde non corrupti. Molestias omnis qui est necessitatibus doloremque aut. Ullam vel error nisi perspiciatis odit consequatur.','2001-02-23 09:18:48'),
('15','5','5','Molestias reiciendis veritatis soluta voluptas officiis corrupti. Cumque minus vel vero adipisci repudiandae sit nihil. Velit et eum rerum ullam aut.','1992-12-25 16:34:25'),
('16','6','6','Ut consequatur sunt delectus animi nisi architecto voluptatem quos. Qui deleniti consequuntur explicabo id quis consequatur. Necessitatibus commodi est aut blanditiis voluptatem. Vitae et iure animi aut autem eligendi voluptatem.','2011-05-15 03:56:01'),
('17','7','7','Natus excepturi itaque nihil qui. Labore voluptas dolor laboriosam saepe minima aspernatur praesentium in. Eius veritatis sed odio porro corporis commodi et pariatur.','2011-02-01 20:52:23'),
('18','8','8','Magni aperiam esse deleniti ducimus et. Deleniti cupiditate eaque facere voluptatum labore repellendus est. Nisi enim et impedit dolores.','1971-08-30 00:27:19'),
('19','9','9','Nulla eos illum officia velit facere pariatur dolor. Sint vitae sed quis ex. Dolorum nobis dolor nesciunt nulla tempora a. Et nihil non recusandae eaque porro consequatur magnam. Nesciunt aut cupiditate est facilis.','1990-12-31 12:48:47'),
('20','10','10','Sit necessitatibus quos doloribus ipsa. Porro suscipit dolor quo quidem amet. Assumenda accusamus et deserunt autem quia error qui. Repellendus fugit quas aspernatur id a autem.','1983-10-30 13:53:06'),
('21','1','1','Laboriosam sed et nam et. Incidunt debitis placeat id. Eos rem porro quae. Autem ex ipsam et voluptatem natus. Cupiditate distinctio quas minima et.','1986-03-01 22:53:54'),
('22','2','2','Voluptate aperiam suscipit in. Rerum natus quo nam nihil perferendis. Iusto ipsam qui vel cum.','1985-12-16 12:24:05'),
('23','3','3','Ipsa aut et debitis ullam consequatur. Necessitatibus dolorem ut quibusdam. Atque et eos harum nisi est iusto eum eos.','1970-12-28 14:09:18'),
('24','4','4','Odio esse ea non dolore porro in accusantium. Numquam eaque consectetur reiciendis sint. Quis nemo explicabo asperiores reprehenderit ducimus. Repellat voluptatem neque dolore ea.','1982-01-23 16:03:57'),
('25','5','5','Consectetur voluptas minus praesentium est facere earum necessitatibus. Qui aperiam recusandae deserunt sed corporis voluptatem. Ducimus non sit vero voluptas. Unde est voluptatem et.','1975-08-10 04:07:55'),
('26','6','6','Mollitia aspernatur et ipsam nostrum quia. Odit ratione laudantium aut consequuntur. Cum iusto eius occaecati aspernatur distinctio ut.','1982-10-18 14:21:18'),
('27','7','7','Quod voluptatem quo animi eos harum architecto non. Omnis ad consequatur atque dolor architecto repudiandae necessitatibus. Necessitatibus harum temporibus ab voluptas quidem sit. Sit eligendi laborum numquam.','1981-09-20 01:57:03'),
('28','8','8','Nemo aut et aut. Commodi possimus accusamus sed sint et maxime saepe. Doloremque voluptates placeat aut dolores et hic ad tempora. Soluta ut qui sit fugit velit neque. Quis omnis quo voluptatem et.','2001-01-26 04:20:46'),
('29','9','9','Omnis sint sequi repellendus quia ullam est modi. Omnis autem quidem ipsam. Sequi voluptatibus sed sequi rerum saepe ut. Nesciunt enim architecto veniam sit animi molestias blanditiis.','1972-01-12 11:39:24'),
('30','10','10','Accusantium error voluptas saepe quia sed sequi ratione. Expedita a deserunt ut voluptatum quia. Ut laboriosam qui id iure quia. Qui omnis aliquid quaerat vitae quibusdam et inventore.','1988-12-15 10:35:06'),
('31','1','1','Esse ipsa fugit optio aut quo earum fugiat. Adipisci sequi aspernatur hic rerum nihil eos fugit. Ratione qui laborum voluptatem dolor itaque molestiae sunt. Voluptatem aut impedit aut cumque officia sint.','2019-11-07 21:52:24'),
('32','2','2','Voluptates voluptas dolorem beatae quod molestiae et odio voluptatem. Delectus sed enim enim eveniet dolorem ut atque. Ducimus dolore neque voluptatum nobis qui iure doloribus.','1979-11-05 02:14:46'),
('33','3','3','Vel sunt quas dolores tenetur et. Velit quis dolorum eum mollitia unde. Eius tempore aut sed exercitationem et tenetur.','1979-07-07 17:35:00'),
('34','4','4','Quam odio accusantium quia omnis alias et officia. Nisi qui sed vel ad dolor non ut. Enim ipsa in odio voluptatem praesentium.','2000-03-05 04:12:59'),
('35','5','5','Voluptas quo atque ipsa. Doloremque omnis sit iste accusamus perspiciatis tenetur iure.','1983-03-01 11:08:15'),
('36','6','6','Dolorum tenetur assumenda quae velit. Est cupiditate eveniet sed repellendus.','1976-01-27 05:48:19'),
('37','7','7','Rerum dignissimos molestiae optio qui ut. Veniam architecto dolorem ea nam. Ea voluptas dignissimos autem ipsa cum iusto sunt. Vel ducimus cumque accusantium est distinctio sequi consequuntur.','2003-08-02 17:56:00'),
('38','8','8','Dolores excepturi rerum enim aperiam nihil nam est. Labore debitis delectus repellat qui iure quisquam.','2007-10-15 20:01:06'),
('39','9','9','Quis explicabo debitis ut placeat. Repellat voluptatem aliquid nulla optio id deleniti delectus. Unde occaecati consectetur tempore dolores quia et et reiciendis.','1985-03-16 20:21:03'),
('40','10','10','Sed in similique totam id ea aut perspiciatis. Sapiente reprehenderit ipsam error voluptate est voluptatem. Rem quia officia vel ipsam quaerat inventore ex modi. Voluptatem cumque aut quasi ipsam consequatur dicta perspiciatis facilis.','1972-09-21 20:47:04'),
('41','1','1','Ut occaecati quam et rerum. Debitis nemo voluptas repellat qui explicabo. Quaerat quam qui libero molestiae quo quos. Autem delectus ut consequatur.','1972-10-24 09:06:18'),
('42','2','2','Impedit fugiat architecto sit provident. Eligendi voluptatem facere laudantium et iure ipsa aspernatur. Alias quam ut velit quasi ut tenetur. Autem aut rerum adipisci facere voluptatibus et perspiciatis.','2014-03-30 21:45:30'),
('43','3','3','Nulla aliquam occaecati et exercitationem nesciunt. Voluptatem reprehenderit suscipit dolor. Est soluta id voluptatem veritatis voluptatibus perspiciatis ea.','1971-09-30 10:35:08'),
('44','4','4','Nostrum qui perspiciatis sed ipsa ex non enim. Porro voluptas odit est nulla corrupti laborum aut aut. Tempora est quo eos facilis. Aut dolores dolorum laboriosam. Aut sint reprehenderit ut et.','1979-10-14 06:01:55'),
('45','5','5','Laudantium autem sit est enim. Dolores magnam enim ut numquam doloribus iusto qui. Aspernatur qui animi id. Odit nisi nemo quis rerum fugit. Culpa quia molestiae accusamus perspiciatis.','2019-07-22 20:06:41'),
('46','6','6','Cupiditate delectus aut magni ut vero quis. Et qui itaque ut fuga asperiores modi rerum vel. Maiores quidem ex vero impedit sit.','1983-05-03 12:43:08'),
('47','7','7','Dolorum vel deserunt recusandae tempore eveniet praesentium. Cum molestiae voluptate quasi alias atque. Tempora corrupti id quidem consequatur. Rerum reprehenderit qui deserunt necessitatibus aperiam id.','1977-09-23 22:07:33'),
('48','8','8','Ad voluptate incidunt non. Ullam optio eveniet autem pariatur voluptatem aut tempore et. Sed sequi ut corporis dolores quia magnam.','2001-06-19 23:22:22'),
('49','9','9','Saepe sunt repellat omnis et alias. Officia error sint perspiciatis eius doloribus. In unde numquam vero ducimus explicabo dolore.','2005-02-20 02:01:54'),
('50','10','10','Sit voluptatibus itaque dolorum doloremque voluptatum explicabo. Nam autem accusamus illo explicabo. Nisi aut ex nulla occaecati explicabo hic est. Quia repudiandae ut in qui.','2000-07-02 23:23:31'),
('51','1','1','Facere ipsam est distinctio est. Dolorem consequuntur officia qui repellat dolores. Quasi quae tempora distinctio aspernatur.','2017-02-04 03:34:32'),
('52','2','2','Velit error in incidunt non explicabo rerum dolor. Et et dicta quod impedit officiis quia. Aut odit repellendus ut asperiores dolorem. Libero enim tempora tempore corporis.','1974-07-22 03:59:38'),
('53','3','3','Sit corporis sed maiores voluptatum. Fugiat sit sint qui repellendus esse quam eos quae. Doloribus velit et molestiae rerum voluptate reiciendis odio sunt.','1978-04-19 11:01:34'),
('54','4','4','Iste ratione totam fugiat distinctio maiores expedita. Magni voluptas dolores facilis delectus minima ex corporis. Accusamus illum officiis qui aut.','1989-08-16 14:11:19'),
('55','5','5','Accusantium tenetur a occaecati aut cupiditate debitis est. Consequuntur libero ab occaecati maxime. Ex facere temporibus et.','1987-07-11 18:24:12'),
('56','6','6','Eius eos voluptate nesciunt non commodi reiciendis. Possimus sit maiores facere et. Et inventore aut sint et.','1998-09-10 10:26:32'),
('57','7','7','Omnis eveniet animi laudantium eaque aut numquam. Temporibus ad qui debitis vitae debitis qui modi est. Ipsum voluptas necessitatibus itaque asperiores. Repudiandae non rerum omnis dolorum tempora necessitatibus cumque. Dolor adipisci et dolores qui.','2009-11-01 13:11:05'),
('58','8','8','Hic debitis illo vero cumque laborum. Ab suscipit est quis est eveniet illum. Et tenetur atque facilis est.','2017-08-26 09:23:23'),
('59','9','9','Ut debitis numquam inventore culpa qui aut. Odit optio totam eum nesciunt autem et. Distinctio esse rerum aperiam deleniti.','1981-10-13 15:46:19'),
('60','10','10','Animi harum vero odio perspiciatis repudiandae ullam perferendis. Maiores possimus et totam. Quia animi sit veritatis recusandae est.','1993-08-10 03:51:41'),
('61','1','1','Labore omnis dolor laboriosam atque. Esse est sunt hic voluptatem. Quia qui est eius. Et autem sequi ratione et eius at sit et.','1987-12-11 10:37:23'),
('62','2','2','Quis sed quia ipsa qui atque ut. Odio qui voluptas eveniet nobis fugit deserunt. Itaque qui mollitia non molestiae vel occaecati nemo.','1995-12-13 18:15:37'),
('63','3','3','Facilis eaque fugit aut itaque est. Qui natus totam eveniet magni maiores. Dolores et nemo sint temporibus expedita exercitationem quo. Ut animi voluptas quaerat recusandae est nostrum consectetur.','2000-07-03 10:16:44'),
('64','4','4','Iusto unde nobis quo aut error asperiores ea. Et ex consequatur quo. Voluptatum rem dolore earum omnis architecto qui.','1998-07-28 16:08:32'),
('65','5','5','Dolorem reiciendis quasi est fugiat fuga voluptas doloribus soluta. Doloribus in eum culpa nobis odit velit omnis. Voluptatem non ea a quis. Minima numquam voluptatum quia.','2004-03-14 15:14:25'),
('66','6','6','Molestias sunt tenetur ratione est non rerum non. Optio quae similique sit nostrum quidem voluptatum. Voluptatum voluptas quasi enim veritatis saepe sint. Quis ipsum voluptas quibusdam aperiam.','1978-11-04 06:02:20'),
('67','7','7','Ut reiciendis et et. Tenetur voluptatem id nisi sed. Quos et sequi rerum nostrum. Et provident reprehenderit blanditiis aspernatur corporis.','1985-10-07 11:15:13'),
('68','8','8','Dolores sed inventore voluptatem natus quam et ut. Mollitia nihil deserunt optio rerum. Quibusdam omnis ab modi illum magni sit.','1999-04-10 07:22:19'),
('69','9','9','Voluptate cupiditate et dolores dolorum. Dolorem vitae cum voluptate qui et. Perferendis ut et non dolorum quia et asperiores. Non soluta laudantium perferendis accusantium vel.','1983-03-22 01:26:54'),
('70','10','10','Numquam et tempora numquam ut. Similique recusandae perspiciatis sed expedita ducimus adipisci. Voluptatem inventore nulla nobis et velit. Sunt soluta dolor illum commodi neque. In nesciunt quidem cum vel mollitia eligendi maiores.','1975-11-04 04:19:06'),
('71','1','1','Impedit ex sit praesentium sapiente. Qui perferendis inventore aut in dicta. Quae totam laborum fuga qui fuga ipsum veniam aut.','1976-06-05 15:46:38'),
('72','2','2','Cum dolorem laudantium quasi placeat placeat totam ad. Reiciendis est eum sunt ducimus perspiciatis est et quis. Officia temporibus similique enim aut. Repellat cupiditate eveniet sapiente eum.','1997-11-22 07:50:29'),
('73','3','3','Cupiditate aut totam eos et quia qui omnis. Delectus enim labore ut quidem aspernatur quod rem asperiores. Porro quia dolorum porro amet sit adipisci. Mollitia non ipsam velit omnis occaecati. Et id qui non voluptatem assumenda.','2000-11-19 00:22:22'),
('74','4','4','Voluptates velit qui nihil quos dolorem fugiat nesciunt. Quae omnis sit iusto placeat accusantium sapiente officia. Neque et officia dicta.','1985-09-06 16:29:26'),
('75','5','5','Rerum odit architecto culpa rerum a ea. Rerum totam ipsa quia consequatur et totam eum deleniti. Nostrum consectetur deserunt et dolorem tenetur.','2016-12-27 12:49:52'),
('76','6','6','Expedita maxime mollitia laboriosam consequuntur et. Cupiditate vero sint quod mollitia et.','1993-12-18 11:02:12'),
('77','7','7','Est ut ut ea officiis ut tempora autem. Et facilis perferendis soluta et. Impedit harum assumenda soluta et non necessitatibus unde quasi. Eos nihil aliquid tenetur reprehenderit iusto eum.','1974-05-11 04:15:09'),
('78','8','8','Distinctio vero incidunt soluta temporibus. Ad molestias aut at quam id laudantium. Sequi sit vel minus ut. Sed odio corporis molestiae natus eum ipsum neque.','1981-02-08 08:49:18'),
('79','9','9','Porro id consequatur odit excepturi aut tempora. Non sit rerum commodi et sed. Nam dolorem dolor vero cum mollitia et quidem. Voluptas quae similique repellendus dolorum voluptatum. Dignissimos quia beatae quaerat aut occaecati saepe ipsa.','1977-12-21 05:50:44'),
('80','10','10','Incidunt est sapiente numquam. Labore ratione aut eum eius. Sed est maiores saepe in. Ut commodi sed adipisci voluptatibus labore sed.','1994-05-26 01:12:16'),
('81','1','1','Ipsa ea consequatur consectetur omnis voluptas quia. Corrupti totam et pariatur quos sint. Aliquam et molestias nostrum ut vel. Rerum omnis et provident cumque blanditiis. Nostrum occaecati amet excepturi sit aut doloribus deleniti.','2017-05-17 09:33:25'),
('82','2','2','Distinctio sunt harum et officia libero rerum odit. Necessitatibus at ex aliquam libero voluptatem incidunt dolores. Vel voluptatem tempore consequatur.','1996-10-01 03:11:10'),
('83','3','3','Nam doloribus autem pariatur eos tempora. Omnis qui omnis et quam eum temporibus. Consequatur accusamus ut expedita labore eaque ab. Cum blanditiis modi molestiae.','2013-07-04 07:48:46'),
('84','4','4','Consequatur enim dolorem quasi quos qui. Autem suscipit reprehenderit iure sit similique et est ipsum. Harum illo architecto sed qui id non odit. Modi eius saepe incidunt incidunt quasi.','2005-07-12 16:46:04'),
('85','5','5','Suscipit aliquam earum dolores ipsam possimus. Reiciendis similique laudantium qui sit ut. Nemo aspernatur excepturi perferendis.','2006-06-26 11:36:10'),
('86','6','6','Rerum harum sint alias doloremque voluptatum voluptas voluptatem aliquid. Saepe nemo eaque vel sint minus facere modi. Ut neque eos voluptatem totam nobis quia. Vel eveniet distinctio ut beatae eum.','2007-04-15 06:43:43'),
('87','7','7','Assumenda enim ea autem ut qui. Distinctio dolorem qui voluptatem quia porro corrupti. Veritatis et est numquam cumque nostrum nam quas.','1977-08-21 11:04:59'),
('88','8','8','Accusamus aut autem voluptate reprehenderit eum. Enim est nam et et accusamus distinctio neque. Tempore provident sit aut praesentium fugit sunt harum.','2017-08-11 18:40:22'),
('89','9','9','Commodi sit officia consequuntur similique eius dolores fuga. Dolores laborum labore repudiandae ducimus aut placeat. Dolores tempore velit quod. Quidem qui et id sunt nihil fugit quibusdam.','1992-03-21 07:32:06'),
('90','10','10','Eligendi praesentium quos molestias et. Recusandae et perspiciatis qui quia. Reiciendis asperiores enim laboriosam velit error impedit. Maxime corporis maiores fuga voluptatibus.','2008-09-26 09:36:02'),
('91','1','1','Omnis fugiat ratione facilis at veniam. Dolorem libero labore voluptatem enim nisi in.','1997-11-01 01:36:13'),
('92','2','2','Voluptatem dolor exercitationem dignissimos porro dolores. Ut perspiciatis omnis quis. Expedita velit minima eaque et dolores.','1993-11-27 07:43:35'),
('93','3','3','Nam nam expedita ut quia aut illo nulla non. Non soluta deserunt sunt optio et. Cum aut repellat fugiat qui. Non dolore sequi molestias porro.','1970-03-05 09:59:46'),
('94','4','4','Cumque non iusto et magni eos. Nam sequi id ex aut quidem et ut. Officia perspiciatis sit repudiandae quisquam a porro fugit.','1975-10-21 23:34:48'),
('95','5','5','Voluptatum iusto amet aut. Voluptate dignissimos porro ab dolores velit nobis. Dicta amet culpa ipsa ut quos aperiam. Atque autem nam ea officiis iusto harum.','2020-05-26 13:39:54'),
('96','6','6','Molestias alias est quo quis. Excepturi inventore voluptatem magnam recusandae. Porro assumenda libero maxime dolorem est incidunt dolores quam. Natus totam totam quisquam doloribus aliquam sit iusto cum.','1984-03-02 15:28:23'),
('97','7','7','Consectetur inventore maiores sequi quia nobis. Cum alias excepturi qui inventore molestias delectus. Velit dicta doloribus dolor eligendi.','2005-10-13 09:15:07'),
('98','8','8','Molestias laboriosam officiis assumenda ex hic quas ea. Neque ipsum aut autem corporis doloribus inventore. Voluptatum et qui et enim unde explicabo facilis officia.','1996-05-05 06:45:08'),
('99','9','9','Labore iusto magni blanditiis ipsa magni inventore distinctio. Et rem accusantium doloremque incidunt quas. Qui magnam assumenda ex repellat officiis id ratione. Aut eaque exercitationem minima fugiat dolor. Excepturi quod ipsum et suscipit qui exercitationem voluptas quis.','2013-12-29 14:37:40'),
('100','10','10','Blanditiis eum sint blanditiis officiis quo adipisci soluta dolorem. Est fuga enim fugit voluptatem dolor earum.','1975-04-28 12:14:40'); 


DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `photo_albums_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `photo_albums` VALUES ('1','quia','1'),
('2','qui','2'),
('3','itaque','3'),
('4','dolorem','4'),
('5','numquam','5'),
('6','dolorum','6'),
('7','expedita','7'),
('8','incidunt','8'),
('9','et','9'),
('10','reprehenderit','10'),
('11','est','1'),
('12','velit','2'),
('13','voluptatem','3'),
('14','temporibus','4'),
('15','omnis','5'),
('16','eos','6'),
('17','qui','7'),
('18','et','8'),
('19','rem','9'),
('20','tempore','10'),
('21','eos','1'),
('22','perspiciatis','2'),
('23','culpa','3'),
('24','pariatur','4'),
('25','consequatur','5'),
('26','dignissimos','6'),
('27','delectus','7'),
('28','ad','8'),
('29','illo','9'),
('30','praesentium','10'),
('31','quos','1'),
('32','hic','2'),
('33','id','3'),
('34','in','4'),
('35','consequuntur','5'),
('36','voluptates','6'),
('37','quos','7'),
('38','et','8'),
('39','ut','9'),
('40','optio','10'),
('41','adipisci','1'),
('42','ut','2'),
('43','ipsa','3'),
('44','sit','4'),
('45','reiciendis','5'),
('46','suscipit','6'),
('47','qui','7'),
('48','voluptatem','8'),
('49','quia','9'),
('50','hic','10'),
('51','natus','1'),
('52','deleniti','2'),
('53','ea','3'),
('54','ad','4'),
('55','repellendus','5'),
('56','voluptate','6'),
('57','voluptas','7'),
('58','voluptatem','8'),
('59','adipisci','9'),
('60','deleniti','10'),
('61','atque','1'),
('62','dolor','2'),
('63','hic','3'),
('64','eligendi','4'),
('65','error','5'),
('66','et','6'),
('67','quos','7'),
('68','vero','8'),
('69','omnis','9'),
('70','et','10'),
('71','quis','1'),
('72','et','2'),
('73','consequatur','3'),
('74','mollitia','4'),
('75','debitis','5'),
('76','ut','6'),
('77','voluptas','7'),
('78','id','8'),
('79','quo','9'),
('80','molestiae','10'),
('81','et','1'),
('82','accusantium','2'),
('83','nihil','3'),
('84','excepturi','4'),
('85','et','5'),
('86','tempora','6'),
('87','quo','7'),
('88','eos','8'),
('89','nesciunt','9'),
('90','delectus','10'),
('91','ipsum','1'),
('92','et','2'),
('93','odio','3'),
('94','amet','4'),
('95','et','5'),
('96','commodi','6'),
('97','non','7'),
('98','adipisci','8'),
('99','explicabo','9'),
('100','rerum','10'); 


DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `album_id` bigint(20) unsigned NOT NULL,
  `media_id` bigint(20) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`),
  KEY `album_id` (`album_id`),
  KEY `media_id` (`media_id`),
  CONSTRAINT `photos_ibfk_1` FOREIGN KEY (`album_id`) REFERENCES `photo_albums` (`id`),
  CONSTRAINT `photos_ibfk_2` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `photos` VALUES ('1','1','1'),
('2','2','2'),
('3','3','3'),
('4','4','4'),
('5','5','5'),
('6','6','6'),
('7','7','7'),
('8','8','8'),
('9','9','9'),
('10','10','10'),
('11','11','11'),
('12','12','12'),
('13','13','13'),
('14','14','14'),
('15','15','15'),
('16','16','16'),
('17','17','17'),
('18','18','18'),
('19','19','19'),
('20','20','20'),
('21','21','21'),
('22','22','22'),
('23','23','23'),
('24','24','24'),
('25','25','25'),
('26','26','26'),
('27','27','27'),
('28','28','28'),
('29','29','29'),
('30','30','30'),
('31','31','31'),
('32','32','32'),
('33','33','33'),
('34','34','34'),
('35','35','35'),
('36','36','36'),
('37','37','37'),
('38','38','38'),
('39','39','39'),
('40','40','40'),
('41','41','41'),
('42','42','42'),
('43','43','43'),
('44','44','44'),
('45','45','45'),
('46','46','46'),
('47','47','47'),
('48','48','48'),
('49','49','49'),
('50','50','50'),
('51','51','51'),
('52','52','52'),
('53','53','53'),
('54','54','54'),
('55','55','55'),
('56','56','56'),
('57','57','57'),
('58','58','58'),
('59','59','59'),
('60','60','60'),
('61','61','61'),
('62','62','62'),
('63','63','63'),
('64','64','64'),
('65','65','65'),
('66','66','66'),
('67','67','67'),
('68','68','68'),
('69','69','69'),
('70','70','70'),
('71','71','71'),
('72','72','72'),
('73','73','73'),
('74','74','74'),
('75','75','75'),
('76','76','76'),
('77','77','77'),
('78','78','78'),
('79','79','79'),
('80','80','80'),
('81','81','81'),
('82','82','82'),
('83','83','83'),
('84','84','84'),
('85','85','85'),
('86','86','86'),
('87','87','87'),
('88','88','88'),
('89','89','89'),
('90','90','90'),
('91','91','91'),
('92','92','92'),
('93','93','93'),
('94','94','94'),
('95','95','95'),
('96','96','96'),
('97','97','97'),
('98','98','98'),
('99','99','99'),
('100','100','100'); 


DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
  `user_id` bigint(20) unsigned NOT NULL,
  `gender` char(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `photo_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `hometown` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `profiles` VALUES ('1','1','2019-10-07','1','1','2005-12-27 17:20:40',NULL),
('2','2','1986-01-28','0','2','2013-02-16 07:42:20',NULL),
('3','1','2008-09-12','0','3','2005-05-17 23:00:28',NULL),
('4','2','1970-01-18','0','4','2003-05-20 15:48:16',NULL),
('5','3','1996-02-13','1','5','1996-02-14 01:37:07',NULL),
('6','2','1998-06-28','0','6','2002-07-30 15:02:48',NULL),
('7','3','1975-02-25','1','7','2006-01-24 17:49:20',NULL),
('8','3','1994-12-25','1','8','1990-08-02 23:00:30',NULL),
('9','1','1984-06-23','0','9','1991-05-28 06:30:26',NULL),
('10','2','2005-09-16','1','10','1974-03-16 14:47:11',NULL); 


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Фамиль',
  `age` int(10) unsigned NOT NULL,
  `email` varchar(120) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_hash` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `users_firstname_lastname_idx` (`firstname`,`lastname`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='юзеры';

INSERT INTO `users` VALUES ('1','Abraham','35','9561','chandler88@example.org','234749d860ea34ab9c4642759d4b3f007500f5c9','0'),
('2','Karelle','46','142803','casper.xavier@example.org','da1fe744c406387d5e4620dbaa9f29e9634fef1a','9'),
('3','Teresa','51','35797941','uriah98@example.com','6bf23892b84e955dad50754528d982e650c4e111','5'),
('4','Alessia','39','1674','sbode@example.com','2f055b90cedeea59f1139c62e2f129907b9cdf91','8'),
('5','Mathilde','56','627','vking@example.org','7a46075be9342ea607ff76caa426590e1f6fd38f','2'),
('6','Justine','50','68252','lauren.ward@example.net','495a9d539c9a58620a74e724ec4b0d026807ccdc','7'),
('7','Lamont','48','40752','macejkovic.lenna@example.com','f6dd2e98e7c88d190b53f286832c20d30a878908','4'),
('8','Tressie','18','67','hertha.pfeffer@example.org','bd6fd086b45529e9e4086ed478188ffd3f583645','6'),
('9','Gerhard','18','59','trantow.madyson@example.com','dc089af36b983a1019412884c0ac91814b710b83','1'),
('10','Crystal','36','32270037','tillman.hartmann@example.net','ded8511c6bce7e4c7b404dc71e574b7920b05a35','3'); 


DROP TABLE IF EXISTS `users_communities`;
CREATE TABLE `users_communities` (
  `user_id` bigint(20) unsigned NOT NULL,
  `community_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`user_id`,`community_id`),
  KEY `community_id` (`community_id`),
  CONSTRAINT `users_communities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `users_communities_ibfk_2` FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `users_communities` VALUES ('1','1'),
('1','11'),
('1','21'),
('1','31'),
('1','41'),
('1','51'),
('1','61'),
('1','71'),
('1','81'),
('1','91'),
('2','2'),
('2','12'),
('2','22'),
('2','32'),
('2','42'),
('2','52'),
('2','62'),
('2','72'),
('2','82'),
('2','92'),
('3','3'),
('3','13'),
('3','23'),
('3','33'),
('3','43'),
('3','53'),
('3','63'),
('3','73'),
('3','83'),
('3','93'),
('4','4'),
('4','14'),
('4','24'),
('4','34'),
('4','44'),
('4','54'),
('4','64'),
('4','74'),
('4','84'),
('4','94'),
('5','5'),
('5','15'),
('5','25'),
('5','35'),
('5','45'),
('5','55'),
('5','65'),
('5','75'),
('5','85'),
('5','95'),
('6','6'),
('6','16'),
('6','26'),
('6','36'),
('6','46'),
('6','56'),
('6','66'),
('6','76'),
('6','86'),
('6','96'),
('7','7'),
('7','17'),
('7','27'),
('7','37'),
('7','47'),
('7','57'),
('7','67'),
('7','77'),
('7','87'),
('7','97'),
('8','8'),
('8','18'),
('8','28'),
('8','38'),
('8','48'),
('8','58'),
('8','68'),
('8','78'),
('8','88'),
('8','98'),
('9','9'),
('9','19'),
('9','29'),
('9','39'),
('9','49'),
('9','59'),
('9','69'),
('9','79'),
('9','89'),
('9','99'),
('10','10'),
('10','20'),
('10','30'),
('10','40'),
('10','50'),
('10','60'),
('10','70'),
('10','80'),
('10','90'),
('10','100'); 




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
