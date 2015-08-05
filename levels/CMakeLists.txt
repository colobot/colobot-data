cmake_minimum_required(VERSION 2.8)

include(../i18n-tools/I18NTools.cmake)

set(LEVEL_INSTALL_DATA_DIR ${COLOBOT_INSTALL_DATA_DIR}/levels)

##
# Add level category directory with all chapters inside
##
function(add_level_category level_category_dir)

    message(STATUS "Adding translation targets for level/${level_category_dir}")

    # Without Python, just install all files as they are
    if(NOT PYTHONINTERP_FOUND)
        install(DIRECTORY ${add_level_category} DESTINATION ${LEVEL_INSTALL_DATA_DIR})
        return()
    endif()

    add_chaptertitles(${level_category_dir})

    file(GLOB level_dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*/level*)
    foreach(level_dir ${level_dirs})
        add_level(${level_dir})
    endforeach()

    # Install all other category files
    install(DIRECTORY ${level_category_dir}/ DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_category_dir}
            PATTERN "chapter*" EXCLUDE
            PATTERN "po" EXCLUDE)

    # Install all other chapter files
    file(GLOB chapter_dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*)
    foreach(chapter_dir ${chapter_dirs})
        install(DIRECTORY ${chapter_dir}/ DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${chapter_dir}
                PATTERN "level*" EXCLUDE
                PATTERN "chaptertitle.txt" EXCLUDE)
    endforeach()

endfunction()

##
# Add chaptertitles
##
function(add_chaptertitles level_category_dir)

    set(work_dir ${DATA_BINARY_DIR}/levels-po/${level_category_dir})
    generate_translations(translated_chaptertitle_files
                          "chaptertitles"
                          ${CMAKE_CURRENT_SOURCE_DIR}
                          ${level_category_dir}
                          ${level_category_dir}/po
                          ${work_dir}
                          "")

    install_preserving_relative_paths("${translated_chaptertitle_files}"
                                      ${work_dir}
                                      ${LEVEL_INSTALL_DATA_DIR}/${level_category_dir})

endfunction()

##
# Add level directory
##
function(add_level level_dir)

    set(work_dir ${DATA_BINARY_DIR}/levels-po/${level_dir})
    generate_translations(translated_level_files
                          "level"
                          ${CMAKE_CURRENT_SOURCE_DIR}
                          ${level_dir}
                          ${level_dir}/po
                          ${work_dir}
                          "")

    file(GLOB english_help_files ${level_dir}/help/*)
    install(FILES ${english_help_files} DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_dir}/help)

    install_preserving_relative_paths("${translated_level_files}"
                                      ${work_dir}
                                      ${LEVEL_INSTALL_DATA_DIR}/${level_dir})

    # Install all other (non-translatable) files
    install(DIRECTORY ${level_dir}/ DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_dir}
            PATTERN "help*" EXCLUDE
            PATTERN "po*" EXCLUDE
            PATTERN "scene.txt" EXCLUDE)

endfunction()


add_level_category(challenges)
add_level_category(exercises)
add_level_category(freemissions)
add_level_category(missions)

install(DIRECTORY other DESTINATION ${LEVEL_INSTALL_DATA_DIR})
