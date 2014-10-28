#!/bin/bash

##
# Script to do some cleaning up of merged/generated *.po and *.pot files
#
# It is basically a sed wrapper that does two things:
# - remove information about absolute filenames which were used to generate translations
# - remove modification date of file
#
# By doing these two things, it makes sure that *.po and *.pot files do not change
# compared to versions stored in repository when building the project
#
# The arguments are a colon-separated list of *.po or *.pot files and
# two dummy signal files used by build system that must be updated
##

# stop on errors
set -e

if [ $# -ne 3 ]; then
    echo "Invalid arguments!" >&2
    echo "Usage: $0 po_file1[:po_file2;...] translation_signalfile po_clean_signalfile" >&2
    exit 1
fi

PO_FILES="$1"
TRANSLATION_SIGNALFILE="$2"
PO_CLEAN_SIGNALFILE="$3"

IFS=':' read -a po_files_array <<< "$PO_FILES"

for po_file in "${po_files_array[@]}"; do
    # strip unnecessary part of file names
    sed -i 's|^#: .*data/\(.*\)$|#: \1|' "$po_file"
    # remove the creation date
    sed -i 's|^\("POT-Creation-Date:\).*$|\1 DATE\\n"|' "$po_file"
done

# update the dummy signal files to indicate success
# we also have to touch translation signalfile because it's supposed to be modified later than po files
touch "$TRANSLATION_SIGNALFILE"
touch "$PO_CLEAN_SIGNALFILE"