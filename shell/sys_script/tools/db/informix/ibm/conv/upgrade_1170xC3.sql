{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  Copyright IBM Corporation 2011                                        *}
{*                                                                        *}
{**************************************************************************}
{                                                    			   }
{   Title:  upgrade_1170xC3.sql                         		   }
{   Description:                                     			   }
{       Upgrade from 11.70 to 11.70xC3                  		   }
{   Note:                                                                  }
{       Errors encountered while executing this sql script are NOT ignored.}
{	'upgrade_1170xC3_setup.sql' is run before this script.		   }
{**************************************************************************}


DATABASE sysadmin;

UPDATE STATISTICS FOR PROCEDURE;


/********************
* UTF-8 SUPPORT UDR *
*********************/
CREATE FUNCTION IF NOT EXISTS string_to_utf8(string lvarchar(4096), source_locale lvarchar)
    RETURNS lvarchar
    EXTERNAL NAME '(string_to_utf8)'
    LANGUAGE C;

/********************
* LOG FILE ROTATION *
*********************/

DELETE FROM ph_threshold WHERE name = "MAX_MSGPATH_VERSIONS";
DELETE FROM ph_threshold WHERE name = "MAX_BAR_ACT_LOG_VERSIONS";
DELETE FROM ph_threshold WHERE name = "MAX_BAR_DEBUG_LOG_VERSIONS";

INSERT INTO ph_threshold(id,name,task_name,value,value_type,description)
VALUES
(0,"MAX_MSGPATH_VERSIONS", "online_log_rotate","12","NUMERIC"
,"Maximum number of online log files to keep.");

INSERT INTO ph_threshold(id,name,task_name,value,value_type,description)
VALUES
(0,"MAX_BAR_ACT_LOG_VERSIONS", "bar_act_log_rotate","12","NUMERIC"
,"Maximum number of bar act log files to keep.");

INSERT INTO ph_threshold(id,name,task_name,value,value_type,description)
VALUES
(0,"MAX_BAR_DEBUG_LOG_VERSIONS", "bar_debug_log_rotate","12","NUMERIC"
,"Maximum number of bar debug log files to keep.");

--DROP FUNCTION IF EXISTS admin_message_log_rotate(INT,INT,VARCHAR(255),INT);

CREATE FUNCTION admin_message_log_rotate(task_id INT, task_seq INT 
                      , param VARCHAR(255) , max_files_to_keep INT DEFAULT NULL)
RETURNING INTEGER;

DEFINE path_to_message_log LVARCHAR(513);
DEFINE is_default BOOLEAN;
DEFINE ret_code INTEGER;
DEFINE temp_max_files_to_keep INTEGER;

