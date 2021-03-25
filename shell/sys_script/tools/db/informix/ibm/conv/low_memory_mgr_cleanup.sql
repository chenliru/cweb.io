{ Remove the tasks from the ph_task table }
DELETE FROM ph_task WHERE tk_id = -3;
DELETE FROM ph_task WHERE tk_name = "Low Memory Reconfig";

{ SAVE LMM ph_threshold VALUES. }

{ REMOVE ANY PREVIOUSLY SAVED VALUES }
DELETE FROM ph_threshold WHERE name IN
( "XX LMM START THRESHOLD", "XX LMM STOP THRESHOLD", "XX LMM IDLE TIME" );

{ SAVE THE CURRENT VALUES }
UPDATE ph_threshold SET name = "XX "||name WHERE name IN
( "LMM START THRESHOLD", "LMM STOP THRESHOLD", "LMM IDLE TIME" );

{ Remove the existing functions }
DROP FUNCTION informix.low_memory_mgr_message(informix.integer, informix.integer,
                      informix.lvarchar, informix.integer );
DROP FUNCTION db_low_memory_mgr();
DROP FUNCTION LowMemoryManager(INTEGER, INTEGER);
DROP FUNCTION LowMemoryReconfig(INTEGER, INTEGER, LVARCHAR);
DROP PROCEDURE kill_fat_sessions(INTEGER);
DROP PROCEDURE kill_idle_sessions(INTEGER);

