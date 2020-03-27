
rem Remove all the .deleteme files

del ../install/.deleteme
del ../bin/.deleteme
del ../release/.deleteme
del ../docs/.deleteme
del ../www/.deleteme
del ../www/src/css/.deleteme
del ../www/src/js/.deleteme
del ../www/src/.deleteme
del ../www/src/img/.deleteme
del ../www/src/lib/.deleteme
del ../conversion/.deleteme
del ../plsql/.deleteme
del ../views/.deleteme
del ../tmp/.deleteme
del ../sql/.deleteme

rem Remove repo images
del ../tmp/*.png

rem Add bin, tmp to the .gitignore
echo "bin" >> ../.gitignore
echo "tmp" >> ../.gitignore

type "Remember to enter your workspace and app number in app/_ins.sql"
