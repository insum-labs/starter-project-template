#!/bin/bash


# Remove all the .gitkeep files
# find .. -name ".gitkeep" -exec rm -f {} \;

# Add bin, tmp to the .gitignore
echo "bin" >> ../.gitignore
echo "tmp" >> ../.gitignore

# Remove repo images
rm ../tmp/*.png

# Done
echo "Remember to enter your workspace and app number in app/_ins.sql"
