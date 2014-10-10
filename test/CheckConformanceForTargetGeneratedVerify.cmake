# /tests/CheckConformanceForTargetGeneratedVerify.cmake
# Verifies that we actually ran vera++ on our custom target with both the
# native and generated sources.
#
# See LICENCE.md for Copyright information.

include (CMakeUnit)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)

set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*vera.. .*Source.cpp.*$")
assert_file_has_line_matching (${BUILD_OUTPUT}
                               "^.*vera.. .*GeneratedSource.cpp.*$")