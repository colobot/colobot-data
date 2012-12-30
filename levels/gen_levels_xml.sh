#!/bin/sh

set -e

lang_short="E F"
lang_long="en fr"

categories="defi free lost perso proto scene1 scene2 scene3 scene4 scene5 scene6 scene7 scene8 scene9 train1 train2 train3 train4 train5 train6 train7"
empty_categories="win"

allsfile_e=xhtml

gen_i18n_file () {

levelfileorig=$1
allsfile_c=$2

levelfile=$(echo $levelfileorig | sed -e "s/\.txt$//g")

if [ -z "$levelfileorig" ] || [ ! -f $levelfileorig ]; then
	echo "No file name provided; syntax is : $0 filename.txt"
	return 1;
fi

for lang in $lang_short; do
	dot=".";
	langcode="";
	case $lang in
		E) dot="";;
		F) langcode=fr;;
	esac
	destfile=$levelfile$dot$langcode.xml;
	allsfile=$allsfile_c$dot$langcode.$allsfile_e;
	echo "<$levelfile>" > $destfile
	echo "<h1><!-- Level: $levelfile --></h1>" >> $allsfile
	for key in Title Resume ScriptName; do
		for subkey in text resume; do
			subval=$(grep "^$key.$lang.*$subkey" $levelfileorig | sed -e "s/^.*$subkey=\"\([^\"]*\)\".*$/\1/")
			# Always write entries, even when empty, otherwise breaks po4a-gettextize
			echo "<${key}_$subkey>$levelfile:$subval</${key}_$subkey>" >> $destfile
			echo "<p type=\"$key $subkey\">$levelfile:$subval</p>" >> $allsfile
		done
	done
	echo "</$levelfile>" >> $destfile
done

echo "[type:xml] $levelfile.xml \$lang:$levelfile.\$lang.xml" >> $allsfile_c-po4a.cfg

echo -n "."
}

echo "* Cleanup"

rm -f *.xml
rm -f *po4a.cfg

for category in $categories; do
echo "* Category: $category "

	echo " * Create initial files"

	echo "[po_directory] $category-po/" > $category-po4a.cfg
	mkdir -p $category-po

	echo -n " * Generate transitional translation files "

	echo "<html><body>" > $category.$allsfile_e
	for lang in $lang_long; do
		if [ $lang = "en" ]; then continue; fi;
		echo "<html><body>" > $category.$lang.$allsfile_e
	done

	for level in $(ls $category*.txt); do
		gen_i18n_file $level $category
	done
	echo "done"

	echo "</body></html>" >> $category.$allsfile_e


	echo -n " * Generate pristine potfile: "
	po4a-gettextize -M UTF-8 -f xhtml -m $category.$allsfile_e > $category-po/$category.pot 2>/dev/null
	echo "done"

	echo -n " * Generate translation files: "
	for lang in $lang_long; do
		if [ $lang = "en" ]; then continue; fi;
		echo -n "$lang"
		echo "</body></html>" >> $category.$lang.$allsfile_e
		pofile=$category-po/$lang.po
		if [ ! -f $pofile ]; then
			po4a-gettextize -M UTF-8 -L UTF-8 -f xhtml -m $category.$allsfile_e -l $category.$lang.$allsfile_e > $pofile
			sed -e 's/, fuzzy//g' -i $pofile
		else
			po4a-updatepo -M UTF-8 -f xhtml -m $category.$allsfile_e -p $pofile 2>/dev/null
		fi
	done
	echo " done"

	echo -n " * Cleanup po4a infrastructure, run po4a … "
	po4a -f $category-po4a.cfg 2>/dev/null 1>&2
	echo "done"

done

echo -n "* Inject translation in level files: "

for levelfile in $(ls *.txt); do
	rootfilename=$(echo $levelfile | sed 's/\.txt$//g')
	mv $levelfile $levelfile.old
	for lang in $lang_long; do
		case $lang in
			en) xmlfile=$rootfilename.xml; langcode=".E";;
			fr) xmlfile=$rootfilename.$lang.xml; langcode=".F";;
		esac
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
					echo "$key$langcode$lineend" >> $levelfile
				fi
			done
		fi
	done
	sed -e '/^Title/d;/^Resume/d;/^ScriptName/d' $levelfile.old >> $levelfile
	rm $levelfile.old
done

echo "done."
