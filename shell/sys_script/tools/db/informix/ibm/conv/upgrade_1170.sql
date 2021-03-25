{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  Copyright IBM Corporation 2009, 2010                                  *}
{*                                                                        *}
{**************************************************************************}
{                                                    			   }
{   Title:  upgrade_1170.sql                         			   }
{   Description:                                     			   }
{       Upgrade from 11.50 to 11.70                  			   }
{   Note:                                                                  }
{       Errors encountered while executing this sql script are NOT ignored.}
{	'upgrade_1170_setup.sql' is run before this script.		   }
{**************************************************************************}


DATABASE sysadmin;

{**************************************************************************
          Tasks and functions to register database extensions on-first-use
**************************************************************************}
INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_delete,
tk_frequency,
tk_next_execution,
tk_dbs,
tk_enable
)
VALUES
(
"autoreg exe",
"TASK",
"SERVER",
"Register a database extension on-first-use",
"autoregexe",
NULL,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
NULL,
NULL,
"sysadmin",
"f"
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
tk_delete,
tk_frequency,
tk_next_execution,
tk_dbs,
tk_enable
)
VALUES
(
"autoreg vp",
"TASK",
"SERVER",
"Create a VP on-first-use",
"autoregvp",
NULL,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
NULL,
NULL,
"sysadmin",
"f"
);

CREATE FUNCTION autoregexe(integer, integer, lvarchar)
    RETURNS integer
    EXTERNAL NAME '(autoregexe)'
    LANGUAGE C;

CREATE FUNCTION autoregvp(integer, integer, lvarchar)
    RETURNS integer
    EXTERNAL NAME '(autoregvp)'
    LANGUAGE C;

insert into ph_task
(
tk_name,
tk_dbs,
tk_type,
tk_execute,
tk_delete,
tk_start_time,
tk_stop_time,
tk_frequency
) values
(
"autoreg migrate-console",
"sysadmin",
"STARTUP SENSOR",
"
  INSERT INTO ph_task
  (
  tk_name,
  tk_dbs,
  tk_type,
  tk_execute,
  tk_delete,
  tk_start_time,
  tk_stop_time,
  tk_frequency
  )


  SELECT

  ""autoreg migrate ""||name,
  name,
  ""STARTUP TASK"",
  ""EXECUTE FUNCTION SYSBldPrepare('spatial','migrate');"",
  NULL::DATETIME YEAR TO SECOND,
  CURRENT::DATETIME YEAR TO SECOND,
  NULL::DATETIME YEAR TO SECOND,
  NULL::DATETIME YEAR TO SECOND

  FROM sysmaster:sysdatabases a

  WHERE
    (is_logging = 1 OR is_buff_log = 1) AND
    name NOT LIKE 'sys%' AND
    0 = ( SELECT count(*) FROM ph_task
          WHERE tk_name like 'autoreg migrate %' AND tk_dbs = a.name );
",
NULL::DATETIME YEAR TO SECOND,
CURRENT::DATETIME YEAR TO SECOND,
NULL::DATETIME YEAR TO SECOND,
NULL::DATETIME YEAR TO SECOND

);


{**************************************************************************
          Storage Provisioning Tasks/Functions 
**************************************************************************}

{*
 * Storage pool
 *
 * This table stores directories, cooked files and raw devices for use
 * by the storage provisioning feature. Columns are as follows:
 *    path
 *    offset
 *    device_size
 *    chunk_size
 *    priority
 *    logid       -- We use the last two columns to store a log position
 *    logused     -- so we can allocate in round-robin fashion.
 *
 * All items can be broken down into two categories: Fixed Length and 
 * Extendable. Here is the information we'll be storing in those columns
 * for each class of item:
 *
 * Fixed Length
 *      path            Path of device
 *      offset          Starting offset into device
 *      device_size     total size of device
 *      chunk_size      minimum size of chunk allocated from this device
 *      priority        1, 2, or 3
 *
 * Extendable
 *      path            Path of device or directory
 *      offset          Starting offset into device, NULL for directory
 *      device_size     NULL
 *      chunk_size      Initial size of either the device or the cooked 
 *                      chunks within the directory
 *      priority        1, 2, or 3
 *
 * Note that we can distinguish between fixed length and extendable items,
 * since fixed length entries always have a non-null device_size value. We can
 * also distinguish between directories and files/devices, because 'offset' 
 * will always be NULL for directories and populated for files.
 * 
 * Valid 'priority' values are:
 *      1 = High
 *      2 = Medium
 *      3 = Low
 *
 * Default: 2
*}
CREATE TABLE storagepool
    (
    entry_id    serial not null,
    path        varchar(255) not null,
    beg_offset  bigint not null,
    end_offset  bigint not null,
    chunk_size  bigint not null,
    status      varchar(255),
    priority    int     default 2,
    last_alloc  datetime year to second,
    logid       int,
    logused     int
    ) lock mode row;

