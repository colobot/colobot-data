#!/bin/bash

# Bash script to create a zipped package labeled with current date

# Get current date (UTC)
date=`date -u '+%Y-%m-%d'`
# Name of directory in zip
dir_name="colobot-data-$date"
# Name of zip
zip_name="$dir_name.zip"

# git branches
current_branch=$(git rev-parse --abbrev-ref HEAD)
release_branch=${current_branch}_release_$date

# Create new branch for the date substitution
git checkout -b $release_branch >/dev/null 2>&1
# Prepare the release where needed
sed -i 's/\[\[\[date\]\]\]/'"$date"'/' README.txt

# Commit the changes
git commit README.txt -m "colobot-data $date release" >/dev/null

# Create the zipfile
echo -n "Creating package $zip_name …"
git archive --prefix=$dir_name/ --format=zip $release_branch > ../$dir_name.zip
echo " done!"

# Cleanup our trails
git checkout $current_branch >/dev/null 2>&1
git branch -D $release_branch >/dev/null
