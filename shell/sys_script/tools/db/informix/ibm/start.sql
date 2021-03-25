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
{   Title:  start.sql                      }
{   Description:                           }
{       start the scheduler                }

DATABASE sysadmin;

EXECUTE FUNCTION task("scheduler start");

CLOSE DATABASE;

