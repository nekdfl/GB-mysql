/**
Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.
*/

drop database  if exists example;
CREATE database example;
use example;

CREATE TABLE users (
id int not null auto_increment primary key,
name varchar(40)
);
