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


# File Mappings
# This will be used in VSCode to allow for quick generate of a given file based on template data
# Format:
# <name>:<template_file prefix (no extension)>:<file extensions (; delimited)>:<destination directory>
# 
# Definitions:
# - name: Name that will be mapped to VSCode task
# - template file: Template file prefix to use (no extension)
# - file extensions: ";" delimited list of file extensions to reference each template file
# - destination directory: where to store the new file
OBJECT_FILE_TEMPLATE_MAP=""
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,package:templates/template_pkg:$EXT_PACKAGE_SPEC;$EXT_PACKAGE_BODY:packages"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,view:templates/template_view:$EXT_VIEW:views"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,data_array:templates/template_data_array:sql:data"
OBJECT_FILE_TEMPLATE_MAP="$OBJECT_FILE_TEMPLATE_MAP,data_json:templates/template_data_json:sql:data"