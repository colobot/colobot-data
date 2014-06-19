cmake_minimum_required(VERSION 2.8)

# Meta-infrastructure to allow po-based translation of Colobot help files and scene-description (level) files.

# set(LEVELS_I18N_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# set(LEVEL_CODENAME "scene100")
# set(SCENEFILE "scene100/scene.txt")
# set(SCENEDEST "scene101.txt") # If unset , use the same name as SCENEFILE
# set(PODIR     "scene100/po/")
# set(HELPDIR   "scene100/help/")
# set(HELPDEST  "")

project(colobot-level-${LEVEL_CODENAME} NONE)

if(NOT DEFINED COLOBOT_INSTALL_DATA_DIR)
        set(COLOBOT_INSTALL_DATA_DIR ${CMAKE_INSTALL_PREFIX}/share/games/colobot CACHE PATH "Colobot shared data directory")
endif()
set(LEVEL_INSTALL_DATA_DIR ${COLOBOT_INSTALL_DATA_DIR}/levels/)
set(HELP_INSTALL_DATA_DIR  ${COLOBOT_INSTALL_DATA_DIR}/help/)

# Translate translatable material
find_program(PO4A po4a)

if(NOT PO4A)
    message(WARNING "PO4A not found, level files will NOT be translated!")
endif()

### STEP 3 # Inject translations in levels
set(_levels_i18n_target "levels_i18n")

file(GLOB levelfiles "${CMAKE_CURRENT_SOURCE_DIR}/${SCENEFILE}")
foreach(levelfile ${levelfiles})
	if(DEFINED SCENEDEST)
		get_filename_component(_scenedest ${SCENEDEST} NAME)
	else()
		get_filename_component(_scenedest ${levelfile} NAME)
	endif()
	get_filename_component(_levelfile ${levelfile} NAME_WE)
	if(PO4A AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${PODIR}")
		add_custom_command(OUTPUT ${_levels_i18n_target}/${_scenedest}
			COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${_levels_i18n_target}
			COMMAND ${LEVELS_I18N_PATH}/scripts/03_inject_translations.sh ${levelfile} ${CMAKE_CURRENT_BINARY_DIR}/${LEVEL_CODENAME}/${_levelfile} ${PODIR} > ${CMAKE_CURRENT_BINARY_DIR}/${_levels_i18n_target}/${_scenedest}
			DEPENDS po4a-${LEVEL_CODENAME}
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMENT "${LEVEL_CODENAME}: Inject translation in ${_scenedest}"
			)
	else()
		add_custom_command(OUTPUT ${_levels_i18n_target}/${_scenedest}
			COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${_levels_i18n_target}
			COMMAND cp ${levelfile} ${CMAKE_CURRENT_BINARY_DIR}/${_levels_i18n_target}/${_scenedest}
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMENT "${LEVEL_CODENAME}: Move untranslatable ${_scenedest}"
			)
	endif()
	add_custom_target(level_i18n-${LEVEL_CODENAME}_${_levelfile} ALL DEPENDS ${_levels_i18n_target}/${_scenedest})
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${_levels_i18n_target}/${_scenedest}
		DESTINATION ${LEVEL_INSTALL_DATA_DIR})
endforeach()

file(GLOB helpfiles  "${CMAKE_CURRENT_SOURCE_DIR}/${HELPDIR}/E/*.txt")
list(SORT helpfiles)

if(PO4A AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${PODIR}")
	foreach(helpfile ${helpfiles})
		get_filename_component(_helpfile_we ${helpfile} NAME_WE)
		get_filename_component(_helpfile    ${helpfile} NAME)
	
		### STEP 4 # Put translated help files in the correct place
		set(_help_i18n_target "help_i18n_${LEVEL_CODENAME}_${_helpfile_we}")
		add_custom_command(OUTPUT moved-all-${LEVEL_CODENAME}-${_helpfile}
			COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${_help_i18n_target}
			COMMAND ${LEVELS_I18N_PATH}/scripts/04_move_helpfiles_to_paths.sh ${LEVEL_CODENAME} ${LEVEL_CODENAME}-help/${_helpfile} ${_help_i18n_target} '${HELPDIR}' '${HELPDEST}' ${CMAKE_CURRENT_SOURCE_DIR} > moved-all-${LEVEL_CODENAME}-${_helpfile}
			DEPENDS po4a-${LEVEL_CODENAME}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
			COMMENT "${LEVEL_CODENAME}: Move ${_helpfile} translations around"
			)
		add_custom_target(help_i18n-${LEVEL_CODENAME}_${_helpfile_we} ALL DEPENDS moved-all-${LEVEL_CODENAME}-${_helpfile})
		install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${_help_i18n_target}/
			DESTINATION ${HELP_INSTALL_DATA_DIR})

	endforeach()
elseif(DEFINED HELPDIR AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${HELPDIR}")
	set(_help_i18n_target "help_i18n_${LEVEL_CODENAME}")
	add_custom_command(OUTPUT moved-all-${LEVEL_CODENAME}
		COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${_help_i18n_target}
		COMMAND ${LEVELS_I18N_PATH}/scripts/05_move_untranslated_helpfiles_to_paths.sh '${_help_i18n_target}' '${HELPDEST}' '${CMAKE_CURRENT_SOURCE_DIR}/${HELPDIR}' > moved-all-${LEVEL_CODENAME}-${_helpfile}
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		COMMENT "${LEVEL_CODENAME}: Move untranslatable help files"
		)
	add_custom_target(help_i18n-${LEVEL_CODENAME} ALL DEPENDS moved-all-${LEVEL_CODENAME})
	install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${_help_i18n_target}/
		DESTINATION ${HELP_INSTALL_DATA_DIR})

endif()


#### STEP 1 # Create po4a.cfg file out of the list of files
add_custom_command(OUTPUT po4a-${LEVEL_CODENAME}.cfg
	COMMAND ${LEVELS_I18N_PATH}/scripts/01_create_po4a_file.sh ${CMAKE_CURRENT_SOURCE_DIR} ${PODIR} ${LEVEL_CODENAME} '${SCENEFILE}' '${HELPDIR}/E' > ${CMAKE_CURRENT_BINARY_DIR}/po4a-${LEVEL_CODENAME}.cfg
	COMMENT "${LEVEL_CODENAME}: Create po4a configuration file"
	WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
	)

if(PO4A AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${PODIR})
	#### STEP 2 # Run po4a
	add_custom_command(OUTPUT po4a-ran-${LEVEL_CODENAME}
			   COMMAND ${LEVELS_I18N_PATH}/scripts/02_run_po4a.sh ${LEVELS_I18N_PATH} ${CMAKE_CURRENT_BINARY_DIR}/po4a-${LEVEL_CODENAME}.cfg
			   COMMAND touch po4a-ran-${LEVEL_CODENAME}
			   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/po4a-${LEVEL_CODENAME}.cfg
			   WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
			   COMMENT "${LEVEL_CODENAME}: Run po4a to generate the translated files out of the .po files")
	add_custom_target(po4a-${LEVEL_CODENAME} DEPENDS po4a-ran-${LEVEL_CODENAME})
else()
	message(STATUS "${LEVEL_CODENAME}: No translation needed or possible")
	file(GLOB levelfiles "${CMAKE_CURRENT_SOURCE_DIR}/levels/*.txt")
	install(FILES ${levelfiles} DESTINATION ${LEVEL_INSTALL_DATA_DIR}/)
endif()
