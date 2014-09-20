#!/bin/bash

# Stop on errors
set -e

if [ $# -ne 4 ]; then
    echo "Invalid arguments!" >&2
    echo "Usage: $0 source_file1[:source_file2:...] output_file1[:output_file2:...] po4a_config_file translation_signalfile" >&2
    exit 1
fi

SOURCE_FILES="$1"
OUTPUT_FILES="$2"
PO4A_FILE="$3"
TRANSLATION_SIGNALFILE="$4"

# get the directory where the script is in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# generate translated files using po4a
if [ -n "$VERBOSE" ]; then
    verbosity="-v"
else
    verbosity="-q"
fi
PERL5LIB="${SCRIPT_DIR}/perllib${PERL5LIB+:}$PERL5LIB" po4a -k0 $verbosity -f "$PO4A_FILE" --msgmerge-opt -F

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