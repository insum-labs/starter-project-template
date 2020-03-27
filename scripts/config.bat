
rem Remove all the .deleteme files

del ../install/.deleteme
del ../bin/.deleteme
del ../data/.deleteme
del ../build/.deleteme
del ../release/.deleteme
del ../docs/.deleteme
del ../lib/.deleteme
del ../www/.deleteme
del ../www/src/css/.deleteme
del ../www/src/js/.deleteme
del ../www/src/.deleteme
del ../www/src/img/.deleteme
del ../www/src/lib/.deleteme
del ../conversion/.deleteme
del ../packages/.deleteme
del ../synonyms/.deleteme
del ../triggers/.deleteme
del ../views/.deleteme
del ../sql/.deleteme

rem Remove repo images
del ../tmp/*.png

rem Add bin, tmp to the .gitignore
echo "bin" >> ../.gitignore
echo "tmp" >> ../.gitignore

type "Remember to enter your workspace and app number in app/_ins.sql"
