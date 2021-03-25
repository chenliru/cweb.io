{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 1996, 2010 All rights reserved.         *}
{*                                                                        *}
{**************************************************************************}
{                                          }
{   Title:  db_install.sql                 }
{   Description:                           }
{       setup sysadmin database            }
{*****************************************************************
******************************************************************

                    Create the SQL admin UDRs

******************************************************************
******************************************************************}

create function
    string_to_utf8(string lvarchar(4096), source_locale lvarchar)
    returns lvarchar
    external name '(string_to_utf8)'
    language C;

create function
    informix.task(informix.lvarchar)
    returns informix.lvarchar
    external name '(task)'
    language C;


create function
    informix.task(informix.lvarchar, informix.lvarchar)
    returns informix.lvarchar
    external name '(task_c)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar)
    returns informix.lvarchar
    external name '(task_cc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar)
    returns informix.lvarchar
    external name '(task_ccc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar)
    returns informix.lvarchar
    external name '(task_cccc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar)
    returns informix.lvarchar
    external name '(task_ccccc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar)
    returns informix.lvarchar
    external name '(task_cccccc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar)
    returns informix.lvarchar
    external name '(task_ccccccc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar)
    returns informix.lvarchar
    external name '(task_cccccccc)'
    language C;

create function
    informix.task(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar, informix.lvarchar, informix.lvarchar,
		  informix.lvarchar)
    returns informix.lvarchar
    external name '(task_ccccccccc)'
    language C;


create function
    informix.admin(informix.lvarchar)
    returns integer
    external name '(admin)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(admin_c)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(admin_cc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar)
    returns integer
    external name '(admin_ccc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(admin_cccc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(admin_ccccc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar)
    returns integer
    external name '(admin_cccccc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(admin_ccccccc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(admin_cccccccc)'
    language C;

create function
    informix.admin(informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar, informix.lvarchar, informix.lvarchar,
		   informix.lvarchar)
    returns integer
    external name '(admin_ccccccccc)'
    language C;


create function
    informix.exectask(informix.lvarchar)
    returns integer
    external name '(ph_sensor_c)'
    language C;
create function
    informix.exectask(lvarchar, lvarchar)
    returns integer
    external name '(ph_sensor_cc)'
    language C;

create function
    informix.exectask(informix.integer)
    returns integer
    external name '(ph_sensor_i)'
    language C;
create function
    informix.exectask(integer,lvarchar)
    returns integer
    external name '(ph_sensor_ic)'
    language C;

create function
    informix.exectask_async(informix.lvarchar)
    returns integer
    external name '(ph_sensor_c_async)'
    language C;
create function
    informix.exectask_async(lvarchar, lvarchar)
    returns integer
    external name '(ph_sensor_cc_async)'
    language C;

create function
    informix.exectask_async(informix.integer)
    returns integer
    external name '(ph_sensor_i_async)'
    language C;
create function
    informix.exectask_async(integer, lvarchar)
    returns integer
    external name '(ph_sensor_ic_async)'
    language C;

create function informix.alert_exec_recommend(informix.integer)
    returns integer
    external name '(ph_alert_exec_recommend)'
    language C;

create function informix.ph_dbs_alert(informix.integer, informix.integer,
		   informix.pointer)
    returns integer
    external name '(ph_dbs_alert)'
    language C;

create function informix.refreshstats(informix.integer, informix.integer,
		   informix.pointer)
    returns integer
    external name '(refreshstats)'
    language C;

CREATE FUNCTION ph_reset_next_execution(attr INTEGER)
     RETURNING DATETIME YEAR TO SECOND, INTEGER
     DEFINE curr_time  DATETIME YEAR TO SECOND;
     DEFINE flags      INTEGER;

     -- Set TK_ATTR_EVALUTE_TIME_ONLY (0x2) flag
     LET flags = BITOR(attr, 2);
     LET curr_time = CURRENT;

     RETURN curr_time, flags;
