#!/bin/bash
# Author : BCE - 19/05.
# extractions from i18n po files. (visualisazion only, no modifications)
#  extract all language translations for checks, grep, identify typo...
#  extract also links or tags
#  permit word i18n control (non case sensitive, with regexp)
#  identify fuzzy areas
# (to launch in main directory colobot or into any directory containing po files)
#
# designed for Colobot, some parts like -K may be specific, rest should be usable in other projects
#
#
version=V1.0.0      #thanks to upgrade this tag in case of change.
authorList="BCE"    #thanks to upgrade this tag in case of change.

usage(){
    echo " Purpose: extract language translations for checks."  >&2
    echo "          from every po files into subdirectories"    >&2
    echo ""   >&2
    echo " Usage: ${0##*/} [-l language_digram] -[AaTtKZf] [-s] [-O] [-hH] [-w pattern] [dir]"  >&2
    echo "      (-l xx and -lxx are equivalent, options can be put together)"   >&2
    if [[ $# -lt 1 ]]; then
        echo "   dir : optionnal directory and subdirectories where looking for xx.po files, current one by default"   >&2
        echo "  ==== processing types ==="  >&2
        echo "       : full wanted language extraction from every lg.po into subfolders"    >&2
        echo "  -a/A : tags link (<a xxx|yyy>zzz</a>) extraction only  (table presentation)"   >&2
        echo "  -t/T : tags extraction only (<tt xxx|yyy>zz<>/tt>) (table presentation)"   >&2
        echo "          A/T : like a/t, without inside part (zz) (for ref/link comparisons)"   >&2
        echo "  -K   : key tags only (\\\\key option;) (table presentation)"  >&2
        echo "  -Z   : identify fuzzy parts (non took in account translations...)"  >&2
        echo "  -f   : identify filenames references alterations"             >&2
        echo "  -w pattern: non case sensitive translation extraction for i18n checks (ignoring codes parts)" >&2
                    # non case sensitive...
                    # support regexp .*[]
                    #   sample : getI18n.sh -Ow "d[ée]fi"
                    # support also regexp +{} but escaping them
                    #   color can be disabled with C option
        echo "  -h   : this help page"                              >&2
        echo "  -H   : samples page"                                >&2
        echo "  ==== specializations ==="                           >&2
        echo "  -l lg : set language : {cs,de,fr,pl,ru,pt,..}.po sources files. (default is fr)"    >&2
        echo "  -e : corresponding english i18n origins instead"    >&2
        echo "  -O : origin from each line (usefull with sort)"     >&2
        echo "  -s : sort & count"                                  >&2
        #echo "  -C : disable color highlightment for -w"           >&2 # further batch treatments?
        echo "  dir : directory to analyse with its subdirectories" >&2
        echo "  (last opt argument) (default:current)"              >&2
        echo "" >&2
        echo "       Designed for i18n Colobot'uses - $version - $authorList"   >&2
    else
        echo "  -h : usage help page"                               >&2
        echo "  ==== samples ==="                                   >&2
        echo "     full brazilian portuguese i18n extraction"       >&2
        echo "  $0 -l pt"                                           >&2
        echo "     full fr i18n extraction with origin into a file having current date" >&2
        echo "  $0 -O -lfr > i18nFr.$(date +%y%m%d).txt"            >&2
        echo "     every german tags (sorted)"                      >&2
        echo "  ${0##*/} -l de -ts"                                 >&2
        echo "     compare 'a' tags between wanted lg & corresponding english (constumize spaces to be ignore)"  >&2
        echo "  ${0##*/} -Asl pl> s.tmp && ${0##*/} -Asel pl> e.tmp && meld [se].tmp && rm [se].tmp"    >&2
        echo "     every key-tags from russian (sorted) (e:original english part) (from there)" >&2
        echo "  ${0##*/} -KsOel ru ../.."                           >&2
        echo "     every fuzzy (ignored translations) parts into russian" >&2
        echo "  ${0##*/} -Zl ru"                                    >&2
        echo "     search for \"cell\" translations into czech"     >&2
        echo "  ${0##*/} -ewlcz \"cell\""                           >&2
        echo "     search for \"powerplant\"/\"lowerplant\" translations into polish files" >&2
        echo "  ${0##*/}"' -lpl -Oew "[PL]ower.\{0,2\}plant"'       >&2
        echo "     every key translated (from Colobot root)"        >&2
        echo "  ${0##*/}"' -Ksl..'                                  >&2
        echo "     every instruction tags translated (from Colobot root)" >&2
        echo "  ${0##*/}"' -Tsl.. |grep " cbot"'                    >&2
        echo "     every fr files containing a pattern (from Colobot root)"     >&2
        echo "  ${0##*/} -Olfr | grep -i tireur | sed 's/^.*\.\///' | uniq"  >&2
        echo "  ====================="                              >&2
    fi
}

KO(){
    usage
    echo "" >&2
    echo " -f, -t, -T, -K & -Z are incompatible options" >&2
    echo " -e , -f & -Z are also incompatible options" >&2
    exit 1
}

# internals vars & default values
language=fr     #language_digram
bSort=false
bOrig=false
bEnglish=false
bTags=false
bTagsLinkOnly=false
bTagsOnly=false
bKey=false
bFuzzy=false
bWord=false
sWord=""
bColor=true # hided option, only for -w, word highlightment
bFilesNameCheck=false
sSrc=""

# check params
while getopts ":esOtTaAhHl:KZvw:Cf" option ; do #IndevW
    # echo "option $option"  >&2
    case $option in
    e)  $bFuzzy && KO
        bEnglish=true ;;
    s)  bSort=true ;;
    O)  bOrig=true ;;
    t)  $bTags && KO
        bTags=true ;;
    T)  $bTags && KO
        bTags=true ; bTagsOnly=true ;;
    a)  $bTags && KO
        bTags=true ; bTagsLinkOnly=true ;;
    A)  $bTags && KO
        bTags=true ; bTagsLinkOnly=true ; bTagsOnly=true ;;
    K)  $bTags && KO
        bTags=true ; bKey=true ;;
    l)  language=$OPTARG
        case $language in
        "cs")   ;;
        "de")   ;;
        "fr")   ;;
        "pl")   ;;
        "ru")   ;;
        "pt")   ;;
        "..")   language='??' ;;    #every ones
        *)  usage
            echo "Unknown language : <$language> : not into {cs,de,fr,pl,ru,pt,..}" >&2
            exit 1;;
        esac ;;
    Z)  $bTags || $bEnglish && KO
        bTags=true; bFuzzy=true ;;
    f)  $bTags || $bEnglish && KO
        bTags=true; bFilesNameCheck=true ;;
    h)  usage; exit 1 ;;
    H)  usage 2; exit 1 ;;
    v)  echo $version ; exit 0;;
    \?) usage
        echo " $OPTARG : invalid option"  >&2
        exit 1 ;;
    w)  sWord=$OPTARG
        bWord=true ;;
    C)  bColor=false;;
    esac
