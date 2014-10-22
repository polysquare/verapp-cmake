# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (VeraPPCMakeTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (VERAPP_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (VERAPP_CMAKE_DIRECTORY
                        ${VERAPP_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${VERAPP_CMAKE_DIRECTORY}/cmake-unit)

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${VERAPP_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (VARIABLES CMAKE_MODULE_PATH)

add_cmake_test (ListFilesInExternalDirectory)
add_cmake_test (ListFilesInExternalDirectoryMatching)
add_cmake_build_test (CopyFilesInDirToSubdirOnTarget
                      CopyFilesInDirToSubdirOnTargetVerify)

if (CMAKE_GENERATOR STREQUAL "Unix Makefiles")
    add_cmake_build_test (CopyFilesInDirToSubdirOnTargetWithComment
                          CopyFilesInDirToSubdirOnTargetWithCommentVerify)
    add_cmake_build_test (ImportDefaultRulesIntoSubdirOnTargetWithComment
                          ImportDefaultRulesIntoSubdirOnTargetVerify)
    add_cmake_build_test (ImportDefaultTransformationsIntoSubdirOnTargetWithComment
                          ImportDefaultTransformationsIntoSubdirOnTargetWithCommentVerify)
    add_cmake_build_test (ImportDefaultProfilesIntoSubdirOnTargetWithComment
                          ImportDefaultProfilesIntoSubdirOnTargetWithCommentVerify)
endif (CMAKE_GENERATOR STREQUAL "Unix Makefiles")

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
add_cmake_build_test (CheckConformanceForTargetGenerated
                      CheckConformanceForTargetGeneratedVerify)
add_cmake_build_test (CheckConformanceForTargetNoGenerated
                      CheckConformanceForTargetNoGeneratedVerify)
add_cmake_build_test (CheckConformanceForTargetErrorMode
                      CheckConformanceForTargetErrorModeVerify)