CREATE UNIQUE INDEX ix_storagepool_1 ON storagepool(entry_id);

CREATE FUNCTION
    informix.adm_add_storage(informix.pointer)
    returns informix.integer
    external name '(adm_add_storage)'
    language C;

CREATE FUNCTION
    informix.mon_low_storage(informix.integer,informix.integer)
    returns informix.integer
    external name '(mon_low_storage)'
    language C;

{**************************************************************************
          Task to add storage, and task to detect low free space
**************************************************************************}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_start_time,
tk_stop_time,
tk_delete,
tk_frequency,
tk_next_execution
)
VALUES
(
"add_storage",
"TASK",
"DISK",
"Add storage",
"adm_add_storage",
NULL,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
NULL,
NULL
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
tk_delete
)
VALUES
(
"mon_low_storage",
"TASK",
"DISK",
"Monitor storage and add space when necessary",
"mon_low_storage",
NULL,
NULL,
INTERVAL ( 1 ) HOUR TO HOUR,
INTERVAL ( 30 ) DAY TO DAY
);


{*** IDLE USER TIMEOUT ***}

DELETE FROM ph_threshold WHERE name = "IDLE TIMEOUT";

{*** CREATE THE THRESHOLD ***}
INSERT INTO ph_threshold(name,task_name,value,value_type,description)
VALUES("IDLE TIMEOUT", "idle_user_timeout","60","NUMERIC","Maximum amount of time in minutes for non-informix users to be idle.");

DELETE FROM ph_task WHERE tk_name = "idle_user_timeout";

{*** CREATE THE task
     by default the task will not be enabled
     and is scheduled for every 2 hours ***}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_next_execution,
tk_start_time,
tk_stop_time,
tk_frequency,
tk_delete,
tk_enable
)
VALUES
(
"idle_user_timeout",
"TASK",
"SERVER",
"Terminate idle users",
"idle_user_timeout",
NULL,
NULL,
NULL,
INTERVAL ( 2 ) HOUR TO HOUR,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);


CREATE FUNCTION idle_user_timeout( task_id INTEGER, task_seq INTEGER)
RETURNING INTEGER

DEFINE time_allowed INTEGER;
DEFINE sys_hostname CHAR(256);
DEFINE sys_username CHAR(32);
DEFINE sys_sid      INTEGER;
DEFINE rc           INTEGER;

{*** Get the maximum amount of time to be idle ***}
SELECT value::integer  INTO time_allowed  FROM ph_threshold
WHERE name = "IDLE TIMEOUT";

{*** Check the value for IDLE TIMEOUT is reasonable , ie: >= 5 minutes ***}

     IF time_allowed < 5 THEN
        INSERT INTO ph_alert ( ID, alert_task_id,alert_task_seq,                                               alert_type, alert_color, alert_state,
                               alert_object_type, alert_object_name,
                               alert_message,  alert_action  )
        VALUES
           ( 0,task_id, task_seq, "WARNING", "GREEN", "ADDRESSED", "USER",
             "TIMEOUT", "Invalid IDLE TIMEOUT value("||time_allowed||"). Needs to be greater than 4", NULL );
        RETURN -1;
     END IF

{*** Find all users who have been idle longer than the threshold and try to
     terminate the session. ***}

