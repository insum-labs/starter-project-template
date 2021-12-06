#!/bin/bash
# Env variables $1, $2, etc are from the tasks.json args array

# Directory of this file
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load helper
source $SCRIPT_DIR/../../scripts/helper.sh

# File can be referenced either as a full path or relative path
FILE_FULL_PATH=$2
FILE_RELATIVE_PATH=$1

# VSCODE_TASK_COMPILE_FILE should be defined in user-config.sh
if [ -z "$VSCODE_TASK_COMPILE_FILE" ]; then
  echo -e "${COLOR_ORANGE} Warning: VSCODE_TASK_COMPILE_FILE is not defined.${COLOR_RESET}\nSet VSCODE_TASK_COMPILE_FILE in $USER_CONFIG_FILE"
  echo -e "Defaulting to full path"
  VSCODE_TASK_COMPILE_FILE=$FILE_FULL_PATH
fi
# Since VSCODE_TASK_COMPILE_FILE contains the variable reference need to evaluate it here
VSCODE_TASK_COMPILE_FILE=$(eval "echo $VSCODE_TASK_COMPILE_FILE")

echo -e "Parsing file: ${COLOR_LIGHT_GREEN}$VSCODE_TASK_COMPILE_FILE${COLOR_RESET}"
echo -e "pwd: $PWD"

# run sqlplus, execute the script, then get the error list and exit
# VSCODE_TASK_COMPILE_BIN is set in the config.sh file (either sqlplus or sqlcl)
$VSCODE_TASK_COMPILE_BIN $DB_CONN << EOF
set define off
--
-- Set any alter session statements here (examples below)
-- alter session set plsql_ccflags = 'dev_env:true';
-- alter session set plsql_warnings = 'ENABLE:ALL';
-- 
-- #38: This will raise a warning message in SQL*Plus but worth keeping in to encourage use if using SQLcl to compile
set codescan all
--
-- Load user specific commands here
$VSCODE_TASK_COMPILE_SQL_PREFIX
--
-- 
-- Run file
@$VSCODE_TASK_COMPILE_FILE
--
set define on
show errors
exit;
EOF





