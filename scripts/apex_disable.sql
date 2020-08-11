-- Disables comma delimited list of APEX applications
-- This is primarily used at the start of an APEX release process
-- Commit is applied at the end of this file. If not then the app won't be disabled for end users
-- 
-- Parameters
-- 1: Comma delimited list of application IDs. Ex: 100,200
-- 
-- 
prompt Disable APEX Application(s)
declare
  c_app_ids constant varchar2(500) := '&1.';
  c_username constant varchar2(30) := user;

  l_apex_app_ids apex_t_varchar2;
begin
  l_apex_app_ids := apex_string.split(p_str => c_app_ids, p_sep => ',');

  -- Note if getting error "ORA_20987 to catch the error: ORA-20987: APEX - An API call has been prohibited."
  -- Change your Application Security Settings
  -- Shared Components > Security Attributes > Runtime API Usage: 
  --  - Check "Modify This Application"

  for i in l_apex_app_ids.first .. l_apex_app_ids.last loop

    apex_session.create_session (
      p_app_id => l_apex_app_ids(i) ,
      p_page_id => 1,
      p_username => c_username );

    apex_util.set_application_status(
      p_application_id => l_apex_app_ids(i) ,
      p_application_status => 'UNAVAILABLE',
      p_unavailable_value => 'Scheduled update of application.');

    -- See https://github.com/insum-labs/starter-project-template/issues/28 for full description
    apex_session.detach; 

  end loop;

  commit; -- Commit required to ensure the disabling of application is applied
end;
/
