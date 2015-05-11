##
# Meta-infrastructure to allow po-based translation of Colobot help files
##

##
# Generate translated files with Python script
##
function(generate_translations
         result_output_files # output variable to return file names of translated files
         type                # type of files to process
         working_dir         # working directory for the commands to run
         input_dir           # directory with source files
         po_dir              # directory with translations
         output_dir          # directory where to save generated files
         output_subdir)      # optional installation subdirectory

    if(output_subdir STREQUAL "")
        set(output_subdir_opt "")
    else()
        set(output_subdir_opt "--output_subdir")
    endif()

    # first command is used to get list of input and output files when running CMake to
    # execute appropriate CMake install commands and set up dependencies properly
    execute_process(COMMAND ${PYTHON_EXECUTABLE}
                    ${DATA_SOURCE_DIR}/i18n-tools/scripts/process_translations.py
                    --mode print_files
                    --type ${type}
                    --input_dir ${input_dir}
                    --po_dir ${po_dir}
                    --output_dir ${output_dir}
                    ${output_subdir_opt} ${output_subdir}
                    WORKING_DIRECTORY ${working_dir}
                    OUTPUT_VARIABLE files_list)

    string(REGEX REPLACE "(.*)\n(.*)" "\\1" input_files "${files_list}")
    string(REGEX REPLACE "(.*)\n(.*)" "\\2" output_files "${files_list}")

    # return the list of output files to parent
    set(${result_output_files} ${output_files} PARENT_SCOPE)

    # dummy file to indicate success
    set(signal_file ${output_dir}/translation)

    # po files are also dependency
    file(GLOB po_files ${po_dir}/*)

    # actual command used to generate translations executed when building project
    add_custom_command(OUTPUT ${signal_file}
                       COMMAND ${PYTHON_EXECUTABLE}
                       ${DATA_SOURCE_DIR}/i18n-tools/scripts/process_translations.py
                       --mode generate
                       --type ${type}
                       --input_dir ${input_dir}
                       --po_dir ${po_dir}
                       --output_dir ${output_dir}
                       ${output_subdir_opt} ${output_subdir}
                       --signal_file ${signal_file}
                       WORKING_DIRECTORY ${working_dir}
                       DEPENDS ${input_files} ${po_files})

    # generate some unique string for target name
    string(REGEX REPLACE "[/\\]" "_" target_suffix ${po_dir})

    # target to run the command
    add_custom_target(i18n_${target_suffix} ALL DEPENDS ${signal_file})

endfunction()

##
# Convenience function to installing generated files while keeping
# their relative paths in output directory
##
function(install_preserving_relative_paths
         output_files      # list of output files
         output_dir        # output directory
         destination_dir)  # install destination directory

    foreach(output_file ${output_files})
            file(RELATIVE_PATH rel_output_file ${output_dir} ${output_file})
            get_filename_component(rel_output_file_dir ${rel_output_file} DIRECTORY)
            install(FILES ${output_file} DESTINATION ${destination_dir}/${rel_output_file_dir})
    endforeach()

endfunction()
