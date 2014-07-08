#!/bin/sh

set -e

levelfile=$1
translations_prefix=$2
PODIR=$3
targetfile=$4

rootfilename=$(basename $translations_prefix)

# Autodetect translated languages
script_path=$(dirname $0)
linguas=$(cd $PODIR/; ls *.po | sed -e 's/\.po$//g')

echo -n "" > $targetfile

# Make sure we take english (first, but it's not really important)
for lang in en $linguas; do
	dotlang=".$lang"
	if [ "$lang" = "en" ]; then
		dotlang="";
	fi
	i18nfile=$translations_prefix$dotlang.txt
	if [ -f $i18nfile ]; then
		sed -n '/^Title/p;/^Resume/p;/^ScriptName/p' $i18nfile >> $targetfile
	fi
done
echo "// End of level headers translations" >> $targetfile
echo "" >> $targetfile
sed -e '/^Title/d;/^Resume/d;/^ScriptName/d' $levelfile >> $targetfile
