#!/bin/sh

set -e

LEVELS_I18N_PATH=$1
PO4A_FILE=$2

export PERL5LIB=${LEVELS_I18N_PATH}/scripts/perllib${PERL5LIB+:}$PERL5LIB

po4a -k0 -v -f $PO4A_FILE
