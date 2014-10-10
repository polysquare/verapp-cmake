# /tests/ImportDefaultRulesIntoSubdirOnTargetWithCommentVerify.cmake
# Verifies that the comment "Importing Vera++ rule" was printed.

include (CMakeUnit)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_contains (${BUILD_OUTPUT} "Importing Vera++ rule")