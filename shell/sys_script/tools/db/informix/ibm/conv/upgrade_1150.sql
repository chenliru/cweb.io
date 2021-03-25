{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2010 All rights reserved.               *}
{*                                                                        *}
{**************************************************************************}
{                                                    }
{   Title:  upgrade_1150.sql                         }
{   Description:                                     }
{       Upgrade from 11.10 to 11.50                  }

DATABASE sysadmin;
/*
 **************************************************************
 **************************************************************
 *                    SCHEMA CHANGES
 **************************************************************
 **************************************************************
 */

/* Remove the constraing on the alert_object_type 
 *    Add the default back
 *    Add the Check constraint back with ALARM
 *    Remove all InPlace Alters
 */
ALTER TABLE ph_alert MODIFY ( alert_object_type char(16) );
ALTER TABLE ph_alert MODIFY ( alert_object_type char(15) DEFAULT 'MISC');
ALTER TABLE ph_alert ADD CONSTRAINT 
        CHECK ( UPPER(alert_object_type) IN
                 ("SERVER","DATABASE","TABLE","INDEX", "DBSPACE", 
                  "CHUNK","USER","SQL","MISC", "ALARM") ) CONSTRAINT ph_alert_constr1;
UPDATE ph_alert SET alert_object_type=alert_object_type WHERE 1=1;

/* Remove the check constraint value 'QUEUEDJOB'
 *    Add the default back
 *    Add the Check constraint back without QUEUEDJOB
 *    Remove all InPlace Alters
 */
ALTER TABLE ph_task MODIFY ( tk_type char(20) );
ALTER TABLE ph_task MODIFY ( tk_type char(18) DEFAULT 'SENSOR');
ALTER TABLE ph_task ADD CONSTRAINT 
        CHECK ( UPPER(tk_type) IN
             ("SENSOR", "TASK",
              "STARTUP SENSOR", "STARTUP TASK" ) ) CONSTRAINT ph_task_constr1;
UPDATE ph_task SET tk_name=tk_name WHERE 1=1;

ALTER TABLE ph_task ADD CONSTRAINT 
        CHECK ( tk_frequency > INTERVAL(0 00:00:00) day to second)
              CONSTRAINT ph_task_constr2;

CREATE VIEW ph_alerts
     (
       alert_id, run_id, task_id,
       task_name, task_description,
       alert_type, alert_color, alert_time,
       alert_state, alert_object_type, alert_object_name,
       alert_message, alert_action_dbs, alert_action
     )
AS SELECT ph_alert.id, ph_run.run_id, ph_task.tk_id,
          tk_name, tk_description, alert_type, alert_color,
          alert_time,
          alert_state, alert_object_type, alert_object_name,
          alert_message, alert_action_dbs, alert_action
FROM ph_alert, ph_run, ph_task
WHERE ph_alert.alert_task_id = ph_task.tk_id
      AND ph_run.run_task_id = ph_task.tk_id
      AND ph_alert.alert_task_seq = ph_run.run_task_seq;

CREATE VIEW ph_config ( ID, name, task_name, value, value_type )
        AS SELECT ID, name, task_name, value, value_type
        FROM ph_threshold;

create function
    informix.exectask_async(informix.lvarchar)
    returns informix.integer
    external name '(ph_sensor_c_async)'
    language C;

create function
    informix.exectask_async(informix.integer)
    returns informix.integer
    external name '(ph_sensor_i_async)'
    language C;


CREATE FUNCTION ph_reset_next_execution(attr INTEGER)
     RETURNING DATETIME YEAR TO SECOND, INTEGER
     DEFINE curr_time  DATETIME YEAR TO SECOND;
     DEFINE flags      INTEGER;

     LET flags = BITOR(attr, 2); /* set TK_ATTR_EVALUTE_TIME_ONLY(0x2) flag */
     LET curr_time = CURRENT;

     RETURN curr_time, flags;
END FUNCTION;

CREATE TRIGGER ph_task_trig_update_exec_time
    UPDATE OF tk_frequency, tk_start_time, tk_stop_time,
    tk_Monday, tk_Tuesday, tk_Wednesday, tk_Thursday,
    tk_Friday, tk_Saturday, tk_Sunday
    ON ph_task
    REFERENCING OLD AS pre NEW AS post
    FOR EACH ROW
        (EXECUTE FUNCTION ph_reset_next_execution(pre.tk_attributes)
            INTO tk_next_execution, tk_attributes)
    AFTER (EXECUTE PROCEDURE wake_dba());

CREATE PROCEDURE ph_task_delete_check(attr INTEGER);
    
    -- Check if we are trying to delete a system generated task
    -- Marked via TK_ATTR_SYSTEM_TASK (0x4) flag
    IF BITAND(attr, 4) <> 0 THEN
        RAISE EXCEPTION -274, -107;
    END IF
END PROCEDURE;

CREATE TRIGGER ph_task_delete
    DELETE ON ph_task
    REFERENCING OLD AS pre
    FOR EACH ROW
        (EXECUTE PROCEDURE ph_task_delete_check(pre.tk_attributes));

/*
 **************************************************************
 **************************************************************
 *               TASK & SENSOR CHANGES
 **************************************************************
 **************************************************************
 */

/*
 **************************************************************
 *  Create a task which will cleanup the alert table.
 **************************************************************
 */
DELETE from ph_threshold WHERE name = "ALERT HISTORY RETENTION";
INSERT INTO ph_threshold
       (name,task_name,value,value_type,description)
