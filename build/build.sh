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


# TODO mdsouza: renable
# echo -e "*** Running Release Auto Complete ***\n"
# cd $SCRIPT_DIR
# node $SCRIPT_DIR/relase-autocomplete/release.js ./release/_release.sql

# TODO #10 APEX Nitro configuration
# echo -e "*** APEX Nitro Publish ***\n"
# apex-nitro publish gre

# Export APEX applications, defined in project-config.sh
export_apex_app $VERSION


