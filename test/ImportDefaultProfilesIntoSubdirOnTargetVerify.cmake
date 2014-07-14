# /tests/ImportDefaultProfilesIntoSubdirOnTargetVerify.cmake
# Verifies that the default rules were copied into the nominated subdirectory.

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_exists (${DESTINATION_DIRECTORY}/boost)
assert_file_exists (${DESTINATION_DIRECTORY}/default)
assert_file_exists (${DESTINATION_DIRECTORY}/full)