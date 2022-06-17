/**
Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным пользователем.

будем искать кто общался с пользователем user_id=1.  Т.е. надо найти пользователя который больше всех писал сообщения пользователю 1
*/

-- не получлись выполнить агрегацию в функцию max, 

	select count(*)  as cnt, from_user_id, to_user_id
	from 
		messages
	where 
		to_user_id =1
	group by 
		from_user_id 



/**
====================== 2 ===========================
Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
*/

select count(*) from likes 
where user_id in (
	SELECT user_id 
 	from profiles
   	where
   	TIMESTAMPDIFF(YEAR, birthday, NOW()) < 18
); 


/**
=======================3 =================================
Определить кто больше поставил лайков (всего): мужчины или женщины.
*/

select (
	select count(*) from likes 
	where user_id in (SELECT user_id 
					  from profiles
                      where
                      profiles.gender = 'f')
) as women_votes,  
(
	select count(*) from likes 
	where user_id in (SELECT user_id 
					  from profiles
                      where
                      profiles.gender = 'm')
) as man_votes
, 
if ((
	select count(*) from likes 
	where user_id in (SELECT user_id 
					  from profiles
                      where
                      profiles.gender = 'f')
)  > (
	select count(*) from likes 
	where user_id in (SELECT user_id 
					  from profiles
                      where
                      profiles.gender = 'm')
), "Женских голсоов больше", "Мужских голосов больше" ) as res
  

                               
                               
                               