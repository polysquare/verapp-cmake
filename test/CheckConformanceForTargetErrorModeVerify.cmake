# /tests/CheckConformanceForSourcesErrorModeVerify.cmake
# Verifies that we toggle --error mode when specifying ERROR.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_contains (${BUILD_OUTPUT} "--error")