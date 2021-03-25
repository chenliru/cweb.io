{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2001, 2011. All rights reserved.        *}
{*                                                                        *}
{**************************************************************************}

DATABASE sysadmin;

{*********************************************************
 *
 *  The following section load all the parameters
 *    utilized by AUS
 *
 ********************************************************
 *}

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"AUS_AGE","Auto Update Statistics Evaluation","30","NUMERIC(6.2)",
"The statistics are rebuilt after this many days.");

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"AUS_CHANGE","Auto Update Statistics Evaluation","10","NUMERIC",
"The statistics are rebuilt after this percentage of data has changed.");


INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"AUS_AUTO_RULES","Auto Update Statistics Evaluation","1","NUMERIC",
"Ensures a base set of guidelines are followed when building statistics.");

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"AUS_SMALL_TABLES","Auto Update Statistics Evaluation","100","NUMERIC",
"Tables containing less than this number of rows will always have their statistics rebuilt.");

INSERT INTO ph_threshold
(id,name,task_name,value,value_type,description)
VALUES
(0,"AUS_PDQ","Auto Update Statistics Refresh","10","NUMERIC",
"Update statistics executes with this PDQ priority.");


{*********************************************************
 *
 *  The following section creates all the procedures
 *    utilized by AUS
 *
 ********************************************************
 *}

CREATE FUNCTION aus_get_realtime()
   RETURNING DATETIME YEAR TO SECOND
DEFINE cur_time DATETIME YEAR TO SECOND;

   LET cur_time = (SELECT
        DBINFO( 'utc_to_datetime',sh_curtime)::DATETIME YEAR TO SECOND
        FROM sysmaster:sysshmvals);

   RETURN cur_time;
END FUNCTION;


CREATE FUNCTION aus_setup_mon_table_profile(task_id INTEGER, task_seq INTEGER,
                                            inHDRmode INTEGER)
   RETURNING INTEGER
DEFINE task_cnt     INTEGER;
DEFINE index_cnt    INTEGER;
--TRACE "FUNCTION aus_setup_mon_table_profile()" ;



   -- Make sure the task mon_table_profile is there an active
   SELECT count(*) 
        INTO task_cnt
        FROM ph_task
        WHERE tk_name ="mon_table_profile";

   -- Check to see if index exists on (id,partnum)

    SELECT count(*) 
        INTO index_cnt
        FROM sysindices
        WHERE tabid = ( SELECT tabid FROM systables 
                        WHERE tabname = "mon_table_profile" )
        AND ABS(ikeyextractcolno(indexkeys,0)) =
            ( SELECT colno FROM syscolumns
              WHERE tabid = ( SELECT tabid FROM systables 
                              WHERE tabname = "mon_table_profile"
                            ) 
              AND colname ='id'
            )
        AND ABS(ikeyextractcolno(indexkeys,1)) =
            ( SELECT colno FROM syscolumns
              WHERE tabid = ( SELECT tabid FROM systables 
                              WHERE tabname = "mon_table_profile"
                            ) 
              AND colname ='partnum'
            );


   IF task_cnt < 1 THEN
          INSERT INTO ph_alert
              (ID, alert_task_id,alert_task_seq,alert_type,
               alert_color, alert_object_type,
               alert_object_name, alert_message,alert_action)
           VALUES
              (0,task_id, task_seq, "WARNING", "green", 
              "SERVER","Auto Update Statistics",
              "Built in server task (mon_table_profile) is missing. " ||
              "Auto Update Statistics proceeding with limited information.",
                NULL);
       RETURN -1;
   END IF;

   IF index_cnt < 1 THEN
          INSERT INTO ph_alert
              (ID, alert_task_id,alert_task_seq,alert_type,
               alert_color, alert_object_type,
               alert_object_name, alert_message,alert_action)
           VALUES
              (0,task_id, task_seq, "INFO", "green", 
              "SERVER","Auto Update Statistics",
              "Building index on table mon_table_profile to optimize performance for Auto Update Statistics." ,
                NULL);

       IF inHDRmode = 1 THEN
          CREATE INDEX mon_table_profile_sys_ix1 
              ON mon_table_profile(id,partnum) ONLINE;
       ELSE
         CREATE INDEX mon_table_profile_sys_ix1 
              ON mon_table_profile(id,partnum);
       END IF;

   END IF;


   RETURN 1;
END FUNCTION;

CREATE FUNCTION aus_get_exclusive_access(task_id INTEGER, task_seq INTEGER)
   RETURNING INTEGER
DEFINE errnum          INTEGER;
DEFINE cnt             INTEGER;
DEFINE lk_sid          INTEGER;
--TRACE "FUNCTION aus_get_exclusive_access()" ;

    BEGIN
        ON EXCEPTION IN ( -310 ) SET errnum
            SELECT count(*) , MAX(aus_lk_sid)
               INTO cnt, lk_sid
               FROM aus_work_lock, sysmaster:sysscblst
               WHERE aus_lk_sid     = sid
               AND aus_lk_task_id  = task_id
               AND aus_lk_task_seq = task_seq;

--TRACE "CNT = " || cnt || "lock SID = "||lk_sid;
            IF cnt > 0 THEN
                RAISE EXCEPTION -777, -107,
                      "Current AUS tables are in use by Session ID "||lk_sid;
            END IF
            -- Fall through if count equal zero
            DELETE FROM aus_work_lock;

        END EXCEPTION WITH RESUME

        CREATE TABLE aus_work_lock (
                aus_lk_sid      INTEGER,
                aus_lk_task_id  INTEGER,
                aus_lk_task_seq INTEGER );
        INSERT INTO aus_work_lock(aus_lk_sid,aus_lk_task_id,aus_lk_task_seq)
                VALUES
               (DBINFO('sessionid'),task_id,task_seq);
    END

    RETURN 0;
END FUNCTION;


CREATE FUNCTION aus_rel_exclusive_access()
   RETURNING INTEGER
--TRACE "FUNCTION aus_rel_exclusive_access()" ;
   BEGIN
        ON EXCEPTION IN ( -206, -310 ) 
        END EXCEPTION
   DROP TABLE aus_work_lock;
   END

   RETURN 0;
END FUNCTION;

CREATE FUNCTION aus_cleanup_table( save_results INTEGER )
   RETURNING INTEGER
DEFINE errnum          INTEGER;
DEFINE cnt             INTEGER;
--TRACE "FUNCTION aus_cleanup_table()" ;

    IF save_results = 0 THEN
       SELECT COUNT(*) 
       INTO cnt 
       FROM ph_task 
       WHERE BITAND(tk_attributes, '0x200' ) > 0
       AND tk_name like "Auto Update Statistics Refresh%"
       AND tk_next_execution <= ( SELECT tk_next_execution
                                  FROM ph_task
                                  WHERE tk_name = "Auto Update Statistics Evaluation");

       IF cnt > 0 THEN
          RAISE EXCEPTION -214, -107, "Current AUS tables are in use";
       END IF
    END IF
    /*  Cleanup all the work tables */
    BEGIN
        ON EXCEPTION IN ( -214, -206, -394 ) SET errnum    
            -- non-exclusive access, & table does not exist
            IF errnum = -214 THEN
                RAISE EXCEPTION -214, -107, "Current AUS tables are in use";
            END IF
            -- If error is -206 ignore the error, tables have been dropped
        END EXCEPTION WITH RESUME

        DROP TABLE aus_work_icols;
        DROP TABLE aus_work_dist;
        DROP TABLE aus_work_info;
        IF save_results == 0 THEN
            DROP TABLE aus_work_icols;
            DROP TABLE aus_work_dist;
            DROP TABLE aus_work_info;
            DROP TABLE aus_cmd_info;
            DROP VIEW aus_cmd_list;
            DROP VIEW aus_cmd_comp;
            DROP TABLE aus_command;  -- drop views also
        END IF
    END

    RETURN 1;

