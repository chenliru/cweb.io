-------------------------------------------------------------------------
-- SCRIPT             : active_db_mon_main.sql                          -
--                                                                      -
-- DESCRIPTION        : SQL script that performs a general datbasae     -
--                      health check. This script is meant to run       -
--                      periodically through a scheduelr to detect      -
--                      any issues with the running instance.           -
--                                                                      -
-- INPUT FILES        : None                                            -
--                                                                      -
-- OUTPUT FILES       : /kec1dump/datadump/db_mon/<db_name>/            -
--                      dbmon.log                                       -
--                                                                      -
-- SETUP INSTRUCTIONS : "DBMON_DIR" directory must be set and the user  -
--                      running this script must have read/write privs  -
--                      on the directory.                               -
--                                                                      -
-------------------------------------------------------------------------
-- COMMAND LINE EXECUTION:                                              -
-- Script_name     input parameters (flags)                             -
-- ----------------------------------------                             -
-- <script name>   parm1 parm2 etc showing optional parms in []         -
--                                                                      -
-- parm record layout:                                                  -
-- Parm 1 = Instance Name                                               -
--                                                                      -
-- EXAMPLE: active_db_mon_main.sql                                      -
-------------------------------------------------------------------------
--                                                                      -
-- RESTART INSTRUCTIONS: If the script dies for any reason, kill any    -
--                       background processes (kill -9 ...) and re-run  -
--                       the script.                                    -
--                                                                      -
-------------------------------------------------------------------------
-- Modification Log:                                                    -
-- Date        Name              Description                            -
-------------------------------------------------------------------------
--                                                                      -
-- Feb/07/17   Ramiz Sarah       Initial Creation                       -
-- Mar/06/17   Ramiz Sarah       Added enabled_flg checks               -
--                                                                      -
-------------------------------------------------------------------------
--
DECLARE
--
   out_file                       UTL_FILE.FILE_TYPE;
   report_flag                    boolean := false;
   enabled_flg                    number;
--
   v_mon_session                  v$resource_limit%rowtype;
   v_mon_process                  v$resource_limit%rowtype;
   utilization                    number;
   sessions_threshold             number := 0.10;
   process_threshold              number := 0.10;
--
   v_tablespace_name              dba_tablespaces.TABLESPACE_NAME%type;
   tbs_rc                         SYS_REFCURSOR;
--
   v_file_num                     v$backup.file#%type;
   v_db_file_name                 dba_data_files.file_name%type;
   df_rc                          SYS_REFCURSOR;
--
   v_df_tbs_name                  dba_data_files.tablespace_name%type;
   v_df_status                    dba_data_files.STATUS%type;
   v_file_name                    dba_data_files.file_name%type;
--
   v_arch_space_used              v$flash_recovery_area_usage.PERCENT_SPACE_USED%type;
   arch_space_threshold           number := 80;
--
   v_username                     dba_users.username%type;
   v_def_tbs                      dba_users.default_tablespace%type;
   v_tmp_tbs                      dba_users.temporary_tablespace%type;
   users_rc                       SYS_REFCURSOR;
--
   v_miss_ratio                   number;
   v_imm_miss_ratio               number;
   miss_ratio_threshold           number := 0.01;
--
   v_mem_to_disk_ratio            number;
   mem_to_disk_ratio_threshold    number := 95;
--
   v_data_dict_cache_hit_ratio    number;
   dict_cach_hit_ratio_threshold  number := 95;
--
   v_buffer_cache_hit_ratio       number;
   buf_cach_hit_ratio_threshold   number := 80;
--
   v_indx_owner                   dba_indexes.OWNER%type;
   v_indx_name                    dba_indexes.INDEX_NAME%type;
   v_indx_tab_name                dba_indexes.TABLE_NAME%type;
   index_rc                       SYS_REFCURSOR;
--
   v_lib_cache_miss_ratio         number;
   lib_cache_miss_ratio_threshold number := 1;
--
   v_sid                          v$session.sid%type;
   v_serial                       v$session.serial#%type;
   v_blocking_session_status      v$session.blocking_session_status%type;
   v_blocking_session             v$session.blocking_session%type;
   v_seconds_in_wait              v$session.seconds_in_wait%type;
   sess_rc                        SYS_REFCURSOR;
