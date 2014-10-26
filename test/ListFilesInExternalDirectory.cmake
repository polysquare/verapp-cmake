# /tests/ListFilesInExternalDirectory.cmake
# Tests getting a list of files in some external directory
# using verapp_list_files_in_external_directory
#
# We pass "NO_MATCH" to match as that causes grep to match anything.
#
# See LICENCE.md for Copyright information

include (VeraPPUtilities)
include (CMakeUnit)

set (CMAKE_MODULE_PATH
     ${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

find_package (VeraPP REQUIRED)

set (DIRECTORY_WITH_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/Directory/)
set (FILE_TO_MAKE
     ${DIRECTORY_WITH_FILE}File)

file (MAKE_DIRECTORY ${DIRECTORY_WITH_FILE})
file (WRITE ${FILE_TO_MAKE} "")

verapp_list_files_in_external_directory (RETURN_VALUE
                                         DIRECTORY ${DIRECTORY_WITH_FILE})

assert_variable_is (RETURN_VALUE STRING EQUAL "${FILE_TO_MAKE}")