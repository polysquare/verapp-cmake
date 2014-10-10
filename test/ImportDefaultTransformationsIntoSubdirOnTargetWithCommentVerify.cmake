# /tests/ImportDefaultTransformationsIntoSubdirOnTargetWithCommentVerify.cmake
# Verifies that the comment "Importing Vera++ transformation" was printed.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_contains (${BUILD_OUTPUT} "Importing Vera++ transformation")