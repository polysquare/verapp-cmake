# /tests/CheckConformanceForTargetGenerated.cmake
# Creates a new custom target with our own native and generated sources and
# add vera++ checks to it, with the CHECK_GENERATED to check generated
# sources too.
#
# See LICENCE.md for Copyright information

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/VeraPPUtilities.cmake)
include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (CMAKE_MODULE_PATH
     ${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

find_package (VeraPP REQUIRED)

set (SOURCE_FILE_CONTENTS
     "/* Copyright */\n"
     "void function ()\n"
     "{\n"
     "}\n")
set (SOURCE_FILE_NAME ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
file (WRITE ${SOURCE_FILE_NAME} ${SOURCE_FILE_CONTENTS})

set (GENERATED_SOURCE_FILE_NAME
     ${CMAKE_CURRENT_SOURCE_DIR}/GeneratedSource.cpp)
set (GENERATED_SOURCE_INPUT_FILE_NAME
     ${CMAKE_CURRENT_SOURCE_DIR}/GeneratedSourceInput.cpp)
set (GENERATED_SOURCE_INPUT_FILE_CONTENTS
     "/* Copyright */\n"
     "void other_function ()\n"
     "{\n"
     "}\n")
file (WRITE ${GENERATED_SOURCE_INPUT_FILE_NAME}
      ${GENERATED_SOURCE_INPUT_FILE_CONTENTS})
add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE_NAME}
                    COMMAND
                    ${CMAKE_COMMAND} -E copy
                    ${GENERATED_SOURCE_INPUT_FILE_NAME}
                    ${GENERATED_SOURCE_FILE_NAME})

add_custom_target (other_target ALL
                   SOURCES ${SOURCE_FILE_NAME} ${GENERATED_SOURCE_FILE_NAME})

set (RULES_SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/scripts/rules)
set (PROFILES_SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/scripts/profiles)
add_custom_target (on_all ALL)
verapp_import_default_rules_into_subdirectory_on_target (${RULES_SUBDIR}
	                                                       on_all)
                                                         
verapp_import_default_profiles_into_subdirectory_on_target (${PROFILES_SUBDIR}
                                                            on_all)

set (VERAPP_DIR ${CMAKE_CURRENT_BINARY_DIR})

verapp_profile_check_source_files_conformance (${VERAPP_DIR}
                                               default
                                               other_target
                                               on_all
                                               WARN_ONLY
                                               CHECK_GENERATED)