# /CMakeLists.txt
#
# A toplevel CMakeLists.txt file that the user of these modules
# can import. This will ensure that the verapp_exit_failure_on_stderr
# wrapper gets built

set (VERAPP_EXIT_FAILURE_ON_STDERR_WRAPPER_EXECUTABLE
     veracpp_exit_failure_on_stderr_wrapper)

add_subdirectory (${CMAKE_CURRENT_SOURCE_DIR}/src)
