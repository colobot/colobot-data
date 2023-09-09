cmake_minimum_required(VERSION 3.16)

include(../i18n-tools/I18NTools.cmake)

set(HELP_INSTALL_DATA_DIR  ${COLOBOT_INSTALL_DATA_DIR}/help)

##
# Add help category directory
##
function(add_help_category help_category_dir install_subdir)

    # Always install English files
    file(GLOB english_help_files ${help_category_dir}/E/*)

    if(COLOBOT_DEVELOPMENT_MODE)
        file(COPY ${english_help_files}
            DESTINATION ${PROJECT_BINARY_DIR}/help/E/${install_subdir}
        )
    endif()

    install(FILES ${english_help_files}
        DESTINATION ${HELP_INSTALL_DATA_DIR}/E/${install_subdir}
    )

    # If translations are turned on, also generate translated files
    if(TRANSLATIONS)
        message(STATUS "Adding translation targets for help/${help_category_dir}")

        set(work_dir ${PROJECT_BINARY_DIR}/help-po/${help_category_dir})
        generate_translations(translated_help_files
                              "help"
                              ${CMAKE_CURRENT_SOURCE_DIR}
                              ${help_category_dir}
                              ${help_category_dir}/po
                              ${work_dir}
                              "${install_subdir}")

        install_preserving_relative_paths("${translated_help_files}"
                                          ${work_dir}
                                          ${HELP_INSTALL_DATA_DIR})
    endif()

endfunction()


add_help_category(bots "object")
add_help_category(cbot "cbot")
add_help_category(generic "")
add_help_category(object "object")
add_help_category(programs "programs")
