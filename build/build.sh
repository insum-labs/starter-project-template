#!/bin/bash

# ./build.sh <version>
# Parameters
#   version: This is embedded in the APEX application release.

# TODO delete
# Load varaibles. Did this so we can check in this file without exposing passwords
CONFIG_FILE=config.sh


if [ -z "$1" ]; then
  echo 'Missing version number'
  exit 0
fi

VERSION=$1

# This is the directory that this file is located in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo "Start Dir: $SCRIPT_DIR\n"

# Load Helper
source $SCRIPT_DIR/../scripts/bash-helper.sh


cd $SCRIPT_DIR
if [[ ! -f $CONFIG_FILE ]] ; then
  echo -e "${COLOR_RED}Warning: database connection configuration is missing ${COLOR_RESET}"
  echo -e "${FONT_BOLD}Modify $CONFIG_FILE${FONT_RESET} with your DB connection string and APEX applications"
  cat > $CONFIG_FILE <<EOL
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

# Comma delimited list of APEX Applications to export. Ex: 100,200
APEX_APP_IDS=CHANGEME
EOL
  chmod 755 $CONFIG_FILE
  exit
fi


# Load config
# Variables expected:
#  DB_CONN="martin/martin123@localhost:32118/xepdb1"
sqlcl 
echo -e "*** Loading Config ***\n"
cd $SCRIPT_DIR
source ./$CONFIG_FILE


# TODO mdsouza: renable
# echo -e "*** Running Release Auto Complete ***\n"
# cd $SCRIPT_DIR
# node $SCRIPT_DIR/relase-autocomplete/release.js ./release/_release.sql

# TODO #10 APEX Nitro configuration
# echo -e "*** APEX Nitro Publish ***\n"
# apex-nitro publish gre

# APEX applications are defined in config.sh
echo -e "APEX Applications to export: $APEX_APP_IDS\n"


for APEX_APP_ID in $(echo $APEX_APP_IDS | sed "s/,/ /g")
do
  echo "APEX Export: $APEX_APP_ID"

  # Export single file app
  echo exit | $SQLCL $DB_CONN @apex_export_app.sql $APEX_APP_ID
  
  # Add release number to app
  # In order to support the various versions of sed need to add the "-bak"
  # See: https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed/131940#131940
  sed -i -bak "s/%RELEASE_VERSION%/$VERSION/" f$APEX_APP_ID.sql
  # Remove the backup version of file (see above)
  rm f$APEX_APP_ID.sql-bak

  # Move file to apex folder
  mv f$APEX_APP_ID.sql ../apex


  # Export split app (or APEXcl)
  echo exit | $SQLCL $DB_CONN @apex_export_app.sql $APEX_APP_ID -split
  # Move split folder
  rm -rf ../apex/f$APEX_APP_ID
  mv f$APEX_APP_ID ../apex

done