END FUNCTION;


CREATE FUNCTION aus_setup_table(inHDRmode INTEGER)
   RETURNING integer
DEFINE errnum          INTEGER;

--TRACE "FUNCTION aus_setup_table()" ;

    /*  Cleanup all the work tables */
    BEGIN
        ON EXCEPTION IN ( -310 ) SET errnum    -- table already exists
        END EXCEPTION WITH RESUME


        CREATE TABLE aus_cmd_info
           (
           aus_ci_dbs_partnum     INTEGER,
           aus_ci_stime           DATETIME YEAR TO SECOND
                                  DEFAULT CURRENT YEAR TO SECOND,
           aus_ci_etime           DATETIME YEAR TO SECOND
                                  DEFAULT NULL,
           aus_ci_database        VARCHAR(255) DEFAULT NULL,
           aus_ci_locale          VARCHAR(36)  DEFAULT NULL,
           aus_ci_logmode         CHAR(1)   DEFAULT NULL,
           aus_ci_missed_tables   INTEGER   DEFAULT 0,
           aus_ci_need_tables     INTEGER   DEFAULT 0,
           aus_ci_done_tables     INTEGER   DEFAULT 0
           );

        INSERT INTO aus_cmd_info(aus_ci_dbs_partnum,aus_ci_stime) 
                  VALUES (0,aus_get_realtime());

        IF inHDRmode = 1 THEN
           CREATE UNIQUE INDEX aus_cmd_info_index1 
               ON aus_cmd_info(aus_ci_dbs_partnum) ONLINE;
           CREATE UNIQUE INDEX aus_cmd_info_index2 
               ON aus_cmd_info(aus_ci_database) ONLINE;
        ELSE
           CREATE UNIQUE INDEX aus_cmd_info_index1 
               ON aus_cmd_info(aus_ci_dbs_partnum);
           CREATE UNIQUE INDEX aus_cmd_info_index2 
               ON aus_cmd_info(aus_ci_database);
        END IF;

        CREATE TABLE aus_command
           (
           aus_cmd_id             SERIAL,
           aus_cmd_state          CHAR(1) DEFAULT 'P'
                                  CHECK (aus_cmd_state IN ("P","I","E","C")),
                                  -- P => Command is pending
                                  -- I => Command is inprogress
                                  -- E => Command had an Error
                                  -- C => Command is complete w/o Errors
           aus_cmd_type           CHAR(1), 
           aus_cmd_priority       BIGINT,
           aus_cmd_dbs_partnum    INTEGER,
           aus_cmd_partnum        INTEGER,
           aus_cmd_err_sql        INTEGER,
           aus_cmd_err_isam       INTEGER,
           aus_cmd_time           DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND,
           aus_cmd_runtime        INTERVAL HOUR TO SECOND DEFAULT NULL,
           aus_cmd_exe            LVARCHAR(8192)
           ) LOCK MODE ROW;
        CREATE VIEW aus_cmd_list AS SELECT
           aus_cmd_id, aus_cmd_type,
           aus_cmd_priority, aus_cmd_dbs_partnum,
           aus_cmd_partnum, aus_cmd_exe
           FROM aus_command
           WHERE aus_cmd_state = 'P';
        CREATE VIEW aus_cmd_comp AS SELECT
           aus_cmd_id,   aus_cmd_type,
           aus_cmd_priority, aus_cmd_dbs_partnum,
           aus_cmd_partnum,  aus_cmd_exe,
           aus_cmd_time           
           FROM aus_command
           WHERE aus_cmd_state = 'C';
    END

    BEGIN
       ON EXCEPTION IN ( -310 ) SET errnum    -- table already exists


       END EXCEPTION WITH RESUME

       /*
        *  This table contains both
        *   index columns as wells as
        *   user defined distribution columns
        */
       CREATE TABLE aus_work_icols
         (
         aus_icols_tabid        integer,
         aus_icols_colno        integer,
         aus_icols_lkey         char(1) CHECK( aus_icols_lkey IN ('Y','N')),
         aus_icols_mode         char(1) DEFAULT NULL,
         aus_icols_colname      varchar(128)
         ) LOCK MODE ROW;

       CREATE TABLE aus_work_info
         (
         aus_info_id          SERIAL,
         aus_info_db_partnum  INTEGER,
         aus_info_tabname     VARCHAR(128),
         aus_info_tabid       INTEGER,
         aus_info_partnum     INTEGER,
         aus_info_ustlowts    DATETIME YEAR TO SECOND,
         aus_info_npused      BIGINT,
         aus_info_nrows       BIGINT,
         aus_info_nindexes    smallint
         ) LOCK MODE ROW;

       CREATE TABLE aus_work_dist
          (
          aus_dist_id          serial,
          aus_dist_tabid       INTEGER,      -- this is the tabid
          aus_dist_colno       INTEGER,
          aus_dist_mode        CHAR(1),
          aus_dist_resolution  FLOAT,
          aus_dist_confidence  FLOAT,
          aus_dist_smplsize    float,
          aus_dist_rowssmplde  BIGINT,
          aus_dist_constr_time DATETIME YEAR TO SECOND,
          aus_dist_ustnrows    BIGINT
          ) LOCK MODE ROW;

    END

    RETURN 1;

END FUNCTION;


CREATE FUNCTION aus_refresh_stats_orig( )
   RETURNING integer

DEFINE rc            INTEGER;
DEFINE cnt           INTEGER;
DEFINE i             INTEGER;

    LET rc=1;
    LET i=1;

    WHILE ( rc <> 0 ) LOOP
        LET rc = aus_refresh_stats_orig(-1,i);
        LET i=i+1;
    END LOOP;

   RETURN rc;

END FUNCTION;


CREATE FUNCTION aus_refresh_stats_orig(task_id INTEGER, task_seq INTEGER)
   RETURNING integer

DEFINE rc            INTEGER;
DEFINE cnt           INTEGER;
DEFINE del           INTEGER;
DEFINE t_partnum     INTEGER;
DEFINE last_partnum  INTEGER;
DEFINE t_dbs_partnum INTEGER;
DEFINE last_dbs_partnum INTEGER;
DEFINE t_id          INTEGER;
DEFINE t_type        CHAR(1);
DEFINE t_cmd         CHAR(8192);
DEFINE p_cmd         CHAR(200);
DEFINE t_priority    BIGINT;
DEFINE param_pdq     INTEGER;

--TRACE "FUNCTION aus_refresh_stats_orig";
    LET rc  = 0;
    LET cnt = 0;
    LET del = 0;
    LET last_partnum = 0;
    LET t_partnum = NULL;

--SET DEBUG FILE TO "/tmp/aus.refresh."||task_seq;
--TRACE ON;

     -- Get the config thresholds
    SELECT MAX(value::integer) INTO param_pdq
           FROM sysadmin:ph_threshold WHERE name = "AUS_PDQ";
    IF param_pdq IS NULL THEN
        LET param_pdq = 0;
    ELIF param_pdq < 0 THEN
        LET param_pdq = 0;
    ELIF param_pdq > 100 THEN
        LET param_pdq = 100;
    END IF

    LET p_cmd = "SET PDQPRIORITY " ||param_pdq;

    BEGIN
       ON EXCEPTION IN ( -206 )    -- Exit if aus_cmd_* tables are not found
       END EXCEPTION

    FOREACH SELECT  --+ FIRST_ROWS
              aus_cmd_id, RTRIM(aus_cmd_exe),aus_cmd_partnum, aus_cmd_priority,
              aus_cmd_type, aus_cmd_dbs_partnum 
         INTO
              t_id, t_cmd, t_partnum, t_priority, t_type , t_dbs_partnum
         FROM  aus_command
         WHERE aus_cmd_state = 'P'   -- Pending
         ORDER BY  aus_cmd_priority DESC, aus_cmd_partnum, aus_cmd_type DESC


