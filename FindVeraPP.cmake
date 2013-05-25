# FindVeraPP.cmake
#
# This CMake script will search for vera++ and set the following
# variables
#
# VERAPP_FOUND : Whether or not vera++ is available on the target system
# VERAPP_EXECUTABLE : Fully qualified path to the vera++ executable
# VERAPP_PROFILES : Fully qualified path to the default vera++ profiles
# VERAPP_RULES: Fully qualified path to the default vera++ scripts
# VERAPP_TRANSFORMATIONS: Fully qualified path to the default vera++ scripts
#
# The following variables will affect the operation of this script
# VERAPP_SEARCH_PATHS : List of directories to search for vera++ in, before
#                       searching any system paths. This should be the prefix
#                       to which vera++ was installed, and not the path
#                       that contains the vera++ binary. E.g. /opt/ not
#                       /opt/bin/
#
# See LICENCE.md for Copyright info

# Set-up the directory tree of the vera++ installation
set (_verapp_bin_subdirectory bin)
set (_verapp_lib_subdirectory lib/vera++)
set (_verapp_scripts_subdirectory scripts)
set (_verapp_scripts_subdirectory_location ${_verapp_lib_subdirectory})
set (_verapp_rules_subdirectory rules)
set (_verapp_rules_subdirectory_location
     ${_verapp_scripts_subdirectory_location}/${_verapp_scripts_subdirectory}/)
set (_verapp_transformations_subdirectory transformations)
set (_verapp_transformations_subdirectory_location
     ${_verapp_scripts_subdirectory_location}/${_verapp_scripts_subdirectory}/)
set (_verapp_profiles_subdirectory ${_verapp_lib_subdirectory}/profiles)
set (_verapp_profiles_subdirectory_subdirectory_location
     ${_verapp_lib_subdirectory}/)
set (_verapp_executable_name vera++)

set (_verapp_executable_found FALSE)

function (_check_verapp_version)

    execute_process (COMMAND ${_verapp_executable_path} -version
                     OUTPUT_VARIABLE _verapp_version_number)

    string (STRIP ${_verapp_version_number} _verapp_version_number)

    string (COMPARE GREATER
            ${_verapp_version_number}
            "${VeraPP_FIND_VERSION}"
            _version_greater)

    string (COMPARE EQUAL
            ${_verapp_version_number}
            "${VeraPP_FIND_VERSION}"
            _version_equal)

    if (NOT VeraPP_FIND_QUIETLY)
        message (STATUS "Installed vera++ version: " ${_verapp_version_number})
    endif (NOT VeraPP_FIND_QUIETLY)

    if (VeraPP_FIND_VERSION_EXACT AND NOT _version_equal)
        if (NOT VeraPP_FIND_QUIETLY)
            message (STATUS "Requested exact version: " ${VeraPP_FIND_VERSION}
                     " but vera++ version is not equal")
        endif (NOT VeraPP_FIND_QUIETLY)
        set (_verapp_appropriate_version_found FALSE PARENT_SCOPE)
    elseif (VeraPP_FIND_VERSION AND NOT
            (_version_greater OR
             _version_equal))
        if (NOT VeraPP_FIND_QUIETLY)
            message (STATUS "Requested version at least version: "
                     ${VeraPP_FIND_VERSION} " but vera++ version is lower")
        endif (NOT VeraPP_FIND_QUIETLY)
        set (_verapp_appropriate_version_found FALSE PARENT_SCOPE)
    else (VeraPP_FIND_VERSION_EXACT_AND NOT _version_equal)
        set (_verapp_appropriate_version_found TRUE PARENT_SCOPE)
    endif (VeraPP_FIND_VERSION_EXACT AND NOT _version_equal)

endfunction (_check_verapp_version)

macro (_check_if_verapp_executable_was_found)

    # We do not want this in the user-visible CMake cache
    mark_as_advanced (_verapp_executable_path)

    if (NOT ${_verapp_executable_path} STREQUAL
            "_verapp_executable_path-NOTFOUND")
        set (_verapp_executable_found TRUE PARENT_SCOPE)
        _check_verapp_version ()
        if (_verapp_appropriate_version_found)
            set (_verapp_correct_version_found TRUE PARENT_SCOPE)
        endif (_verapp_appropriate_version_found)
    endif (NOT ${_verapp_executable_path} STREQUAL
            "_verapp_executable_path-NOTFOUND")
endmacro (_check_if_verapp_executable_was_found)

