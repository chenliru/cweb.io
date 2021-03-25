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
{   Title:  revert_1150.sql                          }
{   Description:                                     }
{       Reversion from 11.50 to 11.10                }

DATABASE sysadmin;

drop function informix.exectask_async(informix.lvarchar);

drop function informix.exectask_async(informix.integer);

ALTER TABLE ph_alert DROP CONSTRAINT ph_alert_constr1;
ALTER TABLE ph_task DROP CONSTRAINT ph_task_constr1;
ALTER TABLE ph_task DROP CONSTRAINT ph_task_constr2;

DELETE FROM ph_task
    WHERE tk_name
        IN ('Alert Cleanup',
            'post_alarm_message',
            'Job Runner',
            'Job Results Cleanup',
            'Auto Update Statistics Evaluation',
            'Auto Update Statistics Refresh');

UPDATE ph_task SET tk_attributes = BITANDNOT(tk_attributes, 4)
    WHERE tk_name
        IN ('mon_command_history',
            'mon_config', 'mon_config_startup',
            'mon_sysenv', 'mon_profile', 'mon_vps',
            'mon_checkpoint', 'mon_memory_system',
            'mon_table_profile', 'mon_table_names',
            'mon_users', 'check_backup',
            'ifx_ha_monitor_log_replay_task');

DELETE FROM ph_threshold WHERE name = "ALERT HISTORY RETENTION";

DROP VIEW ph_config;

{ Drop DSAC Common SQL API Stored Procedures 		}

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
