{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2009, 2010 All rights reserved.         *}
{*                                                                        *}
{**************************************************************************}
{                                                    }                  
{   Title:  revert_1150_setup.sql                    }
{   Description:                                     }
{       Prepare the system for reverting to 11.10    }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");


DROP FUNCTION  AlertCleanup(INTEGER, INTEGER);
DROP FUNCTION  ph_dbs_alert(informix.integer,informix.integer,
                                informix.pointer );

DROP TRIGGER ph_task_trig_update_exec_time;
DROP FUNCTION ph_reset_next_execution(INTEGER);
DROP TRIGGER ph_task_delete;
DROP PROCEDURE ph_task_delete_check(INTEGER);

{*********************************************************
 *
 *  The following section cleans up all the resources
 *    utilized by the AUS feature
 *
 ********************************************************
 *}
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
DELETE FROM ph_version WHERE object = 'AUS' and type = 'version';

CLOSE DATABASE;
