
-- 
/*
 * создаем таблицу пользователей - используется только для входа в систему
 * индексы на поля phone, login, enabled, email из расчета что к ник будут часто обращаться при регистрации или поиске контактов 
 * */
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    login VARCHAR(60) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    password_updated_at DATETIME DEFAULT NOW() NOT NULL,
    is_enabled bit DEFAULT 0 NOT NULL,
    is_admin bit DEFAULT 0 NOT NULL,
    created_at DATETIME DEFAULT NOW() NOT NULL,
    birthday DATETIME DEFAULT NULL,
    first_name VARCHAR(40) default null,
    second_name VARCHAR(40) default null,
    third_name VARCHAR(40) default null,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(40) UNIQUE NOT NULL,
    avatar VARCHAR(255) ,
    INDEX users_phone_idx(phone),
    INDEX users_email_idx(phone), 
    INDEX users_login_idx(login),
    INDEX users_enabled_idx(is_enabled)
);


/* 
 * таблица со списком кастомных полей пользователя
 * для полей вида: адрес проживания, офис, номер телефона для связи и т.д.
 */
DROP TABLE IF EXISTS `usercustomfield`;
CREATE TABLE `usercustomfield` (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) unique not null
);

/*
 * таблица дополнительных данных пользователя
 * */
DROP TABLE IF EXISTS `userdetail`;
CREATE TABLE `userdetail` (
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    usercustomfield_id BIGINT UNSIGNED NOT NULL,
    value VARCHAR(40),
    FOREIGN KEY fk_userdetail__user_id (user_id) REFERENCES users(id),
    FOREIGN KEY fk_userdetail__usercustomfield_id (usercustomfield_id) REFERENCES usercustomfield(id)
);

/**
 * тэги
 */
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) unique not null
);

/*
 * cписок проектов
 */
DROP TABLE IF EXISTS `project`;
CREATE TABLE `project` (
    id SERIAL PRIMARY KEY,
    owner BIGINT UNSIGNED NOT NULL,
    updated_at DATETIME DEFAULT NOW() NOT NULL,
    name varchar(40) NOT NULL,
    description text DEFAULT NULL,
    is_closed bit default 0 NOT NULL,
    end_at DATETIME DEFAULT null,
    current_iteration BIGINT UNSIGNED NOT NULL DEFAULT 1,
    FOREIGN KEY fk_project_owner__owner (owner) REFERENCES users(id),
    INDEX project_current_iteration_idx (current_iteration)
    );
   
/**
 * тэги проектов
 */
DROP TABLE IF EXISTS `projecttags`;
CREATE TABLE `projecttags` (
    id SERIAL PRIMARY KEY,
    project_id BIGINT UNSIGNED NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
  	FOREIGN KEY fk_projecttags__tag_id(tag_id) REFERENCES tags(id),
    FOREIGN KEY fk_projecttags__project_id (project_id) REFERENCES project(id)
    
    );    

/*
 * список состояний задачи (дорожек) 
 * Новая, в разработке, Ожидает проверки, Тестирование, Завершена
 * */
DROP TABLE IF EXISTS `projectrow`;
CREATE TABLE `projectrow` (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) default "New"
);
   
/*
 * список ролей в проекте 
 * Тимлид, архитектор системы, разработчик БД, дизайнер, владелец продукта и т.д.
 * */
DROP TABLE IF EXISTS `projectrole`;
CREATE TABLE `projectrole` (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40),
    project_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY fk_projectrole__project_id  (project_id) REFERENCES project(id),
    UNIQUE role_in_project (name, project_id) 
);

/*
 * список команд разработчиков
 * */
DROP TABLE IF EXISTS `team`;
CREATE TABLE `team` (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) UNIQUE NOT NULL,
    owner_user_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY fk_team__owner_user_id  (owner_user_id) REFERENCES users(id)
    
);

/**
 * список состава команды 
 * */
