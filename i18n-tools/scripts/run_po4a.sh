#!/bin/bash

##
# Script to execute PO4A with proper enviroment and commandline options
#
# The arguments are config file which is assumed to be already present and
# optional dummy signal file which is used by build system
##

# stop on errors
set -e

if [ $# -ne 1 -a $# -ne 2 ]; then
    echo "Invalid arguments!" >&2
    echo "Usage: $0 po4a_config_file [po4a_signalfile]" >&2
    exit 1
fi

PO4A_CONFIG_FILE="$1"
PO4A_SIGNALFILE="$2"

# get the directory where the script is in
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# run po4a
if [ -n "$VERBOSE" ]; then
    verbosity="-v"
else
    verbosity="-q"
fi
PERL5LIB="${SCRIPT_DIR}/perllib${PERL5LIB+:}$PERL5LIB" po4a -k0 $verbosity -f "$PO4A_CONFIG_FILE" --msgmerge-opt=--no-wrap --master-charset=UTF-8 --localized-charset=UTF-8

# if applicable, touch dummy signal file to indicate success
if [ -n "$PO4A_SIGNALFILE" ]; then
    touch "$PO4A_SIGNALFILE"
fi