--
   v_tab_owner                    dba_tables.owner%type;
   v_tab_name                     dba_tables.table_name%type;
   v_last_analyzed                dba_tables.last_analyzed%type;
   tab_last_anl_rc                SYS_REFCURSOR;
   last_analyzed_threshold        number := 7;
--
   v_ind_owner                    dba_indexes.owner%type;
   v_ind_name                     dba_indexes.index_name%type;
   v_ind_tab_owner                dba_indexes.table_owner%type;
   v_ind_tab_name                 dba_indexes.table_name%type;
   ind_last_anl_rc                SYS_REFCURSOR;
--
   v_tbs_name                     dba_tablespaces.tablespace_name%type;
   v_tbs_space_perc_used          number;
   tbs_free_space_threshold       number := 10;
   tbs_free_space_rc              SYS_REFCURSOR;
--
   v_inv_obj_owner                dba_objects.OWNER%type;
   v_inv_obj_name                 dba_objects.OBJECT_NAME%type;
   v_inv_obj_type                 dba_objects.OBJECT_TYPE%type;
   v_run_number                   number;
   inv_obj_rc                     SYS_REFCURSOR;
--
   run_number_next_val            number;
   v_seq_run_num                  number;
--
   v_event                        v$system_event.EVENT%TYPE;
   v_total_percent                number;
   wait_event_threshold           number := 40;
   wait_event_rc                  SYS_REFCURSOR;
--
BEGIN
--
   out_file := UTL_FILE.FOPEN('DBMON_DIR', 'dbmon.log', 'W');
--
-------------------------------------------------------------------------
-- Session Information
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'SESSION_CHK';

IF enabled_flg = 1 THEN
   SELECT *
   INTO v_mon_session
   FROM v$resource_limit
   WHERE resource_name = 'sessions';
--
-- Check against the max utilization, report if we're within 10% of reaching
-- max utilization
--
   utilization := v_mon_session.MAX_UTILIZATION * sessions_threshold;
--
   IF v_mon_session.CURRENT_UTILIZATION > (v_mon_session.MAX_UTILIZATION - utilization) THEN
     --dbms_output.put_line('Number of Sessions used are within 10% of Max Utilization');
     report_flag := true;
     UTL_FILE.PUT_LINE(out_file , 'Number of Sessions used are within '||sessions_threshold*100||'% of Max Utilization');
   END IF;
END IF;
--
-------------------------------------------------------------------------
-- Process Information
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'PROCESS_CHK';

IF enabled_flg = 1 THEN
   SELECT *
   INTO v_mon_process
   FROM v$resource_limit
   WHERE resource_name = 'processes';
--
-- Check against the max utilization, report if we're within 10% of reaching
-- process max utilization
--
   utilization := v_mon_process.MAX_UTILIZATION * process_threshold;
--
   IF v_mon_process.CURRENT_UTILIZATION > (v_mon_process.MAX_UTILIZATION - utilization) THEN
     --dbms_output.put_line('Number of Processes used are within 10% of Max Utilization');
     report_flag := true;
     UTL_FILE.PUT_LINE(out_file , 'Number of Processes used are within '||process_threshold*100||'% of Max Utilization');
   END IF;
END IF;
--
-------------------------------------------------------------------------
-- Check Tablespace Status - report if status is "OFFLINE".
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'TBS_STATUS_CHK';

IF enabled_flg = 1 THEN
   OPEN tbs_rc FOR SELECT tablespace_name 
                   FROM dba_tablespaces 
                   WHERE status ='OFFLINE' 
                   ORDER BY tablespace_name;
--
   LOOP
     FETCH tbs_rc INTO v_tablespace_name;
     EXIT
   WHEN tbs_rc%NOTFOUND; -- Exit the loop when we've run out of data
     IF tbs_rc%found THEN
       report_flag := true;
       UTL_FILE.PUT_LINE(out_file, 'Tablespace '||v_tablespace_name||' is OFFLINE');
       --   dbms_output.put_line('Tablespace '||v_tablespace_name||' is OFFLINE');
     END IF;
   END LOOP;
   CLOSE tbs_rc;
