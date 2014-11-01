##
# Meta-infrastructure to allow po-based translation of Colobot help files
##

find_program(PO4A po4a)

if(NOT PO4A)
    message(WARNING "PO4A not found, help files will NOT be translated!")
endif()

##
# Generate translated help files in separate directories per language
##
function(generate_help_i18n
         result_generated_help_dirs # output variable to return names of directories with translated files
         source_help_files          # input help files
         po_dir                     # directory with translations
         work_dir)                  # directory where to save generated files

    # generated config file for po4a
    set(po4a_cfg_file ${work_dir}/help_po4a.cfg)

    # get translations from po directory
    get_filename_component(abs_po_dir ${po_dir} ABSOLUTE)
    file(WRITE ${po4a_cfg_file} "[po_directory] ${abs_po_dir}\n")

    # prepare output directories
    set(output_help_subdirs "")
    file(GLOB po_files ${po_dir}/*.po)
    foreach(po_file ${po_files})
        get_language_char(language_char ${po_file})
        #set(language_help_subdir ${work_dir}/${language_char})
        list(APPEND output_help_subdirs ${language_char})
    endforeach()

    # add translation rules for help files
    foreach(source_help_file ${source_help_files})
        get_filename_component(abs_source_help_file ${source_help_file} ABSOLUTE)
        get_filename_component(help_file_name ${source_help_file} NAME)

        file(APPEND ${po4a_cfg_file} "\n[type:colobothelp] ${abs_source_help_file}")
        foreach(po_file ${po_files})
            # generated file for single language
            get_language_code(language_code ${po_file})
            get_language_char(language_char ${po_file})
            set(generated_help_file ${work_dir}/${language_char}/${help_file_name})
            file(APPEND ${po4a_cfg_file} " \\\n    ${language_code}:${generated_help_file}")
        endforeach()
    endforeach()

    # dummy files to signal that scripts have finished running
    set(translation_signalfile ${work_dir}/translations)
    set(po_clean_signalfile ${work_dir}/po_clean)

    # script to run po4a and generate translated files
    add_custom_command(OUTPUT ${translation_signalfile}
                       COMMAND ${DATA_SOURCE_DIR}/i18n-tools/scripts/run_po4a.sh
                                   ${po4a_cfg_file}
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
    set(${result_generated_help_dirs} ${output_help_subdirs} PARENT_SCOPE)
endfunction()