done
shift $(($OPTIND - 1))

if [[ $# -gt 1 ]]; then
    usage
    echo " Unsupported arguments list (or option provide after the folder): $*"  >&2
    exit 1
fi

dir=.
if [[ $# -eq 1 ]]; then
    [[ ! -d $1 ]] &&
        usage &&
        echo " Unsupported arguments : not a directory : $*"  >&2 &&
        exit 1
    dir=$1
fi

if $bWord ; then
    [[ "${#sWord}" -lt 1 ]] &&
        usage &&
        echo " No argument provided for research of translations  : $*"  >&2 &&
        exit 1

    $bSort && usage && echo " argument -s incompatible with -w"  >&2 && exit 1
    $bTags && usage && echo " arguments -KtTZ are incompatible with -w"  >&2 && exit 1
    bTags=true
fi

#trace
sTags="language"
$bTags &&   sTags="tags from language"
$bKey  &&   sTags="special keys from language"
$bWord &&   $bEnglish && sTags="Translations for <$sWord>"   #IndevW
$bWord && ! $bEnglish && sTags="Translations sources for <$sWord>"   #IndevW

if $bFuzzy ; then
    echo "~~Extraction of fuzzy translations from $language.po" >&2
elif $bFilesNameCheck ; then
    echo "~~Extraction of alterations translations of filenames from $language.po" >&2
elif ! $bEnglish ; then
    echo "~~Extraction of $sTags : $language"   >&2
    sLangFilter='/msgstr/,/msgid/p'
    sLangFilter2="s/^msgid .*//"
    sLangFilter3='s/^msgstr //'
else
    echo "~~Extraction of $sTags : english from $language files"    >&2
    sLangFilter='/msgid/,/msgstr/p'
    sLangFilter2="s/^msgstr .*//"
    sLangFilter3="s/^msgid //"
fi

# corpus
if ! $bTags ; then  # full wanted language extraction
    for fic in $(find $dir -name "$language.po" |sort) ; do
        # echo "~~~~~~~ Extraction from : $fic ~~~~~~~ "    #>&2  #(not synchro)
        [[ $bOrig == true ]] &&
            sSrc="s:$:\t${fic}:"
        sed '1,17d' $fic <(echo "msgid ") |
        sed '/^#/d'             |
        sed -n "$sLangFilter"   |
        sed -e "$sLangFilter2"  \
            -e "$sLangFilter3"  \
            -e 's/^\"//'        \
            -e 's/\"$//'        \
            -e '/^$/d'          \
            -e "$sSrc"
    done | if $bSort ; then sort -i |uniq -ci ; else cat; fi

else    #  {$bTags == true} (+bTagsLinkOnly or not)
    # t/T : tags extraction  or a/A : a tags extraction
    #   <tt xxx|yyy>zz<>/tt> or <a xxx|yyy>zz<>/a>
    sInside=""
    $bTagsOnly &&
        sInside="s:>:>\n:g"
    if ! $bWord && ! $bKey && ! $bFuzzy && ! $bFilesNameCheck ; then #tags
        for fic in $(find $dir -name "$language.po" |sort) ; do
            $bOrig &&
                sSrc="s:>:¯${fic}>:g"
            # echo "~~~~~~~ Extraction from : $fic ~~~~~~~ "    >&2
            sed '1,17d' $fic <(echo "msgid ") |
            sed '/^#/d'               |
            sed -n "$sLangFilter"     |
            sed -e "$sLangFilter2"    \
                -e "$sLangFilter3"    \
                -e '/^$/d'            \
                -e '/^""$/d'          \
                -e 's:<n/>:\n:g'      \
                -e 's:\([^<]\)/:\1¯:' \
                -e "$sSrc"            \
                -e "$sInside"         \
                -e 's:|:¯:g'          \
                -e 's:\\\\:¯:'        |
            if $bTagsLinkOnly ; then
                grep '<a .*>' | sed -e "s/<a/\n<a/g" -e "s/<\/a/\n/g" |
                grep '<a .*>'  | sed -e 's/^<a //'
            else
                grep -i '<[a-z].*>' | sed -e "s/<\([^>\/]*\)/\n<\1/g" -e "s/<\//\n/g" |
                grep -i '<.*>'  | sed -e 's/^<//' -e 's:/>.*:>:'  #|
                #grep -ve '^a[ ¯]' | grep -ve '^button[ ¯]' | grep -ve '^code[ ¯]' | grep -ve '^c[ ¯]' #tmp for other checks
            fi |
            if $bTagsOnly ; then
                sed -e 's/>//'
            else
                sed -e 's/>/¯/'
            fi |
            sed -e '/^$/d'            |
            if $bTagsOnly && ! $bOrig ; then        # t , TO, a, AO
                cat
            else
                sed -e 's:^\([^¯]*\)¯\([^¯]*\)$:\1¯ ¯\2:'
            fi                        |
            if ! $bTagsOnly && $bOrig ; then        # tO , aO
                sed -e 's:^\([^¯]*\)¯\([^¯]*\)¯\([^¯]*\)$:\1¯ ¯\2¯\3:'
            else
                cat
            fi
        done |
        if $bSort ; then
            sort -i | column -t -s "¯" |uniq -c
        else
            column -t -s "¯" | uniq
        fi

    elif ! $bWord && ! $bFuzzy && ! $bFilesNameCheck ; then #bKey
        # -K : key tags only (\\\\key option;) (table presentation)
        sSrc="s:;:;\n:g"
        for fic in $(find $dir -name "$language.po" |sort) ; do
            $bOrig &&
                sSrc="s:;:¯${fic};\n:g"
            # echo "~~~~~~~ Extraction from : $fic ~~~~~~~ "    >&2
            sed '1,17d' $fic <(echo "msgid ") |
            sed '/^#/d'               |
            sed -n "$sLangFilter"     |
            sed -e "$sLangFilter2"    \
                -e "$sLangFilter3"    \
                -e "$sSrc"            \
                -e '/^$/d'            \
                -e '/^""$/d'
        done |
        grep -e '\\\\[^;]*;'       |
        sed -e 's/.*\\\\/\\\\/'    \
            -e 's/;//'             \
            -e 's:^\([^¯ ]*\)[¯ ]\([^¯ ]*\)$:\1¯ ¯\2:' |
        if $bSort ; then
            sort -i | column -t -s "¯ " | uniq -ci
        else
            column -t -s "¯ " | uniq
        fi

    elif ! $bWord && ! $bFilesNameCheck ; then    #bFuzzy
        # extract fuzzy part en & translation to be validate
        sLangFilter='/fuzzy/,/^$/p'
        for fic in $(find $dir -name "$language.po" |sort) ; do
            $bOrig &&
                sSrc="s:\(fuzzy.*\)$:\1¯${fic}:"
            sed '1,17d' $fic <(echo "msgid ") |
            sed -n "$sLangFilter"     |
            sed -e "$sSrc"            \
                -e 's/^#/\n~\n#/'     \
                -e '/^$/d'            \
                -e '/^""$/d'
        done |  column -t -s "¯" | uniq

    elif $bFilesNameCheck ; then  #bFilesNameCheck
        # pattern to check :
        # #. type: Image filename
        # ...
        # msgid "xxx"
        # msgstr "xxx"
        #   or
        # msgstr ""
        #   other msgstr are displayed...
        #   : possible specific i18n image with translated legends

        sLangFilter='/#\..*type:.*filename/,/^$/p'
        sTrslFrom=""
        sTrslTo=""
        sPlomp=""
        for fic in $(find $dir -name "$language.po" |sort) ; do
            $bOrig &&
                sSrc="s:\(filename.*\)$:\1¯${fic}:"
            sed '1,17d' $fic <(echo -e "\n\n#\. type:   filename\nmsgid zz12 \nmsgstr zz1\n\n") |
            sed -n "$sLangFilter"             |
            grep -E "msgid|msgstr|filename|\#:" |
            sed -e "$sSrc"            \
                -e 's/^#/\n~\n#/'     \
                -e '/^$/d'            \
                -e '/^""$/d'
        done |
            while read -r sLine ; do
                if [[ "${sLine::6}" == "msgstr" ]] ; then    #begin with msgstr
                    sTrslTo="${sLine:6}"
                    [[ $sTrslTo == $sTrslFrom ]] &&
                        sPlomp="" &&
                        continue
                    [[ $sTrslTo == ' ""' ]] &&
                        sPlomp="" &&
                        continue
                    # [[ "${sTrslFrom%\"}_cs\"" == "$sTrslTo" ]] &&   # those alterate images exist !
                    #     sPlomp="" &&
                    #     continue
                    sPlomp="$sPlomp\n$sLine"
                    echo -e "$sPlomp"
                    sPlomp=""
                elif [[ "${sLine::5}" == "msgid" ]] ; then   #begin with msgid
                    sTrslFrom="${sLine:5}"
                    sPlomp="$sPlomp\n$sLine"
                elif [[ "${sLine::2}" == "#:" ]] ; then   #begin with msgid
                    sPlomp="${sPlomp%%\\n\\n~}^?¯(->${sLine:2})"
                else
                    sPlomp="$sPlomp\n$sLine"
                fi
            done |  column -t -s "¯" |
                # if 0 output, next lines + prev pipe are commentable
                #  thoses few lines just to get an output in case of success
                tee /dev/tty |
                (
                    nb=0
                    while read -r sLine ; do
                        (( nb++ ))
                        break
                    done
                    [[ nb -lt 1 ]] &&
                        echo "     => No alterations found !" >&2
                )

    else    #bWord .. -non case senstive research-  manage plural forms
            #   + ignore most of detectable "code parts"
            # even grep -i is more efficient, it detects codes and only matched line.
        sTrslFrom=""
        sTrslTo=""
        sSrc=""
        bLastIsId=false
        $bColor &&
            sColor="s/\($sWord\)/$(tput setaf 2)\1$(tput sgr 0)/gI"
        shopt -s nocasematch
        for fic in $(find $dir -name "$language.po" |sort) ; do
            # echo "~~~~~~~ Extraction from : $fic ~~~~~~~ "    >&2
            $bOrig &&
                sSrc="s,^$,\n~~~~ ${fic},"
            bInCode=false
            bInCodeComment=false
            sed '1,17d' $fic <(echo -e "\n\nmsgid EOF1\nmsgstr EOF2\n\n") |
            sed -e 's/^#.*$//'      \
                -e '/^$/d'        \
                -e 's/<a [^<>]*>/<a …>/g' \
                -e 's/<code>[^/]*<\/code>/ ~~SOME_CODES~~ /g' \
                -e 's/<code>[^><]*\(\/\/[^><]*\)<\/code>/ ~~SOME_CODES~~ \1 ~EOC~ /g' \
                -e 's/<s\/>/ /g' \
                -e 's/<c\/>[^/]*<n\/>/ ~SOME_CODES~ /g' \
                -e 's:<c/>[^/]*//\([^/><]*\)<n/>: ~SOME_CODES~ \1 ~EOC~ :g' \
                -e 's/\([^\"]\)<code/\1\"n"<code/g' \
                -e 's/<\/code>/<\/code>"\n"/g' \
                -e 's/\\/\\\\/g'  |
                # -e 's/<[stb]\/>/ /g'
            while read -r sLine ; do
                # ignoring codes without comments (cleaning sLine)
                ! $bInCode &&
                    if $( echo "$sLine" | grep -q "^\"<code>[^/]*//" ) ; then
                        sLine=$( echo $sLine | sed "s/<code>[^/]*/ ~SomeCodes~ /" )
                        bInCode=true
                        bInCodeComment=true
                    fi
                ! $bInCode &&
                    if $( echo "$sLine" | grep -qe "^\"<code>[^/]*$" ) ; then
                        if $( echo "$sLine" | grep -q "</code>" ) ; then
                            bInCode=false
                            sLine=$( echo $sLine | sed "s/.*<\/code>/ ~PeaceOfCode~ /" )
                            bInCode=false
                        else
                            sLine=" ~SomeCodes~ "
                            bInCode=true
                        fi
                    fi
                ! $bInCode &&
                    if [[ "${sLine::6}" == "<code>" ]] ; then
                        #check if slash are from other xml peaces... or from a comment...
                        sBeg=$( echo $sLine | sed "s:</:<…:g" )
                        sEnd=$( echo $sBeg | sed "s:/::g" )
                        # sEnd="${sBeg#/}"
                        [[ $sBeg != $sEnd ]] && ! $( echo "$sLine" | grep -q "//" ) &&
                            sBeg="$sEnd"
                        [[ $sBeg != $sEnd ]] && ! $( echo "$sLine" | sed "s:<a[^/>]*>:<a…>:g" ) &&
                            sBeg="$sEnd"
                        if [[ $sBeg == $sEnd ]] ; then #no comment nor divide
                            if $( echo "$sLine" | grep -q "</code>" ) ; then
                                sLine=$( echo $sLine | sed "s/.*<\/code>/ ~PeaceOfCode2~ /" )
                                bInCode=false
                            else
                                sLine=" ~SomeCodes2~ "
                                bInCode=true
                            fi
                        #else
                        #    ; #TODO : manage++ lines with multine code, slashes & comments
                        fi
                    fi
                $bInCode &&
                    if $( echo "$sLine" | grep -q "</code>" ) ; then
                        bInCode=false

                        sBeg=$( echo $sLine | sed "s/<\/code>$//" )
                        sEnd=""
                        if $( echo "$sBeg" | grep -q "//" ) ; then
                            sBeg=$( echo $sLine | sed "s:^.*\(//.*\)<\/code>.*$:\1:" )
                        else
                            sBeg=""
                        fi
                        bInCode=false
                        bInCodeComment=false
                        sLine="$sBeg ~Codes~ $sEnd"
                    elif $( echo "$sLine" | grep -q "//" ) ; then
                        sLine=$( echo $sLine | sed "s:^.*\(//.*\)$: ~~ALineOfCodeWithCom~~ \1:" )
                    else
                        sLine=" ~~A_LINE_OF_CODES~~ "
                    fi
                # std treatments
                if [[ "${sLine::6}" == "msgstr" ]] ; then    #begin with msgstr
                    $bEnglish &&
                        [[ ${#sTrslFrom} -gt 1 ]] &&
                        ! $( echo "$sTrslFrom"| grep -iq "$sWord" ) &&
                        sTrslFrom=""    &&
                        sTrslTo=""      &&
                        bLastIsId=false &&
                        continue
                    $bLastIsId &&
                        sTrslTo="${sLine:7}" ||
                        sTrslTo="$sTrslTo\n${sLine:7}"
                    bLastIsId=false;
                elif [[ "${sLine::5}" == "msgid" ]] ; then   #begin with msgid
                    if ! $bLastIsId ; then
                        ! $bEnglish &&
                            [[ ${#sTrslTo} -gt 1 ]] &&
                            ! $( echo "$sTrslTo"| grep -iq "$sWord" ) &&
                            sTrslFrom=""    &&
                            sTrslTo=""
                        # clean before display
                        [[ ${#sTrslFrom} -gt 0 ]] &&
                            sTrslFrom=$(echo $sTrslFrom |
                                sed -e 's/\"\"\n//'     \
                                    -e 's/\"\"//'       \
                                    -e 's/\"$//'        \
                                    -e 's/^"/</'
                                    )
                        [[ ${#sTrslTo} -gt 0 ]] &&
                            sTrslTo=$(echo $sTrslTo |
                                sed -e 's/\"\"\n//' \
                                    -e 's/\"\"//'   \
                                    -e 's/\"$//'    \
                                    -e 's/^"/>/'
                                    )
                        if [[ ${#sTrslTo} -gt 0 ]] ; then
                            [[ ${#sTrslFrom} -gt 0 ]] &&
                            echo -e "\n${sTrslFrom//\\\\n}\n${sTrslTo//\\\\n}"
                            # echo -n
                        else
                            [[ ${#sTrslFrom} -gt 0 ]] &&
                                echo -e "\n${sTrslFrom//\\\\n}"
                        fi |    sed -e "$sColor"    \
                                    -e "$sSrc"
                    fi
                    #new ... = > prepare next
                    sTrslTo=""
                    ! $bLastIsId &&
                        sTrslFrom="${sLine:6}" ||
                        sTrslFrom="$sTrslFrom\n${sLine:6}"
                    bLastIsId=true;
                else
                    #next... or empty
                    [[ ${#sLine} -lt 2 ]] &&
                        continue
                    if $bLastIsId ; then
                        [[ ${#sTrslFrom} -gt 2 ]] &&
                            sTrslFrom="$sTrslFrom\n$sLine" ||
                            sTrslFrom="$sLine"
                    else
                        [[ ${#sTrslTo} -gt 2 ]] &&
                            sTrslTo="$sTrslTo\n$sLine" ||
                            sTrslTo="$sLine"
                    fi
                fi
            done # every sLines
        done # every xx.po files
    fi
fi

echo "!! $0 END" >&2
