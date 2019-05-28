#!/bin/bash
# Author : BCE - 1905 - 1906
#
# correction into i18n po files.
#	restablish fake wrapping done by lokalize...
#	checking non existing save
#	preventively creating a save before eventual modifications
#	and removing it if no alteration
#
# Histo
#	V0.1
#		base
#		non treatment for po commented lines
#		...
#	V1.0
#		checking save don't exist => checking non existing save
#		+ trace only for modified files
#	issue : sometimes to launch twice...


#
lg=fr 		# language digramme xx.po

# forcing a save name (v 0.2)
# sav=sav0 # permit indental saves use sav, sav1, sav2, ... (v 0.2)
# for fic in $(find . -name $lg.po |sort) ; do
# 	[[ -e $fic.$sav ]] &&
# 		echo -e "=== $fic.$sav preexist\n\t\t ABANDON"  >&2 &&
# 		exit -1
# done

# autofinding a non used savename	(v 1.0)
echo "Seeking for a non used save name..." >&2
i=0
while : ; do
	j=$i
	sav=sav$i # permit indental saves use sav1, sav2, ...
	nb=$(find . -name $lg.po.$sav -print -quit 2> /dev/null | wc -l)
	[[ $nb -eq 0 ]] && break
	(( ++i ))
done

echo "OK, no save $sav preexist ! => processing saving $lg.po into $lg.po.$sav" >&2
sleep 1

	# -exec echo " == restablishing {} =="  >&2 \; 	\
find . -name $lg.po -type f \
	-exec sed -i.$sav \
		-e '/^[^#]/ s/\\n\([^"]\)/\\n"\n"\1/g'	 \
		-e '/^msgid "[^"]/  N;s/^msgid \("[^\n]\+"\)\n"/msgid ""\n\1\n"/' \
		-e '/^msgstr "[^"]/ N;s/^msgstr \(".\+"\)\n"/msgstr ""\n\1\n"/' \
		-e '/^[^#]/ s/\\n\([^"]\)/\\n"\n"\1/g'	 \
			{} \; \
	-exec bash -c '[[ $(diff {} {}.'$sav' 2>/dev/null | wc -l ) == 0 ]] && rm {}.'$sav' || echo "   cleaning {} !!" >&2' \;

	# note : doubling s/\\n\([^"]\)/../g to cover the case : ".*\\n\\n.*"

echo "!! END $0 !" >&2
