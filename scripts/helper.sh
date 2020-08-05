#!/bin/bash

# Global variables
# Find the current path this script is in
# This needs to be run outside of any functions as $0 has different meaning in a function
# If this script is being called from using "source ..." then ${BASH_SOURCE[0]} evaluates to null Use $0 instead
if [ -z "${BASH_SOURCE[0]}" ] ; then 
  SCRIPT_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
else 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi
# Root folder in project directory
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
# echo "SCRIPT_DIR: $SCRIPT_DIR"
# echo "PROJECT_DIR: $PROJECT_DIR"


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
  USER_CONFIG_FILE=$PROJECT_DIR/scripts/user-config.sh
  PROJECT_CONFIG_FILE=$PROJECT_DIR/scripts/project-config.sh
  # echo "USER_CONFIG_FILE: $USER_CONFIG_FILE"
  # echo "PROJECT_CONFIG_FILE: $PROJECT_CONFIG_FILE"

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


# *** VSCode settings ***

# Compile file: chose $SQLCL or $SQLPLUS
# Recommended to use $SQLPLUS as it's quicker
VSCODE_TASK_COMPILE_BIN=\$SQLPLUS

# File to compile. Options:
# \\\$FILE_RELATIVE_PATH: Will evaluate to relative to project ex: views/my_view.sql
# \\\$FILE_FULL_PATH: Will evalutate to full path to file ex:
# 
# If using sqlplus for docker an example may be:
# VSCODE_TASK_COMPILE_FILE=/sqlplus/\\\$FILE_RELATIVE_PATH 
# Note: You need to escape the "$" here so it should say "\\\$FILE_FULL_PATH"
VSCODE_TASK_COMPILE_FILE=\\\$FILE_FULL_PATH

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


# Verifies configuration
verify_config(){
  # APEX_APP_IDS should be blank or list of IDs and not what is provided by default
  if [ $APEX_APP_IDS = "CHANGEME" ]; then
    echo -e "${COLOR_RED}APEX_APP_IDS is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
    exit
  fi

  # Check that DB connection string is defined
  if [[ $DB_CONN == *"CHANGME_USERNAME"* ]]; then
    echo -e "${COLOR_RED}DB_CONN is not configured.${COLOR_RESET} Modify $USER_CONFIG_FILE"
    exit
  fi
} # verify_config


# Export APEX applications
# Parameters
# $1 Version number
export_apex_app(){

  local APEX_APP_VERSION=$1

  for APEX_APP_ID in $(echo $APEX_APP_IDS | sed "s/,/ /g")
  do
    echo "APEX Export: $APEX_APP_ID"

    # Export single file app
    # Need to start in root project dicetory as export will automatically store files in the apex folder
    cd $PROJECT_DIR

    echo exit | $SQLCL $DB_CONN @scripts/apex_export.sql $APEX_APP_ID
    
    if [ ! -z "$APEX_APP_VERSION" ]; then
      # Add release number to app
      # In order to support the various versions of sed need to add the "-bak"
      # See: https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed/131940#131940
      echo "APEX_APP_VERSION: $APEX_APP_VERSION detected, injecting into APEX application"
      sed -i -bak "s/%RELEASE_VERSION%/$VERSION/" apex/f$APEX_APP_ID.sql
      # Remove the backup version of file (see above)
      rm apex/f$APEX_APP_ID.sql-bak
    fi

    # Export split app (or APEXcl)
    echo exit | $SQLCL $DB_CONN @scripts/apex_export.sql $APEX_APP_ID -split

  done
}


# Resets release/code/_run_code.sql and deletes all files in release/code directory
# 
# Parmaters
# $1 confirmation root folder name. Given that this will delete files in the release folder want to make sure we're deleting files where expexcted.
#  For example this starter project exsts in /users/martin/git/starter-project-template
#  For this function to work you must call: reset_release starter-project-template
reset_release(){
  local CONFIRMATION_DIR=$1
  local PROJECT_DIR_FOLDER_NAME=${PROJECT_DIR##*/}

  if [[ $CONFIRMATION_DIR != $PROJECT_DIR_FOLDER_NAME ]]; then
    echo -e "${COLOR_RED}Error: ${COLOR_RESET} confirmation directory missing or not matching. Correct value is: $PROJECT_DIR_FOLDER_NAME"
    # exit 1
  else
    # Clear release-specific code
    rm $PROJECT_DIR/release/code/*.sql
    # Reset _run_code.sql file
    echo "-- Release specific references to files in this folder" > $PROJECT_DIR/release/code/_run_code.sql
    echo "-- This file is automatically executed from the /release/_release.sql file" >>$PROJECT_DIR/release/code/_run_code.sql
    echo "-- \n-- Ex: @code/issue-123.sql \n" >>$PROJECT_DIR/release/code/_run_code.sql
} # reset_release



# List all files in directory
#
# Parameters
# $1: Folder (relative to root project folder) to list all the files from. Ex: views
# $2: File (relative to root project folder) to store the list of files in: ex: release/all_views.sql
# $3: Comma delimited list of file extensions to search for. Ex: pks,pkb. Default sql
list_all_files(){

  local FOLDER_NAME=$1
  local OUTPUT_FILE=$2
  local FILE_EXTENSION_ARR=$3

  local RUN_HELP="get_all_files <relative_folder_name> <relative_output_file> <optional: file_extension_list>
The following example will list all the .sql files in ./views and reference them in release/all_views.sql

get_all_files views release/all_views.sql sql

For packages it's useful to list the extensions in order as they should be compiled. Ex: pks,pkb to compile spec before body
"
  
  # Validation
  if [ -z "$FOLDER_NAME" ]; then
    echo "${COLOR_RED}Error: ${COLOR_RESET} Missing folder name"
    echo "\n$RUN_HELP"
    return 1
  elif [ -z "$OUTPUT_FILE" ]; then
    echo "${COLOR_RED}Error: ${COLOR_RESET} Missing output file"
    echo "\n$RUN_HELP"
    return 1
  fi

  # Defaulting extensions
  if [ -z "$FILE_EXTENSION_ARR" ]; then
    FILE_EXTENSION_ARR="sql"
  fi

  
  echo "-- Automated listing for $FOLDER_NAME" > $PROJECT_DIR/$OUTPUT_FILE
  for FILE_EXT in $(echo $FILE_EXTENSION_ARR | sed "s/,/ /g"); do

    echo "Listing files in: $PROJECT_DIR/$FOLDER_NAME extension: $FILE_EXT"
    for file in $PROJECT_DIR/$FOLDER_NAME/*.$FILE_EXT; do
    # for file in $PROJECT_DIR/$FOLDER_NAME/*.sql; do
    # for file in $(ls $PROJECT_DIR/$FOLDER_NAME/*.sql ); do
      echo "prompt @../$FOLDER_NAME/${file##*/}" >> $OUTPUT_FILE
      echo "@../$FOLDER_NAME/${file##*/}" >> $OUTPUT_FILE
    done
  done

} # list_all_files



# Initializing Helper
load_colors
load_config
verify_config