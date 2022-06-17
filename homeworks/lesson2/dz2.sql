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
    is_adult BIT NOT NULL,
    photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
    
    , FOREIGN KEY (photo_id) REFERENCES media(id)
);

ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE -- (значение по умолчанию)
    ON DELETE restrict; -- (значение по умолчанию)

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

    PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
    -- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

--намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме
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

-- основная таблица сообществ
DROP TABLE IF EXISTS `community`; -- удалить если есть
CREATE TABLE `community` ( -- создаем таблицу сообщества
    id SERIAL PRIMARY KEY, -- добавляем первичный ключ BIGINT UNSIGNED DEFAULT NULL AI PK
    owner_id BIGINT UNSIGNED DEFAULT NULL, -- ид владельца сообщества
    community_name varchar (50), -- название сообщества
    community_description  TEXT, -- описание 
    community_url varchar(50) unique, -- уникальное имя группы, которое добавиться к базовому домену
    created_at DATETIME DEFAULT NOW(), -- дата создания приложения
    updated_at DATETIME DEFAULT NOW(), -- дата создания приложения
    FOREIGN KEY (owner_id) REFERENCES users(id) -- внешний ключ, ссылка на пользователя
) comment  "comunities of VK";

-- список пользователей сообщества
DROP TABLE IF EXISTS `community_users`; -- удалить если есть
CREATE TABLE `community_users` ( -- создаем таблицу пользователей сообщества
    community_id BIGINT UNSIGNED DEFAULT NULL, -- ид владельца сообщества
    is_moderator BOOL,
    user_id BIGINT UNSIGNED DEFAULT NULL, -- ид пользователя
    created_at DATETIME DEFAULT NOW(), -- дата создания добавления пользователя в сообщества
    FOREIGN KEY (community_id) REFERENCES community(id), -- внешний ключ, ссылка на пользователя
    FOREIGN KEY (user_id) REFERENCES users(id) -- внешний ключ, ссылка на пользователя
) comment  "user list of comunity in VK";

