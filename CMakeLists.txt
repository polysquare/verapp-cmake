# /CMakeLists.txt
#
# A toplevel CMakeLists.txt file that the user of these modules
# can import. This will ensure that the verapp_exit_failure_on_stderr
# wrapper gets built

add_subdirectory (${CMAKE_CURRENT_SOURCE_DIR}/src)
