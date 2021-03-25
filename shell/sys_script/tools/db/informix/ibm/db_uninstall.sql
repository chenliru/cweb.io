{**************************************************************************}
{*                                                                        *}
{*  Licensed Materials - Property of IBM                                  *}
{*                                                                        *}
{*  "Restricted Materials of IBM"                                         *}
{*                                                                        *}
{*  IBM Informix Dynamic Server                                           *}
{*  (c) Copyright IBM Corporation 1996, 2006 All rights reserved.         *}
{*                                                                        *}
{**************************************************************************}
{                                          }
{   Title:  db_uninstall.sql               }
{   Description:                           }
{       drop sysadmin database             }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler shutdown");

CLOSE DATABASE;

SET LOCK MODE TO WAIT 120;

DROP DATABASE sysadmin;