END IF;
--
-------------------------------------------------------------------------
-- Check Tablespace in backup mode - Status is "ACTIVE".
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'TBS_BKUP_MD_CHK';

IF enabled_flg = 1 THEN
   OPEN df_rc FOR SELECT b.file#, df.file_name
                  FROM v$backup b, dba_data_files df 
                  WHERE b.file# = df.file_id 
                    AND b.status='ACTIVE';
--
   LOOP
     FETCH df_rc INTO v_file_num , v_db_file_name;
     EXIT
   WHEN df_rc%NOTFOUND; -- Exit the loop when we've run out of data
     IF df_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, 'Datafile '||v_db_file_name||' is in ACTIVE backup mode');
       -- dbms_output.put_line('Datafile '||v_db_file_name||' is in ACTIVE backup mode');
     END IF;
   END LOOP;
   CLOSE df_rc;
END IF;
--
-------------------------------------------------------------------------
-- Datafiles - Status should be set to "AVAILABLE", report otherwise.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'DF_AVAIL_CHK';

IF enabled_flg = 1 THEN
   OPEN df_rc FOR SELECT TABLESPACE_NAME, FILE_NAME, STATUS 
                  FROM dba_data_files 
                  WHERE status != 'AVAILABLE' 
                  ORDER BY TABLESPACE_NAME, FILE_NAME;
--
   LOOP
     FETCH df_rc INTO v_df_tbs_name , v_file_name, v_df_status;
     EXIT
   WHEN df_rc%NOTFOUND; -- Exit the loop when we've run out of data
     IF df_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, 'Datafile '||v_file_name||' status is '||v_df_status||'. Status should be AVAILABLE');
       -- dbms_output.put_line(v_df_tbs_name||'   '||v_file_name||'   '||v_df_status);
     END IF;
   END LOOP;
   CLOSE df_rc;
END IF;
--
-------------------------------------------------------------------------
-- Free space avaialable in the Archivelog and Flashback Directories.
-- Report if defined thrashold reached.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'ARCLOG_DIR_SPC_CHK';

IF enabled_flg = 1 THEN
   SELECT SUM(percent_space_used)
   INTO v_arch_space_used
   FROM v$flash_recovery_area_usage;
--
   IF v_arch_space_used > arch_space_threshold THEN
     report_flag     := TRUE;
     -- dbms_output.put_line('Archive free space directory is '||v_arch_space_used||'% full!');
   END IF;
END IF;
--
-- Oracle User Ids with SYSTEM as their default/temp tablespaces
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'SYSTEM_DEF_TBS_CHK';

IF enabled_flg = 1 THEN
   OPEN users_rc FOR SELECT  username, default_tablespace, temporary_tablespace
                     FROM  dba_users
                     WHERE username NOT IN ('SYS','SYSTEM','OUTLN','MGMT_VIEW')
                       AND default_tablespace = 'SYSTEM'
                        OR temporary_tablespace = 'SYSTEM'
                     ORDER BY username;
--
   LOOP
     FETCH users_rc INTO v_username , v_def_tbs, v_tmp_tbs;
     EXIT
   WHEN users_rc%NOTFOUND; 
     IF users_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, 'Username '||v_username||' default tablespace '||v_def_tbs||' temporary tablespace '||v_tmp_tbs);
       -- dbms_output.put_line('Username '||v_username||' default tablespace '||v_def_tbs||' temporary tablespace '||v_tmp_tbs);
     END IF;
   END LOOP;
   CLOSE users_rc;
END IF;
--
-------------------------------------------------------------------------
-- Oracle Redo Latch Contention
-- If the ratio of MISSES to GETS exceeds 1%, or the ratio of 
-- IMMEDIATE_MISSES to (IMMEDIATE_GETS + IMMEDIATE_MISSES) exceeds 1%, 
-- there is latch contention.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'REDO_LATCH_CONT_CHK';

