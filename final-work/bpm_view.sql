/****************************
 * *****Представления*******
 */

/**
 * Выборка для списка контактов при поиске людей в БД
 */
CREATE OR REPLACE  VIEW user_contacts AS SELECT id, login, email, phone from users ORDER BY id;
 
/**
 * Выборка для показа детальной информации с дополнительными полями.
 */
CREATE OR REPLACE VIEW user_conects_with_userdetail AS 
SELECT login, email, phone, u3.name, u2.value from users u 
LEFT join userdetail u2 
on u.id =u2.user_id 
RIGHT join usercustomfield u3 
on u2.usercustomfield_id = u3.id ORDER BY u.id ;


