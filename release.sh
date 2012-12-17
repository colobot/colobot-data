#!/bin/bash

# Bash script to create a zipped package labeled with current date

# Get current date (UTC)
version=`date -u '+%Y-%m-%d'`
# Full archive name
git_release_tag=colobot-data-$version
# Name of archive
archive_name="$git_release_tag.zip"

echo -n "Preparing the $version release …"
  # Prepare the release where needed
  for f in README.md CHANGELOG.txt; do
    sed -i 's/\*IN-DEVELOPEMENT\*/'"$version"'/' $f
    git add $f
  done

  # Commit the changes
  git commit -m "colobot-data $version release" >/dev/null
  git tag -m "colobot-data $version release" $git_release_tag
echo " done!"

# Create the zipfile
echo -n "Creating package $archive_name …"
  git archive --prefix=$git_release_tag/ --format=zip $git_release_tag > ../$archive_name
echo " done!"

echo -n "Post-release cleanup …"
# Cleanup our trails
git checkout HEAD^ README.md >/dev/null 2>&1
mv CHANGELOG.txt CHANGELOG-TAIL.txt
echo "*IN-DEVELOPEMENT*
----------
" > CHANGELOG.txt
cat CHANGELOG-TAIL.txt >> CHANGELOG.txt
rm CHANGELOG-TAIL.txt
git add CHANGELOG.txt

git commit -m "Post-release preparations" > /dev/null
echo " done!"
