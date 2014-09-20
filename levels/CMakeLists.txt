cmake_minimum_required(VERSION 2.8)

include(../i18n-tools/LevelsI18N.cmake)

##
# Add level category directory with all chapters inside
##
function(add_level_category level_category_dir)
    file(GLOB chaptertitle_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*/chaptertitle.txt)
    if(PO4A AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${level_category_dir}/po/)
        generate_chaptertitles_i18n(translated_chaptertitle_files "${chaptertitle_files}" ${level_category_dir}/po)
    else()
        set(translated_chaptertitle_files ${chaptertitle_files})
    endif()

    file(GLOB chapter_dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*)
    list(LENGTH chapter_dirs chapter_dirs_count)
    math(EXPR iterate_range "${chapter_dirs_count} - 1")
    foreach(index RANGE ${iterate_range})
        list(GET chapter_dirs ${index} chapter_dir)
        list(GET translated_chaptertitle_files ${index} translated_chaptertitle_file)
        install(FILES ${translated_chaptertitle_file} DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${chapter_dir})
    endforeach()

    file(GLOB chapter_dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${level_category_dir}/chapter*)
    foreach(chapter_dir ${chapter_dirs})
        add_chapter(${chapter_dir})
    endforeach()
endfunction()

##
# Add chapter directory with all levels inside
##
function(add_chapter chapter_dir)
    file(GLOB level_dirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${chapter_dir}/level*)
    foreach(level_dir ${level_dirs})
        add_level(${level_dir})
    endforeach()
endfunction()

##
# Add level directory
##
function(add_level level_dir)
    if(PO4A)
        generate_scene_i18n(translated_scene_path ${level_dir}/scene.txt)
    else()
        set(translated_scene_path ${level_dir}/scene.txt)
    endif()
    install(FILES ${translated_scene_path} DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_dir})

# TODO install help files
#     if(EXISTS ${level_dir}/help)
#         install(DIRECTORY ${level_dir}/help DESTINATION ${LEVEL_INSTALL_DATA_DIR}/${level_dir})
#     endif()
endfunction()


add_level_category(challenges)
add_level_category(exercises)
add_level_category(freemissions)
add_level_category(missions)
