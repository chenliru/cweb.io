-- This CLP file was created using DB2LOOK Version "9.5" 
-- Timestamp: Wed Mar 16 09:28:20 EDT 2011
-- Database Name: ICMNLSDB       
-- Database Manager Version: DB2/AIX64 Version 9.5.5       
-- Database Codepage: 819
-- Database Collating Sequence is: UNIQUE


CONNECT TO ICMNLSDB;

------------------------------------------------
-- DDL Statements for table "ICMADMIN"."USPORTS"
------------------------------------------------
 

CREATE TABLE "ICMADMIN"."USPORTS"  (
		  "PORT_CODE" CHAR(4) NOT NULL , 
		  "PORT_NAME" CHAR(50) NOT NULL , 
		  "UPDATE_DATETIME" TIMESTAMP NOT NULL , 
		  "UPDATE_USERID" CHAR(20) NOT NULL )   
		 IN "ICMVFQ04" ; 


-- DDL Statements for indexes on Table "ICMADMIN"."USPORTS"

CREATE INDEX "ICMADMIN"."CC1207238448305" ON "ICMADMIN"."USPORTS" 
		("PORT_CODE" ASC)
		DISALLOW REVERSE SCANS;
-- DDL Statements for primary key on Table "ICMADMIN"."USPORTS"

ALTER TABLE "ICMADMIN"."USPORTS" 
	ADD CONSTRAINT "CC1207238448305" PRIMARY KEY
		("PORT_CODE");










COMMIT WORK;

CONNECT RESET;

TERMINATE;

