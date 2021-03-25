{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 2009 All rights reserved.               *}
{*                                                                        *}
{**************************************************************************}
{                                          }
{   Title:  revert_1100.sql                }
{   Description:                           }
{      Revert the system before IDS v11.10 }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

CLOSE DATABASE;

SET LOCK MODE TO WAIT 120;

DROP DATABASE sysadmin;

