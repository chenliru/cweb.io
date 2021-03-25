{ ** INSERT THE DEFAULT THRESHOLD VALUES **}

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"LMM START THRESHOLD","Low Memory Manager","5120","NUMERIC(8.2)",
"Low Memory Manager Start Clean Threshold.");

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"LMM STOP THRESHOLD","Low Memory Manager","10240","NUMERIC(8.2)",
"Low Memory Manager Stop Clean Threshold.");

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"LMM IDLE TIME","Low Memory Manager","300","NUMERIC",
"Low Memory Manager idle timeout.");

{** UPDATE THE DEFAULTS WITH SAVED VALUES , IF UPGRADING **}

UPDATE ph_threshold 
  SET value = NVL ( ( SELECT value FROM ph_threshold WHERE name = "XX LMM START THRESHOLD" ) , value )
   WHERE name = "LMM START THRESHOLD";

UPDATE ph_threshold 
   SET value = NVL ( ( SELECT value FROM ph_threshold WHERE name = "XX LMM STOP THRESHOLD" ) , value )
    WHERE name = "LMM STOP THRESHOLD";

UPDATE ph_threshold 
   SET value = NVL ( ( SELECT value FROM ph_threshold WHERE name = "XX LMM IDLE TIME" ), value )
     WHERE name = "LMM IDLE TIME";

{** REMOVE ANY SAVED THRESHOLD VALUES ** }

DELETE FROM ph_threshold WHERE name IN
( "XX LMM START THRESHOLD", "XX LMM STOP THRESHOLD", "XX LMM IDLE TIME" );

CREATE FUNCTION
    informix.low_memory_mgr_message(INTEGER, INTEGER, LVARCHAR, INTEGER DEFAULT 1 )
    RETURNS INTEGER
    EXTERNAL NAME '(dbcron_alert_msg_low_memory)'
    LANGUAGE C;

CREATE PROCEDURE kill_fat_sessions(INTEGER) external name '(kill_fat_sessions)' LANGUAGE C;
CREATE PROCEDURE kill_idle_sessions(INTEGER) external name '(kill_idle_sessions)' LANGUAGE C;

CREATE FUNCTION informix.db_low_memory_mgr() RETURNS informix.integer
    EXTERNAL NAME '(db_low_memory_mgr)' LANGUAGE C;

------------------------------------------------------------------
-- This function is used to augment the current built-in function.
--   To enable this function to be called prior to the built-in
--   function you must put the name of this function in the 
--   tk_execute column of the Low Memory Manager task entry. 
------------------------------------------------------------------
CREATE FUNCTION LowMemoryManager(task_id INTEGER, task_seq INTEGER)
    RETURNING  INTEGER

DEFINE rc  INTEGER;

    --  These procedures are called on all editions but ulimate
    --  on ulimate these are called by default unless you have
    --  changed the low memory manager's task attributes
    --  EXECUTE PROCEDURE kill_fat_sessions(0);
    --  EXECUTE PROCEDURE kill_idle_sessions(0);

    EXECUTE FUNCTION low_memory_mgr_message(task_id, task_seq,
               "Low Memory Activated, (additional comments here)") 
            INTO rc;

    RETURN 0;

END FUNCTION;


CREATE FUNCTION LowMemoryReconfig(task_id INTEGER, task_seq INTEGER, 
                                  caller LVARCHAR DEFAULT "NONE" )
    RETURNING  INTEGER

DEFINE rc  INTEGER;
DEFINE idle_time  BIGINT;
DEFINE sh_total BIGINT;
DEFINE start_threshold  BIGINT;
DEFINE stop_threshold  BIGINT;
DEFINE used_limit BIGINT;
DEFINE used_memory BIGINT;
DEFINE num_sessions INTEGER;
DEFINE tmpstr CHAR(30);

    --  Do not run reconfig if LMM is not running
    SELECT COUNT(*)
         INTO rc
         FROM sysmaster:systhreads
         WHERE th_name = "LowMemoryMgr";
    IF rc = 0 THEN
        RETURN 0;
    END IF
    LET rc =0;

    SELECT NVL(MAX(value::integer) ,300)
         INTO idle_time
         FROM sysadmin:ph_threshold
         WHERE name = "LMM IDLE TIME";

    SELECT NVL(MAX(value::integer) ,4096)/4
         INTO start_threshold
         FROM sysadmin:ph_threshold
         WHERE name = "LMM START THRESHOLD";

    IF start_threshold <= 0 THEN
       LET start_threshold = 10240;
    END IF

    SELECT NVL(MAX(value::integer) ,10240)/4
         INTO stop_threshold
         FROM sysadmin:ph_threshold
         WHERE name = "LMM STOP THRESHOLD";

    IF stop_threshold < start_threshold THEN
       LET stop_threshold = start_threshold * 2 ;
    END IF

   SELECT cf_effective
        INTO sh_total
        FROM sysmaster:sysconfig
        WHERE cf_name="SHMTOTAL";

   LET used_limit = sh_total - (stop_threshold * 1024);

   SELECT sum(seg_blkused)*4096
        INTO used_memory
        FROM sysmaster:sysseglst WHERE seg_class != 3;


    IF caller = "LMM" OR used_memory > used_limit  THEN

	/* reduce system resources */
        EXECUTE FUNCTION low_memory_mgr_message(task_id, task_seq,
               "Low Memory Activated, (additional comments here)",1)
               INTO rc;
        /* Set the VP CACHE off if enabled */
	SELECT sysadmin:admin('onmode', 'wm', 'VP_MEMORY_CACHE_KB=0')
	    INTO rc
	    FROM sysmaster:syscfgtab
	    WHERE cf_name = "VP_MEMORY_CACHE_KB" AND
		  cf_effective > 0;

        EXECUTE FUNCTION admin('onmode', 'F') INTO rc;

    ELIF (SELECT COUNT(*) FROM ph_run WHERE run_task_id = task_id
              AND  run_time > CURRENT - INTERVAL (5) MINUTE TO MINUTE) > 0
         AND used_memory > used_limit  THEN

	/* restore the system back to its normal state */
        EXECUTE FUNCTION low_memory_mgr_message(task_id, task_seq,
               "Low Memory Restored, (additional comments here)", 0)
               INTO rc;

	SELECT sysadmin:admin('onmode', 'wm', 'VP_MEMORY_CACHE_KB='||trim(cf_original))
	    INTO rc
	    FROM sysmaster:syscfgtab
	    WHERE cf_name = "VP_MEMORY_CACHE_KB" AND
		  cf_original > 0;

        EXECUTE FUNCTION admin('onmode', 'F') INTO rc;

    END IF

    RETURN rc;


END FUNCTION;

SET TRIGGERS FOR ph_task DISABLED;

INSERT INTO ph_task
(
tk_id,
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_frequency,
tk_enable
)
VALUES
(
-3,
"Low Memory Manager",
"TASK",
"SERVER",
"Low memory condition has been detected so reconfigure the system accordingly.",
NULL,
NULL,
NULL,
NULL,
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
tk_frequency,
tk_next_execution
)
VALUES
(
"Low Memory Reconfig",
"TASK",
"SERVER",
"Check for change in availible memory and reconfigure the system.",
"LowMemoryReconfig",
NULL,
NULL,
INTERVAL ( 60 ) MINUTE TO MINUTE,
CURRENT + INTERVAL ( 60 ) MINUTE TO MINUTE
);

SET TRIGGERS FOR ph_task ENABLED;
