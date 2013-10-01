# VeraPPUtilities.cmake
#
# Some utility functions to scan projects using vera++

# verapp_list_files_in_external_directory
#
# Workaround for file (GLOB ...) only working on
# the current directory. We use ls | grep ${MATCH}
# in order to find those files
#
# This is unfortunately Unix-only at the moment,
# feel free to submit an alternative to Windows
#
# DIRECTORY : Directory to list files from. Must end with a "/"
# MATCH : Pattern used to match files to list or NO_MATCH.
#         Not a regex or globbing expression.
# RETURN_FILES : The name of a variable to store a list
#                of fully-qualified files
#
# See LICENCE.md for Copyright info

function (verapp_list_files_in_external_directory DIRECTORY MATCH RETURN_FILES)
    find_program (_verapp_ls ls)
    mark_as_advanced (_verapp_ls)

    if (${_verapp_ls} STREQUAL "_verapp_ls-NOTFOUND")
        message (FATAL_ERROR "A Unix userland containing 'ls' was not found")
    endif (${_verapp_ls} STREQUAL "_verapp_ls-NOTFOUND")

    find_program (_verapp_grep grep)
    mark_as_advanced (_verapp_grep)

    if (${_verapp_ls} STREQUAL "_verapp_grep-NOTFOUND")
        message (FATAL_ERROR "A Unix userland containing 'grep' was not found")
    endif (${_verapp_ls} STREQUAL "_verapp_grep-NOTFOUND")

    string (LENGTH "${DIRECTORY}" _verapp_list_directory_string_length)
    math (EXPR _verapp_list_directory_second_last_char_index
               "${_verapp_list_directory_string_length} - 1")
    string (SUBSTRING
            ${DIRECTORY}
            ${_verapp_list_directory_second_last_char_index}
            1
            _verapp_list_directory_string_second_last_char)

    if (NOT _verapp_list_directory_string_second_last_char STREQUAL "/")
        message (FATAL_ERROR "DIRECTORY passed to "
                             "verapp_list_files_in_external_directory must "
                             "end with a /")
    endif (NOT _verapp_list_directory_string_second_last_char STREQUAL "/")

    # ls ${DIRECTORY} | grep ${MATCH}
    set (_verapp_grep_command COMMAND ${_verapp_grep} ${MATCH})

    # If we don't want to match anything, then just neuter the grep
    # command
    if (${MATCH} STREQUAL "NO_MATCH")
        set (_verapp_grep_command)
    endif (${MATCH} STREQUAL "NO_MATCH")

    execute_process (COMMAND ${_verapp_ls} ${DIRECTORY}
                     ${_verapp_grep_command}
                     RESULT_VARIABLE _verapp_ls_result
                     OUTPUT_VARIABLE _verapp_ls_output
                     ERROR_VARIABLE _verapp_ls_error)

    # Success
    if (${_verapp_ls_result} EQUAL 0)
        # Replace \n with ;
        string (REPLACE "\n" ";" _verapp_ls_list ${_verapp_ls_output})

        # For each item in the new list, add it to the 
        # _verapp_ls_return_list var along with the DIRECTORY prefixed
        foreach (_verapp_ls_list_item ${_verapp_ls_list})
            string (STRIP ${_verapp_ls_list_item} verapp_ls_list_item)

            # Don't include any items that are zero-length
            string (LENGTH "${_verapp_ls_list_item}"
                    _verapp_ls_list_item_length)

            if (${_verapp_ls_list_item_length} GREATER 0)
                list (APPEND _verapp_ls_return_list
                      ${DIRECTORY}${_verapp_ls_list_item})
            endif (${_verapp_ls_list_item_length} GREATER 0)
        endforeach (_verapp_ls_list_item)

        # Set RETURN_FILES in PARENT_SCOPE
        set (${RETURN_FILES} ${_verapp_ls_return_list} PARENT_SCOPE)
    else (${_verapp_ls_result} EQUAL 0)
        message (FATAL_ERROR "ls: " ${_verapp_ls_error})
    endif (${_verapp_ls_result} EQUAL 0)
endfunction (verapp_list_files_in_external_directory)

