# /src/CMakeLists.txt
#
# Build a simple binary that redirects stdout to stderr and returns
# and error status if there was anything to redirect. Otherwise returns
# zero
#
# See LICENCE.md for Copyright information

find_package (Boost 1.49 REQUIRED COMPONENTS iostreams)

set (CMAKE_CXX_FLAGS "-std=c++0x -Wall -Werror" ${CMAKE_CXX_FLAGS})

set (VERACPP_EXIT_FAILURE_ON_STDERR_WRAPPER_SRCS
     ${CMAKE_CURRENT_SOURCE_DIR}/exit_failure_on_stderr_wrapper.cpp)

include_directories (${Boost_INCLUDE_DIRS})

add_executable (${VERAPP_EXIT_FAILURE_ON_STDERR_WRAPPER_EXECUTABLE}
                ${VERACPP_EXIT_FAILURE_ON_STDERR_WRAPPER_SRCS})

target_link_libraries (${VERAPP_EXIT_FAILURE_ON_STDERR_WRAPPER_EXECUTABLE}
                       ${Boost_LIBRARIES})
