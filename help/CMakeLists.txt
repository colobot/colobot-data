cmake_minimum_required(VERSION 2.8)

set(LEVELS_I18N_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../levels-i18n/)

# Handle all help categories' translations
foreach(LEVEL_CODENAME cbot;object)
    set(SCENEFILE)
    set(SCENEDEST)
    set(PODIR     "${LEVEL_CODENAME}/po/")
    set(HELPDIR   "${LEVEL_CODENAME}/")
    set(HELPDEST  "${LEVEL_CODENAME}")
    message(STATUS "Managing translations for '${LEVEL_CODENAME}' help category")
    include(${LEVELS_I18N_PATH}/CMakeLists.txt)
endforeach()

set(LEVEL_CODENAME generic)
set(SCENEFILE)
set(SCENEDEST)
set(PODIR     "${LEVEL_CODENAME}/po/")
set(HELPDIR   "${LEVEL_CODENAME}/")
set(HELPDEST  "")
message(STATUS "Managing translations for '${LEVEL_CODENAME}' help category")
include(${LEVELS_I18N_PATH}/CMakeLists.txt)

set(LEVEL_CODENAME bots)
set(SCENEFILE)
set(SCENEDEST)
set(PODIR     "${LEVEL_CODENAME}/po/")
set(HELPDIR   "${LEVEL_CODENAME}/")
set(HELPDEST  "object/")
message(STATUS "Managing translations for '${LEVEL_CODENAME}' help category")
include(${LEVELS_I18N_PATH}/CMakeLists.txt)

