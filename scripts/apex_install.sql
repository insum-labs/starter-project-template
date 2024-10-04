-- Installs an APEX application
-- 
-- Parameters:
-- 1: Schema to install into
-- 2: Workspace to install into
-- 3: Application ID to run

set serveroutput on size unlimited;
set timing off;
set define on

declare
begin

  apex_application_install.set_application_id(&3.);
  apex_application_install.set_schema(upper('&1.'));
  apex_application_install.set_workspace(upper('&2.'));
  -- apex_application_install.generate_offset; [IGST-37] https://insumsolutions.atlassian.net/browse/IGST-37

end;
/

@../apex/f&3..sql