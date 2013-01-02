cmake_minimum_required(VERSION 2.8)

# Translate translatable material
find_program(PO4A po4a)

if(PO4A)
	add_custom_command(OUTPUT levels_i18n
		COMMAND ./gen_levels_xml.sh ${CMAKE_CURRENT_BINARY_DIR}/
		COMMAND touch ${CMAKE_CURRENT_BINARY_DIR}/levels_i18n
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Handle level instruction translations"
		)
	add_custom_target(translate_levels ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/levels_i18n)
endif()

file(GLOB levelfiles "${CMAKE_CURRENT_BINARY_DIR}/*.txt")
install(FILES ${levelfiles} DESTINATION ${COLOBOT_INSTALL_DATA_DIR}/levels/)
