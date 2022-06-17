/**
=============================== 1 ======================
Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
Заполните их текущими датой и временем.
*/

use  vk;
-- таблица users имела другой вид.  Добавим колонки

alter table `users`
ADD COLUMN created_at varchar (30),
ADD COLUMN updated_at varchar(30);
 
/**
*
* заполним таблицу текущей датой
*/

-- РЕШЕНИЕ
update `users`
set 
created_at = now() ,
updated_at = now()
where id  <> 0;



/**
*
=============================== 2 ======================
Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR 
и в них долгое время помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к 
типу DATETIME, сохранив введеные ранее значения.
*/

--РЕШЕНИЕ

alter table `users`
MODIFY COLUMN created_at datetime DEFAULT now(),
MODIFY COLUMN updated_at datetime DEFAULT now();



/**
=============================== 3 ======================

В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, 
если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи 
таким образом, чтобы они выводились в порядке увеличения значения value. Однако, нулевые запасы 
должны выводиться в конце, после всех записей.
*/



-- Generation time: Fri, 07 Aug 2020 13:42:58 +0000
-- Host: mysql.hostinger.ro
-- DB name: u574849695_24
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

DROP TABLE IF EXISTS `storehouses_products`;
CREATE TABLE `storehouses_products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `value` bigint(20) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `storehouses_products` VALUES ('1','28'),
('2','24'),
('3','19'),
('4','36'),
('5','33'),
('6','10'),
('7','38'),
('8','3'),
('9','1'),
('10','12'),
('11','21'),
('12','18'),
('13','42'),
('14','25'),
('15','7'),
('16','37'),
('17','21'),
('18','24'),
('19','18'),
('20','32'),
('21','3'),
('22','18'),
('23','32'),
('24','31'),
('25','2'),
('26','2'),
('27','8'),
('28','14'),
('29','39'),
('30','31'),
('31','27'),
('32','37'),
('33','27'),
('34','7'),
('35','2'),
('36','8'),
('37','25'),
('38','39'),
('39','25'),
('40','34'),
('41','4'),
('42','0'),
('43','28'),
('44','1'),
('45','37'),
('46','21'),
('47','42'),
('48','5'),
('49','35'),
('50','20'),
('51','39'),
('52','26'),
('53','11'),
('54','40'),
('55','26'),
('56','30'),
('57','39'),
('58','28'),
('59','26'),
('60','20'),
('61','19'),
('62','6'),
('63','15'),
('64','39'),
('65','22'),
('66','36'),
('67','18'),
('68','19'),
('69','12'),
('70','37'),
('71','1'),
('72','29'),
('73','36'),
('74','22'),
('75','2'),
('76','33'),
('77','39'),
('78','10'),
('79','35'),
('80','42'),
('81','27'),
('82','37'),
('83','2'),
('84','11'),
('85','28'),
('86','37'),
('87','44'),
('88','44'),
('89','9'),
('90','24'),
('91','32'),
('92','0'),
('93','13'),
('94','8'),
('95','14'),
('96','12'),
('97','0'),
('98','28'),
('99','10'),
('100','41'); 




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- РЕШЕНИЕ

SELECT `value`  FROM vk.storehouses_products
ORDER by `value`  > 0, `value` DESC



/**
=============================== 4 ======================

(по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
Месяцы заданы в виде списка английских названий ('may', 'august')

*/

-- Generation time: Fri, 07 Aug 2020 14:17:55 +0000
-- Host: mysql.hostinger.ro
-- DB name: u574849695_18
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

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Фамиль',
  `age` int(10) unsigned NOT NULL,
  `email` varchar(120) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_hash` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` bigint(20) unsigned DEFAULT NULL,
  `birthday` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `users_firstname_lastname_idx` (`firstname`,`lastname`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='юзеры';

INSERT INTO `users` VALUES ('101','Adela','Emard','6','chelsea70@example.net','4564d29ac112f455233b52c75d4959ca9260855f','852342','2018-05-26 22:50:29'),
('102','Clementine','Kilback','6','jan52@example.net','a64ddc4588f2f57f7165db8a6674564351187b38','0','2011-09-16 07:05:37'),
('104','Willis','Williamson','0','gabe.hudson@example.org','d2ac36bd40cfdcfb6a948722dc6a6cdbb0a0dab0','7078273839','2013-05-04 15:50:46'),
('105','Marianne','Ward','6','rath.nova@example.org','036b2f1cb12cd80c8eb8441b06137af06727e9e8','997','2007-03-01 18:12:59'),
('107','Octavia','Lubowitz','0','crooks.deondre@example.net','e4729e78fbb9bb82c01c8f87667ca9c5b1608a47','1','1998-08-12 19:30:28'),
('109','Muhammad','Hansen','2','dwalker@example.net','5067db80ef44331039c4e4e6a35cc234a87e55cf','92','1995-03-26 13:23:27'),
('110','Louvenia','Schimmel','3','telly60@example.com','d313e046afb93bccded7558e233a1d71ae4594e3','943818','2009-03-23 19:15:43'),
('111','Hertha','Bechtelar','0','hritchie@example.com','1a76a5943789ea1920055c4d55e041294482d425','510','1999-01-18 16:29:15'),
('112','Haven','Collier','5','tristian.auer@example.org','a388219b0574307c0ec7b97218a3dcacf5e98c3b','81','2007-09-01 04:04:19'),
('113','Austin','Marquardt','0','dmayert@example.com','391e58e4941d9716a4e41d468c6554f872f50a5a','431','2019-11-15 12:50:08'),
('114','Hellen','Swift','9','farrell.erick@example.com','b9a78c7a441e785ebfd6928d2d7058057f99cee1','964290','1996-06-11 13:56:07'),
('115','Roderick','Rath','5','willms.mohammad@example.org','8d02be5a778324123d36bafde8b11e1b1098cdbc','963','2017-01-20 07:08:40'),
('118','Norval','Jacobi','7','sophia.becker@example.com','5470f9a769dd62d96c16bbabb72f920b99c3f9d6','104746','2014-11-18 15:13:57'),
('119','Ollie','Friesen','5','mraz.amani@example.com','fee1093e18cd0d4e289705faa520eb38ec10e075','494204','1991-02-01 01:35:24'),
('120','Bonita','Feest','0','giovanny.beer@example.org','c7a95851f3a8ea8119fb4bbb7390cb959ae67560','683590','1993-07-29 12:02:14'),
('124','Gladys','Heaney','7','xleannon@example.org','51b8de47ff658c927c93477d7dee76d9b65a99ad','221','2008-03-03 02:34:08'),
('126','Murphy','Sauer','3','mills.hipolito@example.net','8158372d935fc3ae462c57d8400f091388a1134a','154','2017-07-05 05:28:19'),
('127','Royce','Kassulke','2','ymoore@example.org','947e1d7dba164c6cbb58f9e81692b9b5e72142ff','300913','2009-03-10 17:47:21'),
('129','Evangeline','Beatty','6','hspinka@example.org','9bd7a1fcb21fd64498574dd388c84d6c7789c185','61','2019-01-03 19:53:58'),
('130','Drew','Wiegand','7','heath44@example.net','1d93093c3f4395ac3b01a3f94892c3fd6b7890c3','880','2016-10-03 01:33:14'),
('131','Claudie','Rohan','1','kaylee88@example.com','5e5e36e7a9339099a3da5f31a6015be67cc154fd','482580','2019-08-11 01:05:06'),
('134','Andreane','Sporer','1','mkoss@example.org','5a1ee664df4f2b94706d0d7f55b311e4a8b087a9','333','2005-09-20 11:37:31'),
('135','Elissa','Gaylord','0','wcorkery@example.net','e1267e092d532b0130a8ea39ebe85a0ff6329e16','354','2006-08-30 01:16:58'),
('136','Roberto','Waelchi','8','audrey.stracke@example.org','8cb690ead4bb5707e43e77bd17251aac8af1bf76','993790','2011-06-06 12:32:36'),
('137','Rashawn','Bahringer','2','wisoky.valentine@example.net','6d0ad941992f6bc396469a15d5c0b3d76bc9337b','316','2006-10-28 22:04:32'),
('138','Gabriella','Kling','5','wava.dooley@example.org','325e87c41c2c5d6e262b50eeec3d744cd5cb6657','140','1995-04-14 10:54:28'),
('139','Keven','Toy','1','dorcas22@example.org','4848841a0b7c6373250e744b0d0153770097050b','419','2010-10-27 00:54:29'),
('140','Graham','Denesik','5','hilton.murazik@example.org','7d0be0b9721c6adcce0f22069fa560ddf2426f4f','417','2002-01-31 14:17:17'),
('141','Shad','Koelpin','8','o\'kon.andreanne@example.com','4694809e37a6be8d4c6948923279be184d59805b','986100','1999-04-27 01:14:40'),
('142','Woodrow','Funk','0','gbarton@example.com','154c14796b146077c3ab9595c3b1d6fdb969e954','45','2010-04-24 12:40:07'),
('143','Graham','Ullrich','7','treva74@example.com','8019ce13e0288a2c8d3f38636dffa3cfaf0422b1','6557635030','1997-09-25 15:29:34'),
('144','Susie','Russel','2','emelia18@example.net','e15d0a0129af31ef3c7fa9f1d7377f620719eae1','7','2019-07-10 09:07:07'),
('147','Ernesto','Cremin','8','aniyah04@example.org','e1d22c6254c487ec4c015b17be9356c28d1cb3d1','77','1997-07-16 21:28:44'),
('148','Stevie','Wiegand','1','borer.reid@example.com','e13e75ddcbaf648782674bf87646e98b17583ac8','4','2011-05-25 05:42:23'),
('149','Emilia','Gutmann','2','stiedemann.anais@example.com','6b344430831016ceab24d2171a0af5c1dd322218','207091','1998-07-31 20:04:56'),
('150','Earl','Herzog','0','savannah35@example.net','a5cd80f5a033caebe4c5581f478cf8409c3f8c67','856','1997-01-27 09:53:40'),
('152','Modesta','Nicolas','1','antonietta91@example.com','c26459c4cbac85db52c312e0d0cb3cc286d69edc','493057','1993-01-25 06:00:47'),
('153','Kareem','Schultz','4','feeney.santiago@example.net','3909ba37c7731e7eb81840f723a1b0e40072c801','2472533187','2011-03-22 16:03:08'),
('155','Waino','Daniel','4','vtrantow@example.com','13f915dae69f9bc2313a24a1f29e38188e3b6e9b','8','1998-05-30 16:08:08'),
('159','Stefanie','Huels','8','ykling@example.net','21fa0c2c4e029ece84816ab0af8a9f35ee835e79','79','2018-01-02 18:52:57'),
('162','Hillary','Rempel','6','francesco73@example.org','beb4057f1f72000479bdd7ba11dc6ed6b73c6464','519915','2011-02-12 16:49:00'),
('164','Myles','Gleichner','2','rossie.turcotte@example.net','a45ce14b3e98751d697c28372dcbc16bf456caff','164','1999-08-19 13:21:07'),
('165','Cleveland','Sporer','6','elenora.o\'keefe@example.org','4230b9a7c7f3ef900386636f5a947e8ca8945e6e','147','2005-01-24 07:21:13'),
('166','Andy','Thiel','9','jarret03@example.net','a85f83823a97366fc24bfaf2f487c0d5325497e2','646467','2005-07-03 12:47:40'),
('167','Benton','Gleichner','1','lamont73@example.net','796ddfb03b7279a949a84a1eff1218ed2434970f','692302','1991-04-08 02:49:24'),
('168','Austyn','Waelchi','3','macejkovic.dario@example.org','8ab18cb5fac0e430993471f7694b26eff7b086c7','3669407589','2001-07-10 03:50:28'),
('169','Sarai','Botsford','7','trantow.antonietta@example.com','4ce43abd95d29c17fadb3eb44a41559b0da85eb7','24','1999-11-05 13:27:25'),
('171','Vida','Morissette','8','shanon31@example.net','fabcb3f505f2139190e1066c6b289ce780df602f','723953','2002-04-27 17:56:26'),
('174','Timmothy','Schowalter','6','hector08@example.org','3ef4e9e1cacb4a6f7dace77daacab12412444736','68','2015-10-28 02:36:59'),
('175','Helena','Crona','0','trath@example.org','18fb0424927cce50e301e5c3d665b7f4f280c695','562','2007-01-10 23:07:12'),
('177','Una','Rice','6','bgreenholt@example.org','9c7765964639b97fa3093f5b1ad50f0e0009fdc3','541813','2020-02-29 18:24:47'),
('181','Buddy','Bartoletti','9','khaley@example.org','3e27c3d02e9d9970491e016d5d7889cf3de4c7a3','4809738215','1996-06-24 02:40:47'),
('183','Baylee','Lesch','0','schowalter.jayde@example.org','10b55627872c30bcd5acfc884c2a1e8172e07b2e','5670131208','2004-11-28 14:29:53'),
('185','Alice','Rohan','1','rath.elda@example.com','400554b77fa695878b9c81d0ee05086464754d72','813','2003-09-26 14:34:15'),
('187','Lawson','Veum','1','hparker@example.com','b812bfb54e98148a3c4627abc7af62c5c00ffecf','5772620506','2007-10-03 00:26:15'),
('189','Meggie','Bergstrom','9','rollin.fahey@example.net','0327f5201a894123c913d6b1c687a29859ecdef5','82','1996-06-07 01:53:57'),
('192','Clemmie','Weissnat','3','upacocha@example.com','1fc9cca3f652770fa487b9cfa1281b595cf937ef','789','1992-11-12 05:51:36'),
('194','Flossie','Breitenberg','0','taylor.dicki@example.org','33e3cede8876bfa3304e8a92c47d717d88dcf10a','6','1991-10-04 19:10:03'),
('196','Cara','Veum','2','dyost@example.com','ecb121994b0b0fed1cb43b9d37af1c331a64f216','70524','1999-09-07 19:57:26'),
('197','Leopold','Schmeler','7','kprohaska@example.com','0cf54a7cc8435ad68c1ee063fbfcf36d9af1099f','8524975536','1993-09-03 23:38:22'),
('198','Paula','Bartoletti','6','justice59@example.org','7eb09aab24e62724c1d4af036911a32cd1047c2b','5077932087','2020-04-27 02:19:21'),
('199','Jaylon','Wilderman','4','carissa77@example.net','42302ff08ac6adabbbda303d1acd14fda6cc41d7','80','2010-05-22 01:28:37'); 




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;



-- РЕШЕНИЕ

SELECT *  FROM vk.users
where date_format(`birthday`, '%b') in ('may', 'august');


/**
=============================== 4 ======================

(по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
*/

-- РЕШЕНИЕ

SELECT * FROM catalogs WHERE id IN (5, 1, 2)
order by FIELD (id, 5,2,1); 


-- Практическое задание теме “Агрегация данных”
/**
=============================== 1 ======================
Подсчитайте средний возраст пользователей в таблице users
*/

-- РЕШЕНИЕ


SELECT  AVG(TIMESTAMPDIFF(YEAR, birthday, CURDATE())) AS AVG_AGE
FROM vk.users;

/**
=============================== 2 ======================
Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
Следует учесть, что необходимы дни недели текущего года, а не года рождения.
*/
-- РЕШЕНИЕ
select date_format(
	DATE(
	CONCAT_WS('-', YEAR(now()), MONTH(birthday), DAY(birthday))
	), '%W'
	) as dayweek ,
	COUNT(*) as counter
from 
   `profiles`
group by 
    dayweek
order by
	counter DESC


/**
=============================== 3 ======================
Подсчитайте средний возраст пользователей в таблице users
*/

/**
 логарифм произведения равен сумме логарифмов.
*/

-- РЕШЕНИЕ
SELECT exp(sum(ln(id))) FROM catalogs;