END FUNCTION;

CREATE PROCEDURE ph_task_delete_check(attr INTEGER);

    -- Check if we are trying to delete a system generated task
    -- Marked via TK_ATTR_SYSTEM_TASK (0x4) flag
    IF BITAND(attr, 4) <> 0 THEN
        RAISE EXCEPTION -274, -107;
    END IF
END PROCEDURE;

{*****************************************************************
******************************************************************

                    Create the admin API tables

******************************************************************
******************************************************************}


create table command_history
     (
     cmd_number        serial(100),
     cmd_exec_time     datetime YEAR TO SECOND
                                DEFAULT CURRENT YEAR TO SECOND,
     cmd_user          varchar(254),
     cmd_hostname      varchar(254),
     cmd_executed      varchar(254),
     cmd_ret_status    integer,
     cmd_ret_msg       lvarchar(30000)
     );

CREATE UNIQUE INDEX ix_cmd_hist_01 ON command_history(cmd_number);
CREATE INDEX ix_cmd_hist_02 ON command_history(cmd_executed);



{*****************************************************************
******************************************************************

                          AUTO DBA

******************************************************************
******************************************************************}

create procedure
    informix.wake_dba()
    external name '(ph_wakeup)'
    language C;

create function
    informix.db_sch_worker()
    returns informix.integer
    external name '(db_sch_worker)'
    language C;

create function
    informix.db_sched()
    returns informix.integer
    external name '(db_sched)'
    language C;

create function
    informix.db_low_memory_mgr()
    returns informix.integer
    external name '(db_low_memory_mgr)'
    language C;

create function
    informix.low_memory_mgr_message(informix.integer, informix.integer, 
                      informix.lvarchar, informix.integer default 1 )
    returns informix.integer
    external name '(dbcron_alert_msg_low_memory)'
    language C;

create function
    informix.yieldn()
    returns informix.integer
    external name '(admin_yield)'
    language C;

create function
    informix.yieldn(informix.integer)
    returns informix.integer
    external name '(admin_yieldn)'
    language C;


create function
    informix.run_job(informix.integer, informix.integer,
	informix.lvarchar default null)
    returns integer
    external name '(bg_jobs)'
    language C;

{*****************************************************************
******************************************************************

                    Create the AUTO DBA tables

******************************************************************
******************************************************************}


CREATE TABLE ph_group (
    group_id             SERIAL,
    group_name           varchar(129),
    group_description    lvarchar
    ) LOCK MODE ROW;
CREATE UNIQUE INDEX ix_ph_group_01 ON ph_group(group_id);
CREATE UNIQUE INDEX ix_ph_group_02 ON ph_group(group_name);
ALTER TABLE ph_group ADD CONSTRAINT UNIQUE (group_name) CONSTRAINT u_ph_group_01;
INSERT INTO ph_group VALUES (0,"MISC","no group was defined");



