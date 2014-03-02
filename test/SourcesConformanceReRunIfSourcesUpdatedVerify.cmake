# /tests/SourcesConformanceReRunIfSourcesUpdatedVerify.cmake
# Verifies that vera++ is run on our sources if targets which the stampfile
# depends on are out of date.
#
# See LICENCE.md for Copyright information.

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (VERAPP_ON_SOURCE_FILE_REGEX
   "^.*vera\\+\\+.*Source\\.cpp.*$")
set (VERAPP_ON_GENERATED_FILE_REGEX
   "^.*vera\\+\\+.*Generated\\.cpp.*$")
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${VERAPP_ON_SOURCE_FILE_REGEX})
assert_file_has_line_matching (${BUILD_OUTPUT}
                               ${VERAPP_ON_GENERATED_FILE_REGEX})