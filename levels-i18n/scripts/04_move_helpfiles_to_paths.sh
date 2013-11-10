#!/bin/sh

set -e

codename=$1
orig_file=$2
dest_dir=$3
HELPDIR=$4
HELPDEST=$5
CMAKE_CURRENT_SOURCE_DIR=$6

orig_l10n_file=$(basename $orig_file .txt)
orig_l10n_dir=$(dirname $orig_file)

# Get all language codes
for lcodef in $(ls ${codename}.*.languagecode); do
	# Get the one-letter language code
	LCODE=$(cat $lcodef)
	lang=$(echo $lcodef | sed -e 's/.*\.\(.*\)\.languagecode/\1/')
	# Foreach, rename the source files
	mkdir -p $dest_dir/$LCODE/$HELPDEST

	orig_trans=$CMAKE_CURRENT_SOURCE_DIR/$HELPDIR/$LCODE/$orig_l10n_file.txt

	# Copy the translated file to the correct pathi
	if [ -e $orig_l10n_dir/$orig_l10n_file.$lang.txt ]; then
		cp -Lf $orig_l10n_dir/$orig_l10n_file.$lang.txt $dest_dir/$LCODE/$HELPDEST/$orig_l10n_file.txt
		# Mark the source file that the translation is supposed to replace # Replace false by true to make it happen
		if [ -e $orig_trans ] && false; then
			sed -e '/Obsoleted translation/d;/This translated file/d' $orig_trans >$orig_trans.temp
			echo "\\\\b; Obsoleted translation\nThis translated file has been replaced by it's PO-based counterpart and should be removed.\n" > $orig_trans
			cat $orig_trans.temp >> $orig_trans
			rm $orig_trans.temp
		fi
	elif [ -e $orig_trans ]; then
		cp -Lf $orig_trans $dest_dir/$LCODE/$HELPDEST/$orig_l10n_file.txt
	fi
done

mkdir -p $dest_dir/E/$HELPDEST
# Copy the english file to the correct path too
cp -Lf $orig_file $dest_dir/E/$HELPDEST/$orig_l10n_file.txt
