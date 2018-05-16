set(COLOBOT_INSTALL_COLOBOT_DATA_DIR "${COLOBOT_INSTALL_DATA_DIR}/colobot" CACHE PATH "Colobot shared game data directory")

set(DATA_CURRENT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

install(DIRECTORY ai         DESTINATION ${COLOBOT_INSTALL_COLOBOT_DATA_DIR})
install(DIRECTORY icons      DESTINATION ${COLOBOT_INSTALL_COLOBOT_DATA_DIR})
install(DIRECTORY            DESTINATION ${COLOBOT_INSTALL_COLOBOT_DATA_DIR}/mods) # Empty directory
add_subdirectory(help)
add_subdirectory(levels)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/music/CMakeLists.txt)
    add_subdirectory(music)
endif()
