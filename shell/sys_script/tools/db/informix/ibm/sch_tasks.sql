{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 1996, 2011 All rights reserved.         *}
{*                                                                        *}
{**************************************************************************}
{                                          }
{   Title:  sch_tasks.sql                  }
{   Description:                           }
{       system default set of tasks        }

DATABASE sysadmin;

EXECUTE PROCEDURE ifx_allow_newline('t');

INSERT INTO ph_group VALUES (0,"DISK","Disk Subsystem");
INSERT INTO ph_group VALUES (0,"NETWORK","Network subsystem");
INSERT INTO ph_group VALUES (0,"MEMORY","Memory Utilization");
INSERT INTO ph_group VALUES (0,"CPU","CPU Utilization");
INSERT INTO ph_group VALUES (0,"TABLES","Tables");
INSERT INTO ph_group VALUES (0,"INDEXES","Indexes");
INSERT INTO ph_group VALUES (0,"SERVER","Global Server Information");
INSERT INTO ph_group VALUES (0,"USER","User Information");
INSERT INTO ph_group VALUES (0,"BACKUP","Backup and Restore Information");
INSERT INTO ph_group VALUES (0,"PERFORMANCE","Performance Information");


{**************************************************************************
             Monitor for the command history table
**************************************************************************}

INSERT INTO ph_threshold(id,name,task_name,value,description)
VALUES
(0,"COMMAND HISTORY RETENTION", "mon_command_history","30 0:00:00",
"The amount of time the command_history table should contain information about SQL ADMIN commands that habe been executed.  Any SQL ADMIN commands older than this will be purged.");

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
"mon_command_history",
"TASK",
"TABLES",
"Monitor how much data is kept in the command history table",
"delete from command_history where cmd_exec_time < (
        select current - value::INTERVAL DAY to SECOND
        from ph_threshold
        where name = 'COMMAND HISTORY RETENTION' ) ",
DATETIME(02:00:00) HOUR TO SECOND,
NULL,
INTERVAL ( 1 ) DAY TO DAY
);


{**************************************************************************
             Task to track the onconfig paramaters
**************************************************************************}
CREATE FUNCTION onconfig_save_diffs(task_id INTEGER, ID INTEGER)
   RETURNING INTEGER

 DEFINE value    LVARCHAR(1024);
 DEFINE conf_value  LVARCHAR(1024);
 DEFINE conf_id  INTEGER;


  LET value = NULL;

  FOREACH select cf_id, trim(cf_effective)
      INTO conf_id, conf_value
      FROM sysmaster:syscfgtab


  FOREACH  select FIRST 1 config_value
            INTO value
            FROM sysadmin:mon_config
            WHERE mon_config.config_id = conf_id
            ORDER BY id DESC
  END FOREACH

  IF conf_value == value THEN
       CONTINUE FOREACH;
  END IF

  INSERT INTO mon_config VALUES( ID, conf_id, conf_value );

  END FOREACH

  return 0;

END FUNCTION;


INSERT INTO ph_task 
(
tk_name, 
tk_type, 
tk_group, 
tk_description, 
tk_result_table, 
tk_create,
tk_execute,
tk_start_time,
tk_stop_time,
tk_delete,
tk_frequency,
tk_next_execution
)
VALUES
(
"mon_config",
"SENSOR",
"SERVER",
"Collect information about database server's configuration file (onconfig). Only modified parameters are collected.",
"mon_config",
"create table mon_config (ID integer, config_id integer, config_value lvarchar(1024)); create view mon_onconfig as select ID ID, cf_name name, config_value value from mon_config, sysmaster:sysconfig where mon_config.config_id = sysmaster:sysconfig.cf_id;",
"onconfig_save_diffs",
NULL,
NULL,
INTERVAL ( 60 ) DAY TO DAY,
INTERVAL ( 1 ) DAY TO DAY,
DATETIME(05:00:00) HOUR TO SECOND
);

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_start_time,
tk_stop_time,
tk_delete,
tk_frequency,
tk_next_execution
)
VALUES
(
"mon_config_startup",
"STARTUP SENSOR",
"SERVER",
"Collect information about database servers configuration file (onconfig). This
will only collect paramaters which have changed.",
"mon_config",
"create table mon_config (ID integer, config_id integer, config_value lvarchar(1024)); create view mon_onconfig as select ID ID, cf_name name, config_value value from mon_config, sysmaster:sysconfig where mon_config.config_id = sysmaster:sysconfig.cf_id;",
"onconfig_save_diffs",
NULL,
NULL,
INTERVAL ( 99 ) DAY TO DAY,
NULL,
NULL
);



