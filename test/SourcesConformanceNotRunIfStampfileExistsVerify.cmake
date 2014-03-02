# /tests/SourcesConformanceNotRunIfStampfileExistsVerify.cmake
# Verifies that vera++ was not run on our sources if the stampfile
# is already up to date.
#
# See LICENCE.md for Copyright information.

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

set (VERAPP_ON_FILE_REGEX
   "^.*vera\\+\\+.*Source\\.cpp.*$")
assert_file_does_not_have_line_matching (${BUILD_OUTPUT}
                                         ${VERAPP_ON_FILE_REGEX})