IF enabled_flg = 1 THEN
    SELECT 
       (misses / decode(gets,0,gets+1,gets)) * 100,
       (immediate_misses)/decode(immediate_gets+immediate_misses,0,immediate_gets+immediate_misses+1,immediate_gets+immediate_misses) * 100
    INTO v_miss_ratio, v_imm_miss_ratio
    FROM v$latch l, v$latchname ln 
    WHERE ln.name = 'redo allocation' 
      AND ln.latch# = l.latch#; 
--
    IF v_miss_ratio > miss_ratio_threshold OR v_imm_miss_ratio > miss_ratio_threshold THEN
      report_flag    := TRUE;
      IF v_miss_ratio > miss_ratio_threshold THEN
         UTL_FILE.PUT_LINE(out_file, 'Redo ratio of MISSES to GETS exceeds '||miss_ratio_threshold*100||'%');
         -- dbms_output.put_line('Redo ratio of MISSES to GETS exceeds '||miss_ratio_threshold*100||'%');
      ELSIF v_imm_miss_ratio > miss_ratio_threshold THEN
         UTL_FILE.PUT_LINE(out_file, 'Redo  ratio of IMMEDIATE_MISSES to (IMMEDIATE_GETS + IMMEDIATE_MISSES) exceeds '||miss_ratio_threshold*100||'%');
         -- dbms_output.put_line('Redo  ratio of IMMEDIATE_MISSES to (IMMEDIATE_GETS + IMMEDIATE_MISSES) exceeds '||miss_ratio_threshold*100||'%');
      END IF;
    END IF;
END IF;
--   
-------------------------------------------------------------------------
-- In memory and disk sorts - Ratio of disk sorts to memory sorts should 
-- be less than 5%.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'MEM_DISK_SORT_CHK';

IF enabled_flg = 1 THEN
    SELECT round((100*b.value)/decode((a.value+b.value),0,1,(a.value+b.value)),2)
    INTO  v_mem_to_disk_ratio
    FROM  v$sysstat a, v$sysstat b
    WHERE a.name = 'sorts (disk)' and b.name = 'sorts (memory)';
--
    IF v_mem_to_disk_ratio < mem_to_disk_ratio_threshold THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, 'Ratio of disk sorts to Memory sorts exceeds '||mem_to_disk_ratio_threshold||'%');
       -- dbms_output.put_line('Ratio of disk sorts to Memory sorts exceeds 5%');
    END IF;
END IF;
--
-------------------------------------------------------------------------
-- Data dictionary cache hit ratio
-- Hit ratio should be over 95% (miss ratio below below 5%) to keep the 
-- data dictionary cached in the SGA.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'DATA_DICT_CACHE_HIT_RAT_CHK';

IF enabled_flg = 1 THEN
   SELECT round((1-(sum(getmisses)/sum(gets)))*100,2)
   INTO v_data_dict_cache_hit_ratio
   FROM v$rowcache;
--
   IF v_data_dict_cache_hit_ratio < dict_cach_hit_ratio_threshold THEN
      report_flag := TRUE;
      UTL_FILE.PUT_LINE(out_file, 'Data dictionary cache hit ratio is less than'||dict_cach_hit_ratio_threshold||'%');
      -- dbms_output.put_line('Data dictionary cache hit ratio is less than'||dict_cach_hit_ratio_threshold||'%');
   END IF;
END IF;
--
-------------------------------------------------------------------------
-- Buffer cache hit ratio.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'BUFFER_CACHE_HIT_RAT_CHK';

IF enabled_flg = 1 THEN
   SELECT ((cur.value+con.value)/(( cur.value+con.value)+phy.value))*100 
   INTO  v_buffer_cache_hit_ratio
   FROM  v$sysstat cur, v$sysstat con, v$sysstat phy
   WHERE cur.name = 'db block gets' 
     AND con.name = 'consistent gets' 
     AND phy.name = 'physical reads';
--
   IF v_buffer_cache_hit_ratio < buf_cach_hit_ratio_threshold THEN
      report_flag := TRUE;
      UTL_FILE.PUT_LINE(out_file, 'Buffer cache hit ratio '||v_buffer_cache_hit_ratio||' is less than '||buf_cach_hit_ratio_threshold||'% threshold');
      -- dbms_output.put_line('Buffer cache hit ratio '||v_buffer_cache_hit_ratio||' is less than '||buf_cach_hit_ratio_threshold||'% threshold');
   END IF;
