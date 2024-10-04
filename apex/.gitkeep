# APEX Applications

By default the build script included in this project will do some "extra" things for your APEX applications. 

- [Summary](#summary)
- [App Version](#app-version)
- [Error Handling Function](#error-handling-function)

## Summary

Provides a brief summary of all changes you'll need to make in your APEX application to take advantage of all the features that build script provides:

1. Go to `Application Properties > Version` and set to `Release %RELEASE_VERSION%` (or whatever text your want but `%RELEASE_VERSION%` will be the version number)


## App Version

Every APEX application has version attribute which is stored in `Application Properties > Version`. By default it's set to `Release 1.0` and shows up in the bottom left footer of your application. Manually changing this value for each release can be cumbersome and error prone. Instead use `%RELEASE_VERSION%` in the `Version` attribute and `%RELEASE_VERSION%` will be replaced automatically with your build version.

For example set the `Version` to `Release %RELEASE_VERSION%` and when you "build" version `2.0.0` it will show up as `Release 2.0.0` in your application.


## Error Handling Function

By default APEX will show system error messages as they are raised. Example `ORA-123: Some error message`. APEX allows you to *intercept* these error messages and display your own error message instead. This can be very useful to both provide a more user-friendly error message and log everything about the user's session to help with debugging.

Below is an example of an error handling function that can easily be modified and augmented for your application. The base code was taken from the [Example of an Error Handling Function](https://docs.oracle.com/en/database/oracle/application-express/20.1/aeapi/Example-of-an-Error-Handling-Function.html#GUID-2CD75881-1A59-4787-B04B-9AAEC14E1A82) in the APEX documentation. *Again it's important to note that you can modify this to your project's needs and tools*. The error function does the following:

- Provide a generic friendly error message along with a human readable error code for users to reference in support tickets
  - This error code can then be referenced in your logs
  - The error code will be a combination of the application ID and the current time
- Logs everything about the error as well as all session state values
- Will display the technical error message on screen if APEX is in developer mode (i.e. the developer is logged into the builder)

Dependencies:

- [Logger](https://github.com/oraopensource/logger)
- [OOS Utils](https://github.com/OraOpenSource/oos-utils)

To apply this custom error handling function in APEX go to `Shared Components > Application Definitions > Error Handling` set the option `Error Handling Function` to `pkg_apex.apex_error_handler` (assuming the function below is added to a package called `pkg_apex`).


```sql
function apex_error_handler(
  p_error in apex_error.t_error)
  return apex_error.t_error_result
as
  l_scope logger_logs.scope%type := gc_scope_prefix || 'apex_error_handler';
  l_params logger.tab_param;

  l_return apex_error.t_error_result;

  c_reference_code constant varchar2(255) := to_char(apex_application.g_flow_id) || to_char(systimestamp, '.YY.DDD.SSSSS');
  c_err_msg constant varchar2(255) := apex_string.format('An unexpected error has occurred. Please contact support with reference [%0].', c_reference_code);

  procedure generate_err_msg
  as
  begin
    -- Some situations want to use specific codes but also reference the l_reference error number
    l_return.message := c_err_msg;

    -- If exception occurs before a session has been initialized, there will
    -- be no session. So don't try to log any items.
    if apex_application.g_instance is not null then -- g_instance = session_id
      logger.log_apex_items(
        p_text => 'APEX unhandled exception (see logger_logs_apex_items)',
        p_scope => c_reference_code,
        p_level => logger.g_error
      );
    end if;

    logger.log_cgi_env(
      p_scope => c_reference_code,
      p_level => logger.g_error
    );

    logger.log_error(p_error.message, c_reference_code, p_error.additional_info, l_params);

  end generate_err_msg;

begin
  logger.append_param(l_params, 'p_error.message', p_error.message);
  logger.append_param(l_params, 'p_error.additional_info', p_error.additional_info);
  logger.append_param(l_params, 'p_error.display_location', p_error.display_location);
  logger.append_param(l_params, 'p_error.association_type', p_error.association_type);
  logger.append_param(l_params, 'p_error.page_item_name', p_error.page_item_name);
  logger.append_param(l_params, 'p_error.region_id', p_error.region_id);
  logger.append_param(l_params, 'p_error.column_alias', p_error.column_alias);
  logger.append_param(l_params, 'p_error.row_num', p_error.row_num);
  logger.append_param(l_params, 'p_error.apex_error_code', p_error.apex_error_code);
  logger.append_param(l_params, 'p_error.is_internal_error', oos_util_string.to_char(p_error.is_internal_error));
  logger.append_param(l_params, 'p_error.is_common_runtime_error', oos_util_string.to_char(p_error.is_common_runtime_error));
  logger.append_param(l_params, 'p_error.ora_sqlcode', p_error.ora_sqlcode);
  logger.append_param(l_params, 'p_error.ora_sqlerrm', p_error.ora_sqlerrm);
  logger.append_param(l_params, 'p_error.error_backtrace', p_error.error_backtrace);
  logger.append_param(l_params, 'p_error.error_statement', p_error.error_statement);
  logger.append_param(l_params, 'p_error.component.type', p_error.component.type);
  logger.append_param(l_params, 'p_error.component.id', p_error.component.id);
  logger.append_param(l_params, 'p_error.component.name', p_error.component.name);
  logger.log('START', l_scope, null, l_params);

  l_return := apex_error.init_error_result (p_error => p_error );

  -- If it's an internal error raised by APEX, like an invalid statement or
  -- code which can't be executed, the error text might contain security sensitive
  -- information. To avoid this security problem we can rewrite the error to
  -- a generic error message and log the original error message for further
  -- investigation by the help desk.
  if p_error.is_internal_error then
    -- mask all errors that are not common runtime errors (Access Denied
    -- errors raised by application / page authorization and all errors
    -- regarding session and session state)
    if not p_error.is_common_runtime_error then
      -- log error for example with an autonomous transaction and return
      -- l_reference_id as reference#
      -- l_reference_id := log_error (
      --                       p_error => p_error );
      --

      -- Change the message to the generic error message which doesn't expose
      -- any sensitive information.
      l_return.additional_info := null;
      generate_err_msg;
    end if;
  else
    -- Always show the error as inline error
    -- Note: If you have created manual tabular forms (using the package
    --       apex_item/htmldb_item in the SQL statement) you should still
    --       use "On error page" on that pages to avoid loosing entered data
    l_return.display_location := 
      case
        when l_return.display_location = apex_error.c_on_error_page then apex_error.c_inline_in_notification
        else l_return.display_location
      end;

    --
    -- Note: If you want to have friendlier ORA error messages, you can also define
    --       a text message with the name pattern APEX.ERROR.ORA-number
    --       There is no need to implement custom code for that.
    --

    -- If it's a constraint violation like
    --
    --   -) ORA-00001: unique constraint violated
    --   -) ORA-02091: transaction rolled back (-> can hide a deferred constraint)
    --   -) ORA-02290: check constraint violated
    --   -) ORA-02291: integrity constraint violated - parent key not found
    --   -) ORA-02292: integrity constraint violated - child record found
    --
    -- we try to get a friendly error message from our constraint lookup configuration.
    -- If we don't find the constraint in our lookup table we fallback to
    -- the original ORA error message.
    -- if p_error.ora_sqlcode in (-1, -2091, -2290, -2291, -2292) then
    --     l_constraint_name := apex_error.extract_constraint_name (p_error => p_error );

    --     begin
    --         select message
    --           into l_result.message
    --           from constraint_lookup
    --          where constraint_name = l_constraint_name;
    --     exception when no_data_found then null; -- not every constraint has to be in our lookup table
    --     end;
    -- end if;

    -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
    -- in a table trigger or in a PL/SQL package called by a process and we
    -- haven't found the error in our lookup table, then we just want to see
    -- the actual error text and not the full error stack with all the ORA error numbers.
    if p_error.ora_sqlcode is not null and l_return.message = p_error.message then
      l_return.message := apex_error.get_first_ora_error_text (p_error => p_error );
      generate_err_msg;
    end if;

    -- If no associated page item/tabular form column has been set, we can use
    -- apex_error.auto_set_associated_item to automatically guess the affected
    -- error field by examine the ORA error for constraint names or column names.
    if l_return.page_item_name is null and l_return.column_alias is null then
      apex_error.auto_set_associated_item (
        p_error => p_error,
        p_error_result => l_return);
    end if;
  end if;

  -- If developer is enabled show additional error information
    if 1=1
      and l_return.message != p_error.message
      and oos_util_apex.is_developer
      then
      l_return.message := l_return.message || '</br></br>*** Technical Details (Developers Only) ***</br>' || p_error.message;
    end if;

  logger.log('END', l_scope);
  return l_return;
exception

  when others then
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end apex_error_handler;
```
