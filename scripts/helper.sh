#!/bin/bash

# Load colors
# To use colors:
# echo -e "${COLOR_RED}this is red${COLOR_RESET}"
load_colors(){
  # Colors for bash. See: http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
  COLOR_LIGHT_GREEN='\033[0;92m'
  COLOR_ORANGE='\033[0;33m'
  COLOR_RED='\033[0;31m'
  COLOR_RESET='\033[0m' # No Color

  FONT_BOLD='\033[1m'
  FONT_RESET='\033[22m'
} # load_colors

# Load the config file stored in scripts/config
load_config(){
  local SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  
  USER_CONFIG_FILE=$SCRIPT_DIR/config.sh
  PROJECT_CONFIG_FILE=$SCRIPT_DIR/project-config.sh

  if [[ ! -f $USER_CONFIG_FILE ]] ; then
    echo -e "${COLOR_RED}Warning: database connection configuration is missing ${COLOR_RESET}"
    echo -e "${FONT_BOLD}Modify $USER_CONFIG_FILE${FONT_RESET} with your DB connection string and APEX applications"
    cat > $USER_CONFIG_FILE <<EOL
#!/bin/bash

# If you need to register any aliases in bash uncomment these lines
# shopt -s expand_aliases
# This should reference where you store aliases (or manually define them)
# source ~/.aliases.sh

# Connection string to development environment
DB_CONN="CHANGME_USERNAME/CHANGEME_PASSWORD@CHANGEME_SERVER:CHANGEME_PORT/CHANGEME_SID"

# SQLcl binary (either sql or sqlcl depending on if you changed anything)
# If using a docker container for SQLcl ensure the run alias does not include the "-it" option as TTY is not necessary for these scripts
SQLCL=sql

# sql*plus binary
# If using a docker container for sqlplus ensure the run alias does not include the "-it" option as TTY is not necessary for these scripts
SQLPLUS=sqlplus

# Comma delimited list of APEX Applications to export. Ex: 100,200
APEX_APP_IDS=CHANGEME


# *** VSCode settings ***

# Compile file: chose $SQLCL or $SQLPLUS
# Recommended to use $SQLPLUS as it's quicker
VSCODE_TASK_COMPILE_BIN=\$SQLPLUS

# File to compile. Options:
# $FILE_RELATIVE_PATH: Will evaluate to relative to project ex: views/my_view.sql
# $FILE_FULL_PATH: Will evalutate to full path to file ex:
# 
# If using sqlplus for docker an example may be:
# VSCODE_TASK_COMPILE_FILE=/sqlplus/\$FILE_RELATIVE_PATH 
VSCODE_TASK_COMPILE_FILE=\$FILE_FULL_PATH

# This code will be run before the file is executed
read -d '' VSCODE_TASK_COMPILE_SQL_PREFIX << EOF
-- Add any custom alter statements etc here
-- alter session set plsql_warnings = 'ENABLE:ALL';
EOF

EOL
    chmod 755 $USER_CONFIG_FILE
    exit
  fi

  # Load project config
  source $PROJECT_CONFIG_FILE
  # Load user config
  source $USER_CONFIG_FILE
} # load_config


load_colors
load_config