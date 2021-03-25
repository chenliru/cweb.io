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
{   Title:  revert_1170_setup.sql                    			   }
{   Description:                                     			   }
{       Prepare the system for reverting to 11.50    			   }
{   Note:								   } 
{	Errors encountered while executing this sql script are IGNORED.	   }
{**************************************************************************}

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

CLOSE DATABASE;
