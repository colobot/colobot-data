#!/bin/sh

set -e

outdir=$1

if [ -z "$outdir" ] || [ "$outdir" = "." ] || [ ! -d $outdir ]; then
	echo "No existing output directory provided; syntax is : $0 output_directory"
	return 1;
fi

linguas="en fr"

categories="defi free win lost perso proto"
for sc_i in $(seq 1 9); do
	categories="$categories scene$sc_i"
done
for tr_i in $(seq 1 7); do
	categories="$categories train$tr_i"
done

common_i18n_ext=xhtml

gen_i18n_file () {

levelfileorig=$1
common_i18n_file=$2

if [ -z "$levelfileorig" ] || [ ! -f $levelfileorig ]; then
	echo "No file name provided; syntax is : $0 filename.txt"
	return 1;
fi

levelfile=$(echo $levelfileorig | sed -e "s/\.txt$//g")

destfile=$levelfile.xml;
allsfile=$common_i18n_file.$common_i18n_ext;

echo "<$levelfile>" > $destfile
echo "<h1><!-- Level: $levelfile --></h1>" >> $allsfile
for key in Title Resume ScriptName; do
	for subkey in text resume; do
		subval=$(grep "^$key\.E.*$subkey" $levelfileorig | sed -e "s/^.*$subkey=\"\([^\"]*\)\".*$/\1/")
		# Always write entries, even when empty, otherwise breaks po4a-gettextize
		echo "<${key}_$subkey>$levelfile:$subval</${key}_$subkey>" >> $destfile
		echo "<p type=\"$key $subkey\">$levelfile:$subval</p>" >> $allsfile
	done
done
echo "</$levelfile>" >> $destfile

echo "[type:xml] $levelfile.xml \$lang:$levelfile.\$lang.xml" >> $common_i18n_file-po4a.cfg

echo -n "."
}

for category in $categories; do
	echo "* Category: $category "

	rm -f $category*.xml
	rm -f $category-po4a.cfg

	echo " 0 - Create initial files"

	echo "[po_directory] $category-po/" > $category-po4a.cfg
	mkdir -p $category-po

	echo -n " 1 - Generate transitional source translation files from level files"

	echo "<html><body>" > $category.$common_i18n_ext
	for lang in $linguas; do
		if [ $lang = "en" ]; then continue; fi;
		echo "<html><body>" > $category.$lang.$common_i18n_ext
	done

	for level in $(ls $category*.txt); do
		gen_i18n_file $level $category
	done
	echo "</body></html>" >> $category.$common_i18n_ext

	echo "done"

	echo -n " 3 - Generate pristine potfile: "
	po4a-gettextize -M UTF-8 -f xhtml -m $category.$common_i18n_ext > $category-po/$category.pot 2>/dev/null
	echo "done"

	echo -n " 4 - Generate translation files: "
	for lang in $linguas; do
		if [ $lang = "en" ]; then continue; fi;
		echo -n "$lang "
		echo "</body></html>" >> $category.$lang.$common_i18n_ext
		pofile=$category-po/$lang.po
		if [ ! -f $pofile ]; then
			sed -e 's/charset=CHARSET/charset=UTF-8/g' $category-po/$category.pot > $pofile
		fi
		po4a-updatepo -M UTF-8 -f xhtml -m $category.$common_i18n_ext -p $pofile 2>/dev/null
	done
	echo " done"

	echo -n " 5 - Cleanup po4a infrastructure, run po4a … "
	po4a -f $category-po4a.cfg 2>/dev/null 1>&2
	echo "done"

	echo -n " 6 - Inject translation in level files: "
	
	for levelfile in $(ls $category*.txt); do
		# Always start afresh
		rm -f $outdir/$levelfile

		rootfilename=$(echo $levelfile | sed 's/\.txt$//g')
		for lang in $linguas; do
			dotlang=".$lang"
			langcode="";
			case $lang in
				en) dotlang=""; langcode=".E";;
				fr) langcode=".F";;
				pl) langcode=".P";;
			esac
			xmlfile=$rootfilename$dotlang.xml
			echo -n "."
			if [ -f $xmlfile ]; then
				for key in Title Resume ScriptName; do
					lineend=""
					for subkey in text resume; do
						keyval=$(grep "^<${key}_${subkey}>" $xmlfile | sed -e "s|^<${key}\_${subkey}>${rootfilename}:\(.*\)<\/${key}\_${subkey}>$|\1|g")
						if [ -n "$keyval" ]; then
							lineend="$lineend $subkey=\"$keyval\""
						fi
					done
					if [ -n "$lineend" ]; then
						echo "$key$langcode$lineend" >> $outdir/$levelfile
					fi
				done
			fi
		done
		sed -e '/^Title/d;/^Resume/d;/^ScriptName/d' $levelfile >> $outdir/$levelfile
	done
	echo "done."
done
