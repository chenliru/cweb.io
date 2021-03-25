{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2011
{*                                                                        *}
{**************************************************************************}


{* If the ph_version table contains an entry for the upgrade_ph_task *}
{* then we should drop the constraint.                               *}

CREATE PROCEDURE drop_contraint_ph_task_constr2()

DEFINE num_rows INTEGER;

LET num_rows = 0;

SELECT count(*) INTO num_rows FROM ph_version WHERE
object = "upgrade ph_task";

IF num_rows > 0 THEN
    ALTER TABLE ph_task DROP CONSTRAINT ph_task_constr2;
END IF
 
END PROCEDURE;

EXECUTE PROCEDURE drop_constraint_ph_task_constr21234();

DROP PROCEDURE drop_constraint_ph_task_constr21234();