{**************************************************************************
      Task to track the database servers environment information
**************************************************************************}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_stop_time,
tk_start_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_sysenv",
"STARTUP SENSOR",
"SERVER",
"Tracks the database servers startup environment.",
"mon_sysenv",
"create table mon_sysenv (ID integer, name varchar(250), value lvarchar(1024))",
"insert into mon_sysenv select $DATA_SEQ_ID, TRIM(env_name), TRIM(env_value) FROM sysmaster:sysenv",
NULL,
NULL,
"0 0:01:00",
INTERVAL ( 60 ) DAY TO DAY
);


{**************************************************************************
          Task to track the general system profile information
**************************************************************************}

INSERT INTO ph_task 
(
tk_name,
tk_type,
tk_group, 
tk_description,
tk_result_table, 
tk_create,
tk_execute,
tk_start_time,
tk_stop_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_profile",
"SENSOR",
"PERFORMANCE",
"Collect the general profile information",
"mon_prof",
"create table mon_prof (ID integer, number integer, value int8 );create view mon_profile as select ID, A.name, B.value from sysmaster:sysshmhdr A, mon_prof B where B.number = A.number; create index mon_prof_idx1 on mon_prof(ID, number)",
"insert into mon_prof select $DATA_SEQ_ID, number, value from sysmaster:sysshmhdr where name != 'unused'",
NULL,
NULL,
INTERVAL ( 4 ) HOUR TO HOUR,
INTERVAL ( 30 ) DAY TO DAY
);


{**************************************************************************
          Task to track the general cpu usage by process class
**************************************************************************}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_stop_time,
tk_start_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_vps",
"SENSOR",
"CPU",
"Process time of the Virtual Processors",
"mon_vps",
"create table mon_vps (ID integer, vpid smallint, num_ready smallint, class integer,  usecs_user float, usecs_sys float)",
"insert into mon_vps select $DATA_SEQ_ID,  vpid, num_ready, class, usecs_user, usecs_sys FROM sysmaster:sysvplst",
NULL,
NULL,
INTERVAL ( 4 ) HOUR TO HOUR,
INTERVAL ( 15 ) DAY TO DAY
);

{**************************************************************************
          Task to track the checkpoint information
**************************************************************************}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_stop_time,
tk_start_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_checkpoint",
"SENSOR",
"SERVER",
"Track the checkpoint information",
"mon_checkpoint",
"create table mon_checkpoint (ID integer, intvl integer, type char(12), caller char(10), clock_time int, crit_time float, flush_time float, cp_time float, n_dirty_buffs int, plogs_per_sec int, llogs_per_sec int, dskflush_per_sec  int, ckpt_logid int, ckpt_logpos int, physused int, logused int, n_crit_waits int, tot_crit_wait float, longest_crit_wait float, block_time float);create unique index idx_mon_ckpt_1 on mon_checkpoint(intvl)",
"insert into mon_checkpoint select $DATA_SEQ_ID, intvl, type, caller, clock_time, crit_time, flush_time, cp_time, n_dirty_buffs, plogs_per_sec, llogs_per_sec, dskflush_per_sec, ckpt_logid, ckpt_logpos, physused, logused, n_crit_waits, tot_crit_wait, longest_crit_wait, block_time FROM sysmaster:syscheckpoint WHERE intvl > (select NVL(max(intvl),0) from mon_checkpoint)",
NULL,
NULL,
INTERVAL ( 60 ) MINUTE TO MINUTE,
INTERVAL ( 7 ) DAY TO DAY
);

