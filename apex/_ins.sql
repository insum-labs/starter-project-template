-- *** APEX ***
PROMPT *** APEX Installation ***

set serveroutput on size unlimited;
declare
  l_workspace_id apex_workspaces.workspace_id%type;
begin
  select workspace_id
  into l_workspace_id
  from apex_workspaces
  where workspace = 'WORKSPACE_NAME';

  apex_application_install.set_application_id(100);
  apex_application_install.set_schema('APP_SCHEMA');
  apex_application_install.set_workspace_id(l_workspace_id);
  apex_application_install.generate_offset;
end;
/

@f100.sql