VALUES
("ALERT HISTORY RETENTION", "Alert Cleanup","15 0:00:00","NUMERIC",
"Remove all alerts that are older than then the threshold.");

CREATE FUNCTION AlertCleanup(task_id INTEGER, ID INTEGER)
   RETURNING INTEGER

DEFINE cur_run_id LIKE ph_run.run_id;
DEFINE cur_id     LIKE ph_alert.id;
DEFINE count      INTEGER;

    LET count =0;

    FOREACH SELECT id, run_id 
        INTO cur_id, cur_run_id
        FROM ph_alert, ph_run
        WHERE ph_alert.alert_task_id = ph_run.run_task_id
          AND ph_alert.alert_task_seq  = ph_run.run_task_seq
          AND alert_time < (
            SELECT current - value::INTERVAL DAY to SECOND
            FROM ph_threshold
            WHERE name = 'ALERT HISTORY RETENTION' )

     DELETE FROM ph_run where run_id = cur_run_id;
     DELETE FROM ph_alert where id = cur_id;

    LET count = count + 1;

    END FOREACH

    RETURN count;

END FUNCTION;

DELETE from ph_task WHERE tk_name = "Alert Cleanup";
INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_frequency
)
VALUES
(
"Alert Cleanup",
"TASK",
"SERVER",
"Remove all old alert entries from the system.",
"AlertCleanup",
DATETIME(02:00:00) HOUR TO SECOND,
NULL,
INTERVAL ( 1 ) DAY TO DAY
);

/*
 **************************************************************
 *  Setup the Alarm handler
 **************************************************************
 */
CREATE FUNCTION informix.ph_dbs_alert(informix.integer,informix.integer, 
				informix.pointer )
      RETURNS informix.integer
      EXTERNAL NAME '(ph_dbs_alert)'
      LANGUAGE C;
    
DELETE FROM ph_task WHERE tk_name="post_alarm_message";
INSERT INTO ph_task
    (
    tk_name,
    tk_type,
    tk_group,
    tk_description,
    tk_execute,
    tk_start_time,
    tk_stop_time,
    tk_frequency,
    tk_next_execution
    )
VALUES
    (
    "post_alarm_message",
    "TASK", 
    "SERVER",
    "System function to post alerts",
    "ph_dbs_alert",
    NULL,
    NULL,
    NULL,
    NULL
    );

{**************************************************************************
          MARK THE ABOVE TASKS AS SYSTEM TASKS
**************************************************************************}
UPDATE ph_task SET tk_attributes = BITOR(tk_attributes, 4)
    WHERE tk_name
        IN ('mon_command_history',
            'mon_config', 'mon_config_startup',
            'mon_sysenv', 'mon_profile', 'mon_vps',
            'mon_checkpoint', 'mon_memory_system',
            'mon_table_profile', 'mon_table_names',
            'mon_users', 'check_backup',
            'ifx_ha_monitor_log_replay_task',
            'Alert Cleanup',
            'post_alarm_message');

{**************************************************************************
          Add DSAC Common SQL API Stored Procedures
**************************************************************************}
CREATE FUNCTION SYSPROC.GET_MESSAGE
  ( INOUT  MAJOR_VERSION  INTEGER
  , INOUT  MINOR_VERSION  INTEGER
  , REQUESTED_LOCALE  VARCHAR(33)
  , XML_INPUT  BLOB
  , XML_FILTER BLOB
  , OUT    XML_OUTPUT BLOB
  , OUT    XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
EXTERNAL NAME '(admin_get_message)'
LANGUAGE C;

CREATE FUNCTION SYSPROC.GET_CONFIG
  ( INOUT MAJOR_VERSION INTEGER
  , INOUT MINOR_VERSION INTEGER
  , REQUESTED_LOCALE VARCHAR(33)
  , XML_INPUT BLOB
  , XML_FILTER BLOB
  , OUT XML_OUTPUT BLOB
  , OUT XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
EXTERNAL NAME '(admin_get_config)'
LANGUAGE C;

CREATE FUNCTION SYSPROC.GET_SYSTEM_INFO
  ( INOUT  MAJOR_VERSION  INTEGER
  , INOUT  MINOR_VERSION  INTEGER
  , REQUESTED_LOCALE  VARCHAR(33)
  , XML_INPUT  BLOB
  , XML_FILTER BLOB
  , OUT    XML_OUTPUT BLOB
  , OUT    XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
EXTERNAL NAME '(admin_get_system_info)'
LANGUAGE C;

CREATE FUNCTION SYSPROC.SET_CONFIG
  ( INOUT  MAJOR_VERSION  INTEGER
  , INOUT  MINOR_VERSION  INTEGER
  , REQUESTED_LOCALE  VARCHAR(33)
  , XML_INPUT  BLOB
  , XML_FILTER BLOB
  , OUT    XML_OUTPUT BLOB
  , OUT    XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
EXTERNAL NAME '(admin_set_config)'
LANGUAGE C;

CREATE FUNCTION SYSPROC.ITMA_SET_CONFIG (
    HOST      LVARCHAR(256),
    PORT      INTEGER,
    OPTIONS   LVARCHAR(2048),
    ACTION    SMALLINT,
    OUT   SQLCODE   INTEGER ,
    OUT   MESSAGE   LVARCHAR(1331) )
RETURNING INTEGER
WITH (HANDLESNULLS)
EXTERNAL NAME '(admin_itma_set_config)'
LANGUAGE C;

CLOSE DATABASE;