END IF;
--
-------------------------------------------------------------------------
-- Library cache reload ratio
-- This ratio should be very low (< 1.0) indicating that the library cache 
-- is large enough.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'LIB_CACHE_RELOAD_RAT_CHK';

IF enabled_flg = 1 THEN
   SELECT (((sum(reloads)/sum(pins))))
   INTO v_lib_cache_miss_ratio
   FROM v$librarycache; 
--
   IF v_lib_cache_miss_ratio >= lib_cache_miss_ratio_threshold THEN
      report_flag := TRUE;
      UTL_FILE.PUT_LINE(out_file, 'Library Cache Miss Ratio is more than '||lib_cache_miss_ratio_threshold||'% threshold');
      -- dbms_output.put_line('Library Cache Miss Ratio is more than '||lib_cache_miss_ratio_threshold||'% threshold');
   END IF;
END IF;
--
-------------------------------------------------------------------------
-- Invlid Indexes - Indexes that are in an unusable state; Investigate 
-- urgently if any exists.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'INVALID_IDX_CHK';

IF enabled_flg = 1 THEN
   OPEN index_rc FOR SELECT owner, index_name, table_name
                     FROM dba_indexes
                     WHERE status='UNUSABLE'
                     ORDER BY owner,index_name;
  --
   LOOP
     FETCH index_rc INTO v_indx_owner , v_indx_name, v_indx_tab_name;
     EXIT
   WHEN index_rc%NOTFOUND; 
     IF index_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, 'Index '||v_indx_owner||'.'||v_indx_name||' on table '||v_indx_tab_name||' is in UNUSABLE state');
       -- dbms_output.put_line('Index '||v_indx_owner||'.'||v_indx_name||' on table '||v_indx_tab_name||' is in UNUSABLE state');
     END IF;
   END LOOP;
   CLOSE index_rc;
END IF;
--
-------------------------------------------------------------------------
-- Blocking Locks Information
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'BLK_LOCK_CHK';

IF enabled_flg = 1 THEN
   OPEN sess_rc FOR SELECT blocking_session, sid, serial#, blocking_session_status, seconds_in_wait
                    FROM   v$session
                    WHERE  blocking_session IS NOT NULL
                    ORDER BY blocking_session;
--
   LOOP
     FETCH sess_rc INTO v_blocking_session, v_sid, v_serial, v_blocking_session_status, v_seconds_in_wait;
     EXIT
   WHEN sess_rc%NOTFOUND; 
     IF sess_rc%found THEN
       report_flag := TRUE;
	    IF v_seconds_in_wait > 0 THEN
	       UTL_FILE.PUT_LINE(out_file, 'Session '||v_blocking_session||' has been blocking session ['||v_sid||','||v_serial||'] for '||v_seconds_in_wait||' seconds');
		   --dbms_output.put_line('Session '||v_blocking_session||' has been blocking session ['||v_sid||','||v_serial||'] for '||v_seconds_in_wait||' seconds');
	    ELSE
	       UTL_FILE.PUT_LINE(out_file, 'Session '||v_blocking_session||' is blocking session ['||v_sid||','||v_serial||']');
		   --dbms_output.put_line('Session '||v_blocking_session||' is blocking session ['||v_sid||','||v_serial||']');
	    END IF;
	 END IF;
   END LOOP;
   CLOSE sess_rc;
END IF;
--
-------------------------------------------------------------------------
-- Displays Tables Last Analyzed Details for none system/oracle shipped 
-- schemas.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'TAB_LAST_ANAL_CHK';

