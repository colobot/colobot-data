#!/bin/bash

##
# Script to consolidate multiple translated level files (scene.txt or chaptertitle.txt),
# generated previously by PO4A, into a single all-in-one output file
#
# It supports multiple pairs of source and output files and makes the assumption that
# each source file was processed by PO4A to yield output files named like $output_file.$language_code
#
# Basically, it is a simple sed wrapper that uses the source file and the translated files to copy-paste
# content into resulting output file
#
# The arugments are list of source files as a colon-separated list, list of output files also as colon-separated list
# and dummy signal file used by build system
##

# Stop on errors
set -e

if [ $# -ne 3 ]; then
    echo "Invalid arguments!" >&2
    echo "Usage: $0 source_file1[:source_file2:...] output_file1[:output_file2:...] translation_signalfile" >&2
    exit 1
fi

SOURCE_FILES="$1"
OUTPUT_FILES="$2"
TRANSLATION_SIGNALFILE="$3"

IFS=':' read -a source_files_array <<< "$SOURCE_FILES"
IFS=':' read -a output_files_array <<< "$OUTPUT_FILES"

for index in "${!source_files_array[@]}"; do
    source_file="${source_files_array[index]}"
    output_file="${output_files_array[index]}"

    # generate output file
    echo -n "" > "$output_file"

    # first, write original English headers
    sed -n '/^Title/p;/^Resume/p;/^ScriptName/p' "$source_file" >> "$output_file"

    # now, copy translated headers from translated files
    # (translated files are named output file + suffix with language code)
    for translated_file in $output_file.*; do
        sed -n '/^Title/p;/^Resume/p;/^ScriptName/p' "$translated_file" >> "$output_file"
    done
    echo "// End of level headers translations" >> "$output_file"
    echo "" >> "$output_file"

    # copy the rest of source file, excluding headers
    sed -e '/^Title/d;/^Resume/d;/^ScriptName/d' "$source_file" >> "$output_file"
done

# update the dummy signal file to indicate success
touch "$TRANSLATION_SIGNALFILE"