FOREACH
   SELECT admin("onmode","z",A.sid), A.username, A.sid, hostname
        INTO rc, sys_username, sys_sid, sys_hostname
   FROM sysmaster:sysrstcb A , sysmaster:systcblst B
      , sysmaster:sysscblst C
   WHERE A.tid = B.tid
     AND C.sid = A.sid
     AND LOWER(name) IN  ("sqlexec")
     AND CURRENT - DBINFO("utc_to_datetime",last_run_time) > time_allowed UNITS MINUTE
     AND LOWER(A.username) NOT IN( "informix", "root")

     {*** If we sucessfully terminated a user log ***}
     {*** the information into the alert table    ***}

     IF rc > 0 THEN
        INSERT INTO ph_alert ( ID, alert_task_id,alert_task_seq,                                               alert_type, alert_color, alert_state,
                               alert_object_type, alert_object_name,
                               alert_message,  alert_action  )
        VALUES
           ( 0,task_id, task_seq, "INFO", "GREEN", "ADDRESSED", "USER",
             "TIMEOUT", "User "||TRIM(sys_username)||"@"||TRIM(sys_hostname)||" sid("||sys_sid||")"||" terminated due to idle timeout.", NULL );
     END IF

   END FOREACH;

   RETURN 0;

END FUNCTION;

{**************************************************************************
          Unique Event Alarms
**************************************************************************}

ALTER TABLE ph_alert ADD (alert_object_info BIGINT DEFAULT 0);
UPDATE ph_alert SET alert_task_id = alert_task_id;

CREATE VIEW ph_alerts
     (
       alert_id, run_id, task_id,
       task_name, task_description,
       alert_type, alert_color, alert_time,
       alert_state, alert_object_type, alert_object_name,
       alert_message, alert_action_dbs, alert_action, alert_object_info
     )
AS SELECT ph_alert.id, ph_run.run_id, ph_task.tk_id,
          tk_name, tk_description, alert_type, alert_color,
          alert_time,
          alert_state, alert_object_type, alert_object_name,
          alert_message, alert_action_dbs, alert_action, alert_object_info
FROM ph_alert, ph_run, ph_task
WHERE ph_alert.alert_task_id = ph_task.tk_id
      AND ph_run.run_task_id = ph_task.tk_id
      AND ph_alert.alert_task_seq = ph_run.run_task_seq;

UPDATE ph_version SET value = 14
    WHERE object = 'ph_alert' and type = 'table';
UPDATE ph_version SET value = 182
    WHERE object = 'ph_alert' and type = 'colnames';

{** bad_index_alert ** }

DELETE FROM ph_task WHERE tk_name = "bad_index_alert";

{*** CREATE THE task for bad_index_alert *** }

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_next_execution,
tk_start_time,
tk_stop_time,
tk_frequency,
tk_delete,
tk_enable
)
VALUES
(
"bad_index_alert",
"TASK",
"SERVER",
"Find indices marked as bad and create alert",
"bad_index_alert",
NULL,
DATETIME(04:00:00) HOUR TO SECOND,
NULL,
INTERVAL ( 1 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);


{*** CREATE the function that will be run by the task ***}
CREATE FUNCTION bad_index_alert ( task_id INTEGER, task_seq INTEGER)
RETURNING INTEGER

DEFINE p_partnum INTEGER;
DEFINE p_fullname CHAR(300);
DEFINE p_database CHAR(128);
FOREACH 
	
SELECT k.partnum 
, dbsname
, trim(owner)||"."||
  tabname  AS fullname
INTO p_partnum ,p_database , p_fullname 
FROM
sysmaster:sysptnkey k,sysmaster:systabnames t
WHERE  sysmaster:bitand(flags,"0x00000040") > 0
and k.partnum = t.partnum
and dbsname not in ("sysmaster")

INSERT INTO ph_alert ( ID, alert_task_id ,alert_task_seq ,alert_type ,alert_color
                         , alert_object_type ,alert_object_name ,alert_message
                         , alert_action_dbs ,alert_action )
        VALUES
           ( 0,task_id, task_seq, "WARNING", "red", "SERVER", p_fullname
              , "Index "||trim(p_database)||":"||trim(p_fullname)||" is marked as bad."
              , p_database ,NULL );

END FOREACH;

RETURN 0;

END FUNCTION;

{** auto_tune_cpu_vps ** }

DELETE FROM ph_task WHERE tk_name = "auto_tune_cpu_vps";

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
tk_next_execution,
tk_delete,
tk_enable
)
VALUES
(
"auto_tune_cpu_vps",
"STARTUP TASK",
"SERVER",
"Automatically allocate additional cpu vps at system start.",
"auto_tune_cpu_vps",
NULL,
NULL,
NULL,
NULL,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);

