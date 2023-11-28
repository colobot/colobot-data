cmake_minimum_required(VERSION 3.16)

include(../i18n-tools/I18NTools.cmake)

set(LEVEL_INSTALL_DATA_DIR ${COLOBOT_INSTALL_DATA_DIR}/levels)

##
# Add level category directory with all chapters inside
##
function(add_level_category level_category_dir)
    # If translations are turned off, just install all files as they are
    if(NOT TRANSLATIONS)
        if(COLOBOT_DEVELOPMENT_MODE)
            file(COPY ${level_category_dir}
                DESTINATION ${PROJECT_BINARY_DIR}/levels
            )
        endif()

        install(DIRECTORY ${level_category_dir}
            DESTINATION ${LEVEL_INSTALL_DATA_DIR}
        )
        return()
    endif()

    message(STATUS "Adding translation targets for level/${level_category_dir}")

    add_chaptertitles(${level_category_dir})

    file(GLOB level_dirs RELATIVE
        ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*/level*)
    foreach(level_dir ${level_dirs})
        add_level(${level_dir})
    endforeach()

    # Install all other category files
    if(COLOBOT_DEVELOPMENT_MODE)
        file(COPY ${level_category_dir}/
            DESTINATION ${PROJECT_BINARY_DIR}/levels/${level_category_dir}
            PATTERN "chapter*" EXCLUDE
            PATTERN "po" EXCLUDE
        )
    endif()

    install(DIRECTORY ${level_category_dir}/
        DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_category_dir}
        PATTERN "chapter*" EXCLUDE
        PATTERN "po" EXCLUDE
    )

    # Install all other chapter files
    file(GLOB chapter_dirs RELATIVE
        ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*)
    foreach(chapter_dir ${chapter_dirs})
        if(COLOBOT_DEVELOPMENT_MODE)
            file(COPY ${chapter_dir}/
                DESTINATION ${PROJECT_BINARY_DIR}/levels/${chapter_dir}
                PATTERN "level*" EXCLUDE
            )
        endif()

        install(DIRECTORY ${chapter_dir}/
            DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${chapter_dir}
            PATTERN "level*" EXCLUDE
            PATTERN "chaptertitle.txt" EXCLUDE
        )
    endforeach()

endfunction()

##
# Add chaptertitles
##
function(add_chaptertitles level_category_dir)
    set(work_dir ${PROJECT_BINARY_DIR}/levels/po/${level_category_dir})

    generate_translations(
        OUTPUT_VAR      translated_chaptertitle_files
        TYPE            "chaptertitles"
        WORKING_DIR     ${CMAKE_CURRENT_SOURCE_DIR}
        INPUT_DIR       ${level_category_dir}
        PO_DIR          ${level_category_dir}/po
        OUTPUT_DIR      ${work_dir}
        OUTPUT_SUBDIR   "${install_subdir}"
    )

    install_preserving_relative_paths("${translated_chaptertitle_files}"
        ${work_dir}
        ${LEVEL_INSTALL_DATA_DIR}/${level_category_dir}
    )
endfunction()

##
# Add level directory
##
function(add_level level_dir)
    set(work_dir ${PROJECT_BINARY_DIR}/levels/po/${level_dir})

    generate_translations(
        OUTPUT_VAR      translated_level_files
        TYPE            "level"
        WORKING_DIR     ${CMAKE_CURRENT_SOURCE_DIR}
        INPUT_DIR       ${level_dir}
        PO_DIR          ${level_dir}/po
        OUTPUT_DIR      ${work_dir}
        OUTPUT_SUBDIR   ""
    )

    file(GLOB english_help_files ${level_dir}/help/*)

    if(COLOBOT_DEVELOPMENT_MODE)
        file(COPY ${english_help_files}
            DESTINATION ${PROJECT_BINARY_DIR}/levels/${level_dir}/help
        )
    endif()

    install(FILES ${english_help_files}
        DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_dir}/help
    )

    install_preserving_relative_paths("${translated_level_files}"
        ${work_dir}
        ${LEVEL_INSTALL_DATA_DIR}/${level_dir}
    )

    # Copy all other (non-translatable) files to build directory
    if(COLOBOT_DEVELOPMENT_MODE)
        file(COPY ${level_dir}/
            DESTINATION ${PROJECT_BINARY_DIR}/levels/${level_dir}
            PATTERN "help*" EXCLUDE
            PATTERN "po*" EXCLUDE
        )
    endif()

    # Install all other (non-translatable) files
    install(DIRECTORY ${level_dir}/
        DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_dir}
        PATTERN "help*" EXCLUDE
        PATTERN "po*" EXCLUDE
        PATTERN "scene.txt" EXCLUDE
    )
endfunction()


add_level_category(missions)
add_level_category(free)
add_level_category(exercises)
add_level_category(challenges)
add_level_category(battles)
add_level_category(plus)

if(COLOBOT_DEVELOPMENT_MODE)
    file(COPY other DESTINATION ${PROJECT_BINARY_DIR}/levels/)
endif()

install(DIRECTORY other DESTINATION ${LEVEL_INSTALL_DATA_DIR})