CREATE TABLE ph_task (
tk_id	              SERIAL,
tk_name	              CHAR(36)
                          CHECK ( tk_name[1,1] != ' ' ),
tk_description	      LVARCHAR,
tk_type	              CHAR(18)
                        DEFAULT 'SENSOR' NOT NULL
                        CHECK ( UPPER(tk_type) IN
                         ("SENSOR", "TASK",
                          "STARTUP SENSOR", "STARTUP TASK" ) ) CONSTRAINT ph_task_constr1,
tk_sequence 	      INTEGER   DEFAULT 0,
tk_result_table	      LVARCHAR,
tk_create	      LVARCHAR  DEFAULT NULL,
tk_dbs                VARCHAR(250)     DEFAULT 'sysadmin',
tk_execute	      LVARCHAR,
tk_delete	      INTERVAL day(2) TO second
                	DEFAULT INTERVAL( 0 1:00:00 ) day to second,
tk_start_time	      DATETIME hour to second
                	DEFAULT DATETIME(08:00:00) hour to second,
tk_stop_time	      DATETIME hour TO second
                	DEFAULT DATETIME(19:00:00) hour to second,
tk_frequency	      INTERVAL day(2) to second
                	DEFAULT INTERVAL( 1 0:00:00 ) day to second
                        CHECK (tk_frequency > INTERVAL(0 00:00:00) day to second) 
                        CONSTRAINT ph_task_constr2,
tk_next_execution     DATETIME year TO second
                        DEFAULT CURRENT year to second,
tk_total_executions   INTEGER   DEFAULT  0,
tk_total_time         FLOAT     DEFAULT  0.0,
tk_Monday             BOOLEAN	DEFAULT 'T',
tk_Tuesday            BOOLEAN	DEFAULT 'T',
tk_Wednesday          BOOLEAN	DEFAULT 'T',
tk_Thursday           BOOLEAN	DEFAULT 'T',
tk_Friday             BOOLEAN	DEFAULT 'T',
tk_Saturday           BOOLEAN	DEFAULT 'T',
tk_Sunday             BOOLEAN	DEFAULT 'T',
tk_attributes         INTEGER   DEFAULT  0,
tk_group              VARCHAR(129)   DEFAULT  'MISC'
                                REFERENCES ph_group(group_name),
tk_enable             BOOLEAN   DEFAULT 'T',
tk_priority           INTEGER   DEFAULT  0
) LOCK MODE ROW;

CREATE UNIQUE INDEX ix_ph_task_01 ON ph_task(tk_id);
CREATE UNIQUE INDEX ix_ph_task_02 ON ph_task(tk_name);
CREATE INDEX ix_ph_task_03 ON ph_task(tk_next_execution, tk_id);

CREATE TRIGGER ph_task_trig1
       INSERT ON ph_task
       AFTER ( EXECUTE PROCEDURE wake_dba() );

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

CREATE TRIGGER ph_task_delete
    DELETE ON ph_task
    REFERENCING OLD AS pre
    FOR EACH ROW
        (EXECUTE PROCEDURE ph_task_delete_check(pre.tk_attributes));

CREATE TABLE ph_run (
    run_id            SERIAL,
    run_task_id       INTEGER,
    run_task_seq      INTEGER,
    run_retcode       INTEGER,
    run_time          DATETIME year to second
                          DEFAULT CURRENT year to second,
    run_duration      FLOAT,
    run_ztime         INTEGER,
    run_btime         INTEGER,
    run_mttime        INTEGER
    ) LOCK MODE ROW;
CREATE UNIQUE INDEX ix_ph_run_01 ON ph_run(run_id);
CREATE INDEX ix_ph_run_02 ON ph_run(run_task_seq,run_task_id);
CREATE INDEX ix_ph_run_03 ON ph_run(run_task_id,run_time);


CREATE TABLE ph_alert (
    ID		       SERIAL,
    alert_task_id      INTEGER,
    alert_task_seq     INTEGER,
    alert_type         CHAR(8)
                          DEFAULT 'INFO'
                          CHECK ( UPPER(alert_type) IN
                                       ("INFO","WARNING","ERROR") ),
    alert_color        CHAR(15)
                          DEFAULT 'GREEN'
                          CHECK ( UPPER(alert_color) IN
                                       ("RED","YELLOW","GREEN") ),
    alert_time         DATETIME year TO second
                          DEFAULT CURRENT year to second,
    alert_state        CHAR(15)
                          DEFAULT 'NEW'
                          CHECK ( UPPER(alert_state) IN
                                  ("NEW","ADDRESSED",
                                   "ACKNOWLEDGED","IGNORED") ),
    alert_state_changed DATETIME year TO second
                          DEFAULT CURRENT year to second,
    alert_object_type  CHAR(15)
                          DEFAULT 'MISC'
                          CHECK ( UPPER(alert_object_type) IN
                              ("SERVER","DATABASE","TABLE","INDEX", "DBSPACE",
                               "CHUNK","USER","SQL","MISC","ALARM") ) CONSTRAINT ph_alert_constr1,
    alert_object_name  VARCHAR(254),
    alert_message      LVARCHAR,
    alert_action_dbs   LVARCHAR(256)
                          DEFAULT 'sysadmin',
    alert_action       LVARCHAR,
    alert_object_info  BIGINT
                          DEFAULT 0
    ) LOCK MODE ROW;