{*** CREATE the function that will be run by the task auto_tune_cpu_vps ***}
{*** The number of desired cpu vps is limited to 8 *** }
{*** if the os has 3 or more cpus then we use 50% *** }
{*** if the os has 3 then we use 2 *** }
{*** if the os has < 3 we use 1 *** }
CREATE FUNCTION auto_tune_cpu_vps(task_id INTEGER, task_seq INTEGER)
   RETURNING INTEGER

DEFINE current_cpu_vps  INTEGER;
DEFINE desired_cpu_vps  INTEGER;
DEFINE add_cpu_vps      INTEGER;
DEFINE rc               INTEGER;

    LET add_cpu_vps = 0;

    {* check the value of SINGLE_CPU_VP , if it is set then
       we cannot add any additional cpu vps so we can return early *}

    SELECT cf_effective INTO add_cpu_vps FROM sysmaster:sysconfig
    WHERE cf_name = "SINGLE_CPU_VP";

    IF add_cpu_vps != 0 THEN
        RETURN 0;
    END IF


    SELECT count(*) INTO current_cpu_vps
    FROM sysmaster:sysvplst
    WHERE classname="cpu";

    SELECT CASE
        WHEN os_num_procs > 16  THEN
              8
        WHEN os_num_procs > 3  THEN
              os_num_procs/2
        WHEN os_num_procs = 3 THEN
              2
        ELSE
              1
        END::INTEGER
     INTO  desired_cpu_vps
     FROM sysmaster:sysmachineinfo;

    LET add_cpu_vps = desired_cpu_vps - current_cpu_vps;

    IF add_cpu_vps > 0  THEN
        INSERT INTO ph_alert
          (ID, alert_task_id,alert_task_seq,alert_type,
           alert_color, alert_object_type,
           alert_object_name, alert_message,alert_action)
            VALUES
          (0,task_id, task_seq, "INFO", "YELLOW",
           "SERVER","CPU VPS",
          "Dynamically adding "||add_cpu_vps|| " cpu vp(s)." ,
           NULL);

          LET rc = admin( "onmode", "p",add_cpu_vps,"cpu");
     ELSE
          LET rc = 0;
     END IF

     RETURN rc;

END FUNCTION;

DELETE FROM ph_threshold WHERE name = "AUTOCOMPRESS_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTOCOMPRESS_ROWS";

DELETE FROM ph_threshold WHERE name = "AUTOREPACK_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTOREPACK_SPACE";

DELETE FROM ph_threshold WHERE name = "AUTOSHRINK_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTOSHRINK_UNUSED";

DELETE FROM ph_threshold WHERE name = "AUTODEFRAG_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTODEFRAG_EXTENTS";

{*** CREATE THE THRESHOLDS ***}

{** compress **}

INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTOCOMPRESS_ENABLED", "auto_crsd","F","STRING","Auto Compression of tables/fragments is enabled.");

INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTOCOMPRESS_ROWS", "auto_crsd","50000","NUMERIC","Number of rows required in the table/fragment.");

{** repack **}
INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTOREPACK_ENABLED", "auto_crsd","F","STRING","Auto Repack of tables is enabled.");
INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTOREPACK_SPACE", "auto_crsd","50","NUMERIC","Percentage.");

{** shrink **}
INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTOSHRINK_ENABLED", "auto_crsd","F","STRING","Auto Shrink of tables is enabled.");
INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTOSHRINK_UNUSED", "auto_crsd","50","NUMERIC","Percentage of unused space.");

{** defrag **}
INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTODEFRAG_ENABLED", "auto_crsd","F","STRING","Auto Defrag of tables is enabled.");
INSERT INTO ph_threshold
(name,task_name,value,value_type,description)
VALUES
("AUTODEFRAG_EXTENTS", "auto_crsd","100","NUMERIC","Number of extents.");


DELETE FROM ph_task WHERE tk_name = "auto_crsd";

{*** CREATE THE task 
     by default the task will not be enabled 
     and is scheduled for every 7 days at 3:00am
     ***}

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
"auto_crsd",
"TASK",
"SERVER",
"Automatic Compress/Repack/Shrink and Defrag",
"auto_crsd",
DATETIME(03:00:00) HOUR TO SECOND,
NULL,
NULL,
INTERVAL ( 7 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);


CREATE FUNCTION auto_crsd( g_task_id INTEGER, g_task_seq INTEGER)
RETURNING INTEGER

DEFINE p_enabled LIKE sysadmin:ph_threshold.value;

DEFINE p_value INTEGER;