--TRACE "LAST partnum ="||last_partnum;

        IF  last_partnum == 0 THEN
           LET last_partnum = t_partnum;
           LET last_dbs_partnum = t_dbs_partnum;
           LET cnt = cnt + 1;
        ELIF last_partnum <> t_partnum THEN
           LET last_partnum = t_partnum;
           IF t_priority > 100000 THEN
               IF last_dbs_partnum <> t_dbs_partnum THEN
                   CONTINUE FOREACH;
               END IF
               IF cnt > 100 THEN
                   EXIT FOREACH;
               END IF
               LET cnt = cnt + 1;
           ELSE
               EXIT FOREACH;
           END IF
        END IF

--TRACE "UPDATING cmd_id="||t_id ||" TABLE "|| t_partnum||" MODE " || RTRIM(t_type)::lvarchar ||" CNT =" ||cnt;
        DELETE FROM aus_command WHERE  aus_cmd_id = t_id;
        LET del =  DBINFO("sqlca.sqlerrd2");
        /* If we did not delete anything then skip this row, parallel */
        IF del < 0 THEN
           CONTINUE FOREACH;
        END IF
  

        BEGIN
            ON EXCEPTION IN ( -206 )    -- IGNORE if the table is gone

            END EXCEPTION WITH RESUME

            EXECUTE IMMEDIATE p_cmd;
            EXECUTE IMMEDIATE t_cmd;
            SET PDQPRIORITY 0;
        END

        INSERT INTO aus_command
               ( aus_cmd_id, aus_cmd_type, aus_cmd_priority, aus_cmd_state, 
                 aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
             VALUES
              ( t_id, t_type, t_priority, 'C', t_dbs_partnum, t_partnum, TRIM(t_cmd));


        LET rc=rc+1;

    END FOREACH
 
    IF cnt > 0 THEN 
        UPDATE aus_cmd_info
            SET (aus_ci_done_tables) = (aus_ci_done_tables + cnt)
            WHERE aus_ci_dbs_partnum = last_dbs_partnum;
   ELIF task_id > 0 THEN
      /* I have no more work to and I am a real task disable my self */
     UPDATE ph_task SET ( tk_enable ) = ('F') WHERE tk_id = task_id;
   END IF
   END

   RETURN rc;

END FUNCTION;

CREATE FUNCTION aus_enable_refresh()
    RETURNING INTEGER

    UPDATE ph_task SET ( tk_enable) =
                       ('T')
           WHERE tk_name matches "Auto Update Statistics Refresh*";


END FUNCTION;



CREATE FUNCTION aus_create_cmd_dist(dbsname char(128), dbs_partnum INTEGER, 
                                  tabname CHAR(128), partnum INTEGER,  tabid INTEGER,
                                  param_rules INTEGER, expire_priority BIGINT)
    RETURNING BIGINT

DEFINE rc                INTEGER;
DEFINE cnt               INTEGER;
DEFINE collist           CHAR(7600);
DEFINE maxcollength      INTEGER;
DEFINE collistlen        INTEGER;
DEFINE collen            INTEGER;

DEFINE  t_colno          INTEGER;
DEFINE  t_resolution     DECIMAL(5,3);
DEFINE  last_resolution  DECIMAL(5,3);
DEFINE  t_confidence     DECIMAL(5,3);
DEFINE  t_smplsize       DECIMAL(16,3);
DEFINE  t_colname        CHAR(128);
DEFINE  tmp              CHAR(128);
DEFINE  lasttmp          CHAR(128);
DEFINE  end_str          CHAR(256);

--TRACE "FUNCTION aus_create_cmd_dist( database=" || RTRIM(dbsname) || " tabid = " || tabid || "  )" ;
    LET collist = NULL;

    LET rc = 0;

    /* Note the l must be lower case, so we
     *  can order by later can get the order as
     *   H, M, l
     * when building commands.
     */
    INSERT INTO aus_command
          ( aus_cmd_id, aus_cmd_type, aus_cmd_priority, aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
       VALUES
          ( 0, "l", expire_priority, dbs_partnum, partnum,
            "UPDATE STATISTICS LOW FOR TABLE " || RTRIM(dbsname) || ":" 
            || RTRIM(tabname)
          );
    /* FIND ALL HIGH COLUMNS 
     *   The first part finds all column 
     *      which were previously in sysdistrib
     *   The second part SQL is executed if
     *      the auto rules are enable, it finds 
     *      the minimum set of columns for this
     *      table for the optimizer
     */

    UPDATE aus_work_icols SET ( aus_icols_mode ) = ( 'H' )
          WHERE aus_icols_tabid = tabid
          AND aus_icols_colno in ( SELECT aus_dist_colno FROM aus_work_dist
                   WHERE aus_dist_tabid  = tabid
                   AND aus_dist_mode = 'H');

--TRACE "EXISTING HIGH ROWS UPDATED " || DBINFO("sqlca.sqlerrd2") || ")";

    IF param_rules > 0 THEN
        UPDATE aus_work_icols SET ( aus_icols_mode ) = ( decode(aus_icols_lkey,'Y','H','M') )
              WHERE aus_icols_tabid = tabid
              AND aus_icols_mode IS NULL;
--TRACE "PARAM_RULES ROWS UPDATED " || DBINFO("sqlca.sqlerrd2") || ")";
    ELSE
        SELECT count(*) INTO cnt  
             FROM aus_work_icols 
             WHERE aus_icols_mode IS NULL AND  aus_icols_tabid = tabid;
        
        IF  cnt >  0 THEN
            UPDATE aus_cmd_info SET
               (aus_ci_missed_tables) = (aus_ci_missed_tables + 1)
               WHERE aus_ci_database = dbsname;
        END IF

    END IF


    /** HIGH COLUMNS  **/
    LET collist = NULL;
    LET maxcollength = 7600;
    LET collistlen = 0;
    LET collen = 0;

    LET tmp     = NULL;
    LET lasttmp = NULL;
    FOREACH SELECT  
             aus_icols_colno, aus_icols_colname, NVL(aus_dist_resolution,0.5)
           INTO
              t_colno,  t_colname, t_resolution
           FROM  aus_work_icols , OUTER aus_work_dist 
           WHERE  aus_icols_tabid = aus_dist_tabid
              AND aus_icols_colno = aus_dist_colno
              AND aus_icols_tabid = tabid
              AND aus_icols_mode = 'H'
           ORDER BY aus_dist_resolution, aus_dist_colno

         IF collist IS NULL THEN
             LET collist = RTRIM(t_colname);
             LET collistlen = LENGTH(TRIM(collist));
             LET last_resolution = t_resolution;
             LET end_str = "  RESOLUTION " || t_resolution || " DISTRIBUTIONS ONLY";
         ELIF last_resolution == t_resolution THEN
             LET collen = LENGTH(RTRIM(t_colname));
             -- TRACE "collist len: " || collistlen;
             IF collen + collistlen + 2 >= maxcollength THEN
                 INSERT INTO aus_command
                   ( aus_cmd_id, aus_cmd_type, aus_cmd_priority,
                     aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
                 VALUES
                   ( 0, "H", expire_priority, dbs_partnum, partnum,
                   "UPDATE STATISTICS HIGH FOR TABLE " || RTRIM(dbsname)
                   || ":" || RTRIM(tabname)
                   || " ( " || TRIM(collist) || " ) " || TRIM(end_str)
                   );
                 LET collist = RTRIM(t_colname);
                 LET collistlen = LENGTH(TRIM(collist));
             ELSE
                 LET collist = RTRIM(collist) || ", " ||
                               RTRIM(t_colname);
                 LET collistlen = collistlen + collen + 2;
             END IF
         ELSE
             INSERT INTO aus_command
               ( aus_cmd_id, aus_cmd_type, aus_cmd_priority, 
                 aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
             VALUES
               ( 0, "H", expire_priority, dbs_partnum, partnum,
               "UPDATE STATISTICS HIGH FOR TABLE " || RTRIM(dbsname)
               || ":" || RTRIM(tabname)
               || " ( " || TRIM(collist) || " ) " || TRIM(end_str) 
               );
             LET collist = TRIM(t_colname);
             LET collistlen = LENGTH(TRIM(collist));
             LET end_str = " RESOLUTION " || t_resolution || " DISTRIBUTIONS ONLY";
             LET last_resolution = t_resolution;
         END IF
--TRACE "COLLIST LENGTH: " || LENGTH(TRIM(collist));
--TRACE "HIGH Colname " || RTRIM(t_colname);

    END FOREACH 

    IF collist IS NOT NULL THEN 
             INSERT INTO aus_command
               ( aus_cmd_id, aus_cmd_type, aus_cmd_priority, 
                 aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
             VALUES
               ( 0, "H", expire_priority, dbs_partnum, partnum,
               "UPDATE STATISTICS HIGH FOR TABLE "|| RTRIM(dbsname)
               || ":" || RTRIM(tabname)
               || " ( "|| RTRIM(collist) || " ) " || TRIM(end_str)
               );
    END IF
/*
   -- FIND ALL MED COLUMNS 
*/ 
    LET collist = NULL;
    LET collistlen = 0;
    LET collen = 0;
    LET tmp     = NULL;
    LET lasttmp = NULL;
    FOREACH SELECT  
               aus_icols_colno, aus_icols_colname,
               NVL(aus_dist_resolution,2.0), NVL(aus_dist_confidence,0.95),
               NVL(aus_dist_smplsize,0.0),
               NVL(aus_dist_smplsize,0)::DECIMAL(16,3) || "_" ||
                    NVL(aus_dist_resolution,0)::DECIMAL(5,2) || "_" ||
                    NVL(aus_dist_confidence,0)::DECIMAL(4,2)   AS C
           INTO
              t_colno,  t_colname, 
              t_resolution, t_confidence,
              t_smplsize, tmp
           FROM  aus_work_icols , OUTER aus_work_dist
           WHERE  aus_icols_tabid = aus_dist_tabid
              AND aus_icols_colno = aus_dist_colno
              AND aus_icols_tabid = tabid
              AND aus_icols_mode = 'M'
           ORDER BY C, aus_dist_colno

--TRACE "MED Colname " || RTRIM(t_colname) || "  tmp" || RTRIM(tmp);
--TRACE "collist " || TRIM(NVL(collist,"NULL"));
--TRACE "lasttmp " || TRIM(NVL(lasttmp,"NULL"));
--TRACE "tmp     " || TRIM(NVL(tmp,"NULL"));
         IF collist IS NULL THEN
             LET collist = TRIM(t_colname);
             LET collistlen = LENGTH(TRIM(collist));   
             LET lasttmp = tmp;
             LET end_str =  decode(t_smplsize,0.0," "," SAMPLING SIZE "
                            || t_smplsize ) 
                            || "  RESOLUTION "|| t_resolution 
                            || "  " || t_confidence 
                            || " DISTRIBUTIONS ONLY";
--TRACE "NULL collist" || TRIM(t_colname) || "  tmp" || TRIM(tmp);
         ELIF lasttmp IS NULL OR lasttmp == tmp THEN
--TRACE "equal collist" || TRIM(t_colname) || "  tmp" || TRIM(tmp);
             LET collen = LENGTH(RTRIM(t_colname));
             --TRACE "collist len: " || collistlen;
             IF collen + collistlen + 2 >= maxcollength THEN
                 INSERT INTO aus_command
                   ( aus_cmd_id, aus_cmd_type, aus_cmd_priority,
                     aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
                 VALUES
                   ( 0, "M", expire_priority, dbs_partnum, partnum,
                    "UPDATE STATISTICS MEDIUM FOR TABLE "
                    || RTRIM(dbsname) || ":" || TRIM(tabname)
                    || " (" || TRIM(collist) || ") " || TRIM(end_str)
                   );
                 LET collist = RTRIM(t_colname);
                 LET collistlen = LENGTH(TRIM(collist));
             ELSE
                 LET collist = RTRIM(collist) || ", " 
                        || RTRIM(t_colname);
                 LET collistlen = collistlen + collen + 2;
             END IF
         ELSE
            INSERT INTO aus_command
                  ( aus_cmd_id, aus_cmd_type, aus_cmd_priority, 
                    aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
              VALUES
                  ( 0, "M", expire_priority, dbs_partnum, partnum,
                    "UPDATE STATISTICS MEDIUM FOR TABLE " || RTRIM(dbsname)
                    || ":" || TRIM(tabname)
                    || " ("|| TRIM(collist) || ") " || TRIM(end_str)
                 );
             LET collist = TRIM(t_colname);
             LET collistlen = LENGTH(TRIM(collist));
             LET lasttmp = tmp;
             LET end_str =  decode(t_smplsize,0.0," "," SAMPLING SIZE "
                            || t_smplsize )  
                            || "  RESOLUTION " || t_resolution 
                            || "  " || t_confidence 
                            || " DISTRIBUTIONS ONLY";
         END IF
--TRACE "MED Colname " || TRIM(t_colname);


    END FOREACH

    IF collist IS NOT NULL THEN

            INSERT INTO aus_command
                  ( aus_cmd_id, aus_cmd_type, aus_cmd_priority, 
                    aus_cmd_dbs_partnum, aus_cmd_partnum, aus_cmd_exe )
              VALUES
                  ( 0, "M", expire_priority, dbs_partnum, partnum,
                    "UPDATE STATISTICS MEDIUM FOR TABLE " ||
                     TRIM(dbsname) || ":" || TRIM(tabname)
                    || " (" || TRIM(collist) || ") " || TRIM(end_str)
                  );
    END IF


   RETURN 0;

END FUNCTION;


CREATE FUNCTION aus_evaluator_dbs(dbsname CHAR(128), dbs_partnum INTEGER,
                   has_mon_tab_prof INTEGER, inHDRmode INTEGER)
     RETURNING integer

DEFINE aus_if_id         INTEGER;
DEFINE aus_if_tabname    CHAR(128);
DEFINE aus_if_tabid      INTEGER;
DEFINE aus_if_partnum    INTEGER;
DEFINE aus_if_ustlowts   DATETIME YEAR TO SECOND;
DEFINE aus_if_npused     BIGINT;
DEFINE aus_if_nrows      BIGINT;
DEFINE aus_real_rows     BIGINT;
DEFINE aus_if_nindexes   INTEGER;
DEFINE oldest_time       DATETIME YEAR TO SECOND;

DEFINE expired_value   BIGINT;

DEFINE max_seq_id      INTEGER;
DEFINE min_seq_id      INTEGER;

DEFINE hours_expired   BIGINT;
DEFINE nrows, isreads, iswrite, isrwrite, isdelete  FLOAT;
DEFINE delta_time       BIGINT;
DEFINE small_tab_exp    BIGINT;
DEFINE tmin             BIGINT;
DEFINE tmp              BIGINT;
DEFINE param_age_stats  INTEGER;            -- Number of hours
DEFINE param_change     INTEGER;
DEFINE param_rules      INTEGER;
DEFINE param_small_tab  BIGINT;
DEFINE row_count        INTEGER;
DEFINE cmd              CHAR(1000);

--TRACE "FUNCTION aus_evaluator_dbs(database="||TRIM(dbsname)::lvarchar||")" ;

    -- Get the config thresholds
    SELECT MAX(value::float * 24)::integer INTO param_age_stats 
           FROM sysadmin:ph_threshold WHERE name = "AUS_AGE";
    SELECT MAX(value::integer) INTO param_change    
           FROM sysadmin:ph_threshold WHERE name = "AUS_CHANGE";
    SELECT MAX(value::integer) INTO param_rules    
           FROM sysadmin:ph_threshold WHERE name = "AUS_AUTO_RULES";
    SELECT MAX(value::bigint) INTO param_small_tab    
           FROM sysadmin:ph_threshold WHERE name = "AUS_SMALL_TABLES";

    /* Default values if not found in the config table */
    LET param_age_stats = NVL(param_age_stats ,30*24);
    LET param_change    = NVL(param_change    ,10);
    LET param_rules     = NVL(param_rules     ,1);
    LET param_small_tab = NVL(param_small_tab ,100);
    IF param_small_tab > 200000 THEN
        /* Can not let be higher than 200,000 as
         *   will cause overflow of variable 
         */
        LET param_small_tab = 200000;
    END IF

    LET row_count = 0;

    /* Loop through the specified database */
    FOREACH SELECT
             aus_info_id, aus_info_tabname, aus_info_tabid,
             aus_info_partnum, aus_info_ustlowts, aus_info_npused,
             aus_info_nrows, aus_info_nindexes
         INTO
             aus_if_id, aus_if_tabname, aus_if_tabid,
             aus_if_partnum, aus_if_ustlowts, aus_if_npused,
             aus_if_nrows, aus_if_nindexes
         FROM aus_work_info
         WHERE aus_info_db_partnum = dbs_partnum
         ORDER BY aus_info_ustlowts

    IF aus_if_partnum = 0 THEN
         LET cmd = "UPDATE aus_work_info SET (aus_info_nrows) = ("
         || " (SELECT sum(pt.nrows)"
         || " FROM sysmaster:sysptnhdr pt"
         || " WHERE pt.partnum IN (SELECT partn FROM "
         ||                     TRIM(dbsname)::lvarchar||":sysfragments sfg"
         || "                   WHERE sfg.tabid = " || aus_if_tabid
         || "                   AND sfg.fragtype = 'T')))"
         || " WHERE aus_info_tabid = " || aus_if_tabid ;

         EXECUTE IMMEDIATE cmd;

         LET cmd = "UPDATE aus_work_info" 
         || " SET(aus_info_partnum) = ((SELECT min(lockid)"
         || "                          FROM sysmaster:sysptnhdr ptn, "
         ||                            TRIM(dbsname)::lvarchar||":sysfragments"
         || "                          sfg WHERE ptn.partnum = sfg.partn"
         || "                          AND sfg.tabid = " || aus_if_tabid
         || "                          AND sfg.fragtype = 'T' ))"
         || " WHERE aus_info_tabid = " || aus_if_tabid ;

         EXECUTE IMMEDIATE cmd;

         SELECT aus_info_nrows
           INTO aus_real_rows
           FROM aus_work_info
           WHERE aus_info_tabid = aus_if_tabid;
    ELSE
         SELECT sum(pt.nrows) 
           INTO aus_real_rows
           FROM sysmaster:sysptnhdr pt
           WHERE pt.partnum = aus_if_partnum;
    END IF

--TRACE "Checking table "||TRIM(dbsname)::lvarchar||"." || TRIM(aus_if_tabname)::lvarchar;
--TRACE "Number of rows "||aus_real_rows;

        LET expired_value = 0;

        /* If the table is considered a small row table
         *  expire the table and create the commands.
         */
        LET tmp = param_small_tab - aus_real_rows;
        IF  tmp > 0  THEN
            LET small_tab_exp = tmp + 10000 * param_small_tab;
        ELSE
            LET small_tab_exp = 0;
        END IF


        /* Calculate the oldesttime between
         *  the statistics and distributions
         */
        SELECT MIN(aus_dist_constr_time)
          INTO oldest_time
          FROM aus_work_dist
          WHERE aus_dist_tabid  = aus_if_tabid
              AND aus_dist_constr_time IS NOT NULL ;

        IF oldest_time IS NULL AND  aus_if_ustlowts IS NULL THEN
--TRACE "No Statistics and distributions for "|| TRIM(dbsname)::lvarchar||"." || TRIM(aus_if_tabname)::lvarchar;
            IF param_rules == 0 THEN
                /* If we have no stats or dist and we are not
                 *   doing auto rules then continue to the next table
                 */
                UPDATE aus_cmd_info SET
                   (aus_ci_missed_tables) = (aus_ci_missed_tables + 1)
                   WHERE aus_ci_dbs_partnum = dbs_partnum;
                CONTINUE FOREACH;
            ELIF small_tab_exp == 0 THEN
                /* We have auto rules on, but this tables is not small.
                 */
                 LET expired_value = 100;
            ELSE 
                /* We have auto rules on, and a small table
                 */
                 LET expired_value = small_tab_exp;
            END IF
            GOTO do_commands;
        END IF
        IF oldest_time IS NULL THEN
            LET oldest_time = aus_if_ustlowts;
        ELIF  (aus_if_ustlowts IS NOT NULL) AND (aus_if_ustlowts < oldest_time) THEN
            LET oldest_time = aus_if_ustlowts;
        END IF

--TRACE "Oldest time for table "|| TRIM(aus_if_tabname)::lvarchar || " is "|| oldest_time;
         /*  If we have a small table and 
          *     we have any stats or dist OR we are doing auto rules 
          * THEN goto make the commands
          */
         IF (small_tab_exp > 0) AND 
            ( oldest_time IS NOT NULL OR param_rules <> 0 ) THEN
            LET expired_value = small_tab_exp;
            GOTO do_commands;
         END IF

        /* If we are not applying basic rules
         *  and we have no upd stats low information 
         *  for this table before then skip
         *  this table now and look for distributions.
         */
        IF param_rules == 0 AND (aus_if_nrows IS NULL OR aus_if_ustlowts IS NULL) THEN
            GOTO do_distribution_eval;
        END IF

        /* 
         *  Check the age of the statistics
         *   If never been done then assign 100
         */
--TRACE "Start statistics checking basic row count "  || expired_value;
--TRACE "aus_if_nrows      "|| NVL(aus_if_nrows,"NULL");
--TRACE "aus_real_rows     "|| NVL(aus_real_rows,"NULL");
        IF aus_if_nrows IS NULL OR aus_real_rows IS NULL THEN
            LET expired_value  = expired_value + 100;
        ELSE
            LET tmp = (aus_real_rows - aus_if_nrows) / (aus_if_nrows+1) * 100;

--TRACE "Change in basic row count "  || tmp ||"%";
            IF ABS(tmp) > param_change THEN
                LET expired_value  = expired_value + ABS(tmp);
            END IF

        END IF

        /* 
         *  Check the basic row count of the statistics
         *   If never been done then assign 100
         */
--TRACE "Start statistics checking for age " || expired_value ;
        IF oldest_time IS NULL THEN
            LET expired_value  = expired_value + 100;
        ELSE
--TRACE "param_age_stats   "||param_age_stats;
            LET hours_expired =  (
                 ( ( (CURRENT -  oldest_time)::INTERVAL HOUR(5) TO HOUR
                       - param_age_stats UNITS HOUR))::char(20))::BIGINT;

--TRACE "hours_expired   "||hours_expired;

            IF  hours_expired > 0  THEN
              LET expired_value = expired_value +  hours_expired/24;
            END IF 
        END IF
--TRACE "INFO statistics checking basic row count END "  || expired_value;


<<do_distribution_eval>>


--TRACE "Statitics checking advanced row count START "  || expired_value;
    IF oldest_time IS NOT NULL AND has_mon_tab_prof == 1 THEN
        -- Find the MAX/MIN sequence numbers to use for this table statistics 
        --  Currently we do not take into account onstat -z 
        SELECT  MAX(run.run_task_seq),
                MIN(run.run_task_seq),
                ((((MAX(run.run_time) - MIN(run.run_time))::
                    INTERVAL MINUTE(9) TO MINUTE)::char(20))::BIGINT)
            INTO  max_seq_id, min_seq_id, delta_time
            FROM  ph_run run, ph_task task
            WHERE task.tk_id =  run.run_task_id
            AND  tk_name = "mon_table_profile"
            AND   run.run_time > oldest_time;

--TRACE "Delta Time "|| delta_time  ||"  max task_seq "||max_seq_id||" min task_seq "||min_seq_id;

        /* If we had 0 or 1 measurement then delta_time will be 0
         *  we must skip this check, not enough data
         */
        IF delta_time > 0 THEN   
            LET tmin = (((CURRENT - oldest_time)::
                         INTERVAL MINUTE(9) TO MINUTE)::char(20))::BIGINT;

            { Get the number of UDIS for statistics }
--TRACE "SELECT " || aus_if_partnum ;
            SELECT 
                 tmin * ((SUM(aft.nrows)       - SUM(bef.nrows))/delta_time), 
                 tmin * ((SUM(aft.pf_isread)   - SUM(bef.pf_isread))/delta_time), 
                 tmin * ((SUM(aft.pf_iswrite)  - SUM(bef.pf_iswrite))/delta_time), 
                 tmin * ((SUM(aft.pf_isrwrite) - SUM(bef.pf_isrwrite))/delta_time), 
                 tmin * ((SUM(aft.pf_isdelete) - SUM(bef.pf_isdelete))/delta_time)
            INTO nrows, isreads, iswrite, isrwrite, isdelete
            FROM  mon_table_profile bef, mon_table_profile aft
            WHERE aft.id  = max_seq_id
               AND   bef.id = min_seq_id
               AND   aft.lockid = aus_if_partnum
               AND   bef.lockid = aus_if_partnum
               AND   bef.lockid = aft.lockid;
    
--TRACE "Inserts " || iswrite || "Update " || isrwrite|| "Delete " || isdelete;
           LET tmp = (iswrite + isrwrite + isdelete) -  ( aus_real_rows * param_change/100);
--TRACE "Rows Changed " ||  (iswrite + isrwrite + isdelete) || " Precent Changed " || (iswrite + isrwrite + isdelete) / aus_real_rows ;
            IF tmp > 0 THEN
                LET expired_value = expired_value + 100 + tmp;
            END IF
        END IF
    END IF
    /*
     *   DONE calculating the statistics ranking
     */


    IF expired_value == 0 THEN
       CONTINUE FOREACH;
    END IF

<<do_commands>>
--TRACE "Building stats on table "||TRIM(dbsname)::lvarchar||"." || TRIM(aus_if_tabname)::lvarchar;
    /* Build the update low stats command if required */
    LET tmp = aus_create_cmd_dist(dbsname, dbs_partnum, aus_if_tabname, 
                                  aus_if_partnum, aus_if_tabid,
                                  param_rules , expired_value );
--TRACE "NEW CMD row_count="||row_count;
    IF tmp < 0 THEN
       RETURN tmp;
    END IF

    LET row_count = row_count + 1;


    END FOREACH           --- End aus_dbs_list FOREACH

   RETURN row_count;

END FUNCTION;


CREATE FUNCTION aus_load_dbs_data(aus_dbsname CHAR(128), aus_dbs_partnum INTEGER
                                  ,inHDRmode INTEGER)
RETURNING integer

DEFINE tmp             CHAR(1500);

DEFINE nrows           INTEGER;
DEFINE drows           INTEGER;

LET nrows = 0;
LET drows = 0;

                
        /*
         ***********************************************************
         *  Load the aus_work_info table from systables
         ************************************************************
         */
        LET tmp  = "INSERT INTO aus_work_info ("
         || " aus_info_id, aus_info_tabname, aus_info_tabid, aus_info_partnum, "
         || " aus_info_ustlowts, aus_info_npused, aus_info_nrows, "
         || " aus_info_nindexes, aus_info_db_partnum "
         || " ) SELECT "
         || " 0, tabname, tabid, partnum, "
         || " ustlowts, npused, nrows, "
         || " nindexes, "
         || aus_dbs_partnum
         || " FROM " 
              || TRIM(aus_dbsname)::lvarchar||":systables t "
         || " WHERE " 
              || " t.tabtype='T'"
        ;
        EXECUTE IMMEDIATE tmp ;

--TRACE "Loading "||TRIM(aus_dbsname)::lvarchar||":aus_work_info with ROWS(" || DBINFO("sqlca.sqlerrd2")||")";
        LET nrows = nrows + DBINFO("sqlca.sqlerrd2");

        IF (aus_dbsname == "sysadmin") THEN
            DELETE FROM aus_work_info WHERE aus_info_tabname LIKE "aus_work_%"
            AND aus_info_db_partnum = aus_dbs_partnum;

            LET nrows = nrows - 4;
        END IF;

        IF inHDRmode = 1 THEN
           CREATE INDEX aus_work_info_idx1 ON aus_work_info(aus_info_tabid) 
           ONLINE;
           CREATE INDEX aus_work_info_idx2 ON aus_work_info(aus_info_partnum) 
           ONLINE;
        ELSE
           CREATE INDEX aus_work_info_idx1 ON aus_work_info(aus_info_tabid);
           CREATE INDEX aus_work_info_idx2 ON aus_work_info(aus_info_partnum);
        END IF


        /*
         ***********************************************************
         *  Load the aus_work_dist table from sysdistrib table
         ************************************************************
         */

        LET tmp  = "INSERT INTO aus_work_dist ("
         || " aus_dist_id, aus_dist_tabid, aus_dist_colno, "
         || " aus_dist_mode, aus_dist_resolution, aus_dist_confidence, "
         || " aus_dist_smplsize, aus_dist_rowssmplde, aus_dist_constr_time, "
         || " aus_dist_ustnrows "
         || " ) SELECT "
         || " 0, tabid, colno, "
         || " mode, resolution, confidence, "
         || " smplsize,rowssmpld,constr_time, "
         || " ustnrows" 
         || " FROM " || TRIM(aus_dbsname)::lvarchar||":sysdistrib d "
         || " WHERE  d.seqno=1 " 
        ;

        EXECUTE IMMEDIATE tmp ;
        LET drows = drows + DBINFO("sqlca.sqlerrd2");
        IF inHDRmode = 1 THEN
           CREATE INDEX aus_work_dist_idx1 ON aus_work_dist
                                        (aus_dist_tabid,aus_dist_colno) ONLINE;
        ELSE
           CREATE INDEX aus_work_dist_idx1 ON aus_work_dist
                                        (aus_dist_tabid,aus_dist_colno);
        END IF

--TRACE "Loading "||TRIM(aus_dbsname)::lvarchar||":aus_work_dist with ROWS(" || DBINFO("sqlca.sqlerrd2")||")";


        /* We need to update the fragment tables partnum with
         *  the lock id, so we can reference them as one item.
         *  Also get the current number of rows.
        UPDATE aus_work_info
          SET ( aus_info_partnum, aus_info_nrows)  = 
            ( ( SELECT MAX(lockid), SUM(nrows)
               FROM sysmaster:systabnames t, sysmaster:sysptnhdr pt
               WHERE t.partnum = pt.partnum
                   AND t.partnum = aus_info_partnum
                   AND t.tabname = aus_info_tabname
                   AND t.dbsname = aus_dbsname) )
         WHERE  aus_info_db_partnum = aus_dbs_partnum
                AND  aus_info_nrows = -1
         ;
         */ 

        /*
         ***********************************************************
         *  Load the aus_work_icols table of all index colnames
         ************************************************************
         */
        LET tmp  = "CREATE VIEW aus_view (tabid,colno, colname,lkey) AS "
         || " SELECT "
         || " C.tabid, C.colno, MAX(C.colname), 'N' "
         || " FROM " 
             || TRIM(aus_dbsname)::lvarchar||":syscolumns AS C, "
             || TRIM(aus_dbsname)::lvarchar||":sysindices AS I  "
         || " WHERE "
         || "   C.tabid = I.tabid "
         || "   AND C.colno in "
         || "   (ABS(ikeyextractcolno(indexkeys,0)), "
         || "    ABS(ikeyextractcolno(indexkeys,1)) , "
         || "    ABS(ikeyextractcolno(indexkeys,2)) , "
         || "    ABS(ikeyextractcolno(indexkeys,3)) , "
         || "    ABS(ikeyextractcolno(indexkeys,4)) , "
         || "    ABS(ikeyextractcolno(indexkeys,5)) , "
         || "    ABS(ikeyextractcolno(indexkeys,6)) , "
         || "    ABS(ikeyextractcolno(indexkeys,7)) , "
         || "    ABS(ikeyextractcolno(indexkeys,8)) , "
         || "    ABS(ikeyextractcolno(indexkeys,9)) , "
         || "    ABS(ikeyextractcolno(indexkeys,10)) , "
         || "    ABS(ikeyextractcolno(indexkeys,11)) , "
         || "    ABS(ikeyextractcolno(indexkeys,12)) , "
         || "    ABS(ikeyextractcolno(indexkeys,13)) , "
         || "    ABS(ikeyextractcolno(indexkeys,14)) , "
         || "    ABS(ikeyextractcolno(indexkeys,15)) ) "
         || " GROUP BY 1,2,4 " 
         || "UNION "
         || "SELECT "
         || " C.tabid, C.colno,  MAX(C.colname), 'N' "
         || " FROM " 
             || TRIM(aus_dbsname)::lvarchar||":syscolumns AS C, "
             || "aus_work_dist AS D "
         || " WHERE  C.tabid = D.aus_dist_tabid "
         || "     AND C.colno = D.aus_dist_colno"
         || " GROUP BY 1,2,4 " 
         ;

        EXECUTE IMMEDIATE tmp ;

        LET tmp  = "INSERT INTO aus_work_icols"
                   || "(aus_icols_tabid, aus_icols_colno,aus_icols_colname,aus_icols_lkey) " 
                   || " SELECT tabid, colno, colname,lkey FROM aus_view";
        EXECUTE IMMEDIATE tmp ;
--TRACE "Loading "||TRIM(aus_dbsname)::lvarchar||":aus_work_icols with ROWS(" || DBINFO("sqlca.sqlerrd2")||")";

        DROP VIEW aus_view;

        IF inHDRmode = 1 THEN
           CREATE INDEX aus_work_icols_idx1 ON aus_work_icols
                                      (aus_icols_tabid,aus_icols_colno) ONLINE;
        ELSE
           CREATE INDEX aus_work_icols_idx1 ON aus_work_icols
                                      (aus_icols_tabid,aus_icols_colno);
        END IF

        LET tmp  = "UPDATE aus_work_icols SET aus_icols_lkey = 'Y' " 
                   || "WHERE aus_icols_tabid*65536 + aus_icols_colno "
                   || " IN ( "
                   || " SELECT tabid*65536 + ABS(ikeyextractcolno(indexkeys,0)) "
                   || "FROM " || TRIM(aus_dbsname)::lvarchar||":sysindices)";
        EXECUTE IMMEDIATE tmp ;
--TRACE "Updating lead keys for aus_work_icols," || DBINFO("sqlca.sqlerrd2")||" lead keys found";


    RETURN nrows;

END FUNCTION;

CREATE FUNCTION aus_evaluator(eval_only BOOLEAN)
RETURNING INTEGER

     IF eval_only THEN     
         RETURN aus_evaluator(-1, 1, 0);
     END IF
     RETURN aus_evaluator(-1, 1, 1);

END FUNCTION;

CREATE FUNCTION aus_evaluator(task_id INTEGER, task_seq INTEGER)
RETURNING INTEGER
     
     RETURN aus_evaluator( task_id, task_seq, 1);

END FUNCTION;

CREATE FUNCTION aus_evaluator(task_id INTEGER, task_seq INTEGER,myflags INTEGER)
RETURNING INTEGER

DEFINE aus_dbsname     CHAR(128);
DEFINE aus_dbs_partnum INTEGER;

DEFINE trows           INTEGER;
DEFINE nrows           INTEGER;
DEFINE has_mon_tab_prof INTEGER;

DEFINE param_debug     CHAR(128);
DEFINE dblocale        CHAR(36);
DEFINE logmode         CHAR(3);
DEFINE errnum          INTEGER;
DEFINE inHDRmode       INTEGER;

LET nrows = 0;
LET trows = 0;


    SELECT FIRST 1 value INTO param_debug    
           FROM sysadmin:ph_threshold WHERE name = "AUS_DEBUG";

    IF  param_debug IS NOT NULL THEN
--SET DEBUG FILE TO TRIM(param_debug)::lvarchar||".prc";
--TRACE PROCEDURE;
--TRACE ON;
    ELSE
--SET DEBUG FILE TO "/tmp/aus.debug.off";
--TRACE OFF;
--TRACE ON;
    END IF

    LET errnum = aus_get_exclusive_access(task_id, task_seq);

    LET errnum = aus_cleanup_table(0);

    SELECT FIRST 1 DECODE(type, "Primary", 1, "Standard", 0, 0) INTO inHDRmode
    FROM sysmaster:sysdri;

    IF (inHDRmode = 1) THEN
        SET LOCK MODE TO WAIT 120;
    ELSE
        SET LOCK MODE TO WAIT 5;
    END IF

    LET errnum = aus_setup_table(inHDRmode);

    SET ISOLATION TO DIRTY READ;

    LET has_mon_tab_prof = aus_setup_mon_table_profile(task_id,task_seq,inHDRmode);
    IF has_mon_tab_prof == 1 THEN
        LET nrows = exectask(  "mon_table_profile" );
    END IF

    /*  Loop through all the logging databases 
     *   loading up the aus_work_info table 
     */
--TRACE "Begin examining each logging database";
    FOREACH SELECT TRIM(name), partnum
            INTO aus_dbsname, aus_dbs_partnum
            FROM sysmaster:sysdbspartn
            WHERE partnum NOT IN
                 (select partnum
                  FROM sysmaster:sysdbspartn 
                  WHERE bitand(flags, 3 ) > 0  
                  AND name NOT IN (SELECT value FROM sysadmin:ph_threshold
                                    WHERE name = "AUS_DATABASE_DISABLED" ))
          INSERT INTO ph_alert
              (ID, alert_task_id,alert_task_seq,alert_type,
               alert_color, alert_object_type,
               alert_object_name, alert_message,alert_action)
           VALUES
              (0,task_id, task_seq, "INFO", "yellow", "DATABASE",
               "Auto Update Statistics",
               "Skipping database ["||trim(aus_dbsname)|| 
               "] for Auto Update Statistics. ",
                NULL);

    END FOREACH

    FOREACH SELECT TRIM(D.name), D.partnum, 
            decode(bitand(D.flags,5),0,'N',4,'A','L') as logmode, T.collate
            INTO aus_dbsname, aus_dbs_partnum, logmode, dblocale
            FROM sysmaster:sysdbspartn D, sysmaster:systabnames T
            WHERE bitand(D.flags, 3 ) > 0    --- Not ansi yet need owner names
                  AND D.name <> "sysmaster"
                  AND D.partnum = T.partnum 
                  AND D.name NOT IN (SELECT value FROM sysadmin:ph_threshold
                                    WHERE name = "AUS_DATABASE_DISABLED" )
                
        INSERT INTO aus_cmd_info
                 (aus_ci_dbs_partnum, aus_ci_need_tables,
                  aus_ci_database, aus_ci_locale, aus_ci_logmode, aus_ci_stime)
               VALUES 
                 (aus_dbs_partnum, 0,
                  aus_dbsname, dblocale, logmode,  aus_get_realtime());

--TRACE "Starting database loading " || RTRIM(aus_dbsname);
        LET nrows = aus_load_dbs_data(aus_dbsname, aus_dbs_partnum, inHDRmode);
--TRACE "Starting database evaluation";
        LET trows = aus_evaluator_dbs(aus_dbsname, aus_dbs_partnum,
                                      has_mon_tab_prof, inHDRmode); 

        UPDATE aus_cmd_info 
            SET (aus_ci_need_tables,aus_ci_etime) = 
                (aus_ci_need_tables + trows, aus_get_realtime())
            WHERE aus_ci_database = aus_dbsname;

        IF trows < 0 THEN
           EXIT FOREACH;
        END IF

        IF trows > 0 THEN
          INSERT INTO ph_alert
              (ID, alert_task_id,alert_task_seq,alert_type,
               alert_color, alert_object_type,
               alert_object_name, alert_message,alert_action)
           VALUES
              (0,task_id, task_seq, "INFO", "yellow", "DATABASE",
               "Auto Update Statistics",
               "Found "||trows||" table(s) in database ["||trim(aus_dbsname)|| "]"
               || " which need statistics updated. ",
                NULL);
       ELSE
         INSERT INTO ph_alert
              (ID, alert_task_id,alert_task_seq,alert_type,
               alert_color, alert_object_type,
               alert_object_name, alert_message,alert_action)
           VALUES
              (0,task_id, task_seq, "INFO", "green", "DATABASE",
               "Auto Update Statistics",
               "Found "||trows||" table(s) in database ["||trim(aus_dbsname)|| "]"
               || " which need statistics updated.",
                NULL);
       END IF

       DROP INDEX aus_work_info_idx1;
       DROP INDEX aus_work_info_idx2;
       DROP INDEX aus_work_dist_idx1;
       DROP INDEX aus_work_icols_idx1;
       TRUNCATE TABLE aus_work_info;
       TRUNCATE TABLE aus_work_dist;
       TRUNCATE TABLE aus_work_icols;

    END FOREACH               --- End Database FOREACH

    UPDATE aus_cmd_info 
        SET (aus_ci_etime) = ( aus_get_realtime())
        WHERE aus_ci_database IS NULL;

    LET errnum = aus_cleanup_table(1);

    IF inHDRmode = 1 THEN
       CREATE INDEX aus_command_ix1 ON aus_command(aus_cmd_id) ONLINE;
       CREATE INDEX aus_command_ix2 ON aus_command( aus_cmd_state, 
                      aus_cmd_priority DESC, aus_cmd_partnum, aus_cmd_type DESC)
                      ONLINE;
    ELSE
       CREATE INDEX aus_command_ix1 ON aus_command(aus_cmd_id);
       CREATE INDEX aus_command_ix2 ON aus_command(aus_cmd_state, 
                      aus_cmd_priority DESC, aus_cmd_partnum, aus_cmd_type DESC);
    END IF

    LET errnum = aus_rel_exclusive_access();

    IF bitand(myflags,1) > 0 THEN
        LET errnum = aus_enable_refresh();
    END IF

    RETURN nrows;

END FUNCTION;

{*********************************************************
 *
 *  The following section create the task in the database
 *    scheduler used by the AUS feature
 *
 ********************************************************
 *}
DELETE from ph_task WHERE tk_name = "Auto Update Statistics Evaluation";

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
tk_enable
)
VALUES
(
"Auto Update Statistics Evaluation",
"TASK",
"PERFORMANCE",
"To Evaluate which columns and tables should have the statistics and distributions refreshed.",
"aus_evaluator",
DATETIME(01:00:00) HOUR TO SECOND,
DATETIME(01:10:00) HOUR TO SECOND,
INTERVAL ( 1 ) DAY TO DAY,
't'
);




DELETE from ph_task WHERE tk_name = "Auto Update Statistics Refresh";

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
tk_monday,
tk_Tuesday,
tk_Wednesday,
tk_Thursday,
tk_Friday,
tk_sunday,
tk_saturday,
tk_enable
)
VALUES
(
"Auto Update Statistics Refresh",
"TASK",
"PERFORMANCE",
"Refreshes the statistics and distributions which were recommended by the evaluator.",
"aus_refresh_stats",
DATETIME(01:11:00) HOUR TO SECOND,
DATETIME(05:00:00) HOUR TO SECOND,
INTERVAL ( 1 ) DAY TO DAY,
'f',
'f',
'f',
'f',
'f',
't',
't',
't'
);

create function aus_refresh_stats(task_id integer, seq_id integer,
                                  run_time integer default 0)
    returns integer
    external name '(aus_refresh)'
    language C;

CREATE FUNCTION aus_refresh_upgrade()
   RETURNING INTEGER

    UPDATE ph_task SET 
        ( tk_execute, tk_enable ) = ( "aus_refresh_stats", 't' )
        WHERE tk_name = 'Auto Update Statistics Refresh';

    UPDATE ph_task SET 
        ( tk_frequency ) = ( INTERVAL ( 1 ) DAY TO DAY )
        WHERE tk_name = 'Auto Update Statistics Refresh'
        AND tk_frequency < INTERVAL ( 1 ) DAY TO DAY;

    RETURN 0;

END FUNCTION;

CREATE FUNCTION aus_refresh_downgrade()
   RETURNING INTEGER

    UPDATE ph_task SET 
        ( tk_execute, tk_enable, tk_frequency ) = 
        ( "aus_refresh_stats_orig", 'f', INTERVAL ( 1 ) SECOND TO SECOND )
        WHERE tk_name = 'Auto Update Statistics Refresh';

    RETURN 0;

END FUNCTION;
{**************************************************************************
          MARK THE ABOVE TASKS AS SYSTEM TASKS AND FOR PRIVATE THREAD
**************************************************************************}

UPDATE ph_task SET tk_attributes = BITOR(tk_attributes, 12)
    WHERE tk_name
        IN ('Auto Update Statistics Evaluation',
            'Auto Update Statistics Refresh');

{**************************************************************************
          RECORD THE VERSION OF AUS INSTALLED
**************************************************************************}
DELETE FROM ph_version WHERE object = 'AUS' and type = 'version';
INSERT INTO ph_version(object,type,value) VALUES ( 'AUS','version', 19 );

CLOSE DATABASE;
