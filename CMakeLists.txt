cmake_minimum_required(VERSION 2.8)

option(TRANSLATIONS "Enable translations of help and level files" ON)

if(TRANSLATIONS)
    find_package(PythonInterp 2.7 REQUIRED)
else()
    message(STATUS "Translations disabled; only English files will be installed")
endif()

if(NOT DEFINED COLOBOT_INSTALL_DATA_DIR)
    if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        set(COLOBOT_INSTALL_DATA_DIR ${CMAKE_INSTALL_PREFIX}/data CACHE PATH "Colobot shared data directory")
    else()
        set(COLOBOT_INSTALL_DATA_DIR ${CMAKE_INSTALL_PREFIX}/share/games/colobot CACHE PATH "Colobot shared data directory")
    endif()
endif()

set(DATA_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(common)
add_subdirectory(colobot)
