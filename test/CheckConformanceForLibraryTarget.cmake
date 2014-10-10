# /tests/CheckConformanceForLibraryTarget
# Creates a new library target and adds conformance checks on it with
# the boost profile.
#
# See LICENCE.md for Copyright information.

include (VeraPPUtilities)
include (CMakeUnit)

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

add_library (library SHARED
             ${SOURCE_FILE_NAME})

set (RULES_SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/scripts/rules)
set (PROFILES_SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/scripts/profiles)

add_custom_target (on_all ALL)
verapp_import_default_rules_into_subdirectory_on_target (${RULES_SUBDIR}
                                                       on_all)
                                                         
verapp_import_default_profiles_into_subdirectory_on_target (${PROFILES_SUBDIR}
                                                            on_all)
                                                         

set (VERAPP_DIR ${CMAKE_CURRENT_BINARY_DIR})

verapp_profile_check_source_files_conformance (${VERAPP_DIR}
                                               PROFILE default
                                               TARGET library
                                               DEPENDS on_all
                                               WARN_ONLY)