{**************************************************************************
          Task to track the server memory information
**************************************************************************}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_stop_time,
tk_start_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_memory_system",
"SENSOR",
"MEMORY",
"Server memory consumption",
"mon_memory_system",
"create table mon_memory_system (ID integer, class smallint, size int8, used int8, free int8 )",
"insert into mon_memory_system select $DATA_SEQ_ID, seg_class, seg_size, seg_blkused, seg_blkfree FROM sysmaster:sysseglst",
NULL,
NULL,
INTERVAL ( 2 ) HOUR TO HOUR,
INTERVAL ( 15 ) DAY TO DAY
);


{**************************************************************************
          Task to track the table level statistics
**************************************************************************}
INSERT INTO ph_task
(
tk_name,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_stop_time,
tk_start_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_table_profile",
"TABLES",
"Collect SQL profile information by table/fragment, index information is excluded from this collection",
"mon_table_profile",
" create table mon_table_profile ( id integer, partnum integer, nextns smallint, serialval int8, nptotal integer, npused integer, npdata integer, lockid integer, nrows integer, ucount smallint, ocount smallint, pf_rqlock int8, pf_lockwait int8, pf_isread int8, pf_iswrite int8, pf_isrwrite int8, pf_isdelete int8, pf_bfcread int8, pf_bfcwrite int8, pf_seqscans int8, pf_dskreads int8, pf_dskwrites int8); ",
"insert into mon_table_profile select $DATA_SEQ_ID, partnum, nextns, decode(cur_serial8, 1, cur_serial4::int8, cur_serial8), nptotal, npused, npdata, lockid, nrows, ucount, ocount, pf_rqlock, pf_wtlock + pf_deadlk + pf_dltouts, pf_isread, pf_iswrite, pf_isrwrite, pf_isdelete, pf_bfcread, pf_bfcwrite, pf_seqscans, pf_dskreads, pf_dskwrites FROM sysmaster:sysactptnhdr WHERE  (nkeys >0 AND nrows > 0 ) OR nkeys=0",
NULL,
NULL,
INTERVAL ( 1 ) DAY TO DAY,
INTERVAL ( 7 ) DAY TO DAY
);


{**************************************************************************
             Task to track the tabnames paramaters
**************************************************************************}
CREATE FUNCTION tabnames_save_diffs(task_id INTEGER, ID INTEGER)
   RETURNING INTEGER

 DEFINE cur_dbsname  VARCHAR(128);
 DEFINE cur_owner    VARCHAR(32);
 DEFINE cur_tabname  VARCHAR(128);
 DEFINE cur_created  INTEGER;
 DEFINE cur_partnum  INTEGER;
 DEFINE cur_lockid   INTEGER;



  FOREACH select tab.dbsname, tab.owner, tab.tabname , 
            ptn.created, ptn.partnum, ptn.lockid
      INTO  cur_dbsname, cur_owner, cur_tabname, 
            cur_created, cur_partnum, cur_lockid 
      FROM sysmaster:systabnames tab, sysmaster:sysptnhdr ptn
      WHERE tab.partnum = ptn.partnum
      AND sysmaster:bitval(ptn.flags,'0x20')==0
      AND  ptn.created NOT IN 
               (
               SELECT created 
               FROM mon_table_names
               WHERE mon_table_names.partnum =  ptn.partnum
               AND   mon_table_names.lockid  = ptn.lockid
               )


        INSERT INTO sysadmin:mon_table_names
          (ID, partnum, dbsname, owner, tabname, created, lockid)
          VALUES
          (ID, cur_partnum, TRIM(cur_dbsname), TRIM(cur_owner), 
           TRIM(cur_tabname), cur_created, cur_lockid );

  END FOREACH

  return 0;

END FUNCTION;


INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_stop_time,
tk_start_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_table_names",
"SENSOR",
"TABLES",
"Collect table names from the system",
"mon_table_names",
"create table mon_table_names ( id integer, partnum integer, dbsname varchar(128), owner varchar(32), tabname varchar(128), created integer,lockid integer ); create index mon_table_names_idx1 on mon_table_names(partnum);",
"tabnames_save_diffs",
NULL,
DATETIME(02:00:00) HOUR TO SECOND,
INTERVAL ( 1 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY
);


