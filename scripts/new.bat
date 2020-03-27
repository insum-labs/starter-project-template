
rem This script will clean the release script and start a new template

echo "Start new release"

rem Does that work in Windows?
del ../release/[a-z]*.sql

copy ../release/_release_template.sql ../release/_release.sql