DEFINE p_alert_type LIKE ph_alert.alert_type;
DEFINE p_alert_color LIKE ph_alert.alert_color;
DEFINE p_alert_obj_type LIKE ph_alert.alert_object_type;
DEFINE p_alert_obj_name LIKE ph_alert.alert_object_name;
DEFINE p_alert_message  LIKE ph_alert.alert_message;
DEFINE p_alert_action   LIKE ph_alert.alert_action;

	LET ret_code = 0;
    { check we have a valid param }	
	IF param IS NULL 
		OR param = "" 
		OR param = "ROOTPATH" 
		OR param = "MIRRORPATH"
	THEN
		LET ret_code = -1;
		LET p_alert_type     = "WARNING";
		LET p_alert_color    = "GREEN";
		LET p_alert_obj_type = "SERVER";
		LET p_alert_obj_name = "PARAM";
		LET p_alert_message  = "Invalid param("||param||") passed to admin_message_log_rotate";
		LET p_alert_action = NULL;
		GOTO ALERT_RETURN;
	END IF

	{ check max_files_to_keep 
		if its not passed in then look in sysadmin:ph_threshold
		for MAX_param_VERSIONS 
		if thats not found use the default of 12
	}

    IF max_files_to_keep IS NULL THEN
		SELECT value::integer INTO temp_max_files_to_keep 
		FROM sysadmin:ph_threshold 
		WHERE name = "MAX_"||param||"_VERSIONS";
		IF temp_max_files_to_keep IS NULL THEN
			LET temp_max_files_to_keep = 12;
		END IF
		LET max_files_to_keep = temp_max_files_to_keep;
	END IF

    { bound check the max_files_to_keep }
	IF max_files_to_keep <= 0 
		OR max_files_to_keep > 99
	THEN
		LET ret_code = -1;
		LET p_alert_type     = "WARNING";
		LET p_alert_color    = "GREEN";
		LET p_alert_obj_type = "SERVER";
		LET p_alert_obj_name = "VERSIONS";
		LET p_alert_message  = "Invalid value for the number of versions to keep("||max_files_to_keep||") It must be greater than 0 and less than 99.";
		LET p_alert_action = NULL;
		GOTO ALERT_RETURN;
	END IF

    { get the path name to the file }
       { first check if its an onconfig param }
	SELECT TRIM(cf_effective) INTO path_to_message_log 
	FROM sysmaster:syscfgtab WHERE cf_name = param;
       { quick check that we are not using STDOUT }
	IF ( path_to_message_log == "/dev/tty" ) THEN
		LET ret_code = -1;
		LET p_alert_type     = "WARNING";
		LET p_alert_color    = "GREEN";
		LET p_alert_obj_type = "SERVER";
		LET p_alert_obj_name = "PATH_NAME";
		LET p_alert_message  =  param||" maybe using STDOUT. Cannot rotate.";
		LET p_alert_action = NULL;
		GOTO ALERT_RETURN;
	END IF
	{ check if the param is a ph_threshold PATH_FOR_xxx }    
    IF path_to_message_log IS NULL THEN
		SELECT value::lvarchar INTO path_to_message_log
		FROM sysadmin:ph_threshold 
		WHERE name = "PATH_FOR_"||param;
		IF path_to_message_log IS NULL THEN
			LET path_to_message_log = param;
		END IF
	END IF

	EXECUTE FUNCTION sysadmin:admin("file rotate",path_to_message_log,max_files_to_keep) 
	INTO ret_code;
	IF ret_code < 0 THEN
		LET p_alert_type     = "WARNING";
		LET p_alert_color    = "GREEN";
		LET p_alert_obj_type = "SERVER";
		LET p_alert_obj_name = "PATH_NAME";
		LET p_alert_message  =  "FILE ROTATE failed ";
		LET p_alert_action = NULL;
		GOTO ALERT_RETURN;
	END IF

	RETURN ret_code;

<<ALERT_RETURN>>
        INSERT INTO ph_alert
          (ID, alert_task_id,alert_task_seq,alert_type,
           alert_color, alert_object_type,
           alert_object_name, alert_message,alert_action)
            VALUES
          (0,task_id, task_seq, p_alert_type
          , p_alert_color ,p_alert_obj_type ,p_alert_obj_name
		  , p_alert_message , p_alert_action);

		RETURN ret_code;

END FUNCTION;

DELETE FROM ph_task WHERE tk_name = "online_log_rotate";
DELETE FROM ph_task WHERE tk_name = "bar_act_log_rotate";
DELETE FROM ph_task WHERE tk_name = "bar_debug_log_rotate";

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_next_execution,
tk_frequency,
tk_delete,
tk_enable
)
VALUES
(
"online_log_rotate",
"TASK",
"SERVER",
"Rotate the Online Log",
"execute function admin_message_log_rotate($DATA_TASK_ID,$DATA_SEQ_ID,'MSGPATH')",
DATETIME(03:00:00) HOUR TO SECOND,
DATETIME(03:01:00) HOUR TO SECOND,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_next_execution,
tk_frequency,
tk_delete,
tk_enable
)
VALUES
(
"bar_act_log_rotate",
"TASK",
"SERVER",
"Rotate the BAR ACT Log",
"execute function admin_message_log_rotate($DATA_TASK_ID,$DATA_SEQ_ID,'BAR_ACT_LOG')",
DATETIME(03:00:00) HOUR TO SECOND,
DATETIME(03:01:00) HOUR TO SECOND,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_next_execution,
tk_frequency,
tk_delete,
tk_enable
)
VALUES
(
"bar_debug_log_rotate",
"TASK",
"SERVER",
"Rotate the Bar Debug Log",
"execute function admin_message_log_rotate($DATA_TASK_ID,$DATA_SEQ_ID,'BAR_DEBUG_LOG')",
DATETIME(03:00:00) HOUR TO SECOND,
DATETIME(03:01:00) HOUR TO SECOND,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);

    
{**************************************************************************
          MARK THE ABOVE TASKS AS SYSTEM TASKS
**************************************************************************}
UPDATE ph_task SET tk_attributes = BITOR(tk_attributes, 4)
    WHERE tk_name
	IN ( 'online_log_rotate','bar_act_log_rotate','bar_debug_log_rotate' 
		,'autoreg exe', 'autoreg vp', 'autoreg migrate-console'
		,'bad_index_alert','check_for_ipa'
);


CLOSE DATABASE;
