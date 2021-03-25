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
{   Title:  upgrade_1150_setup.sql                   }
{   Description:                                     }
{       Prepare the system for upgrading to 11.50    }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

/*
 *  Remove any functions we will be creating,
 *   could be left around from partial upgrade
 */
DROP FUNCTION  AlertCleanup(INTEGER, INTEGER);
DROP FUNCTION  ph_dbs_alert(informix.integer,informix.integer,
                                informix.pointer );

DROP VIEW ph_alerts;
DROP VIEW ph_config;

drop function informix.exectask_async(informix.lvarchar);

drop function informix.exectask_async(informix.integer);

DROP TRIGGER ph_task_trig_update_exec_time;
DROP FUNCTION ph_reset_next_execution(INTEGER);
DROP TRIGGER ph_task_delete;
DROP PROCEDURE ph_task_delete_check(INTEGER);
ALTER TABLE ph_task DROP CONSTRAINT ph_task_constr2;

{*********************************************************
 *
 *  The following section cleans up all the resources
 *    utilized by the AUS feature
 *
 ********************************************************}
DROP FUNCTION aus_get_realtime();
DROP FUNCTION aus_refresh_stats( );
DROP FUNCTION aus_setup_mon_table_profile(INTEGER, INTEGER);
DROP FUNCTION aus_cleanup_table(INTEGER);
DROP FUNCTION aus_setup_table();
DROP FUNCTION aus_enable_refresh();
DROP FUNCTION aus_refresh_stats(INTEGER,INTEGER);
DROP FUNCTION aus_evaluator(BOOLEAN);
DROP FUNCTION aus_evaluator(INTEGER,INTEGER);
DROP FUNCTION aus_evaluator(INTEGER,INTEGER,INTEGER);
DROP FUNCTION aus_evaluator_dbs(char(128),INTEGER, INTEGER );
DROP FUNCTION aus_load_dbs_data(char(128),INTEGER );
DROP FUNCTION aus_create_cmd_dist(char(128), INTEGER, CHAR(128), INTEGER,
                                  INTEGER, INTEGER,INTEGER);
DROP FUNCTION aus_get_exclusive_access(INTEGER, INTEGER);
DROP FUNCTION aus_rel_exclusive_access();
DROP TABLE aus_work_lock;

DELETE FROM ph_threshold WHERE task_name IN
        (
        "Auto Update Statistics Evaluation",
        "Auto Update Statistics Refresh"
        )
       OR
       name MATCHES "AUS_*";

DROP FUNCTION run_job(INTEGER, INTEGER, LVARCHAR);
DROP TRIGGER ph_bg_jobs_delete;
DELETE FROM ph_threshold WHERE name = "JOB RUNNER HISTORY RETENTION";

{ Drop DSAC Common SQL API Stored Procedures            }

DROP FUNCTION SYSPROC.SET_CONFIG
  ( INTEGER
  , INTEGER
  , VARCHAR(33)
  , BLOB
  , BLOB
  , BLOB
  , BLOB);


DROP FUNCTION SYSPROC.GET_SYSTEM_INFO
  ( INTEGER
  , INTEGER
  , VARCHAR(33)
  , BLOB
  , BLOB
  , BLOB
  , BLOB);

DROP FUNCTION SYSPROC.GET_MESSAGE
  ( INTEGER
  , INTEGER
  , VARCHAR(33)
  , BLOB
  , BLOB
  , BLOB
  , BLOB);

DROP FUNCTION SYSPROC.GET_CONFIG
  ( INTEGER
  , INTEGER
  , VARCHAR(33)
  , BLOB
  , BLOB
  , BLOB
  , BLOB);

DROP FUNCTION SYSPROC.ITMA_SET_CONFIG (
    LVARCHAR(256),
    INTEGER,
    LVARCHAR(2048),
    SMALLINT,
    INTEGER ,
    LVARCHAR(1331) );

CLOSE DATABASE;
