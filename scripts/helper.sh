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
  # SCHEMA_NAME is required
  if [[ $SCHEMA_NAME = "CHANGEME" ]] || [[ -z "$SCHEMA_NAME" ]]; then
    echo -e "${COLOR_RED}SCHEMA_NAME is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
    exit
  fi
  
  # APEX_APP_IDS should be blank or list of IDs and not what is provided by default
  if [[ $APEX_APP_IDS = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_APP_IDS is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
    exit
  fi

  # APEX_WORKSPACE should be blank or list of IDs and not what is provided by default
  if [[ $APEX_WORKSPACE = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_WORKSPACE is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
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
  fi
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

  echo "-- GENERATED from build/build.sh DO NOT modify this file directly as all changes will be overwritten upon next build" > $PROJECT_DIR/$OUTPUT_FILE
  echo "-- Automated listing for $FOLDER_NAME" >> $PROJECT_DIR/$OUTPUT_FILE
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



# Builds files required for the release
# Should be called in build/build.sh
# 
# Issue: #28
gen_release_sql(){
  local loc_env_vars="$PROJECT_DIR/release/load_env_vars.sql"
  local loc_apex_install_all="$PROJECT_DIR/release/all_apex.sql"

  # Build helper sql file to load specific env variables into SQL*Plus session
  echo "-- GENERATED from build/build.sh DO NOT modify this file directly as all changes will be overwritten upon next build\n\n" > $loc_env_vars
  echo "define env_schema_name=$SCHEMA_NAME" >> $loc_env_vars
  echo "define env_apex_app_ids=$APEX_APP_IDS" >> $loc_env_vars
  echo "define env_apex_workspace=$APEX_WORKSPACE" >> $loc_env_vars
  echo "" >> $loc_env_vars
  echo "
prompt ENV variables
select 
  '&env_schema_name.' env_schema_name,
  '&env_apex_app_ids.' env_apex_app_ids,
  '&env_apex_workspace.' env_apex_workspace
from dual;

" >> $loc_env_vars

  # Build helper file to install all APEX applications
  echo "-- GENERATED from build/build.sh DO NOT modify this file." > $loc_apex_install_all
  echo "prompt *** APEX Installation ***" >> $loc_apex_install_all
  for APEX_APP_ID in $(echo $APEX_APP_IDS | sed "s/,/ /g"); do
    echo "prompt *** App: $APEX_APP_ID ***" >> $loc_apex_install_all
    echo "@../scripts/apex_install.sql $SCHEMA_NAME $APEX_WORKSPACE $APEX_APP_ID" >> $loc_apex_install_all
  done
} #gen_release_sql



# #36 Create new files quickly based on template files
# 
# See scripts/project-config.sh on how to define the various object types
# 
# Actions:
# - Create a new file in defined destination folder
# - Based on template
# - Replace all referneces to CHANGEME with the object name
#
# Parameters
# $1 Object type
# $2 Object Name
gen_object(){
  # Parameters
  local p_object_type=$1
  local p_object_name=$2

  # Loop variables
  local object_type_arr
  local object_type
  local object_template
  local object_dest_folder
  local object_dest_file

  # OBJECT_FILE_TEMPLATE_MAP is defined in scripts/project-config.sh
  for object_type in $(echo $OBJECT_FILE_TEMPLATE_MAP | sed "s/,/ /g"); do

    object_type_arr=(`echo "$object_type" | sed 's/:/ /g'`)

    # In bash arrays start at 0 whereas in zsh they start at 1
    # Only way to make array reference compatible with both is to specify the offset and length
    # See: https://stackoverflow.com/questions/50427449/behavior-of-arrays-in-bash-scripting-and-zsh-shell-start-index-0-or-1/50433774
    object_type=${object_type_arr[@]:0:1}
    object_template=${object_type_arr[@]:1:1}
    object_file_exts=${object_type_arr[@]:2:1}
    object_dest_folder=${object_type_arr[@]:3:1}

    if [[ "$p_object_type" == "$object_type" ]]; then

      for file_ext in $(echo $object_file_exts | sed "s/;/ /g"); do
        object_dest_file=$PROJECT_DIR/$object_dest_folder/$p_object_name.$file_ext

        if [[ -f $object_dest_file ]]; then
          echo "${COLOR_ORANGE}File already exists:${COLOR_RESET} $object_dest_file"
        else
          cp $object_template.$file_ext $object_dest_file
          sed -i -bak "s/CHANGEME/$p_object_name/g" $object_dest_file
          # Remove backup versin of file
          rm $object_dest_file-bak 
          echo "Created: $object_dest_file"

          # Open file in code
          code $object_dest_file
        fi
      done

      break # No longer need to loop through other definitions
    fi

  done # OBJECT_FILE_TEMPLATE_MAP

} # gen_object


# Merge a SQL file into one file
# Copied and modified from: https://github.com/insum-labs/conference-manager/blob/master/release/build_release_script.sh
#
# This script received a .sql file as input and will create an output file
# that can be processed by SQL Workshop on apex.oracle.com
# This means that single commands can be executed as they are (for example 
# alter, create table, update, inserts, etc..).
# When a script is found with the form @../file, ie:
# @../views/ks_users_v.sql
# It will be "expanded" into the output file (defined by OUT_FILE)
# 
# Note this will recursively expand files. 
# For example if calling "merge_sql_files _release.sql merged_release.sql" and:
# _release.sql references _all_packages.sql
# and _all_packages.sql references pkg_emp.pks
# Then both _all_packages.sql and pkg_emp.pks will be exampled at the the points they were referenced in each file
#
# Issue: #42
# Example:
# source helper.sh
# merge_sql_files all_packages.sql merged_all_packages.sql
# 
# Parameters
# $1 From/In File
# $2 To/Out File
merge_sql_files(){
  local IN_FILE=$1
  local OUT_FILE=$2

  # Logging function. Calling "logger" so there's no name conflict as "log" is a function in bash
  logger() {
    echo "`date`: $1"
  } # logger

  #*****************************************************************************
  # Expand Script Lines or output regular lines
  # Parameters
  # $1 FILE_LINE: This is the current line from the $IN_FILE
  #******************************************************************************
  process_line (){
    local FILE_LINE=$1

    # logger "Is $1 a script?"
    # ${1:1} https://stackoverflow.com/questions/30197247/using-11-in-bash
    # In this case it's removing the "@" from each line in the script

    if [ -f "${FILE_LINE:1}" ]
    then
      logger "Expanding file: ${FILE_LINE:1}"
      echo "-- $FILE_LINE" >> $OUT_FILE
      
      # Recursively open each file as they themselves may reference other files
      process_file ${FILE_LINE:1}
      
      # Print blank lines
      echo >> $OUT_FILE
      echo >> $OUT_FILE
    else
      echo "$line" >> $OUT_FILE
    fi

  } # process_line


  # Will loop over a file and process each line
  # 
  # Note: process_line will recursively call this function
  # 
  # Parameters
  # $1 file_name
  process_file(){
    echo "Processing: $file_name"
    local file_name=$1

    while IFS='' read -r line || [[ -n "$line" ]]; do
      process_line $line
    done < "$file_name"
  }


  logger "Procesing $IN_FILE into $OUT_FILE"

  echo "-- =============================================================================" > $OUT_FILE
  echo "-- ==========================  Full $IN_FILE file" >> $OUT_FILE
  echo "-- =============================================================================" >> $OUT_FILE
  echo -n >> $OUT_FILE

  # Start merging the original file which will recursively find other files
  process_file $IN_FILE
} # merge_sql_files


# Initialize
init(){
  local PROJECT_DIR_FOLDER_NAME=$(basename $PROJECT_DIR)
  local VSCODE_TASK_FILE=$PROJECT_DIR/.vscode/tasks.json
  
  # #36 Change the VSCode Labels
  # See: https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed/131940#131940
  sed -i -bak "s/CHANGEME_TASKLABEL/$PROJECT_DIR_FOLDER_NAME/g" $VSCODE_TASK_FILE
  # Remove backup versin of file
  rm $VSCODE_TASK_FILE-bak


  # Initializing Helper
  load_colors
  load_config
  verify_config
}

init