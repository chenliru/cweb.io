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
{   Title:  revert_1170.sql                          			   }
{   Description:                                     			   }
{       Reversion from 11.70 to 11.50                			   }
{   Note:                                                                  }
{       Errors encountered while executing this sql script are NOT ignored.}
{       'revert_1170_setup.sql' is run before this script.		   }
{**************************************************************************}

DATABASE sysadmin;

{** For system tasks, remove protective bit from attributes **}
{** before deleting entry from ph_task table.               **}
UPDATE ph_task SET tk_attributes = BITANDNOT(tk_attributes, 4)
    WHERE tk_name
        IN ( 'idle_user_timeout', 'auto_tune_cpu_vps', 'auto_crsd',
             'add_storage', 'mon_low_storage', 'autoreg exe', 'autoreg vp',
             'bad_index_alert', 'check_for_ipa'); 

{** remove idle_users_timeout **}
DELETE FROM ph_task WHERE tk_name = "idle_user_timeout";
DELETE FROM ph_threshold WHERE name = "IDLE TIMEOUT";
DROP FUNCTION idle_user_timeout( INTEGER , INTEGER );

{** remove bad_index_alert **}
DELETE FROM ph_task WHERE tk_name = "bad_index_alert";
DROP FUNCTION bad_index_alert( INTEGER , INTEGER );

{** remove auto_tune_cpu_vps **}
DELETE FROM ph_task WHERE tk_name = "auto_tune_cpu_vps";
DROP FUNCTION auto_tune_cpu_vps( INTEGER , INTEGER );

{** remove auto_crsd **}
DELETE FROM ph_threshold WHERE name = "AUTOCOMPRESS_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTOCOMPRESS_ROWS";
DELETE FROM ph_threshold WHERE name = "AUTOREPACK_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTOREPACK_SPACE";
DELETE FROM ph_threshold WHERE name = "AUTOSHRINK_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTOSHRINK_UNUSED";
DELETE FROM ph_threshold WHERE name = "AUTODEFRAG_ENABLED";
DELETE FROM ph_threshold WHERE name = "AUTODEFRAG_EXTENTS";

DELETE FROM ph_task WHERE tk_name = "auto_crsd";
DROP FUNCTION auto_crsd( INTEGER , INTEGER );

DELETE FROM ph_task WHERE tk_name = "check_for_ipa";
DROP FUNCTION check_for_ipa( INTEGER , INTEGER );

{**************************************************************************
          Tasks and functions to register database extensions on-first-use
**************************************************************************}
DELETE FROM ph_task WHERE tk_name = "autoreg exe" OR tk_name = "autoreg vp";
DROP FUNCTION autoregexe(integer, integer, lvarchar);
DROP FUNCTION autoregvp(integer, integer, lvarchar);
DELETE FROM ph_task WHERE tk_name like "autoreg migrate%";

{**************************************************************************
          Storage Provisioning: Tasks, functions, and other objects
**************************************************************************}
DELETE FROM ph_task WHERE tk_name = "add_storage" OR tk_name = "mon_low_storage";
DROP FUNCTION adm_add_storage(informix.pointer);
DROP FUNCTION mon_low_storage(informix.integer, informix.integer);
DROP INDEX ix_storagepool_1;
DROP TABLE storagepool;

{**************************************************************************
	Unique Event Alarms
**************************************************************************}
DROP VIEW ph_alerts;
ALTER TABLE ph_alert DROP alert_object_info;
UPDATE ph_alert SET alert_task_id = alert_task_id;

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

UPDATE ph_version SET value = 13
    WHERE object = 'ph_alert' and type = 'table';
UPDATE ph_version SET value = 165
    WHERE object = 'ph_alert' and type = 'colnames';

CLOSE DATABASE;
