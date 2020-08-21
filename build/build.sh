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
source $SCRIPT_DIR/../scripts/helper.sh


echo -e "*** Listing all views and packages ***\n"
list_all_files views release/all_views.sql $EXT_VIEW
list_all_files packages release/all_packages.sql $EXT_PACKAGE_SPEC,$EXT_PACKAGE_BODY

# TODO #10 APEX Nitro configuration
# echo -e "*** APEX Nitro Publish ***\n"
# apex-nitro publish gre

# Export APEX applications, defined in project-config.sh
export_apex_app $VERSION

# Generate release support sql files 
gen_release_sql