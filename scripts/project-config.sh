#!/bin/bash

# Name of Schema
SCHEMA_NAME=CHANGEME
# Name of default workspace that applications are associated with
APEX_WORKSPACE=CHANGEME
# Comma delimited list of APEX Applications to export. Ex: 100,200
APEX_APP_IDS=CHANGEME


# File extensions
# Will be used throughought the scripts to generate lists of packages, views, etc from the filesystem
EXT_PACKAGE_SPEC=pks
EXT_PACKAGE_BODY=pkb
EXT_VIEW=sql