DROP TABLE IF EXISTS `teamcomposition`;
CREATE TABLE `teamcomposition` (
    id SERIAL PRIMARY KEY,
    team_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    projectrole_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY fk_teamcomposion__team_id (team_id) REFERENCES team(id),
    FOREIGN KEY fk_teamcomposion__user_id  (user_id) REFERENCES users(id),
	FOREIGN KEY fk_teamcomposion__projectrole_id (projectrole_id) REFERENCES projectrole(id)
);


/*
 * список команд работающих над проектом
 * Эту создал, потому что может быть так что над проектом работает 2 команды
 * к примеру первая по фронту, а вторая бэк или mobile, desktop, но проект общий
 * */
DROP TABLE IF EXISTS `teamproject`;
CREATE TABLE `teamproject` (
    id SERIAL PRIMARY KEY,
    team_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY fk_teamproject__team_id (team_id) REFERENCES team(id),
    FOREIGN KEY fk_teamproject__project_id  (project_id) REFERENCES project(id)
);


/*
 * список задач в проекте 
 * */
DROP TABLE IF EXISTS `taskproject`;
CREATE TABLE `taskproject` (
    id SERIAL PRIMARY KEY,
    name varchar(40) NOT NULL,
    description text DEFAULT NULL,
    projectrow_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL,
  	taskdirector BIGINT UNSIGNED NOT NULL,
    taskperformer BIGINT UNSIGNED NOT NULL,
    is_complete bit default 0, 
    is_checkoncomplete bit default 0, 
    result_url varchar(204) default NULL,
    update_at DATETIME DEFAULT now(),
    end_at DATETIME null,
    iteration BIGINT UNSIGNED NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY fk_taskproject__projectrow_id (projectrow_id) REFERENCES projectrow(id),
    FOREIGN KEY fk_taskproject__project_id (project_id) REFERENCES project(id),
    FOREIGN KEY fk_taskproject__taskdirector (taskdirector) REFERENCES users(id),
    FOREIGN KEY fk_taskproject__taskperformer(taskperformer) REFERENCES users(id)
    );

/*
 * список соисполнителей задачи 
 * */
DROP TABLE IF EXISTS `taskcoperformer`;
CREATE TABLE `taskcoperformer` (
    id SERIAL PRIMARY KEY,
    taskproject_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	FOREIGN KEY fk_taskcoperformer__taskproject_id(taskproject_id) REFERENCES taskproject(id),
    FOREIGN KEY fk_taskcoperformer__user_id (user_id) REFERENCES users(id)
    );  
   
 /*
 * список соисполнителей задачи 
 * */
DROP TABLE IF EXISTS `taskwatchers`;
CREATE TABLE `taskwatchers` (
    id SERIAL PRIMARY KEY,
    taskproject_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	FOREIGN KEY fk_taskwatchers__taskproject_id(taskproject_id) REFERENCES taskproject(id),
    FOREIGN KEY fk_taskwatchers__user_id (user_id) REFERENCES users(id)
    );
   
   
/**
 * тэги задач
 */
DROP TABLE IF EXISTS `tasktags`;
CREATE TABLE `tasktags` (
    id SERIAL PRIMARY KEY,
    taskproject_id BIGINT UNSIGNED NOT NULL,
    tag_id BIGINT UNSIGNED NOT NULL,
  	FOREIGN KEY fk_tasktags__tag_id(tag_id) REFERENCES tags(id),
    FOREIGN KEY fk_tasktags__taskproject_id (taskproject_id) REFERENCES taskproject(id)
    );   
   

/*
 * комментарии к задачам
 * **/
DROP TABLE IF EXISTS `tasksprojectcomment`;
CREATE TABLE `tasksprojectcomment` (
	id SERIAL PRIMARY KEY,
    taskproject_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,   
    update_at DATETIME DEFAULT now() NOT NULL,
    message text,
    parent_message_id BIGINT UNSIGNED DEFAULT NULL,
    FOREIGN KEY fk_tasksprojectcomment__taskproject_id(taskproject_id) REFERENCES taskproject(id),
    FOREIGN KEY fk_tasksprojectcomment__user_id(user_id) REFERENCES users(id)
);

   
   
   
   
   
   
   
   
   
