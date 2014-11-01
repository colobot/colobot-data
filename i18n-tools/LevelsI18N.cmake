##
# Meta-infrastructure to allow po-based translation of Colobot level files
##

find_program(PO4A po4a)

if(NOT PO4A)
    message(WARNING "PO4A not found, level files will NOT be translated!")
endif()

##
# Generate translated chaptertitle files using po4a
##
function(generate_chaptertitles_i18n
         result_translated_chaptertitle_files # output variable to return names of translated chaptertitle files
         source_chaptertitle_prefix_dir       # prefix directory for chaptertitle files
         source_chaptertitle_files            # input chaptertitle files relative to prefix dir
         po_dir                               # directory with translations (*.po, *.pot files)
         work_dir)                            # directory where to save generated files

    # generated dummy file for translation of "E", "D", "F", "P", etc. language letters
    # TODO find a better way to provide translations than this hack
    set(langchar_file ${work_dir}/chaptertitles_langchar.txt)
    file(WRITE ${langchar_file} "E")

    # generated config file for po4a
    set(po4a_cfg_file ${work_dir}/chaptertitles_po4a.cfg)

    # get translations from po directory
    get_filename_component(abs_po_dir ${po_dir} ABSOLUTE)
    file(WRITE ${po4a_cfg_file} "[po_directory] ${abs_po_dir}\n")

    # add content of dummy language file to translation
    file(APPEND ${po4a_cfg_file} "[type:text] ${langchar_file}")

    set(abs_source_chaptertitle_files "")
    set(translated_chaptertitle_files "")
    file(GLOB po_files ${po_dir}/*.po)

    foreach(source_chaptertitle_file ${source_chaptertitle_files})
        get_filename_component(abs_source_chaptertitle_file ${source_chaptertitle_prefix_dir}/${source_chaptertitle_file} ABSOLUTE)
        set(output_chaptertitle_file ${work_dir}/${source_chaptertitle_file})

        # translation rule for chaptertitle file
        file(APPEND ${po4a_cfg_file} "\n[type:colobotlevel] ${abs_source_chaptertitle_file}")

        foreach(po_file ${po_files})
            # generated file for single language
            get_language_code(language_code ${po_file})
            set(generated_language_file ${output_chaptertitle_file}.${language_code})
            file(APPEND ${po4a_cfg_file} " \\\n    ${language_code}:${generated_language_file}")
        endforeach()

        list(APPEND abs_source_chaptertitle_files ${abs_source_chaptertitle_file})
        list(APPEND translated_chaptertitle_files ${output_chaptertitle_file})
    endforeach()

    # dummy files to signal that scripts have finished running
    set(translation_signalfile ${work_dir}/translations)
    set(po_clean_signalfile ${work_dir}/po_clean)

    # script to run po4a and consolidate the translations
    string(REPLACE ";" ":" escaped_abs_source_chaptertitle_files "${abs_source_chaptertitle_files}")
    string(REPLACE ";" ":" escaped_translated_chaptertitle_files "${translated_chaptertitle_files}")
    add_custom_command(OUTPUT ${translation_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/run_po4a.sh ${po4a_cfg_file}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/create_level_translations.sh
                                   ${escaped_abs_source_chaptertitle_files}
                                   ${escaped_translated_chaptertitle_files}
                                   ${translation_signalfile}
                       DEPENDS ${po_files})

    file(GLOB pot_file ${po_dir}/*.pot)
    set(po_files ${po_files} ${pot_file})

    # script to do some cleanups in updated *.po and *.pot files
    string(REPLACE ";" ":" escaped_po_files "${po_files}")
    add_custom_command(OUTPUT ${po_clean_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/clean_po_files.sh
                                   ${escaped_po_files}
                                   ${translation_signalfile}
                                   ${po_clean_signalfile}
                       DEPENDS ${translation_signalfile}
                      )

    # generate some unique string for target name
    string(REGEX REPLACE "[/\\]" "_" target_suffix ${po_dir})

    # target to run both scripts
    add_custom_target(i18n_${target_suffix} ALL DEPENDS ${translation_signalfile} ${po_clean_signalfile})

    # return the translated files
    set(${result_translated_chaptertitle_files} ${translated_chaptertitle_files} PARENT_SCOPE)
endfunction()

##
# Generate translated level and help files using po4a
##
function(generate_level_i18n
         result_translated_level_file # output variable to return names of translaed level files
         result_translated_help_files # output variable to return names of translated help files
         source_level_file            # input scene.txt files
         source_help_files            # input help files
         po_dir                       # directory with translations (*.po, *.pot files)
         work_dir)                    # directory where to save generated files

    # generated dummy file for translation of "E", "D", "F", "P", etc. language letters
    # TODO find a better way to provide translations than this hack
    set(langchar_file ${work_dir}/scene_langchar.txt)
    file(WRITE ${langchar_file} "E")

    # generated config file for po4a
    set(po4a_cfg_file ${work_dir}/scene_po4a.cfg)

    # get translations from po directory
    get_filename_component(abs_po_dir ${po_dir} ABSOLUTE)
    file(WRITE ${po4a_cfg_file} "[po_directory] ${abs_po_dir}\n")

    # add content of dummy language file to translation
    file(APPEND ${po4a_cfg_file} "[type:text] ${langchar_file}")

    # translation rule for scene file
    get_filename_component(abs_source_level_file ${source_level_file} ABSOLUTE)
    file(APPEND ${po4a_cfg_file} "\n[type:colobotlevel] ${abs_source_level_file}")

    get_filename_component(source_level_file_name ${source_level_file} NAME)
    set(output_level_file ${work_dir}/${source_level_file_name})

    file(GLOB po_files ${po_dir}/*.po)
    foreach(po_file ${po_files})
        get_language_code(language_code ${po_file})
        # generated file for single language
        set(generated_language_file ${output_level_file}.${language_code})
        file(APPEND ${po4a_cfg_file} " \\\n    ${language_code}:${generated_language_file}")
    endforeach()

    # translation rules for help files
    set(output_help_dir ${work_dir}/help)
    set(translated_help_files "")

    foreach(source_help_file ${source_help_files})
        get_filename_component(help_file_name ${source_help_file} NAME)

        file(APPEND ${po4a_cfg_file} "\n[type:colobothelp] ${source_help_file}")
        foreach(po_file ${po_files})
            # generated file for single language
            get_language_code(language_code ${po_file})
            get_language_char(language_char ${po_file})
            string(REPLACE ".E." ".${language_char}." generated_help_file_name ${help_file_name})
            set(generated_help_file ${output_help_dir}/${generated_help_file_name})
            file(APPEND ${po4a_cfg_file} " \\\n    ${language_code}:${generated_help_file}")

            list(APPEND translated_help_files ${generated_help_file})
        endforeach()
    endforeach()

    # dummy files to signal that scripts have finished running
    set(translation_signalfile ${work_dir}/translations)
    set(po_clean_signalfile ${work_dir}/po_clean)

    # script to run po4a and consolidate the translations
    add_custom_command(OUTPUT ${translation_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/run_po4a.sh ${po4a_cfg_file}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/create_level_translations.sh
                                   ${abs_source_level_file}
                                   ${output_level_file}
                                   ${translation_signalfile}
                       DEPENDS ${po_files})

    file(GLOB pot_file ${po_dir}/*.pot)
    set(po_files ${po_files} ${pot_file})

    # script to do some cleanups in updated *.po and *.pot files
    string(REPLACE ";" ":" escaped_po_files "${po_files}")
    add_custom_command(OUTPUT ${po_clean_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/clean_po_files.sh
                                   ${escaped_po_files}
                                   ${translation_signalfile}
                                   ${po_clean_signalfile}
                       DEPENDS ${translation_signalfile}
                      )

    # generate some unique string for target name
    string(REGEX REPLACE "[/\\]" "_" target_suffix ${po_dir})

    # target to run both scripts
    add_custom_target(i18n_${target_suffix} ALL DEPENDS ${translation_signalfile} ${po_clean_signalfile})

    # return the translated files
    set(${result_translated_level_file} ${output_level_file} PARENT_SCOPE)
    set(${result_translated_help_files} ${translated_help_files} PARENT_SCOPE)
endfunction()