DEFINE p_fulltabname LVARCHAR(300);
DEFINE p_dbsname  LIKE sysmaster:sysdatabases.name;
DEFINE p_owner    LIKE sysmaster:systabnames.owner;
DEFINE p_tabname  LIKE sysmaster:systabnames.tabname;
DEFINE p_partnum  LIKE sysmaster:systabnames.partnum;

DEFINE p_beforedatacnt LIKE sysmaster:sysptnhdr.npdata;
DEFINE p_beforepagecnt LIKE sysmaster:sysptnhdr.nptotal;
DEFINE p_afterdatacnt  LIKE sysmaster:sysptnhdr.npdata;
DEFINE p_afterpagecnt  LIKE sysmaster:sysptnhdr.nptotal;

DEFINE p_retcode INTEGER;

DEFINE p_alerttype  LIKE sysadmin:ph_alert.alert_type;
DEFINE p_alertcolor LIKE sysadmin:ph_alert.alert_color;
DEFINE p_alerttext  LIKE sysadmin:ph_alert.alert_message;

--SET DEBUG FILE TO "/tmp/compress."||g_task_seq;
--TRACE ON;
{*********** Check if AUTOCOMPRESS is enabled ***********}
LET p_enabled = "F";

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTOCOMPRESS_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTOCOMPRESS_ROWS";
	IF p_value IS NOT NULL AND p_value >= 2000 THEN
		FOREACH SELECT TRIM(T.dbsname) , TRIM(T.owner) 
					 , TRIM(T.tabname) , T.partnum
					 , H.npdata, H.nptotal
			INTO p_dbsname , p_owner , p_tabname , p_partnum
                ,p_beforedatacnt , p_beforepagecnt
			FROM sysmaster:sysptnhdr H , sysmaster:systabnames T
			WHERE 
			H.npdata > 0   -- only data partnums , not index
			AND H.nrows > p_value -- qualifying number of rows
			AND bitand(H.flags , 134217728 ) == 0 -- already compressed
			AND H.partnum = T.partnum
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('fragment compress',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto compressing partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT npdata, nptotal
				 INTO p_afterdatacnt , p_afterpagecnt
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically compressed table:["||p_partnum||"] ["||TRIM(p_fulltabname)||"] went from "||p_beforedatacnt||"/"||p_beforepagecnt||" data/total pages to "||p_afterdatacnt||"/"||p_afterpagecnt||" data/total pages.";
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF

END IF

{*********** Check if AUTOREPACK is enabled ***********}
LET p_enabled = "F";
LET p_retcode = 0;

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTOREPACK_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTOREPACK_SPACE";
	IF p_value IS NOT NULL AND p_value > 0 AND p_value < 100 THEN
		FOREACH SELECT TRIM(dbsname) as dbsname, TRIM(owner) as owner
			, TRIM(tabname) as tabname , T.partnum
			INTO p_dbsname , p_owner , p_tabname , p_partnum
			FROM
			(
			SELECT pnum , count(*) f
			FROM
  			( SELECT pe_extnum as extnum
         			, pe_size as size
         			, pe_partnum as pnum
         			, count(*) as free
    			FROM sysmaster:sysptnext E, sysmaster:sysptnbit B
    			WHERE
      			E.pe_partnum = B.PB_partnum
      			AND ( bitand(pb_bitmap,12) = 0 or bitand(pb_bitmap,12) = 4 )
      			AND E.pe_log <= B.pb_pagenum
      			AND B.pb_pagenum < E.pe_log + E.pe_size
      			GROUP BY 1,2,3
  			) as Y
 			, sysmaster:sysptnhdr  as H
 			, sysmaster:systabnames as T
  			WHERE pnum = H.partnum
    			AND T.partnum = H.partnum
    			AND npdata > 0
  			GROUP BY 1
			)
 			, sysmaster:sysptnhdr  as H
 			, sysmaster:systabnames as T
			WHERE
				pnum = T.partnum
			AND T.partnum = H.partnum
			AND nextns > 4
			AND npdata > 0
			AND (f/nextns)*100::decimal(10,2)  > p_value
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('fragment repack',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto repacking partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT npdata, nptotal
				 INTO p_afterdatacnt , p_afterpagecnt
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically repacked table:["||p_partnum||"] ["||TRIM(p_fulltabname);
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF
END IF

{*********** Check if AUTOSHRINK is enabled ***********}
LET p_enabled = "F";
LET p_retcode = 0;

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTOSHRINK_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTOSHRINK_UNUSED";
	IF p_value IS NOT NULL AND p_value > 0 AND p_value < 100 THEN
		FOREACH SELECT TRIM(T.dbsname) , TRIM(T.owner) 
					 , TRIM(T.tabname) , T.partnum
					 , H.npdata, H.nptotal
			INTO p_dbsname , p_owner , p_tabname , p_partnum
                ,p_beforedatacnt , p_beforepagecnt
			FROM sysmaster:sysptnhdr H , sysmaster:systabnames T
			WHERE 
			H.npdata > 0   -- only data partnums , not index
			AND 
                          (((nptotal - npused) / nptotal )*100) > p_value -- qualifying number of rows
			AND H.nextns > 1
			AND H.partnum = T.partnum
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('fragment shrink',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto shrinking partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT npdata, nptotal
				 INTO p_afterdatacnt , p_afterpagecnt
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically shrunk table:["||p_partnum||"] ["||TRIM(p_fulltabname)||"] went from "||p_beforedatacnt||"/"||p_beforepagecnt||" data/total pages to "||p_afterdatacnt||"/"||p_afterpagecnt||" data/total pages.";
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF
END IF

{*********** Check if AUTODEFRAG is enabled ***********}
LET p_enabled = "F";
LET p_retcode = 0;

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTODEFRAG_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTODEFRAG_EXTENTS";
	IF p_value IS NOT NULL AND p_value > 0 THEN
		FOREACH SELECT TRIM(T.dbsname) , TRIM(T.owner) 
					 , TRIM(T.tabname) , T.partnum
					 , H.nextns
			INTO p_dbsname , p_owner , p_tabname , p_partnum
                ,p_beforedatacnt 
			FROM sysmaster:sysptnhdr H , sysmaster:systabnames T
			WHERE 
			H.npdata > 0   -- only data partnums , not index
			AND H.nextns > p_value -- qualifying number of extents
			AND H.partnum = T.partnum
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('defragment partnum',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto defragging partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT nextns
				 INTO p_afterdatacnt 
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically defragged table:["||p_partnum||"] ["||TRIM(p_fulltabname)||"] went from "||p_beforedatacnt||" extents to "||p_afterdatacnt||" extents.";
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF
END IF

{*** DONE ***}
   RETURN 0;

END FUNCTION;

{*** CREATE THE task
     by default the task will not be enabled
     and is scheduled for every 7 days ***}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_execute,
tk_next_execution,
tk_start_time,
tk_stop_time,
tk_frequency,
tk_delete,
tk_enable
)
VALUES
(
"check_for_ipa",
"TASK",
"SERVER",
"Find tables with outstanding in place alters",
"check_for_ipa",
NULL,
DATETIME(04:00:00) HOUR TO SECOND,
NULL,
INTERVAL ( 7 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
'f'
);


{*** CREATE the function that will be run by the task ***}

CREATE FUNCTION check_for_ipa ( task_id INTEGER, task_seq INTEGER)
RETURNING INTEGER

DEFINE p_fullname CHAR(300);
DEFINE p_database CHAR(128);

FOREACH 
SELECT dbsname
, trim(owner)||"."|| tabname  AS fullname
INTO p_database , p_fullname 
FROM
sysmaster:sysactptnhdr h,sysmaster:systabnames t
WHERE  
h.partnum = t.partnum
and dbsname not in ("sysmaster")
and pta_totpgs != 0

INSERT INTO ph_alert ( ID, alert_task_id ,alert_task_seq ,alert_type ,alert_color
                         , alert_object_type ,alert_object_name ,alert_message
                         , alert_action_dbs ,alert_action )
        VALUES
           ( 0,task_id, task_seq, "INFO", "red", "SERVER", p_fullname
              , "Table "||trim(p_database)||":"||trim(p_fullname)||" has outstanding in place alters."
              , p_database ,NULL );

END FOREACH;

RETURN 0;

END FUNCTION;

UPDATE ph_task SET tk_attributes = BITOR(tk_attributes, 4)
    WHERE tk_name
        IN ( 'idle_user_timeout', 'auto_tune_cpu_vps', 'auto_crsd',
             'add_storage', 'mon_low_storage', 'autoreg exe', 'autoreg vp',
	     'bad_index_alert', 'check_for_ipa');


CLOSE DATABASE;
