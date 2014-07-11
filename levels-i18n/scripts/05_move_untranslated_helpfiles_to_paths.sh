#!/bin/sh

set -e

HELP_I18N_TARGET=$1
HELPDEST=$2
HELPDIR_FULL=$3

for langdir in $(ls ${HELPDIR_FULL}); do
    if [ "$langdir" != "po" ]; then
        mkdir -p ${HELP_I18N_TARGET}/$langdir/${HELPDEST}
        cp ${HELPDIR_FULL}/$langdir/* ${HELP_I18N_TARGET}/$langdir/${HELPDEST}/
    fi
done
