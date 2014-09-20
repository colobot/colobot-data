#!/bin/bash

# Stop on errors
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
    sed -i -E 's|^#: .*(levels/.*)$|#: \1|' "$po_file"
    # remove the creation date
    sed -i -E 's|^("POT-Creation-Date:).*$|\1 DATE\\n"|' "$po_file"
done

# update the dummy signal files to indicate success
# we also have to touch translation signalfile because it's supposed to be modified later than po files
touch "$TRANSLATION_SIGNALFILE"
touch "$PO_CLEAN_SIGNALFILE"