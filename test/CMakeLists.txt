# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (VERAPP_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY
                        ${VERAPP_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/cmake-unit)

set (VERAPP_INITIAL_CACHE_CONTENTS
     "set (VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY\n"
     "     ${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY\n"
     "     ${CMAKE_UNIT_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      VERAPP_INITIAL_CACHE_CONTENTS)

add_cmake_test (ListFilesInExternalDirectory)
add_cmake_test (ListFilesInExternalDirectoryMatching)
add_cmake_build_test (CopyFilesInDirToSubdirOnTarget
                      CopyFilesInDirToSubdirOnTargetVerify)
add_cmake_build_test (ImportDefaultRulesIntoSubdirOnTarget
                      ImportDefaultRulesIntoSubdirOnTargetVerify)
add_cmake_build_test (ImportDefaultTransformationsIntoSubdirOnTarget
                      ImportDefaultTransformationsIntoSubdirOnTargetVerify)
add_cmake_build_test (ImportDefaultProfilesIntoSubdirOnTarget
                      ImportDefaultProfilesIntoSubdirOnTargetVerify)
add_cmake_build_test (CheckConformanceForLibraryTarget
                      CheckConformanceForLibraryTargetVerify)
add_cmake_build_test (CheckConformanceForTarget
                      CheckConformanceForTargetVerify)
add_cmake_build_test (CheckConformanceForSources
                      CheckConformanceForSourcesVerify)
add_cmake_build_test (CheckConformanceForSourcesErrorMode
                      CheckConformanceForSourcesErrorModeVerify)
