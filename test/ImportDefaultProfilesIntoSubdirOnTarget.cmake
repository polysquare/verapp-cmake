# /tests/ImportDefaultProfilesIntoSubdirOnTarget.cmake
# Creates a new target to import vera++ default rules on.
#
# See LICENCE.md for Copyright information

include (VeraPPUtilities)
include (CMakeUnit)

set (CMAKE_MODULE_PATH
     ${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

find_package (VeraPP REQUIRED)

add_custom_target (on_all ALL)

set (SUBDIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)

verapp_import_default_profiles_into_subdirectory_on_target (${SUBDIRECTORY}
                                                           on_all)

assert_target_exists (on_all_verapp_import_default_profiles)