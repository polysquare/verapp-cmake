# /tests/ImportDefaultRulesIntoSubdirOnTargetVerify.cmake
# Verifies that the default rules were copied into the nominated subdirectory.

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_exists (${DESTINATION_DIRECTORY}/F001.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/F002.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/L001.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/L002.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/L003.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/L004.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/L005.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/L006.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T001.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T002.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T003.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T004.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T005.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T006.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T007.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T008.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T009.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T010.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T011.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T012.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T013.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T014.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T015.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T016.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T017.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T018.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/T019.tcl)

assert_file_contains (${BUILD_OUTPUT} "Importing Vera++ rule")