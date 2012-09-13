#!/bin/bash

# Bash script to create a zipped package labeled with current date

# Get current date (UTC)
date=`date -u '+%Y-%m-%d'`
# Temp working dir
temp_dir="/tmp/colobot-data.$RANDOM"
# Name of directory in zip
dir_name="colobot-data-$date"
# Name of zip
zip_name="$dir_name.zip"

echo "Copying files to temp dir: $temp_dir"
mkdir "$temp_dir"
cp -R . "$temp_dir/$dir_name"

old_pwd=`pwd`
cd "$temp_dir"
sed -i 's/\[\[\[date\]\]\]/'"$date"'/' "$dir_name/README.txt"
echo "Zipping files"
zip -9 -r "$zip_name" "$dir_name" > /dev/null

cd "$old_pwd"
mv "$temp_dir/$zip_name" .
echo "Removing temp files"
rm -rf "$temp_dir"
echo "Package $zip_name created"
