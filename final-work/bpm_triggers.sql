-- 
DROP TRIGGER IF EXISTS  `increase_project_iteration`;
DELIMITER $$
CREATE TRIGGER `increase_project_iteration` BEFORE UPDATE 
    ON `taskproject` 
    FOR EACH ROW BEGIN
        IF NEW.iteration < OLD.iteration THEN
			SIGNAL SQLSTATE '40000' SET MESSAGE_TEXT = 'ERROR: taskiteration can\'t be decresed';
        END IF;
END$$
DELIMITER ;

-- select * from taskproject t;
-- 
update taskproject 
set iteration = iteration - 1
where id =1;