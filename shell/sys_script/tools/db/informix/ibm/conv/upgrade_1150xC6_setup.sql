{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2009 All rights reserved.               *}
{*                                                                        *}
{**************************************************************************}
{                                                    }
{   Title:  upgrade_1150xC6_setup.sql                }
{   Description:                                     }
{       Prepare to upgrade to 11.50.xC6              }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

DROP FUNCTION informix.exectask(lvarchar, lvarchar);
DROP FUNCTION informix.exectask(integer, lvarchar);
DROP FUNCTION informix.exectask_async(lvarchar, lvarchar);
DROP FUNCTION informix.exectask_async(integer, lvarchar);

DELETE FROM ph_task WHERE tk_name="Job Runner";
DELETE FROM ph_task WHERE tk_name="Job Results Cleanup";

DELETE FROM ph_threshold WHERE name = "JOB RUNNER HISTORY RETENTION";

DROP FUNCTION run_job(INTEGER, INTEGER, LVARCHAR);

DROP TRIGGER ph_bg_jobs_delete;

DROP TABLE ph_bg_jobs;
DROP TABLE ph_bg_jobs_results;

CLOSE DATABASE;
