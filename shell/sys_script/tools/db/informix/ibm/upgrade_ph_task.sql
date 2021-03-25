{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2011
{*                                                                        *}
{**************************************************************************}


{* ensure there are no ph_task table entries that have a tk_frequency     *}
{* of INTERVAL 0.                                                         *}


UPDATE ph_task SET tk_frequency = NULL 
        WHERE ( tk_frequency = INTERVAL(0 00:00:00) day to second );


{* ensure the ph_task table has the tk_frequency constraint that does     *}
{* not allow 0 interval.                                                  *}

CREATE PROCEDURE create_constraint_ph_task_constr2( )

    DEFINE constraint_exists INTEGER;

    LET constraint_exists = 0 ;

    SELECT count(*) INTO constraint_exists FROM sysadmin:sysconstraints
        WHERE constrname = "ph_task_constr2";

    IF constraint_exists == 0 THEN
        ALTER TABLE ph_task ADD CONSTRAINT
            CHECK ( tk_frequency > INTERVAL(0 00:00:00) day to second)
              CONSTRAINT ph_task_constr2;
    END IF;

END PROCEDURE;

EXECUTE PROCEDURE create_constraint_ph_task_constr2();
DROP PROCEDURE create_constraint_ph_task_constr2();

{* update auto_crsd to include partitions with 0 data pages for autodefrag *}

DROP FUNCTION auto_crsd( INTEGER , INTEGER );

CREATE FUNCTION auto_crsd( g_task_id INTEGER, g_task_seq INTEGER)
RETURNING INTEGER

DEFINE p_enabled LIKE sysadmin:ph_threshold.value;

DEFINE p_value INTEGER;

DEFINE p_fulltabname LVARCHAR(300);
DEFINE p_dbsname  LIKE sysmaster:sysdatabases.name;
DEFINE p_owner    LIKE sysmaster:systabnames.owner;
DEFINE p_tabname  LIKE sysmaster:systabnames.tabname;
DEFINE p_partnum  LIKE sysmaster:systabnames.partnum;

DEFINE p_beforedatacnt LIKE sysmaster:sysptnhdr.npdata;
DEFINE p_beforepagecnt LIKE sysmaster:sysptnhdr.nptotal;
DEFINE p_afterdatacnt  LIKE sysmaster:sysptnhdr.npdata;
DEFINE p_afterpagecnt  LIKE sysmaster:sysptnhdr.nptotal;

DEFINE p_retcode INTEGER;

DEFINE p_alerttype  LIKE sysadmin:ph_alert.alert_type;
DEFINE p_alertcolor LIKE sysadmin:ph_alert.alert_color;
DEFINE p_alerttext  LIKE sysadmin:ph_alert.alert_message;

--SET DEBUG FILE TO "/tmp/compress."||g_task_seq;
--TRACE ON;
{*********** Check if AUTOCOMPRESS is enabled ***********}
LET p_enabled = "F";

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTOCOMPRESS_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTOCOMPRESS_ROWS";
	IF p_value IS NOT NULL AND p_value >= 2000 THEN
		FOREACH SELECT TRIM(T.dbsname) , TRIM(T.owner) 
					 , TRIM(T.tabname) , T.partnum
					 , H.npdata, H.nptotal
			INTO p_dbsname , p_owner , p_tabname , p_partnum
                ,p_beforedatacnt , p_beforepagecnt
			FROM sysmaster:sysptnhdr H , sysmaster:systabnames T
			WHERE 
			H.npdata > 0   -- only data partnums , not index
			AND H.nrows > p_value -- qualifying number of rows
			AND bitand(H.flags , 134217728 ) == 0 -- already compressed
			AND H.partnum = T.partnum
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('fragment compress',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto compressing partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT npdata, nptotal
				 INTO p_afterdatacnt , p_afterpagecnt
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically compressed table:["||p_partnum||"] ["||TRIM(p_fulltabname)||"] went from "||p_beforedatacnt||"/"||p_beforepagecnt||" data/total pages to "||p_afterdatacnt||"/"||p_afterpagecnt||" data/total pages.";
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF

END IF

{*********** Check if AUTOREPACK is enabled ***********}
LET p_enabled = "F";
LET p_retcode = 0;

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTOREPACK_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTOREPACK_SPACE";
	IF p_value IS NOT NULL AND p_value > 0 AND p_value < 100 THEN
		FOREACH SELECT TRIM(dbsname) as dbsname, TRIM(owner) as owner
			, TRIM(tabname) as tabname , T.partnum
			INTO p_dbsname , p_owner , p_tabname , p_partnum
			FROM
			(
			SELECT pnum , count(*) f
			FROM
  			( SELECT pe_extnum as extnum
         			, pe_size as size
         			, pe_partnum as pnum
         			, count(*) as free
    			FROM sysmaster:sysptnext E, sysmaster:sysptnbit B
    			WHERE
      			E.pe_partnum = B.PB_partnum
      			AND ( bitand(pb_bitmap,12) = 0 or bitand(pb_bitmap,12) = 4 )
      			AND E.pe_log <= B.pb_pagenum
      			AND B.pb_pagenum < E.pe_log + E.pe_size
      			GROUP BY 1,2,3
  			) as Y
 			, sysmaster:sysptnhdr  as H
 			, sysmaster:systabnames as T
  			WHERE pnum = H.partnum
    			AND T.partnum = H.partnum
    			AND npdata > 0
  			GROUP BY 1
			)
 			, sysmaster:sysptnhdr  as H
 			, sysmaster:systabnames as T
			WHERE
				pnum = T.partnum
			AND T.partnum = H.partnum
			AND nextns > 4
			AND npdata > 0
			AND (f/nextns)*100::decimal(10,2)  > p_value
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('fragment repack',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto repacking partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT npdata, nptotal
				 INTO p_afterdatacnt , p_afterpagecnt
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically repacked table:["||p_partnum||"] ["||TRIM(p_fulltabname);
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF
END IF

{*********** Check if AUTOSHRINK is enabled ***********}
LET p_enabled = "F";
LET p_retcode = 0;

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTOSHRINK_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTOSHRINK_UNUSED";
	IF p_value IS NOT NULL AND p_value > 0 AND p_value < 100 THEN
		FOREACH SELECT TRIM(T.dbsname) , TRIM(T.owner) 
					 , TRIM(T.tabname) , T.partnum
					 , H.npdata, H.nptotal
			INTO p_dbsname , p_owner , p_tabname , p_partnum
                ,p_beforedatacnt , p_beforepagecnt
			FROM sysmaster:sysptnhdr H , sysmaster:systabnames T
			WHERE 
			H.npdata > 0   -- only data partnums , not index
			AND 
                          (((nptotal - npused) / nptotal )*100) > p_value -- qualifying number of rows
			AND H.nextns > 1
			AND H.partnum = T.partnum
			AND dbsname NOT IN ( "sysmaster" , "system" ) 
			AND T.tabname NOT IN 
				( SELECT N.tabname FROM systables N where N.tabid < 100 )

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('fragment shrink',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto shrinking partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT npdata, nptotal
				 INTO p_afterdatacnt , p_afterpagecnt
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically shrunk table:["||p_partnum||"] ["||TRIM(p_fulltabname)||"] went from "||p_beforedatacnt||"/"||p_beforepagecnt||" data/total pages to "||p_afterdatacnt||"/"||p_afterpagecnt||" data/total pages.";
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF
END IF

{*********** Check if AUTODEFRAG is enabled ***********}
LET p_enabled = "F";
LET p_retcode = 0;

SELECT UPPER(value) INTO p_enabled FROM sysadmin:ph_threshold
WHERE name = "AUTODEFRAG_ENABLED";

IF ( p_enabled == 'T' ) THEN
	{*** SELECT tables that qualify *** }
    SELECT value::INTEGER INTO p_value FROM sysadmin:ph_threshold
	WHERE name = "AUTODEFRAG_EXTENTS";
	IF p_value IS NOT NULL AND p_value > 0 THEN
		FOREACH SELECT TRIM(T.dbsname) , TRIM(T.owner) 
					 , TRIM(T.tabname) , T.partnum
					 , H.nextns
			INTO p_dbsname , p_owner , p_tabname , p_partnum
                ,p_beforedatacnt 
			FROM sysmaster:sysptnhdr H , sysmaster:systabnames T
			WHERE 
				H.partnum = T.partnum
				AND H.nextns > p_value -- qualifying number of extents
				AND dbsname NOT IN ( "sysmaster" , "system" ) -- do no include sysmaster or system database tables.
				-- do not include partitions that do not qualify to avoid unnecessary error reporting.
				AND bitand(H.partnum,"0xFFFFF") != 1   -- exclude partition partition
				AND (
					    bitand (H.flags,"0x00000004") != "0x00000004" -- system catalog
					AND bitand (H.flags,"0x00000020") != "0x00000020" -- temp table
					AND bitand (H.flags,"0x00000080") != "0x00000080" -- sorts
					AND bitand (H.flags,"0x00001000") != "0x00001000" -- optical blobs
					AND bitand (H.flags,"0x00002000") != "0x00002000" -- permanent
					AND bitand (H.flags,"0x00200000") != "0x00200000" -- protected
					AND bitand (H.flags,"0x01000000") != "0x01000000" -- virtual table
					AND bitand (H.flags,"0x20000000") != "0x20000000" -- defrag inprogress
					)

			LET p_fulltabname = TRIM(p_dbsname)||":"||TRIM(p_owner)||"."||TRIM(p_tabname);

			EXECUTE FUNCTION admin('defragment partnum',p_partnum) 
				INTO p_retcode;

			IF p_retcode < 0 THEN
				LET p_alerttype  = "ERROR";
				LET p_alertcolor = "RED";
				LET p_alerttext  = "Error ["||p_retcode||"] when auto defragging partnum: "||p_partnum||" ["||TRIM(p_fulltabname)||"].";
			ELSE
				SELECT nextns
				 INTO p_afterdatacnt 
				FROM sysmaster:sysptnhdr H
				WHERE H.partnum = p_partnum;
				LET p_alerttype  = "INFO";
				LET p_alertcolor = "GREEN";
				LET p_alerttext  = "Automatically defragged table:["||p_partnum||"] ["||TRIM(p_fulltabname)||"] went from "||p_beforedatacnt||" extents to "||p_afterdatacnt||" extents.";
        END IF

        INSERT INTO ph_alert
            (ID, alert_task_id,alert_task_seq, alert_type, alert_color,
             alert_object_type, alert_object_name,
             alert_message,alert_action)
        VALUES
             (0,g_task_id, g_task_seq, p_alerttype, p_alertcolor,
               "DATABASE",TRIM(p_fulltabname),
               p_alerttext, NULL);
			
		END FOREACH;
    END IF
END IF

{*** DONE ***}
   RETURN 0;

END FUNCTION;
