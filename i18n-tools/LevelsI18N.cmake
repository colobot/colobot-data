##
# Meta-infrastructure to allow po-based translation of Colobot help files and scene-description (level) files.
##

find_program(PO4A po4a)

if(NOT PO4A)
    message(WARNING "PO4A not found, level files will NOT be translated!")
endif()

set(LEVEL_INSTALL_DATA_DIR ${COLOBOT_INSTALL_DATA_DIR}/levels)
set(HELP_INSTALL_DATA_DIR  ${COLOBOT_INSTALL_DATA_DIR}/help)

set(LEVELS_I18N_WORK_DIR ${CMAKE_CURRENT_BINARY_DIR}/levels-po)

##
# Generate translated chaptertitle files using po4a
##
function(generate_chaptertitles_i18n result_translated_chaptertitle_files source_chaptertitle_files po_dir)
    get_filename_component(abs_po_dir ${po_dir} ABSOLUTE)
    # generated config file for po4a
    set(po4a_cfg_file ${LEVELS_I18N_WORK_DIR}/${po_dir}/chaptertitles_po4a.cfg)
    # generated dummy file for translation of "E", "D", "F", "P", etc. language letters
    set(langchar_file ${LEVELS_I18N_WORK_DIR}/${po_dir}/chaptertitles_langchar.txt)

    file(WRITE ${langchar_file} "E")

    # get translations from po directory
    file(WRITE ${po4a_cfg_file} "[po_directory] ${abs_po_dir}\n")
    # add content of dummy language file to translation
    file(APPEND ${po4a_cfg_file} "[type:text] ${langchar_file}")

    set(abs_source_chaptertitle_files "")
    set(translated_chaptertitle_files "")

    file(GLOB po_files ${po_dir}/*.po)

    foreach(source_chaptertitle_file ${source_chaptertitle_files})
        get_filename_component(abs_source_chaptertitle_file ${source_chaptertitle_file} ABSOLUTE)
        set(output_chaptertitle_file ${LEVELS_I18N_WORK_DIR}/${source_chaptertitle_file})

        # translation rule for chaptertitle file
        file(APPEND ${po4a_cfg_file} "\n[type:colobotlevel] ${abs_source_chaptertitle_file}")

        foreach(po_file ${po_files})
            get_filename_component(po_file_name ${po_file} NAME)
            # get language code e.g. "de"
            string(REPLACE ".po" "" language_code ${po_file_name})
            # generated file for single language
            set(generated_language_file ${output_chaptertitle_file}.${language_code})
            file(APPEND ${po4a_cfg_file} " \\\n    ${language_code}:${generated_language_file}")
        endforeach()

        list(APPEND abs_source_chaptertitle_files ${abs_source_chaptertitle_file})
        list(APPEND translated_chaptertitle_files ${output_chaptertitle_file})
    endforeach()

    # dummy files to signal that scripts have finished running
    set(translation_signalfile ${LEVELS_I18N_WORK_DIR}/${po_dir}/translations)
    set(po_clean_signalfile ${LEVELS_I18N_WORK_DIR}/${po_dir}/po_clean)

    # script to run po4a and consolidate the translations
    string(REPLACE ";" ":" escaped_abs_source_chaptertitle_files "${abs_source_chaptertitle_files}")
    string(REPLACE ";" ":" escaped_translated_chaptertitle_files "${translated_chaptertitle_files}")
    add_custom_command(OUTPUT ${translation_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/create_translations.sh ${escaped_abs_source_chaptertitle_files} ${escaped_translated_chaptertitle_files} ${po4a_cfg_file} ${translation_signalfile}
                       DEPENDS ${po_files})

    file(GLOB pot_file ${po_dir}/*.pot)
    set(po_files ${po_files} ${pot_file})

    # script to do some cleanups in updated *.po and *.pot files
    string(REPLACE ";" ":" escaped_po_files "${po_files}")
    add_custom_command(OUTPUT ${po_clean_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/clean_po_files.sh ${escaped_po_files} ${translation_signalfile} ${po_clean_signalfile}
                       DEPENDS ${translation_signalfile}
                      )

    # generate some unique string for target name
    string(REGEX REPLACE "[/\\]" "_" target_suffix ${po_dir})
    add_custom_target(level_i18n-${target_suffix} ALL DEPENDS ${translation_signalfile} ${po_clean_signalfile})

    set(${result_translated_chaptertitle_files} ${translated_chaptertitle_files} PARENT_SCOPE)
endfunction()

##
# Generate translated level file using po4a
##
function(generate_scene_i18n translated_scene_file_path source_level_file)
    # TODO finish level translation...
endfunction()