{**************************************************************************
          Task to track the general system profile information
**************************************************************************}

INSERT INTO ph_task
(
tk_name,
tk_type,
tk_group,
tk_description,
tk_result_table,
tk_create,
tk_execute,
tk_start_time,
tk_stop_time,
tk_frequency,
tk_delete
)
VALUES
(
"mon_users",
"SENSOR",
"PERFORMANCE",
"Collect information about each user",
"mon_users",
"CREATE TABLE mon_users (ID integer, sid integer, uid integer, username varchar(16), pid integer, progname varchar(16),hostname varchar(16), memtotal integer, memused integer, upf_rqlock integer, upf_wtlock integer, upf_deadlk integer, upf_lktouts integer, upf_lgrecs integer, upf_isread integer, upf_iswrite integer, upf_isrwrite integer, upf_isdelete integer, upf_iscommit integer, upf_isrollback integer, upf_longtxs integer, upf_bufreads integer,upf_idxbufreads integer, upf_diskreads integer, upf_bufwrites integer, upf_diskwrites integer, upf_logspuse integer, upf_logspmax integer, upf_seqscans integer, upf_totsorts integer, upf_dsksorts integer, upf_srtspmax integer, nlocks integer, lkwaittime float, iowaittime float, upf_niowaits integer, net_read_cnt int8, net_read_bytes int8, net_write_cnt int8, net_write_bytes int8, net_open_time integer, net_last_read integer, net_last_write integer, wreason integer)",
"insert into mon_users (ID, sid, uid, username, pid, progname, hostname, memtotal, memused, upf_rqlock, upf_wtlock, upf_deadlk, upf_lktouts, upf_lgrecs, upf_isread, upf_iswrite, upf_isrwrite, upf_isdelete, upf_iscommit, upf_isrollback, upf_longtxs, upf_bufreads, upf_idxbufreads, upf_diskreads, upf_bufwrites, upf_diskwrites, upf_logspuse, upf_logspmax, upf_seqscans, upf_totsorts, upf_dsksorts, upf_srtspmax, nlocks, lkwaittime, iowaittime, upf_niowaits, net_read_cnt, net_read_bytes, net_write_cnt, net_write_bytes, net_open_time, net_last_read, net_last_write, wreason) SELECT $DATA_SEQ_ID, scb.sid, scb.uid, TRIM(scb.username), scb.pid, TRIM(scb.progname), TRIM(scb.hostname), scb.memtotal, scb.memused, rstcb.upf_rqlock, rstcb.upf_wtlock, rstcb.upf_deadlk, rstcb.upf_lktouts, rstcb.upf_lgrecs, rstcb.upf_isread, rstcb.upf_iswrite, rstcb.upf_isrwrite, rstcb.upf_isdelete , rstcb.upf_iscommit, rstcb.upf_isrollback, rstcb.upf_longtxs, rstcb.upf_bufreads, rstcb.upf_idxbufreads, rstcb.nreads, rstcb.upf_bufwrites, rstcb.nwrites, rstcb.upf_logspuse, rstcb.upf_logspmax, rstcb.upf_seqscans, rstcb.upf_totsorts, rstcb.upf_dsksorts, rstcb.upf_srtspmax, rstcb.nlocks, rstcb.lkwaittime, rstcb.iowaittime, rstcb.upf_niowaits, net_read_cnt, net_read_bytes, net_write_cnt, net_write_bytes, net_open_time, net_last_read, net_last_write, wreason FROM sysmaster:sysrstcb rstcb, sysmaster:sysscblst scb, sysmaster:sysnetworkio net, sysmaster:systcblst tcb where rstcb.sid = scb.sid and scb.netscb = net.net_netscb and tcb.tid = rstcb.tid",
NULL,
NULL,
INTERVAL ( 4 ) HOUR TO HOUR,
INTERVAL ( 7 ) DAY TO DAY
);

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
NULL,
NULL,
"sysadmin",
"f"
);

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
  ""EXECUTE FUNCTION SYSBldPrepare('any','migrate');"",
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
                           HEALTH CHECKS
**************************************************************************}


{**************************************************************************
             Check to make sure backups have been taken                           
**************************************************************************}