# verapp_copy_files_in_dir_to_subdir_on_target
#
# Creates a new target that copies all of the files
# matching the criteria to the destination directory
#
# SOURCE : The directory to scan for files
# DESTINATION : The directory to copy the files into
# MATCH : The globbing expression to match files
# TARGET : The name of the target to create, not run by default
# WHAT : A brief description of what is being copied
function (verapp_copy_files_in_dir_to_subdir_on_target
          SOURCE
          DESTINATION
          MATCH
          TARGET
          WHAT)
    # Collect all the files to copy
    set (_verapp_import_files)
    verapp_list_files_in_external_directory (${SOURCE}
                                             "${MATCH}"
                                             _verapp_import_files)

    # We need to find cmake
    find_program (_verapp_import_cmake cmake)
    mark_as_advanced (_verapp_import_cmake)

    # Set the source files for the new "import" target to none
    set (_verapp_import_target_srcs)

    # We will need the length of the source directory in order to
    # determine how much we need to strip later
    string (LENGTH "${SOURCE}" _verapp_import_source_length)

    # On each individual file ...
    foreach (_verapp_import_file
             ${_verapp_import_files})
        set (_verapp_import_input_file_path
             ${_verapp_import_file})
        
        # Get the output filename by stripping the preceeding path
        string (SUBSTRING
                "${_verapp_import_input_file_path}"
                ${_verapp_import_source_length}
                -1
                _verapp_import_output_file)

        # Get the fully-qualified output filename path
        set (_verapp_import_output_file_path
             ${DESTINATION}/${_verapp_import_output_file})

        # Add a new custom command to generate the imported rule within the
        # build directory
        set (_verapp_out_file ${_verapp_import_output_file_path})
        add_custom_command (OUTPUT ${_verapp_import_output_file_path}
                            COMMAND ${_verapp_import_cmake}
                            ARGS -E copy_if_different
                                    ${_verapp_import_input_file_path}
                                    ${_verapp_import_output_file_path}
                            COMMENT
                            "Importing ${WHAT} ${_verapp_import_output_file}")

        # Add the imported file as a source for the input file target
        list (APPEND _verapp_import_target_srcs
              ${_verapp_import_output_file_path})
    endforeach (_verapp_import_file)

    add_custom_target (${TARGET}
                       DEPENDS ${_verapp_import_target_srcs})
endfunction (verapp_copy_files_in_dir_to_subdir_on_target)

# verapp_import_default_rules_into_subdirectory_on_target
#
# Import the default Vera++ rules into a subdirectory
# specified in DIRECTORY. Useful if you wish to rely
# on some of the default rules and then also mix
# with your own.
#
# You should consider importing the rules into the
# projects binary directory or a subdirectory thereof
#
# SUBDIRECTORY : The subdirectory to import the rules into
# TARGET : The target to run the importation before
function (verapp_import_default_rules_into_subdirectory_on_target
          SUBDIRECTORY
          TARGET)
    if (NOT VERAPP_RULES)
        message (FATAL_ERROR "VERAPP_RULES must be set before using "
                             "this command")
    endif (NOT VERAPP_RULES)

    verapp_copy_files_in_dir_to_subdir_on_target (${VERAPP_RULES}
                                                  ${SUBDIRECTORY}
                                                  .tcl
                                                  verapp_import_default_rules
                                                  "Vera++ rule")

    add_dependencies (${TARGET}
                      verapp_import_default_rules)
endfunction (verapp_import_default_rules_into_subdirectory_on_target)

# verapp_import_default_transformations_into_subdirectory_on_target
#
# Import the default Vera++ transformations into a subdirectory
# specified in DIRECTORY. Useful if you wish to rely
# on some of the default transformations and then also mix
# with your own.
#
# You should consider importing the transformations into the
# projects binary directory or a subdirectory thereof
#
# SUBDIRECTORY : The subdirectory to import the transformations into
# TARGET : The target to run the importation before
function (verapp_import_default_transformations_into_subdirectory_on_target
          SUBDIRECTORY
          TARGET)
    if (NOT VERAPP_TRANSFORMATIONS)
        message (FATAL_ERROR "VERAPP_TRANSFORMATIONS must be set before using "
                             "this command")
    endif (NOT VERAPP_TRANSFORMATIONS)

    verapp_copy_files_in_dir_to_subdir_on_target (${VERAPP_TRANSFORMATIONS}
                                                  ${SUBDIRECTORY}
                                                  .tcl
                                                  verapp_import_transformations
                                                  "Vera++ transformation")

    add_dependencies (${TARGET}
                      verapp_import_transformations)
endfunction (verapp_import_default_transformations_into_subdirectory_on_target)

# verapp_import_default_profiles_into_subdirectory_on_target
#
# Import the default Vera++ transformations into a subdirectory
# specified in DIRECTORY. Useful if you wish to rely
# on some of the default transformations and then also mix
# with your own.
#
# You should consider importing the transformations into the
# projects binary directory or a subdirectory thereof
#
# SUBDIRECTORY : The subdirectory to import the transformations into
# TARGET : The target to run the importation before
function (verapp_import_default_profiles_into_subdirectory_on_target
          SUBDIRECTORY
          TARGET)
    if (NOT VERAPP_PROFILES)
        message (FATAL_ERROR "VERAPP_PROFILES must be set before using "
                             "this command")
    endif (NOT VERAPP_PROFILES)

    verapp_copy_files_in_dir_to_subdir_on_target (${VERAPP_PROFILES}
                                                  ${SUBDIRECTORY}
                                                  NO_MATCH
                                                  verapp_import_default_profiles
                                                  "Vera++ profile")

    add_dependencies (${TARGET}
                      verapp_import_default_profiles)