IF enabled_flg = 1 THEN
   OPEN tab_last_anl_rc FOR SELECT owner, table_name, last_analyzed
                            FROM dba_tables 
                            WHERE owner not in ('SYS', 'SYSTEM','SYSMAN','MDSYS','DIP','TSMSYS','MGMT_VIEW','OUTLN','ORDDATA',
                                                'EXFSYS','DBSNMP','XDB','WMSYS','ANONYMOUS','XS$NULL','CTXSYS','DMSYS','ORDSYS',
                                                'OLAPSYS','PERFSTAT','SCOTT','APEX_030200','APPQOSSYS','FLOWS_FILES','OWBSYS')
                              AND   last_analyzed <= sysdate - last_analyzed_threshold
                            ORDER BY owner, last_analyzed, table_name;
--
   LOOP
     FETCH tab_last_anl_rc INTO v_tab_owner, v_tab_name, v_last_analyzed;
     EXIT
   WHEN tab_last_anl_rc%NOTFOUND; 
     IF tab_last_anl_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, ' Table '||v_tab_owner||'.'||v_tab_name||' has not been analyzed for more than '||last_analyzed_threshold||' days');
       -- dbms_output.put_line(' Table '||v_tab_owner||'.'||v_tab_name||' has not been analyzed for more than '||last_analyzed_threshold||' days');
     END IF;
   END LOOP;
   CLOSE tab_last_anl_rc;
END IF;  
--
-------------------------------------------------------------------------
-- Displays Tables that have been analyzed but their indexes havn't.. The 
-- query excludes all SYS like schemas and oracle standard schemas.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'TAB_ANAL_NOT_IDX_CHK';

IF enabled_flg = 1 THEN
   OPEN ind_last_anl_rc FOR SELECT i.owner,i.index_name,i.table_name, i.table_owner
                              FROM dba_tables t, dba_indexes i
                             WHERE t.table_name = i.table_name
                               AND t.num_rows IS NOT NULL
                               AND i.distinct_keys IS NULL
                               AND t.owner NOT IN ('SYS', 'SYSTEM','SYSMAN','MDSYS','DIP','TSMSYS','MGMT_VIEW','OUTLN',
                                                   'EXFSYS','DBSNMP','XDB','WMSYS','ANONYMOUS','XS$NULL','CTXSYS','DMSYS',
                                                   'OLAPSYS','PERFSTAT','SCOTT','APEX_030200','APPQOSSYS','FLOWS_FILES',
                                                   'ORDDATA','ORDSYS','OWBSYS')
                               AND i.table_name NOT LIKE 'SYS_EXPORT_%';
--
   LOOP
     FETCH ind_last_anl_rc INTO v_ind_owner, v_ind_name, v_ind_tab_owner, v_ind_tab_name;
     EXIT
   WHEN ind_last_anl_rc%NOTFOUND; 
     IF ind_last_anl_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, ' Table '||v_ind_tab_owner||'.'||v_ind_tab_name||' has been analyzed but its index '||v_ind_owner||'.'||v_ind_name||' hasnt been');
       -- dbms_output.put_line(' Table '||v_tab_owner||'.'||v_tab_name||' has not been analyzed for more than '||last_analyzed_threshold||' days');
     END IF;
   END LOOP;
   CLOSE ind_last_anl_rc; 
END IF;
--
-------------------------------------------------------------------------
-- Check tablespaces free space utilization 
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'TBS_FREE_SPC_CHK';

IF enabled_flg = 1 THEN
   OPEN tbs_free_space_rc FOR 
							SELECT a.tablespace_name
								,(nvl(b.tot_used, 0) / a.bytes_alloc) * 100
							FROM (
								SELECT tablespace_name
									,sum(bytes) physical_bytes
									,sum(decode(autoextensible, 'NO', bytes, 'YES', maxbytes)) bytes_alloc
								FROM dba_data_files
								GROUP BY tablespace_name
								) a
								,(
									SELECT tablespace_name
										,sum(bytes) tot_used
									FROM dba_segments
									GROUP BY tablespace_name
									) b
							WHERE a.tablespace_name = b.tablespace_name(+)
								AND a.tablespace_name NOT IN (
									SELECT DISTINCT tablespace_name
									FROM dba_temp_files
									)
								AND a.tablespace_name NOT LIKE 'UNDO%'
							ORDER BY 1; 
