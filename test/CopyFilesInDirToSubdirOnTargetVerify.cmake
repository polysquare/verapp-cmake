# /tests/CopyFilesInDirToSubdirOnTargetVerify.cmake
# Verifies that our files were copied into the subdirectory
#
# See LICENCE.md for Copyright information

include (CMakeUnit)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/Directory/Destination)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_exists (${DESTINATION_DIRECTORY}/FirstFile)
assert_file_exists (${DESTINATION_DIRECTORY}/SecondFile)