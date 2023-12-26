cmake_minimum_required(VERSION 3.16)

project(Colobot-Data)

option(TRANSLATIONS "Enable translations of help and level files" ON)

if(TRANSLATIONS)
    find_package(PythonInterp 3.0 REQUIRED)
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

# Copy content to build directory
if(COLOBOT_DEVELOPMENT_MODE)
    file(COPY ai                 DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    file(COPY fonts              DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    file(COPY icons              DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    file(COPY models             DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    file(COPY sounds             DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    file(COPY textures           DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    file(COPY mods               DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
        PATTERN "AltTextures/textures-src" EXCLUDE)
endif()

# Install
install(DIRECTORY ai         DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY fonts      DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY icons      DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY models     DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY sounds     DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY textures   DESTINATION ${COLOBOT_INSTALL_DATA_DIR})
install(DIRECTORY mods       DESTINATION ${COLOBOT_INSTALL_DATA_DIR}
    PATTERN "AltTextures/textures-src" EXCLUDE)

add_subdirectory(help)
add_subdirectory(levels)

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/music/CMakeLists.txt)
    add_subdirectory(music)
endif()
