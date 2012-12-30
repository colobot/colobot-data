#!/bin/sh

set -e

lang_short="E F"
lang_long="en fr"

allsfile_c=levels
allsfile_e=xhtml

gen_i18n_file () {

levelfileorig=$1
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
			echo "<${key}_$subkey>$subval</${key}_$subkey>" >> $destfile
			echo "<p type=\"$key $subkey\"><!-- $key ($subkey) -->$subval</p>" >> $allsfile
		done
	done
	echo "</$levelfile>" >> $destfile
done

echo "[type:xml] $levelfile.xml \$lang:$levelfile.\$lang.xml" >> po4a.cfg

echo -n "."
}

echo "* Cleanup"

rm -f *.xml
rm -f $allsfile_c.$allsfile_e
rm -f $allsfile_c.*.$allsfile_e
rm -f po4a.cfg

echo "* Create initial files"

echo "[po_directory] po/" > po4a.cfg

echo "<html><body>" > $allsfile_c.$allsfile_e
for lang in $lang_long; do
	if [ $lang = "en" ]; then continue; fi;
	echo "<html><body>" > $allsfile_c.$lang.$allsfile_e
done

echo -n "* Generate intermediate translation files for levels: "
for level in $(ls *.txt); do
	gen_i18n_file $level
done
echo "done"

echo "</body></html>" >> $allsfile_c.$allsfile_e

echo -n "* Generate pristine potfile: "
po4a-gettextize -M UTF-8 -f xhtml -m $allsfile_c.$allsfile_e > po/levels.pot 2>/dev/null
echo "done"

echo -n "* Generate translation files: "
for lang in $lang_long; do
	if [ $lang = "en" ]; then continue; fi;
	echo -n "$lang"
	echo "</body></html>" >> $allsfile_c.fr.$allsfile_e
	pofile=po/$lang.po
	if [ ! -f $pofile ]; then
		po4a-gettextize -M UTF-8 -L UTF-8 -f xhtml -m levels.xhtml -l levels.$lang.xhtml > $pofile 2>/dev/null
		sed -e 's/, fuzzy//g' -i $pofile
	fi
	po4a-updatepo -M UTF-8 -f xhtml -m levels.xhtml -p $pofile 2>/dev/null
done
echo " done"

echo -n "* Cleanup po4a infrastructure, run po4a … "
po4a -f po4a.cfg 2>/dev/null
echo "done"

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
					keyval=$(grep "^<${key}_${subkey}>" $xmlfile | sed -e "s|^<${key}\_${subkey}>\(.*\)<\/${key}\_${subkey}>$|\1|g")
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
