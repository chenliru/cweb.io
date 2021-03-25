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
{   Title:  upgrade_1150xC6.sql                      }
{   Description:                                     }
{       Upgrade to 11.50.xC6                         }

DATABASE sysadmin;

create function
    informix.exectask(lvarchar, lvarchar)
    returns integer
    external name '(ph_sensor_cc)'
    language C;

create function
    informix.exectask(integer,lvarchar)
    returns integer
    external name '(ph_sensor_ic)'
    language C;

create function
    informix.exectask_async(lvarchar, lvarchar)
    returns integer
    external name '(ph_sensor_cc_async)'
    language C;

create function
    informix.exectask_async(integer, lvarchar)
    returns integer
    external name '(ph_sensor_ic_async)'
    language C;

create function
    informix.run_job(informix.integer, informix.integer,
	informix.lvarchar default null)
    returns integer
    external name '(bg_jobs)'
    language C;

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

CREATE SEQUENCE ph_bg_jobs_seq INCREMENT BY 1 START WITH 1 CYCLE NOCACHE;

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

UPDATE ph_task SET tk_attributes = BITOR(tk_attributes, 4)
    WHERE tk_name
        IN ( 'Job Runner', 'Job Results Cleanup');

CLOSE DATABASE;