CREATE UNIQUE INDEX ix_ph_alert_01 ON ph_alert(ID);
CREATE INDEX ix_ph_alert_02 ON ph_alert(alert_task_seq,alert_task_id);

CREATE TABLE ph_threshold (
    ID                  SERIAL,
    name                VARCHAR(254),
    task_name           CHAR(36),
    value               LVARCHAR,
    value_type          VARCHAR(254)
                         DEFAULT 'STRING'
                         CHECK (UPPER(value_type) MATCHES "STRING"  OR
                                UPPER(value_type) MATCHES "NUMERIC" OR
                                UPPER(value_type) MATCHES "NUMERIC(*.*)"),
    description         LVARCHAR
    ) LOCK MODE ROW;

CREATE UNIQUE INDEX ix_ph_threshold_01 ON ph_threshold(ID);
CREATE INDEX ix_ph_threshold_02 ON ph_threshold(name);
CREATE VIEW ph_config ( ID, name, task_name, value, value_type ) 
        AS SELECT ID, name, task_name, value, value_type 
        FROM ph_threshold;


revoke all on ph_task from public;
revoke all on ph_run from public;
revoke all on ph_alert from public;
revoke all on ph_threshold from public;

grant select on ph_alert to public;

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


CREATE TABLE ph_bg_jobs
(
ph_bg_id       SERIAL          NOT NULL,
ph_bg_name     VARCHAR(255)    NOT NULL,
ph_bg_job_id   INTEGER         NOT NULL,
ph_bg_type     VARCHAR(255)    DEFAULT 'MISC' NOT NULL,
ph_bg_desc     VARCHAR(255),
ph_bg_sequence SMALLINT        NOT NULL,
ph_bg_flags    INTEGER         DEFAULT 0 NOT NULL,
ph_bg_stop_on_error  BOOLEAN   DEFAULT 'f' NOT NULL,
ph_bg_database VARCHAR(255)    NOT NULL,
ph_bg_cmd      LVARCHAR(30000) NOT NULL
) LOCK MODE ROW;

CREATE UNIQUE INDEX ph_bg_jobs_ix1 ON ph_bg_jobs (ph_bg_id);
CREATE UNIQUE INDEX ph_bg_jobs_ix2 ON ph_bg_jobs (ph_bg_job_id, ph_bg_sequence);
CREATE UNIQUE INDEX ph_bg_jobs_ix3 ON ph_bg_jobs (ph_bg_name, ph_bg_sequence);


CREATE TABLE ph_bg_jobs_results
(
ph_bgr_id             SERIAL          NOT NULL,
ph_bgr_bg_id          INTEGER         NOT NULL,
ph_bgr_tk_id          INTEGER         NOT NULL,
ph_bgr_tk_sequence    INTEGER         NOT NULL,
ph_bgr_starttime      DATETIME YEAR TO SECOND
                             DEFAULT CURRENT YEAR TO SECOND NOT NULL,
ph_bgr_stoptime       DATETIME YEAR TO SECOND  DEFAULT NULL,
ph_bgr_retcode        INTEGER         DEFAULT NULL,
ph_bgr_retcode2       INTEGER         DEFAULT NULL,
ph_bgr_retmsg         LVARCHAR(30000) DEFAULT NULL
)  LOCK MODE ROW;

CREATE UNIQUE INDEX ph_bg_jobs_results_ix1 ON ph_bg_jobs_results (ph_bgr_id);
CREATE INDEX ph_bg_jobs_results_ix2 ON ph_bg_jobs_results (ph_bgr_bg_id);

