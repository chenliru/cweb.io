-- This CLP file was created using DB2LOOK Version "9.5" 
-- Timestamp: Tue Sep  4 14:15:32 EDT 2012
-- Database Name: ICMNLSDB       
-- Database Manager Version: DB2/AIX64 Version 9.5.5       
-- Database Codepage: 819
-- Database Collating Sequence is: UNIQUE


CONNECT TO ICMNLSDB;

------------------------------------------------
-- DDL Statements for table "ICMADMIN"."CLIENTADM"
------------------------------------------------
 

CREATE TABLE "ICMADMIN"."CLIENTADM"  (
		  "CLIENT_KEY" INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY (  
		    START WITH +1  
		    INCREMENT BY +1  
		    MINVALUE +1  
		    MAXVALUE +2147483647  
		    NO CYCLE  
		    CACHE 2  
		    NO ORDER ) , 
		  "CLIENT_NAME" CHAR(50) NOT NULL , 
		  "CARRIER_CODE" CHAR(4) NOT NULL , 
		  "DIRECTION" CHAR(10) NOT NULL , 
		  "CLIENT_NOTES" VARCHAR(255) NOT NULL , 
		  "CLIENT_TYPE" CHAR(10) NOT NULL )   
		 IN "USERSPACE1" ; 






-- DDL Statements for indexes on Table "ICMADMIN"."CLIENTADM"

CREATE UNIQUE INDEX "ICMADMIN"."CC1184337175552" ON "ICMADMIN"."CLIENTADM" 
		("CLIENT_KEY" ASC)
		DISALLOW REVERSE SCANS;







COMMIT WORK;

CONNECT RESET;

TERMINATE;

