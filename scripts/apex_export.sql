
-- Run in SQLcl
-- 
-- Parameters:
-- 1: Application ID
-- 2: Export options (optional). For example: "-split"
-- 
-- Examples
-- 
-- Export application 100 into f100.sql
-- @apex_export_app 100
-- 
-- Export application 100 into a split file
-- @apex_export_app 100 -split
-- 
set termout off
set verify off


-- From: https://stackoverflow.com/questions/13474899/default-value-for-paramteters-not-passed-sqlplus-script
-- and: http://vbegun.blogspot.com/2008/04/on-sqlplus-defines.html
-- Allow for optional value of 2
column 1 new_value 1
column 2 new_value 2
select '' "1", '' "2" 
from dual 
where rownum = 0;

define 1
define 2

define APP_ID = "&1"
define EXPORT_OPTIONS = "&2"

set termout on
set serveroutput on
begin
  dbms_output.put_line ( 'App ID: &APP_ID' );
  dbms_output.put_line ( 'Export Options: &EXPORT_OPTIONS' );
  dbms_output.put_line ( '------------------' );
end;
/
set serveroutput off
-- end

-- spool f&APP_ID..sql
apex export -applicationid &APP_ID -dir apex &EXPORT_OPTIONS
-- spool off