# _find_verapp_in_custom_paths
#
# Given a list of custom paths SEARCH_PATHS find
# the vera++ binary. Sets _verapp_executable_found
# and _verapp_executable_path upon finding
# 'vera++', otherwise _verapp_executable_path will
# be set to _verapp_executable_path-NOTFOUND
#
# SEARCH_PATHS : Which paths to check for the vera++
#                binary
function (_find_verapp_in_custom_paths SEARCH_PATHS)
    find_program (_verapp_executable_path
                  ${_verapp_executable_name}
                  PATHS ${SEARCH_PATHS}
                  PATH_SUFFIXES ${_verapp_bin_subdirectory}
                  NO_DEFAULT_PATH)

    _check_if_verapp_executable_was_found ()
endfunction (_find_verapp_in_custom_paths)

# _find_verapp_in_system_paths
#
# Find the vera++ binary in system executable paths.
# Sets _verapp_executable_found and _verapp_executable_path
# upon finding 'vera++', otherwise _verapp_executable_path
# will be set to _verapp_executable_path-NOTFOUND
function (_find_verapp_in_system_paths)
    find_program (_verapp_executable_path
                  ${_verapp_executable_name})

    _check_if_verapp_executable_was_found ()
endfunction (_find_verapp_in_system_paths)

# _find_verapp_rules
#
# Find the verapp rules given a VERAPP_PREFIX.
# Sets _verapp_rules_found and _verapp_rules_path
# upon finding the Vera++ default rules, otherwise
# sets _verapp_rules_path to _verapp_rules_path-NOTFOUND
#
# VERAPP_PREFIX : Directory where Vera++ was installed
set (_verapp_rules_path_found FALSE)
function (_find_verapp_rules VERAPP_PREFIX)
    find_path (_verapp_rules_path
               ${_verapp_rules_subdirectory}
               PATHS ${VERAPP_PREFIX}/${_verapp_rules_subdirectory_location}
               NO_DEFAULT_PATH)

    mark_as_advanced (_verapp_rules_path)

    if (NOT ${_verapp_rules_path} STREQUAL
            "_verapp_rules_path-NOTFOUND")
        set (_verapp_rules_path_found TRUE PARENT_SCOPE)
    endif (NOT ${_verapp_rules_path} STREQUAL
            "_verapp_rules_path-NOTFOUND")
endfunction (_find_verapp_rules)

# _find_verapp_transformations
#
# Find the verapp transformations given a VERAPP_PREFIX.
# Sets _verapp_transformations_found and _verapp_transformations_path
# upon finding the Vera++ default transformations, otherwise
# sets _verapp_transformations_path to _verapp_transformations_path-NOTFOUND
#
# VERAPP_PREFIX : Directory where Vera++ was installed
set (_verapp_transformations_path_found FALSE)
function (_find_verapp_transformations VERAPP_PREFIX)
    find_path (_verapp_transformations_path
               ${_verapp_transformations_subdirectory}
               PATHS ${VERAPP_PREFIX}/${_verapp_transformations_subdirectory_location}
               NO_DEFAULT_PATH)

    mark_as_advanced (_verapp_transformations_path)

    if (NOT ${_verapp_transformations_path} STREQUAL
            "_verapp_transformations_path-NOTFOUND")
        set (_verapp_transformations_path_found TRUE PARENT_SCOPE)
    endif (NOT ${_verapp_transformations_path} STREQUAL
            "_verapp_transformations_path-NOTFOUND")
endfunction (_find_verapp_transformations)

# _find_verapp_profiles
#
# Find the verapp profiles given a VERAPP_PREFIX.
# Sets _verapp_profiles_found and _verapp_profiles_path
# upon finding the Vera++ default profiles, otherwise
# sets _verapp_profiles_path to _verapp_profiles_path-NOTFOUND
#
# VERAPP_PREFIX : Directory where Vera++ was installed
set (_verapp_profiles_path_found FALSE)
function (_find_verapp_profiles VERAPP_PREFIX)
    find_path (_verapp_profiles_path
               ${_verapp_profiles_subdirectory}
               PATHS ${VERAPP_PREFIX}/${_verapp_profiles_subdirectory_location}
               NO_DEFAULT_PATH)

    mark_as_advanced (_verapp_profiles_path)

    if (NOT ${_verapp_profiles_path} STREQUAL
            "_verapp_profiles_path-NOTFOUND")
        set (_verapp_profiles_path_found TRUE PARENT_SCOPE)
    endif (NOT ${_verapp_profiles_path} STREQUAL
            "_verapp_profiles_path-NOTFOUND")
