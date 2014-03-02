# /tests/SourcesConformanceReRunIfSourcesUpdated.cmake
# Specifies a list of sources to be checked as part of a group.
# Exit-with-error mode is turned on.
#
# Creates the stampfile before the build starts by writing directly to it
# but also causes a source file for the vera++ checks which the stampfile
# depends on to be generated during the build process.
#
# A correct implementation should re-generate the stampfile and re-run the
# vera++ checks.
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
set (GENERATED_SOURCE_FILE_INPUT_CONTENTS
     ${SOURCE_FILE_CONTENTS})

set (SOURCE_FILE_NAME ${CMAKE_CURRENT_SOURCE_DIR}/Source.cpp)
set (GENERATED_SOURCE_FILE_TEMPLATE_NAME
     ${CMAKE_CURRENT_SOURCE_DIR}/Template.cpp)
set (GENERATED_SOURCE_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/Generated.cpp)

file (WRITE ${SOURCE_FILE_NAME} ${SOURCE_FILE_CONTENTS})
file (WRITE ${GENERATED_SOURCE_FILE_TEMPLATE_NAME}
      ${GENERATED_SOURCE_FILE_INPUT_CONTENTS})

add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE_NAME}
                    COMMAND
                    ${CMAKE_COMMAND} -E copy_if_different
                    ${GENERATED_SOURCE_FILE_TEMPLATE_NAME}
                    ${GENERATED_SOURCE_FILE_NAME})

add_custom_target (generated_source_file
                   DEPENDS ${GENERATED_SOURCE_FILE_NAME})

set (RULES_SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/scripts/rules)
set (PROFILES_SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/scripts/profiles)
add_custom_target (on_all ALL)
verapp_import_default_rules_into_subdirectory_on_target (${RULES_SUBDIR}
                                                         on_all)
                                                         
verapp_import_default_profiles_into_subdirectory_on_target (${PROFILES_SUBDIR}
                                                            on_all)

set (VERAPP_DIR ${CMAKE_CURRENT_BINARY_DIR})

set (CHECK_SOURCES
     ${SOURCE_FILE_NAME}
     ${GENERATED_SOURCE_FILE_NAME})

verapp_profile_check_source_files_conformance_for_target (${VERAPP_DIR}
                                                          CHECK_SOURCES
                                                          default
                                                          other_target
                                                          on_all
                                                          ERROR
                                                          CHECK_GENERATED)

add_dependencies (other_target generated_source_file)

set (STAMPFILE ${CMAKE_CURRENT_BINARY_DIR}/other_target.stamp)
file (WRITE ${STAMPFILE} "")