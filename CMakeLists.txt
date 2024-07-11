cmake_minimum_required(VERSION 3.16)

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

install(DIRECTORY ai         DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY fonts      DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY icons      DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY models     DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
# install(DIRECTORY models-new DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY sounds     DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY textures   DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY mods       DESTINATION ${COLOBOT_INSTALL_DATA_DIR}
    PATTERN "AltTextures/textures-src" EXCLUDE)

set(DATA_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(DATA_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

add_subdirectory(help)
add_subdirectory(levels)

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/music/CMakeLists.txt)
    add_subdirectory(music)
endif()
