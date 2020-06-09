#!/bin/bash

# ./build.sh <version>
# Parameters
#   version: This is embedded in the APEX application release.

if [ -z "$1" ]; then
  echo 'Missing version number'
  exit 0
fi

VERSION=$1

# This is the directory that this file is located in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo "Start Dir: $SCRIPT_DIR\n"

# Load Helper and config
source $SCRIPT_DIR/../scripts/bash-helper.sh


cd $SCRIPT_DIR

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




