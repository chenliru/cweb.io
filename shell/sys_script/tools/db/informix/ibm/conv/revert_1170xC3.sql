{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  Copyright IBM Corporation 2011                                  	  *}
{*                                                                        *}
{**************************************************************************}
{                                                    			   }
{   Title:  revert_1170xC3.sql                         			   }
{   Description:                                     			   }
{       Reversion from 11.70xC3 to 11.70                		   }
{   Note:                                                                  }
{       Errors encountered while executing this sql script are NOT ignored.}
{       'revert_1170xC3_setup.sql' is run before this script.		   }
{**************************************************************************}

DATABASE sysadmin;

DROP FUNCTION IF EXISTS string_to_utf8(lvarchar(4096), lvarchar);

CLOSE DATABASE;