CREATE TRIGGER ph_bg_jobs_delete
    DELETE ON ph_bg_jobs
    REFERENCING OLD AS pre
    FOR EACH ROW
	(DELETE FROM ph_bg_jobs_results
	WHERE ph_bg_jobs_results.ph_bgr_bg_id = pre.ph_bg_id);

REVOKE ALL ON ph_bg_jobs FROM public;
REVOKE ALL ON ph_bg_jobs_results FROM public;
GRANT SELECT ON ph_bg_jobs TO public;
GRANT SELECT ON ph_bg_jobs_results TO public;

CREATE SEQUENCE ph_bg_jobs_seq INCREMENT BY 1 START WITH 1 CYCLE NOCACHE ;


{
**********************************************************************
**********************************************************************
EXAMPLE FUNCTIONS
**********************************************************************
**********************************************************************
}
create function
    informix.dbcron_submit_task(informix.lvarchar, informix.lvarchar)
    returns integer
    external name '(dbcron_submit_task)'
    language C;

create function
    informix.dbcron_submit_task(informix.lvarchar, informix.pointer)
    returns integer
    external name '(dbcron_submit_task)'
    language C;

create function
    informix.rhead()
    returns informix.pointer
    external name '(get_RHEAD)'
    language C;

create function
    informix.dbcron_template_udr_ptr(informix.integer, informix.pointer)
    returns integer
    external name '(dbcron_template_udr_ptr)'
    language C;

create function
    informix.ifx_ha_fire_logwrap_alarm ( varchar ( 128 ) )
    returns integer
    external name '(cloneFireLogWrapAlarm)'
    language C;

create function
    informix.adm_add_storage(informix.pointer)
    returns informix.integer
    external name '(adm_add_storage)'
    language C;

create function
    informix.mon_low_storage(informix.integer,informix.integer)
    returns informix.integer
    external name '(mon_low_storage)'
    language C;

{* This table should be the last one created.  Its  *
 * creation order ensures other object were created * 
 * successfully.
 *} 
 
create table ph_version
    (
    object     varchar(129), 
    type       varchar(18), 
    value      integer
    );

create unique index ph_version_ix1 on ph_version (object,type);

insert into ph_version values ("ph_version","value",1);
insert into ph_version values ("ph_version","table",3);
insert into ph_version values ("ph_task","table",27);
insert into ph_version values ("ph_task","index",3);
insert into ph_version values ("ph_task","colnames",291);
insert into ph_version values ("ph_run","table",9);
insert into ph_version values ("ph_run","index",3);
insert into ph_version values ("ph_run","colnames",88);
insert into ph_version values ("ph_alert","table",14);
insert into ph_version values ("ph_alert","index",2);
insert into ph_version values ("ph_alert","colnames",182);
insert into ph_version values ("ph_threshold","table",6);
insert into ph_version values ("ph_threshold","index",2);
insert into ph_version values ("ph_threshold","colnames",41);
insert into ph_version values ("command_history","table",7);
insert into ph_version values ("command_history","index",2);
insert into ph_version values ("command_history","colnames",80);
insert into ph_version values ("ph_group","table",3);
insert into ph_version values ("ph_group","index",2);
insert into ph_version values ("ph_group","colnames",35);


