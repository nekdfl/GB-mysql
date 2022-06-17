/**
* ********** Процедуры ***********
*/

/*
 *  увеличить итерацию проекта
 */

DROP PROCEDURE IF EXISTS bpm.increase_project_iteration;

DELIMITER $$
$$
CREATE PROCEDURE bpm.increase_project_iteration(in project_id bigint unsigned)
BEGIN
	update project
	set current_iteration = current_iteration + 1
	where id = @project_id;
END$$
DELIMITER ;

/*
 *  уменьшить итерацию проекта
 */

DROP PROCEDURE IF EXISTS bpm.decrease_project_iteration;

DELIMITER $$
$$
CREATE PROCEDURE bpm.decrease_project_iteration(in project_id bigint unsigned)
BEGIN
	update project
	set current_iteration = current_iteration - 1 
	where id = @project_id;
END$$
DELIMITER ;