--
   LOOP
     FETCH tbs_free_space_rc INTO v_tbs_name, v_tbs_space_perc_used;
     EXIT
   WHEN tbs_free_space_rc%NOTFOUND; 
     IF tbs_free_space_rc%found THEN
        IF (100 - v_tbs_space_perc_used <= tbs_free_space_threshold) THEN
           report_flag := TRUE;
           UTL_FILE.PUT_LINE(out_file, 'Tablespace '||v_tbs_name||' free space is less than '||tbs_free_space_threshold||'% threshold');
           -- dbms_output.put_line(' Tablespace '||v_tbs_name||' free space '||v_tbs_free_space ||'% is less than '||tbs_free_space_threshold||'% threshold');
        END IF;
     END IF;
   END LOOP;
   CLOSE tbs_free_space_rc;
END IF;
--
-------------------------------------------------------------------------
-- Find out if any objects have become invalid since the last monitor run.
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'INVALID_OBJ_CHK';

IF enabled_flg = 1 THEN
--
-- Get the last run details using the sequence
--
   SELECT MAX(RUN_NUMBER) INTO v_run_number FROM mon_invalid_objects;
--
-- We're only interested if DBA_OBJECTS has more INVALID objects than 
-- mon_invalid_objects.
--
   OPEN inv_obj_rc FOR SELECT owner, object_name, object_type FROM dba_objects WHERE status = 'INVALID' 
                       MINUS 
                       SELECT object_owner, object_name, object_type FROM mon_invalid_objects WHERE RUN_NUMBER = v_run_number;
--
   LOOP
      FETCH inv_obj_rc INTO v_inv_obj_owner, v_inv_obj_name, v_inv_obj_type;
      EXIT
   WHEN inv_obj_rc%NOTFOUND; 
      IF inv_obj_rc%found THEN
         UTL_FILE.PUT_LINE(out_file, v_inv_obj_type||' '||v_inv_obj_owner||'.'||v_inv_obj_name||' has become invalid; please investigate!');
         -- dbms_output.put_line(v_inv_obj_type||' '||v_inv_obj_owner||'.'||v_inv_obj_name||' has become invalid; please investigate!');	
      END IF;
   END LOOP;
   CLOSE inv_obj_rc;
--
-- Insert the current invalid objects details into the mon_invalid_objects
-- table to be used for the next run.
--
   SELECT run_number_seq.nextval INTO v_seq_run_num FROM DUAL;
--
   INSERT INTO mon_invalid_objects (
      run_number, 
      run_date,
      object_owner,
      object_name, 
      object_type) 
   SELECT v_seq_run_num,
         sysdate,
         owner, 
         object_name, 
         object_type
   FROM dba_objects
   WHERE status = 'INVALID';
END IF;
--  
   COMMIT;
--
-------------------------------------------------------------------------
--
-- Summary of waits from v$system_event (Wait % > X%)
-------------------------------------------------------------------------
--
SELECT ENABLED INTO enabled_flg FROM mon_category WHERE category_name = 'WAIT_EVENT_CHK';

IF enabled_flg = 1 THEN
   OPEN wait_event_rc FOR SELECT event, round((time_waited / total_waittime) * 100, 2)
                            FROM v$system_event SE
	                           ,(
		                         SELECT SUM(time_waited) total_waittime
		                           FROM v$system_event
		                          WHERE wait_class NOT IN ('Idle','Network')
		                        ) TOT
                           WHERE total_waits > 0
	                         AND time_waited > 1000
	                         AND wait_class NOT IN ('Idle','Network')
	                         AND (time_waited / total_waittime) * 100 >= wait_event_threshold;
  --
   LOOP
     FETCH wait_event_rc INTO v_event , v_total_percent;
     EXIT
   WHEN wait_event_rc%NOTFOUND; 
     IF wait_event_rc%found THEN
       report_flag := TRUE;
       UTL_FILE.PUT_LINE(out_file, 'Wait Event '||v_event||' total wait time exceeds the setup threshold');
       -- dbms_output.put_line('Wait Event '||v_event||' total wait time exceeds the setup threshold');
     END IF;
   END LOOP;
   CLOSE wait_event_rc;
END IF;
--
   UTL_FILE.FCLOSE(out_file);
END;
/