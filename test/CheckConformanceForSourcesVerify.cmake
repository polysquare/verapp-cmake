# /tests/CheckConformanceForSourcesVerify.cmake
# Verifies that we actually ran vera++ on our custom target with the specified
# sources.
#
# See LICENCE.md for Copyright information.

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (DESTINATION_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)

set (REAL_SOURCE_DIR_RELATIVE_PATH
     ${CMAKE_CURRENT_SOURCE_DIR}/../)
get_filename_component (REAL_SOURCE_DIR
                        ${REAL_SOURCE_DIR_RELATIVE_PATH}
                        ABSOLUTE)

set (SOURCE_FILE_NAME
     ${REAL_SOURCE_DIR}/Source.cpp)
set (BUILD_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/BUILD.output)

assert_file_contains (${BUILD_OUTPUT} "vera++ ${SOURCE_FILE_NAME}")
assert_file_contains (${BUILD_OUTPUT} "--profile default")