endfunction (_find_verapp_profiles)
               

# Try and find vera++ in the user-specified paths
# if possible
if (VERAPP_SEARCH_PATHS)
    set (_verapp_binary_search_paths)
    foreach (PREFIX_PATH ${VERAPP_SEARCH_PATHS})
        list (APPEND _verapp_binary_search_paths
                     ${PREFIX_PATH}/${_verapp_bin_subdirectory}/)
    endforeach (PREFIX_PATH)

    _find_verapp_in_custom_paths (${_verapp_binary_search_paths})
endif (VERAPP_SEARCH_PATHS)

# If we have not found it yet, find it in
# the system paths
_find_verapp_in_system_paths ()

if (_verapp_executable_found)
    # We have found the executable, now we need to find the
    # rest of the installation

    # Strip unsanitised string
    string (STRIP ${_verapp_executable_path} _verapp_executable_path)

    # First get the vera++ path lengths
    string (LENGTH "${_verapp_executable_path}" _verapp_executable_path_length)
    string (LENGTH "/${_verapp_bin_subdirectory}/${_verapp_executable_name}"
                   _verapp_executable_subdirectory_length)

    # Then determine how long the prefix is
    set (__prefix_len_op1 ${_verapp_executable_path_length})
    set (__prefix_len_op2 ${_verapp_executable_subdirectory_length})
    math (EXPR _verapp_prefix_length
          "${__prefix_len_op1} - ${__prefix_len_op2}")

    # Then we get the prefix substring
    string (SUBSTRING ${_verapp_executable_path} 0 ${_verapp_prefix_length}
                      _verapp_prefix)

    # Find the other parts of the Vera++ installation
    _find_verapp_rules (${_verapp_prefix})
    _find_verapp_profiles (${_verapp_prefix})
    _find_verapp_transformations (${_verapp_prefix})

else (_verapp_executable_found)
    if (NOT VeraPP_FIND_QUIETLY)
        message (STATUS "The 'vera++' executable was not found in any search"
                        " or system paths.\n"
                        ".. Please adjust VERAPP_SEARCH_PATHS"
                        " to the installation prefix of the 'vera++'\n"
                        ".. executable or install Vera++")
    endif (NOT VeraPP_FIND_QUIETLY)
endif (_verapp_executable_found)

if (NOT _verapp_executable_found OR
    NOT _verapp_correct_version_found OR
    NOT _verapp_rules_path_found OR
    NOT _verapp_profiles_path_found OR
    NOT _verapp_transformations_path_found)
    set (VeraPP_FOUND FALSE)

    if (VeraPP_FIND_REQUIRED)
        set (_verapp_not_found_msg_type SEND_ERROR)
    else (VeraPP_FIND_REQUIRED)
        set (_verapp_not_found_msg_type STATUS)
    endif (VeraPP_FIND_REQUIRED)

    if (NOT VeraPP_FIND_QUIETLY OR
        VeraPP_FIND_REQUIRED)
        message (${_verapp_not_found_msg_type} "Vera++ was not found")
    endif (NOT VeraPP_FIND_QUIETLY OR
           VeraPP_FIND_REQUIRED)

else (NOT _verapp_executable_found OR
      NOT _verapp_correct_version_found OR
      NOT _verapp_rules_path_found OR
      NOT _verapp_profiles_path_found OR
      NOT _verapp_transformations_path_found)
    set (VeraPP_FOUND TRUE)
    set (VERAPP_FOUND TRUE)
    set (VERAPP_EXECUTABLE
         ${_verapp_executable_path})
    set (VERAPP_RULES
         ${_verapp_rules_path}/${_verapp_rules_subdirectory}/)
    set (__verapp_transform_path ${_verapp_transformations_path})
    set (__verapp_transform_subdir ${_verapp_transformations_subdirectory})
    set (VERAPP_TRANSFORMATIONS
         ${__verapp_transform_path}/${__verapp_transform_subdir}/)
    set (VERAPP_PROFILES
         ${_verapp_profiles_path}/${_verapp_profiles_subdirectory}/)

    if (NOT VeraPP_FIND_QUIETLY)
        message (STATUS "Vera++ found at " ${_verapp_executable_path})
    endif (NOT VeraPP_FIND_QUIETLY)

endif (NOT _verapp_executable_found OR
       NOT _verapp_correct_version_found OR
       NOT _verapp_rules_path_found OR
       NOT _verapp_profiles_path_found OR
       NOT _verapp_transformations_path_found)
