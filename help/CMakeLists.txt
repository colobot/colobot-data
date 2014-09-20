cmake_minimum_required(VERSION 2.8)


include(../i18n-tools/HelpI18N.cmake)

set(HELP_INSTALL_DATA_DIR  ${COLOBOT_INSTALL_DATA_DIR}/help)

##
# Add help category directory
##
function(add_help_category help_category_dir)
    file(GLOB help_files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${help_category_dir}/E/*.txt)
    list(SORT help_files)
    if(PO4A AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${help_category_dir}/po/)
        generate_help_i18n(translated_help_dirs "${help_files}" ${help_category_dir}/po)
    else()
        set(translated_help_dirs "")
    endif()
    install(DIRECTORY ${help_category_dir}/E DESTINATION ${HELP_INSTALL_DATA_DIR}/${help_category_dir})
    foreach(translated_help_dir ${translated_help_dirs})
        install(DIRECTORY ${translated_help_dir} DESTINATION ${HELP_INSTALL_DATA_DIR}/${help_category_dir})
    endforeach()
endfunction()


add_help_category(bots)
add_help_category(cbot)
add_help_category(generic)
add_help_category(object)