endfunction (verapp_import_default_profiles_into_subdirectory_on_target)

function (_verapp_check_sources_conformance_invariants MODE)

    if (NOT VERAPP_EXECUTABLE)
        message (FATAL_ERROR "VERAPP_EXECUTABLE must be set before using "
                             "this command")
    endif (NOT VERAPP_EXECUTABLE)

    if (NOT MODE STREQUAL "WARN_ONLY" AND NOT MODE STREQUAL "ERROR")
        message (FATAL_ERROR "MODE must be WARN_ONLY or ERROR, was ${MODE}")
    endif (NOT MODE STREQUAL "WARN_ONLY" AND NOT MODE STREQUAL "ERROR")

endfunction (_verapp_check_sources_conformance_invariants)

function (_verapp_profile_check_sources_conformance_for_target VERAPP_DIRECTORY
                                                               SOURCES_VAR
                                                               PROFILE
                                                               TARGET)

    # ERROR passes --error to vera++ so that it
    # returns a nonzero exit code on failure
    if (MODE STREQUAL "ERROR")
        set (_verapp_failure_mode
             --error)
    # WARN_ONLY mode just runs vera++ and lets it
    # print to the stderr. It always returns success
    # so the build will never fail
    elseif (MODE STREQUAL "WARN_ONLY")
        set (_verapp_failure_mode
             --warning)
    endif (MODE STREQUAL "ERROR")

    # Double dereference SOURCES_VAR as SOURCES_VAR
    # just refers to the list name and not the list itself
    foreach (_source ${${SOURCES_VAR}})
        add_custom_command (TARGET ${TARGET}
                            PRE_BUILD
                            COMMAND
                            ${VERAPP_EXECUTABLE}
                            ARGS
                            ${_source}
                            --profile ${PROFILE}
                            --show-rule
                            ${_verapp_failure_mode}
                            WORKING_DIRECTORY ${VERAPP_DIRECTORY})
    endforeach ()

endfunction (_verapp_profile_check_sources_conformance_for_target)

# verapp_profile_check_source_files_list_conformance_for_target
# Run vera++ on the source files provided after building the target
# specified
#
# VERAPP_DIRECTORY : The directory where the vera++ scripts and profiles
#                    are stored
# SOURCES : The sources to check for conformance
# PROFILE : The vera++ profile to run
# TARGET : The target to attach to
# MODE : Either "WARN_ONLY" or "ERROR", the former printing a
#        warning and continuing or the latter forcing an error
function (verapp_profile_check_source_files_conformance_for_target VERAPP_DIRECTORY
                                                                   SOURCES_LIST_VAR
                                                                   PROFILE
                                                                   TARGET
                                                                   MODE)

    _verapp_check_sources_conformance_invariants (${MODE})

    _verapp_profile_check_sources_conformance_for_target (${VERAPP_DIRECTORY}
                                                          ${SOURCES_LIST_VAR}
                                                          ${PROFILE}
                                                          ${TARGET}
                                                          ${MODE})

endfunction (verapp_profile_check_source_files_conformance_for_target)

# verapp_profile_check_source_files_conformance
#
# Run vera++ on the source files used to build the target
# with the specified profile.
#
# VERAPP_DIRECTORY : The directory where the vera++ scripts and profiles
#                    are stored
# SOURCES_DIRECTORY : The directory where the sources are stored
# PROFILE : The vera++ profile to run
# TARGET : The target to scan
# MODE : Either "WARN_ONLY" or "ERROR", the latter printing
#        a warning and continuing, the latter forcing an error
function (verapp_profile_check_source_files_conformance VERAPP_DIRECTORY
                                                        SOURCES_DIRECTORY
                                                        PROFILE
                                                        TARGET
                                                        MODE)

    _verapp_check_sources_conformance_invariants (${MODE})

    get_target_property (_verapp_profile_check_target_sources
                         ${TARGET}
                         SOURCES)

    set (_sources)
    foreach (_verapp_target_source
             ${_verapp_profile_check_target_sources})
        list (APPEND _sources
              ${_verapp_target_source})
    endforeach (_verapp_target_source)

    _verapp_profile_check_sources_conformance_for_target (${VERAPP_DIRECTORY}
                                                          _sources
                                                          ${PROFILE}
                                                          ${TARGET}
                                                          ${MODE})

endfunction (verapp_profile_check_source_files_conformance)
        
