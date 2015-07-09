cmake_minimum_required(VERSION 2.8)

# List of music files to be installed
set(MUSIC_FILES
    Intro1
    Intro2
    music002
    music003
    music004
    music005
    music006
    music007
    music008
    music009
    music010
    music011
    music012
    music013
    Constructive
    Humanitarian
    Hv2
    Quite
    Infinite
    Proton
    Prototype
)

option(MUSIC "Enable music" ON)
if(MUSIC)
    option(MUSIC_FLAC "Download music in FLAC fomat and convert it to *.ogg locally, this lets you change music quality" OFF)
    if(MUSIC_FLAC)
        set(MUSIC_QUALITY 3 CACHE STRING "Music quality [-1(very low) - 10(very high), fractional values allowed]")

        find_program(OGGENC oggenc)
        if(NOT OGGENC)
            message(FATAL_ERROR "oggenc not found! Music files cannot be generated!")
        endif()
    endif()

    if(NOT DEFINED COLOBOT_INSTALL_DATA_DIR)
        if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
            set(COLOBOT_INSTALL_MUSIC_DIR ${CMAKE_INSTALL_PREFIX}/data/music CACHE PATH "Colobot shared music directory")
        else()
            set(COLOBOT_INSTALL_MUSIC_DIR ${CMAKE_INSTALL_PREFIX}/share/games/colobot/music CACHE PATH "Colobot shared music directory")
        endif()
    else()
        set(COLOBOT_INSTALL_MUSIC_DIR ${COLOBOT_INSTALL_DATA_DIR}/music CACHE PATH "Colobot shared music directory")
    endif()

    find_program(WGET wget)

    foreach(FILE ${MUSIC_FILES})
        get_filename_component(FILENAME ${FILE} NAME_WE)

        if(MUSIC_FLAC AND NOT FILE MATCHES "Intro") # TODO: We still don't have FLAC version of Intro files, they are packaged as .ogg directly
            set(DOWNLOAD_FILE ${FILENAME}.flac)
        else()
            set(DOWNLOAD_FILE ${FILENAME}.ogg)
        endif()

        # If the required file is already available in source directory, don't download
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${DOWNLOAD_FILE}")
            set(DOWNLOAD_FILE_LOC "${CMAKE_CURRENT_SOURCE_DIR}/${DOWNLOAD_FILE}")
            add_custom_target(download-${FILENAME}) # no operation
        else()
            if(NOT WGET)
                    message(FATAL_ERROR "wget not found, music files can't be downloaded!")
            endif()

            message(STATUS "Downloading ${DOWNLOAD_FILE} ...")

            add_custom_target(
                download-${FILENAME}
                ALL
                ${WGET} -N "http://colobot.info/files/music/${DOWNLOAD_FILE}"
                COMMENT "Downloading ${DOWNLOAD_FILE}"
            )
            set(DOWNLOAD_FILE_LOC "${CMAKE_CURRENT_BINARY_DIR}/${DOWNLOAD_FILE}")
        endif()

        if(MUSIC_FLAC)
            if(DOWNLOAD_FILE MATCHES ".ogg")
                message(STATUS "Installing ${FILE} (FLAC not available) ...")
                install(FILES ${DOWNLOAD_FILE_LOC} DESTINATION ${COLOBOT_INSTALL_MUSIC_DIR})
            else()
                message(STATUS "Converting ${FILE} to OGG ...")
                add_custom_command(
                    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}.ogg"
                    COMMAND ${OGGENC} -q ${MUSIC_QUALITY} -o "${FILENAME}.ogg" "${DOWNLOAD_FILE_LOC}"
                    DEPENDS download-${FILENAME} "${DOWNLOAD_FILE_LOC}"
                )
                add_custom_target(generate-${FILENAME} ALL DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}.ogg")
                install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}.ogg DESTINATION ${COLOBOT_INSTALL_MUSIC_DIR})
            endif()
        else()
            message(STATUS "Installing ${FILE} ...")
            install(FILES ${DOWNLOAD_FILE_LOC} DESTINATION ${COLOBOT_INSTALL_MUSIC_DIR})
        endif()
    endforeach()
endif()
