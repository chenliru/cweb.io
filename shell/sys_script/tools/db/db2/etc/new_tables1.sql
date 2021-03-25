------------------------------------------------                                    
-- DDL Statements for table "ICMADMIN"."XREFCLIENTBROKERADM"                        
------------------------------------------------                                    
                                                                                    
 CREATE TABLE "ICMADMIN"."XREFCLIENTBROKERADM"  (                                   
		  "CLIENT_KEY" INTEGER NOT NULL ,                                   
		  "BROKER_KEY" INTEGER NOT NULL )                                   
		 IN "ICMVFQ04" ;                                                    
                                                                                    
                                                                                    
-- DDL Statements for unique constraints on Table "ICMADMIN"."XREFCLIENTBROKERADM"  
                                                                                    
ALTER TABLE "ICMADMIN"."XREFCLIENTBROKERADM"                                        
	ADD CONSTRAINT "CC1184336321769" UNIQUE                                     
		("CLIENT_KEY",                                                      
		 "BROKER_KEY");                                                     

------------------------------------------------                               
-- DDL Statements for table "ICMADMIN"."BROKERADM"                             
------------------------------------------------                               
                                                                               
 CREATE TABLE "ICMADMIN"."BROKERADM"  (                                        
		  "BROKER_KEY" INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY ( 
		    START WITH +1                                              
		    INCREMENT BY +1                                            
		    MINVALUE +1                                                
		    MAXVALUE +2147483647                                       
		    NO CYCLE                                                   
		    NO CACHE                                                   
		    NO ORDER ) ,                                               
		  "PORT_CODE" CHAR(4) NOT NULL ,                               
		  "BROKER_NAME" CHAR(50) NOT NULL ,                            
		  "BROKER_CONTACT" CHAR(50) NOT NULL ,                         
		  "BROKER_PHONE" CHAR(11) NOT NULL ,                           
		  "BROKER_FAX" CHAR(11) NOT NULL ,                             
		  "BROKER_EMAIL" CHAR(50) NOT NULL ,                           
		  "CREATE_DATETIME" TIMESTAMP NOT NULL ,                       
		  "CREATE_USERID" CHAR(20) NOT NULL ,                          
		  "BROKER_NOTES" VARCHAR(255) NOT NULL )                       
		 IN "ICMVFQ04" ;                                               
                                                                               
                                                                               
-- DDL Statements for unique constraints on Table "ICMADMIN"."BROKERADM"       
                                                                               
ALTER TABLE "ICMADMIN"."BROKERADM"                                             
	ADD CONSTRAINT "CC1184337501521" UNIQUE                                
		("BROKER_KEY");                                                

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
		    NO CACHE                                                    
		    NO ORDER ) ,                                                
		  "CLIENT_NAME" CHAR(50) NOT NULL ,                             
		  "CARRIER_CODE" CHAR(4) NOT NULL ,                             
		  "DIRECTION" CHAR(10) NOT NULL ,                               
		  "CLIENT_NOTES" VARCHAR(255) NOT NULL ,                        
		  "CLIENT_TYPE" CHAR(10) NOT NULL )                             
		 IN "ICMVFQ04" ;                                                
                                                                                
                                                                                
-- DDL Statements for unique constraints on Table "ICMADMIN"."CLIENTADM"        
                                                                                
ALTER TABLE "ICMADMIN"."CLIENTADM"                                              
	ADD CONSTRAINT "CC1184337175552" UNIQUE                                 
		("CLIENT_KEY");                                                 