INSERT INTO ph_threshold(id,name,task_name,value,description)
VALUES
(0,"REQUIRED LEVEL BACKUP", "check_backup","2", 
"Maximum number of days between backups of any level.");

INSERT INTO ph_threshold(id,name,task_name,value,description)
VALUES
(0,"REQUIRED LEVEL 0 BACKUP", "check_backup","2", 
"Maximum number of days between level 0 backups.");
 

CREATE FUNCTION check_backup(task_id INT, task_seq INT) RETURNING INTEGER
DEFINE dbspace_num INTEGER;
DEFINE dbspace_name CHAR(257);
DEFINE req_level INTEGER;
DEFINE req_level0 INTEGER;
DEFINE level_0 INTEGER;
DEFINE level_1 INTEGER;
DEFINE level_2 INTEGER;
DEFINE arcdist INTERVAL DAY(5) TO SECOND;

  {*** Select the configuration values ***}
  select value::integer INTO req_level FROM ph_threshold where name 
          = "REQUIREDLEVEL BACKUP";
  select value::integer INTO req_level0 FROM ph_threshold where name 
          = "REQUIRED LEVEL 0 BACKUP";

  {*** If not found or are bad values then set better values ***}
  IF req_level < 1 THEN
     LET req_level = 1;
  END IF

  IF req_level0 < 1 THEN
     LET req_level0 = 1;
  END IF

  {*** Check each dbspaces backup time ***}
  FOREACH SELECT dbsnum, name, level0, level1, level2
    INTO dbspace_num, dbspace_name, level_0, level_1, level_2
    FROM sysmaster:sysdbstab
    WHERE dbsnum > 0
    AND sysmaster:bitval(flags, '0x2000')=0
     AND
     ( ((CURRENT - DBINFO("utc_to_datetime",level0) > req_level units day ) AND
        (CURRENT - DBINFO("utc_to_datetime",level1) > req_level units day ) AND
        (CURRENT - DBINFO("utc_to_datetime",level2) > req_level units day ) )
     OR
       (CURRENT - DBINFO("utc_to_datetime",level0) > req_level0 units day ) )

    {*** Check the dbspaces backup for a level 0 backup ***}
    IF level_0 ==  0 THEN 
        INSERT INTO ph_alert
          (ID, alert_task_id,alert_task_seq,alert_type, 
           alert_color, alert_object_type, 
           alert_object_name, alert_message,alert_action)
            VALUES
          (0,task_id, task_seq, "WARNING", "red", "SERVER",dbspace_name,
"Dbspace ["||trim(dbspace_name)|| "] has never had a level 0 backup.
Recommend taking a level 0 backup immediately."
,
NULL
);
    ELIF CURRENT-DBINFO("utc_to_datetime",level_0) > req_level0 units day THEN 
        LET arcdist = CURRENT - DBINFO("utc_to_datetime",level_0);
        INSERT INTO ph_alert
          (ID, alert_task_id,alert_task_seq,alert_type, 
           alert_color, alert_object_type, 
           alert_object_name, alert_message,alert_action)
            VALUES
          (0,task_id, task_seq, "WARNING", "red", "SERVER",dbspace_name,
"Dbspace ["||trim(dbspace_name)|| "] has not had a level 0 backup for "
|| arcdist|| ".
Recommend taking a level 0 backup immediately."
,
NULL
);
    CONTINUE FOREACH;
    END IF


   IF level_0 > level_1 THEN
      LET arcdist = CURRENT - DBINFO("utc_to_datetime",level_0);
   ELIF level_1 > level_2 THEN
      LET arcdist = CURRENT - DBINFO("utc_to_datetime",level_1);
   ELSE
      LET arcdist = CURRENT - DBINFO("utc_to_datetime",level_2);
   END IF

     INSERT INTO ph_alert
        (ID, alert_task_id,alert_task_seq,alert_type, alert_color, alert_object_type, 
           alert_object_name, alert_message,alert_action)
            VALUES
        (0,task_id,task_seq, "WARNING", "red", "SERVER",dbspace_name,
"Dbspace ["||trim(dbspace_name)|| "] has not had a backup for "
|| arcdist||". 
Recommend taking a backup immediately."
,
NULL
);

  END FOREACH


