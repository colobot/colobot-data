#!/bin/sh

set -e

# MUST be run from ${CMAKE_CURRENT_BINARY_DIR}

srcdir=$1 # absolute
PODIR=$2 # relative
LEVEL_CODENAME=$3 # relative
SCENEFILE=$4 # relative
HELPDIR=$5 # relative

if [ ! -d $LEVEL_CODENAME-po -o -h $LEVEL_CODENAME-po ]; then
    rm -f $LEVEL_CODENAME-po
    ln -sf $srcdir/$PODIR $LEVEL_CODENAME-po
fi
echo "[po_directory] $LEVEL_CODENAME-po"

# Create a pseudo file for the translation of the language code
echo "[type:text] ${LEVEL_CODENAME}.languagecode \$lang:${LEVEL_CODENAME}.\$lang.languagecode"
echo "E" > ${LEVEL_CODENAME}.languagecode

# Create symlink for relative paths in po4a
mkdir -p $LEVEL_CODENAME

if [ -n "$SCENEFILE" ]; then
    # Levels are precompiled, they are already in the current dir
    for scene in $(cd $srcdir/; ls $SCENEFILE); do
        scene_=$(basename $scene .txt)
        $(cd $LEVEL_CODENAME;
            if [ ! -f $scene_.txt -o -h $scene_.txt ]; then
                rm -f $scene_.txt;
                ln -sf $srcdir/$scene $scene_.txt;
            fi
         )
        echo "[type:colobotlevel] $LEVEL_CODENAME/$scene_.txt \$lang:$LEVEL_CODENAME/$scene_.\$lang.txt"
    done
fi

# Create symlink for relative paths in po4a
mkdir -p $LEVEL_CODENAME-help

if [ -d $srcdir/$HELPDIR ]; then
    for helpfile in $(cd $srcdir/$HELPDIR; ls *.txt); do
        helpfile_=$(basename $helpfile .txt)
        $(cd $LEVEL_CODENAME-help;
            if [ ! -f $helpfile_.txt -o -h $helpfile_.txt ]; then
                rm -f $helpfile_.txt;
                ln -sf $srcdir/$HELPDIR/$helpfile $helpfile_.txt;
            fi
         )
        echo "[type:colobothelp] $LEVEL_CODENAME-help/$helpfile_.txt \$lang:$LEVEL_CODENAME-help/$helpfile_.\$lang.txt"
    done
fi
