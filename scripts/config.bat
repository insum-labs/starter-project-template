

rem Remove repo images
del ../tmp/*.png

rem Add bin, tmp to the .gitignore
echo "bin" >> ../.gitignore
echo "tmp" >> ../.gitignore

type "Remember to enter your workspace and app number in app/_ins.sql"
