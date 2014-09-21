##
# Common function used in other I18N CMake modules
##

##
# Get language code from *.po file name e.g. "de.po" -> "de"
##
function(get_language_code result_language_code po_file)
    get_filename_component(po_file_name ${po_file} NAME)
    string(REPLACE ".po" "" language_code ${po_file_name})
    set(${result_language_code} ${language_code} PARENT_SCOPE)
endfunction()

##
# Get language char from *.po file name e.g. "de.po" -> "D"
##
function(get_language_char result_language_char po_file)
    get_filename_component(po_file_name ${po_file} NAME)
    string(REGEX REPLACE ".\\.po" "" language_char ${po_file_name})
    string(TOUPPER ${language_char} language_char)
    set(${result_language_char} ${language_char} PARENT_SCOPE)
endfunction()
