# /tests/ImportDefaultTransformationsIntoSubdirOnTargetVerify.cmake
# Verifies that the default rules were copied into the nominated subdirectory.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_exists (${DESTINATION_DIRECTORY}/move_includes.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/move_macros.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/move_namespace.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/to_lower.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/to_xml.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/to_xml2.tcl)
assert_file_exists (${DESTINATION_DIRECTORY}/trim_right.tcl)