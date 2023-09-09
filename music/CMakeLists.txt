cmake_minimum_required(VERSION 3.16)

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
            set(COLOBOT_INSTALL_MUSIC_DIR
                ${CMAKE_INSTALL_PREFIX}/data/music
                CACHE PATH "Colobot shared music directory"
            )
        else()
            set(COLOBOT_INSTALL_MUSIC_DIR
                ${CMAKE_INSTALL_PREFIX}/share/games/colobot/music
                CACHE PATH "Colobot shared music directory"
            )
        endif()
    else()
        set(COLOBOT_INSTALL_MUSIC_DIR
            ${COLOBOT_INSTALL_DATA_DIR}/music
            CACHE PATH "Colobot shared music directory"
        )
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
            message(STATUS "Music file ${DOWNLOAD_FILE} already downloaded")
            set(DOWNLOAD_FILE_LOC "${CMAKE_CURRENT_SOURCE_DIR}/${DOWNLOAD_FILE}")
        else()
            if(NOT WGET)
                message(FATAL_ERROR "wget not found, music files can't be downloaded!")
            endif()

            execute_process(
                COMMAND ${CMAKE_COMMAND} -E echo "Downloading ${DOWNLOAD_FILE}..."
                COMMAND ${WGET} -N "https://colobot.info/files/music/${DOWNLOAD_FILE}"
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            )

            set(DOWNLOAD_FILE_LOC "${CMAKE_CURRENT_SOURCE_DIR}/${DOWNLOAD_FILE}")
        endif()

        if(COLOBOT_DEVELOPMENT_MODE)
            file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/${DOWNLOAD_FILE}"
                DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
            )
        endif()

        if(MUSIC_FLAC)
            if(DOWNLOAD_FILE MATCHES ".ogg")
                message(STATUS "Adding install target for ${FILE} (FLAC not available)")
                install(FILES ${DOWNLOAD_FILE_LOC} DESTINATION ${COLOBOT_INSTALL_MUSIC_DIR})
            else()
                message(STATUS "Adding OGG convert target for ${FILE}")

                execute_process(
                    COMMAND ${OGGENC} -q ${MUSIC_QUALITY} -o "${FILENAME}.ogg" "${DOWNLOAD_FILE_LOC}"
                )

                install(FILES
                    ${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME}.ogg
                    DESTINATION ${COLOBOT_INSTALL_MUSIC_DIR}
                )
            endif()
        else()
            message(STATUS "Adding install target for ${FILE}")
            install(FILES ${DOWNLOAD_FILE_LOC} DESTINATION ${COLOBOT_INSTALL_MUSIC_DIR})
        endif()
    endforeach()
endif()
