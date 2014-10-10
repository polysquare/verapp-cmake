# /tests/ListFilesInExternalDirectoryMatching.cmake
# Tests getting a list of files in some external directory
# using verapp_list_files_in_external_directory
#
# We pass "File" to match the first created file, but not the second.
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
set (UNMATCHED_FILE_TO_MAKE
     ${DIRECTORY_WITH_FILE}AUnmatched)

file (MAKE_DIRECTORY ${DIRECTORY_WITH_FILE})
file (WRITE ${FILE_TO_MAKE} "")
file (MAKE_DIRECTORY ${DIRECTORY_WITH_FILE})
file (WRITE ${UNMATCHED_FILE_TO_MAKE} "")

verapp_list_files_in_external_directory (MATCH "File"
                                         DIRECTORY ${DIRECTORY_WITH_FILE}
                                         RETURN_VALUE)

# Check the return value to make sure that we didn't get our
# unmatched file.
foreach (FILE ${RETURN_VALUE})

	assert_variable_is_not (${FILE}
	                        STRING
	                        EQUAL
	                        ${UNMATCHED_FILE_TO_MAKE})

endforeach ()