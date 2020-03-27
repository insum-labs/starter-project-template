#!/bin/bash

# This script will clean the release script and start a new template
echo "Start new release"
rm ../release/[a-z]*.sql
cp ../release/_release_template.sql ../release/_release.sql