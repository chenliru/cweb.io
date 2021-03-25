-------------------------------------------------------------------------
-- Create the Monitoring tablespace..
-------------------------------------------------------------------------
CREATE TABLESPACE db_mon NOLOGGING
DATAFILE '<path_to_datafiles_dir>/oradata/<db_name>/db_mon_01.ora' SIZE 100m AUTOEXTEND ON NEXT 10M MAXSIZE 8G
EXTENT MANAGEMENT LOCAL 
SEGMENT SPACE MANAGEMENT AUTO;

-------------------------------------------------------------------------
-- Create the Monitoring Schema..
-------------------------------------------------------------------------
create user dbmon identified by dbmon default tablespace db_mon temporary tablespace temp quota unlimited on db_mon;

-------------------------------------------------------------------------
-- Grant DBA privilege to the monitoring schema - This is a must; otherwise
-- individual privileges on dba_* views and v$sys* views must be given.
-------------------------------------------------------------------------
grant dba to dbmon;

-------------------------------------------------------------------------
-- Create the monitor directory. This is the directory where the monitoring 
-- reports will be created at. Grant read/write privileges on the directory
-- to dbamon schema.
-------------------------------------------------------------------------
CREATE OR REPLACE DIRECTORY dbmon_dir AS '/kec1fra/datapump/dbmon/<instance_name>';

GRANT READ, WRITE ON DIRECTORY dbmon_dir TO DBMON; 

-------------------------------------------------------------------------
-- Run Sequence - this is needed to keep track of the individual runs 
-- for the script. This need to be done under the "dbmon" schema.
-------------------------------------------------------------------------
CREATE SEQUENCE run_number_seq
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;
  
-------------------------------------------------------------------------
-- The "MON_INVALID_OBJECTS" table keeps track of the invalid objects
-- found in the database. The "run_number" column is based on the 
-- run_number_seq sequence.
-------------------------------------------------------------------------
CREATE TABLE mon_invalid_objects (
	run_number   NUMBER NOT NULL, 
	run_date     DATE NOT NULL,
	object_owner VARCHAR2(30),
	object_name  VARCHAR2(128),
    object_type  VARCHAR2(19));


-------------------------------------------------------------------------
-- The "MON_CATEGORY" table keeps track of the different criteria to 
-- and/or monitoring criteria in each monitoring run. Categories are 
-- ignored if their respective "enabled" column is set to "0".
-------------------------------------------------------------------------
CREATE TABLE mon_category (
	category_id   NUMBER NOT NULL UNIQUE,
	category_name VARCHAR2(30) NOT NULL,
	enabled       NUMBER(1) NOT NULL CHECK (enabled in (0,1)));

INSERT INTO mon_category VALUES (1,'SESSION_CHK',1);
INSERT INTO mon_category VALUES (2,'PROCESS_CHK',1);
INSERT INTO mon_category VALUES (3,'TBS_STATUS_CHK',1);
INSERT INTO mon_category VALUES (4,'TBS_BKUP_MD_CHK',1);
INSERT INTO mon_category VALUES (5,'DF_AVAIL_CHK',1);
INSERT INTO mon_category VALUES (6,'ARCLOG_DIR_SPC_CHK',1);
INSERT INTO mon_category VALUES (7,'REDO_LATCH_CONT_CHK',1);
INSERT INTO mon_category VALUES (8,'MEM_DISK_SORT_CHK',1);
INSERT INTO mon_category VALUES (9,'DATA_DICT_CACHE_HIT_RAT_CHK',1);
INSERT INTO mon_category VALUES (10,'BUFFER_CACHE_HIT_RAT_CHK',1);
INSERT INTO mon_category VALUES (11,'LIB_CACHE_RELOAD_RAT_CHK',1);
INSERT INTO mon_category VALUES (12,'INVALID_IDX_CHK',1);
INSERT INTO mon_category VALUES (13,'BLK_LOCK_CHK',1);
INSERT INTO mon_category VALUES (14,'TAB_LAST_ANAL_CHK',1);
INSERT INTO mon_category VALUES (15,'TAB_ANAL_NOT_IDX_CHK',1);
INSERT INTO mon_category VALUES (16,'TBS_FREE_SPC_CHK',1);
INSERT INTO mon_category VALUES (17,'INVALID_OBJ_CHK',1);
INSERT INTO mon_category VALUES (18,'SYSTEM_DEF_TBS_CHK',1);
INSERT INTO MON_CATEGORY values (19,'WAIT_EVENT_CHK',1);

COMMIT;