{*
 * Storage pool
 *
 * This table stores directories, cooked files and raw devices for use
 * by the storage provisioning feature. Columns are as follows:
 *    entry_id		-- Serial used to id an entry
 *    path		-- The path to the device/directory/file
 *    beg_offset	-- Starting offset of entry
 *    end_offset	-- End offset of entry
 *    chunk_size	-- Minimum size of an allocation from this entry
 *    priority		-- Affects order in which this entry will be considered
 *    last_alloc	-- Date/time of last allocation from this entry
 *    logid       -- We use the last two columns to store a log position
 *    logused     -- so we can allocate in round-robin fashion.
 *
 * All entries can be broken down into two categories: Fixed Length and 
 * Extendable. The information stored in three of the columns is different
 * for the two types of entry:
 *
 * Fixed Length
 *      beg_offset      Starting offset into device
 *      end_offset      End offset into device
 *      chunk_size      minimum size of chunk allocated from this device
 *
 * Extendable
 *      beg_offset      Starting offset into device, 0 for directory
 *      end_offset      0
 *      chunk_size      Initial size of either the device or the cooked 
 *                      chunks within the directory
 *
 * Note that we can distinguish between fixed length and extendable items,
 * since fixed length entries always have a non-zero end_offset value. We 
 * distinguish between directories and files/devices using the mt_aio_stat() 
 * routine.
 * 
 * Valid 'priority' values are:
 *      1 = High
 *      2 = Medium
 *      3 = Low
 *
 * Default: 2
*}
create table storagepool
    (
    entry_id	serial not null,
    path	varchar(255) not null,
    beg_offset	bigint not null,
    end_offset	bigint not null,
    chunk_size	bigint not null,
    status	varchar(255),
    priority	int	default 2,
    last_alloc	datetime year to second,
    logid	int,
    logused	int
    ) lock mode row;

create unique index ix_storagepool_1 ON storagepool(entry_id);


{*****************************************************************
******************************************************************

                    Create the DSAC Common SQL API procedures

******************************************************************
******************************************************************}

create function SYSPROC.GET_MESSAGE
  ( INOUT  MAJOR_VERSION  INTEGER
  , INOUT  MINOR_VERSION  INTEGER
  , REQUESTED_LOCALE  VARCHAR(33) 
  , XML_INPUT  BLOB
  , XML_FILTER BLOB
  , OUT    XML_OUTPUT BLOB
  , OUT    XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
external name '(admin_get_message)'
LANGUAGE C;

create function SYSPROC.GET_CONFIG
( INOUT MAJOR_VERSION INTEGER
, INOUT MINOR_VERSION INTEGER
, REQUESTED_LOCALE VARCHAR(33) 
, XML_INPUT BLOB
, XML_FILTER BLOB 
, OUT XML_OUTPUT BLOB
, OUT XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
external name '(admin_get_config)'
LANGUAGE C; 

create function SYSPROC.GET_SYSTEM_INFO
  ( INOUT  MAJOR_VERSION  INTEGER
  , INOUT  MINOR_VERSION  INTEGER
  , REQUESTED_LOCALE  VARCHAR(33) 
  , XML_INPUT  BLOB
  , XML_FILTER BLOB
  , OUT    XML_OUTPUT BLOB
  , OUT    XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
external name '(admin_get_system_info)'
LANGUAGE C;

create function SYSPROC.SET_CONFIG
  ( INOUT  MAJOR_VERSION  INTEGER
  , INOUT  MINOR_VERSION  INTEGER
  , REQUESTED_LOCALE  VARCHAR(33) 
  , XML_INPUT  BLOB
  , XML_FILTER BLOB
  , OUT    XML_OUTPUT BLOB
  , OUT    XML_MESSAGE BLOB)
RETURNING INTEGER
WITH (HANDLESNULLS)
external name '(admin_set_config)'
LANGUAGE C;

create function SYSPROC.ITMA_SET_CONFIG (  
    HOST      LVARCHAR(256),
    PORT      INTEGER,
    OPTIONS   LVARCHAR(2048),
    ACTION    SMALLINT,
    OUT  SQLCODE   INTEGER ,
    OUT  MESSAGE   LVARCHAR(1331))
RETURNING INTEGER
WITH (HANDLESNULLS)
external name '(admin_itma_set_config)'
LANGUAGE C;

create function autoregexe(integer, integer, lvarchar)
    RETURNS integer
    external name '(autoregexe)'
    LANGUAGE C;

create function autoregvp(integer, integer, lvarchar)
    RETURNS integer
    external name '(autoregvp)'
    LANGUAGE C;

close database;