RETURN 0;

END FUNCTION;


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
"check_backup",
"TASK",
"BACKUP",
"Checks to ensure a backup has been taken of the data server.",
"check_backup",
DATETIME(05:00:00) HOUR TO SECOND,
NULL,
INTERVAL ( 1 ) DAY TO DAY
);

{**************************************************************************
          HA/MACH11 LOG REPLAY POSITION MONITOR
**************************************************************************}

--DROP   PROCEDURE "informix".ifx_ha_monitor_log_replay ( INTEGER, INTEGER );
CREATE PROCEDURE "informix".ifx_ha_monitor_log_replay ( v_taskid INTEGER,
                                                        v_seqnum INTEGER )

    DEFINE v_rss_servername VARCHAR(128);
    DEFINE v_state          CHAR(1);
    DEFINE v_replay_loguniq INTEGER;
    DEFINE v_replay_logpage INTEGER;
    DEFINE v_capacity       LIKE sysmaster:syslogs.size;
    DEFINE v_distance       LIKE sysmaster:syslogs.size;
    DEFINE v_result         INTEGER;

    /*
     * We give up easily. 
     */

    ON EXCEPTION
        RETURN;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 5;

    /*
     * Get the logical log capacity. It's not very likely
     * to change while we iterate over the HA secondaries.
     */

    SELECT SUM ( size )
      INTO v_capacity
      FROM sysmaster:syslogs
     WHERE is_pre_dropped = 0
       AND is_new         = 0
       AND is_temp        = 0;

    /*
     * Iterate over the HA secondaries,
     * and retrieve their replay positions
     */

    FOREACH SELECT rss_servername
                 , state
                 , replay_loguniq
                 , replay_logpage
              INTO v_rss_servername
                 , v_state
                 , v_replay_loguniq
                 , v_replay_logpage
              FROM sysha:rss_tab


         IF (v_state != 'C' )
         THEN
           CONTINUE FOREACH;
         END IF


        /*
         * Calculate the distance between the 
         * clone's replay and source's current position
         */

        SELECT NVL ( SUM ( size ), 0 ) + v_replay_logpage
          INTO v_distance
          FROM sysmaster:syslogs
         WHERE uniqid < v_replay_loguniq
           AND is_pre_dropped = 0
           AND is_new         = 0
           AND is_temp        = 0;

        /*
         * Is this clone's replay position in danger
         * of being overtaken by the source's current
         * log position ?
         * If so, invoke the alarm function.
         */

        IF  ( ( ( v_distance / v_capacity ) * 100 ) < 25 )
        THEN
            CALL ifx_ha_fire_logwrap_alarm ( v_rss_servername ) 
                RETURNING v_result;
        END IF

    END FOREACH

END PROCEDURE;

/******************************************************************************/
/*                                                                            */
/*                                                                            */
/*                                                                            */
/******************************************************************************/

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
    "ifx_ha_monitor_log_replay_task",
    "TASK",
    "SERVER",
    "Monitors HA secondary log replay position",
    "ifx_ha_monitor_log_replay",
    NULL,
    NULL,
    NULL,
    NULL
    );
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
        FROM ph_alert, OUTER ph_run
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

DELETE FROM ph_task WHERE tk_name="Job Runner";
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
    tk_attributes,
    tk_enable
    )
VALUES
    (
    "Job Runner",
    "TASK",
    "SERVER",
    "Run server tasks in background with a private dbWorker thread.",
    "run_job",
    NULL,
    NULL,
    INTERVAL ( 30 ) DAY TO DAY,
    NULL,
    NULL,
    8,
    'f'
    );

/*
 **************************************************************
 *  Create a task to cleanup the ph_bg_jobs_results table.
 **************************************************************
 */
DELETE from ph_threshold WHERE name = "JOB RUNNER HISTORY RETENTION";
INSERT INTO ph_threshold (
	name,
	task_name,
	value,
	value_type,
	description)
VALUES (
	"JOB RUNNER HISTORY RETENTION",
	"Job Results Cleanup",
	"30 0:00:00",
	"NUMERIC",
	"Remove all job results that are older than then the threshold.");

