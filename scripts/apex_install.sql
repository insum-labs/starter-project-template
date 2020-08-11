-- Installs an APEX application
-- 
-- Parameters:
-- 1: Schema to install into
-- 2: Workspace to install into
-- 3: Application ID to run

set serveroutput on size unlimited;
set timing off;

declare
  l_workspace_id apex_workspaces.workspace_id%type;
  l_build_option_id apex_application_build_options.build_option_id%type;
begin
  select workspace_id
  into l_workspace_id
  from apex_workspaces
  where workspace = upper('&2.');

  apex_application_install.set_application_id(&3.);
  apex_application_install.set_schema('&1.');
  apex_application_install.set_workspace_id(l_workspace_id);
  apex_application_install.generate_offset;

end;
/

@../apex/f&3..sql