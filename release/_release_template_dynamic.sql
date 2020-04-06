--
--                             
--  ____           _                             
-- |  _ \    ___  | |   ___    __ _   ___    ___ 
-- | |_) |  / _ \ | |  / _ \  / _` | / __|  / _ \
-- |  _ <  |  __/ | | |  __/ | (_| | \__ \ |  __/
-- |_| \_\  \___| |_|  \___|  \__,_| |___/  \___|
--
--
--   Sprint: https://jira/secure/RapidBoard.jspa?sprint=nnnn
--     *
--
--   NOTES
--    
--

CLEAR SCREEN

-- Terminate the script on Error during the beginning
whenever sqlerror exit

--  define - Sets the character used to prefix substitution variables
SET define '^'
--  verify off prevents the old/new substitution message
SET verify off
--  feedback - Displays the number of records returned by a script ON=1
SET feedback off
--  timing - Displays the time that commands take to complete
SET timing off
--  display dbms_output messages
SET serveroutput on

define logname                      =''     -- Name of the log file

--  Start The logging
--  =============================================
set termout off
column my_logname new_val logname
select 'release_log_'||sys_context( 'userenv', 'service_name' )|| '_' || to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')||'.log' my_logname from dual;
-- good to clear column names when done with them
column my_logname    clear
set termout on
spool ^logname

PRO  ============================   App  Update  ==========================
PRO  == Version: v1.0.0
PRO  ============================= Installation ===========================
PRO

PRO  Log File                 = ^logname

-- AUTOREPLACE_START
-- AUTOREPLACE_END

PRO _________________________________________________
PRO COMPILE INVALID OBJECTS
PRO *********************************
exec dbms_utility.compile_schema(schema => user, compile_all => false);


PRO _________________________________________________
PRO Deploying application

@../app/_ins.sql

PRO _________________________________________________
PRO . READY!

spool off

exit
