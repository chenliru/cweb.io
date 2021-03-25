{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  Copyright IBM Corporation 2011                                        *}
{*                                                                        *}
{**************************************************************************}
{                                                    			   }
{   Title:  upgrade_1170xC3_setup.sql                   			   }
{   Description:                                     			   }
{       Prepare the system for upgrading to 11.70xC3    			   }
{   Note:								   }
{       Errors encountered while executing this sql script are IGNORED.    }
{**************************************************************************}

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

{** For system tasks, remove protective bit from attributes **}
{** before deleting entry from ph_task table.               **}
UPDATE ph_task SET tk_attributes = BITANDNOT(tk_attributes, 4)
WHERE tk_name IN
( 'online_log_rotate','bar_act_log_rotate','bar_debug_log_rotate' 
 ,'autoreg exe', 'autoreg vp', 'autoreg migrate-console'
 ,'bad_index_alert','check_for_ipa'
);

DELETE FROM ph_task WHERE tk_name = 'online_log_rotate';
DELETE FROM ph_task WHERE tk_name = 'bar_act_log_rotate';
DELETE FROM ph_task WHERE tk_name = 'bar_debug_log_rotate';

DELETE FROM ph_threshold WHERE name = 'MAX_MSGPATH_VERSIONS';
DELETE FROM ph_threshold WHERE name = 'MAX_BAR_ACT_LOG_VERSIONS';
DELETE FROM ph_threshold WHERE name = 'MAX_BAR_DEBUG_LOG_VERSIONS';

DROP FUNCTION admin_message_log_rotate(INT,INT,VARCHAR(255),INT);

{ Defect idsdb00218660 - Delete bad entries from mon_table_profile with
  negative pf_isrwrite values
}
DELETE FROM mon_table_profile
    WHERE pf_isrwrite < 0 OR pf_isrwrite > 999999999999999999;

CLOSE DATABASE;