DELETE from ph_task WHERE tk_name = "Job Results Cleanup";
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
tk_delete,
tk_enable
)   
VALUES
(   
"Job Results Cleanup",
"TASK",
"TABLES",
"Remove all old job results entries from the system.",
"DELETE FROM ph_bg_jobs_results WHERE ph_bgr_starttime < (
	SELECT CURRENT - value::INTERVAL DAY TO SECOND
	FROM ph_threshold
	WHERE name = 'JOB RUNNER HISTORY RETENTION') ",
DATETIME(03:00:00) HOUR TO SECOND,
NULL,
INTERVAL ( 1 ) DAY TO DAY,
INTERVAL ( 30 ) DAY TO DAY,
't'
);  

/* IDLE USERS TIMEOUT */
DELETE FROM ph_threshold WHERE name = "IDLE TIMEOUT";

{*** CREATE THE THRESHOLD : Default = 60 minutes ***}
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

--DROP FUNCTION idle_user_timeout( INTEGER , INTEGER );
{*** CREATE the function that will be run by the task ***}

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

{ ***** CREATE THE bad_index_alert task ***** }
DELETE FROM ph_task WHERE tk_name = "bad_index_alert";

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
--DROP FUNCTION bad_index_alert( int , int );
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
tk_next_execution,
tk_attributes
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
NULL,
"0x408"
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

/* AUTO TUNE CPU VPS */
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


--DROP FUNCTION auto_crsd( INTEGER , INTEGER );

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
				H.partnum = T.partnum
				AND H.nextns > p_value -- qualifying number of extents
				AND dbsname NOT IN ( "sysmaster" , "system" ) -- do no include sysmaster or system database tables.
				-- do not include partitions that do not qualify to avoid unnecessary error reporting.
				AND bitand(H.partnum,"0xFFFFF") != 1   -- exclude partition partition
				AND (
					    bitand (H.flags,"0x00000004") != "0x00000004" -- system catalog
					AND bitand (H.flags,"0x00000020") != "0x00000020" -- temp table
					AND bitand (H.flags,"0x00000080") != "0x00000080" -- sorts
					AND bitand (H.flags,"0x00001000") != "0x00001000" -- optical blobs
					AND bitand (H.flags,"0x00002000") != "0x00002000" -- permanent
					AND bitand (H.flags,"0x00200000") != "0x00200000" -- protected
					AND bitand (H.flags,"0x01000000") != "0x01000000" -- virtual table
					AND bitand (H.flags,"0x20000000") != "0x20000000" -- defrag inprogress
					)

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

{*** CHECK for in place alters ***}

DELETE FROM ph_task WHERE tk_name = "check_for_ipa";

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

--DROP FUNCTION check_for_ipa( int , int );

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

DELETE FROM ph_task WHERE tk_name="refresh_table_stats";
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
    tk_enable
    )
VALUES
    (
    "refresh_table_stats",
    "TASK",
    "SERVER",
    "System function to refresh table statistics",
    "refreshstats",
    NULL,
    NULL,
    NULL,
    NULL,
    'f'
    );


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
        IN ('mon_command_history',
            'mon_config', 'mon_config_startup',
            'mon_sysenv', 'mon_profile', 'mon_vps',
            'mon_checkpoint', 'mon_memory_system',
            'mon_table_profile', 'mon_table_names',
            'mon_users', 'check_backup',
            'ifx_ha_monitor_log_replay_task',
            'Alert Cleanup',
            'post_alarm_message',
            'Job Runner',
            'Job Results Cleanup',
            'idle_user_timeout', 'auto_tune_cpu_vps', 'auto_crsd',
			'add_storage', 'mon_low_storage', 'refresh_table_stats' 
			,'online_log_rotate','bar_act_log_rotate','bar_debug_log_rotate'
			,'autoreg exe', 'autoreg vp', 'autoreg migrate-console'
			,'bad_index_alert','check_for_ipa'
		);

{**************************************************************************
          UPDATE STATISTICS
**************************************************************************}

UPDATE STATISTICS;

CLOSE DATABASE;

