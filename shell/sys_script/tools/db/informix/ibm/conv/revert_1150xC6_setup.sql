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
{   Title:  revert_1150xC6_setup.sql                 }
{   Description:                                     }
{       Setup reversion to < 11.50.xC6               }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

{** For system tasks, remove protective bit from attributes **}
{** before deleting entry from ph_task table.               **}
UPDATE ph_task SET tk_attributes = BITANDNOT(tk_attributes, 4)
    WHERE tk_name
        IN ( 'Job Runner', 'Job Results Cleanup');

DROP FUNCTION informix.exectask(lvarchar, lvarchar);
DROP FUNCTION informix.exectask(integer, lvarchar);
DROP FUNCTION informix.exectask_async(lvarchar, lvarchar);
DROP FUNCTION informix.exectask_async(integer, lvarchar);

{** For system tasks, remove protective bit from attributes **}
{** before deleting entry from ph_task table.               **}
UPDATE ph_task SET tk_attributes = BITANDNOT(tk_attributes, 4)
    WHERE tk_name
        IN ( 'Job Runner', 'Job Results Cleanup');

DELETE FROM ph_task WHERE tk_name="Job Runner";
DELETE FROM ph_task WHERE tk_name="Job Results Cleanup";

DELETE FROM ph_threshold WHERE name = "JOB RUNNER HISTORY RETENTION";

DROP FUNCTION run_job(INTEGER, INTEGER, LVARCHAR);

DROP SEQUENCE ph_bg_jobs_seq;

DROP TRIGGER ph_bg_jobs_delete;

DROP TABLE ph_bg_jobs;
DROP TABLE ph_bg_jobs_results;

CLOSE DATABASE;
