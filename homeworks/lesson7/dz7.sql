/**
################## 1 #######################
Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
*/

select u.name 
from
	users as u
join
	orders as o 
where 
u.id = o.user_id
and 
o.user_id in (
select 
	user_id
from 
	orders 
group by orders.user_id
having count(*) > 0) -- после знака больше пиши больше какого количества повторений нужны записи
group by u.name
 

/*
################## 2 #######################
Выведите список товаров products и разделов catalogs, который соответствует товару.
*/

-- задание понял, так , что нужно вывести таблицу products, заменив catalog_id, на его реальное имя

-- select * from shop.catalogs
-- SELECT * FROM shop.products;


select p.id, p.name, p.description, p.price, c.name, p.created_at, p.updated_at
from
	products as p
join 
	catalogs as c
on 
	p.catalog_id = c.id
	

/*
################## 3 #######################
(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица 
городов cities (label, name). Поля from, to и label содержат английские названия городов, 
поле name — русское. Выведите список рейсов flights с русскими названиями городов.
*/
	
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	`from` varchar(30),
	`to` varchar(30)
);

DROP TABLE if EXISTS cities;
CREATE TABLE cities(
	`label` varchar(30),
	`name` varchar(30)
);

 insert into flights (`from`, `to` ) VALUES 
 ('moscow', 'omsk'),
 ('novgorod', 'kazan'),
 ('irkutsk', 'moscow'),
 ('omsk', 'irkutsk'),
 ('moscow', 'kazan');
 
 insert into cities (`label`, `name`) values 
 ('moscow', 'Москва'),
 ('irkutsk', 'Иркутск'),
 ('novgorod', 'Новгород'),
 ('kazan', 'Казань'),
 ('omsk', 'Омск');


-- решение
 
select 
f.`from` as eng_from, 
c.name as rus_from, 
f.`to` as eng_to,
c2.name as rus_to
from flights as f
join cities as c on c.label= f.`from` 
join cities as c2 on c2.label= f.`to` 



