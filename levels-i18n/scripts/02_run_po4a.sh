#!/bin/sh

set -e

LEVELS_I18N_PATH=$1
PO4A_FILE=$2

export PERLLIB=${LEVELS_I18N_PATH}/scripts/perllib

po4a -k100 -v -f $PO4A_FILE
