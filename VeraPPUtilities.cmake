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

include (CMakeParseArguments)

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
        message (FATAL_ERROR "ls ${DIRECTORY}:" ${_verapp_ls_error})
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
                            DEPENDS ${_verapp_import_input_file_path}
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

    set (_new_target ${TARGET}_verapp_import_default_rules)

    verapp_copy_files_in_dir_to_subdir_on_target (${VERAPP_RULES}
                                                  ${SUBDIRECTORY}
                                                  .tcl
                                                  ${_new_target}
                                                  "Vera++ rule")

    add_dependencies (${TARGET}
                      ${_new_target})
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

    set (_new_target ${TARGET}_verapp_import_default_transformations)

    verapp_copy_files_in_dir_to_subdir_on_target (${VERAPP_TRANSFORMATIONS}
                                                  ${SUBDIRECTORY}
                                                  .tcl
                                                  ${_new_target}
                                                  "Vera++ transformation")

    add_dependencies (${TARGET}
                      ${_new_target})
endfunction (verapp_import_default_transformations_into_subdirectory_on_target)

# verapp_import_default_profiles_into_subdirectory_on_target
#
# Import the default Vera++ profiles into a subdirectory
# specified in DIRECTORY. Useful if you wish to rely
# one one of the default profiles.
#
# You should consider importing the profiles into the
# projects binary directory or a subdirectory thereof
#
# SUBDIRECTORY : The subdirectory to import the profiles into
# TARGET : The target to run the profiles before
function (verapp_import_default_profiles_into_subdirectory_on_target
          SUBDIRECTORY
          TARGET)
    if (NOT VERAPP_PROFILES)
        message (FATAL_ERROR "VERAPP_PROFILES must be set before using "
                             "this command")
    endif (NOT VERAPP_PROFILES)

    set (_new_target ${TARGET}_verapp_import_default_profiles)

    verapp_copy_files_in_dir_to_subdir_on_target (${VERAPP_PROFILES}
                                                  ${SUBDIRECTORY}
                                                  NO_MATCH
                                                  ${_new_target}
                                                  "Vera++ profile")

    add_dependencies (${TARGET}
                      ${_new_target})
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

function (_filter_sources_list RESULT_SOURCES_VARIABLE)

    set (FILTER_SOURCES_LIST_MULTIVAR_OPTIONS SOURCES)
    set (FILTER_SOURCES_LIST_OPTIONS ALLOW_GENERATED)

    cmake_parse_arguments (FILTER_SOURCES_LIST
                           "${FILTER_SOURCES_LIST_OPTIONS}"
                           ""
                           "${FILTER_SOURCES_LIST_MULTIVAR_OPTIONS}"
                           ${ARGN})

    set (FILTERED_SOURCES)

    foreach (SOURCE ${FILTER_SOURCES_LIST_SOURCES})
        get_property (SOURCE_IS_GENERATED
                      SOURCE ${SOURCE}
                      PROPERTY GENERATED)

        if (SOURCE_IS_GENERATED)
            # If we're allowing GENERATED sources then immediately
            # add them to the filtered sources list, otherwise skip them.
            if (FILTER_SOURCES_LIST_ALLOW_GENERATED)
                list (APPEND FILTERED_SOURCES ${SOURCE})
                break ()
            else (FILTER_SOURCES_LIST_ALLOW_GENERATED)
                break ()
            endif (FILTER_SOURCES_LIST_ALLOW_GENERATED)

        else (SOURCE_IS_GENERATED)
            list (APPEND FILTERED_SOURCES ${SOURCE})
        endif (SOURCE_IS_GENERATED)
    endforeach ()

    set (${RESULT_SOURCES_VARIABLE} ${FILTERED_SOURCES} PARENT_SCOPE)

endfunction ()

# Returns a list of command lines to run, each command being separated by
# the COMMAND operator, so that the entire list can be passed directly
# to add_custom_command or add_custom_target
function (_verapp_get_commandline_list COMMANDLINES_RETURN)

    set (GET_COMMANDLINE_OPTIONS
         CHECK_GENERATED)
    set (GET_COMMANDLINE_SINGLEVAR_ARGS
         MODE
         PROFILE)
    set (GET_COMMANDLINE_MULTIVAR_ARGS
         SOURCES)

    cmake_parse_arguments (GET_COMMANDLINE
                           "${GET_COMMANDLINE_OPTIONS}"
                           "${GET_COMMANDLINE_SINGLEVAR_ARGS}"
                           "${GET_COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (NOT GET_COMMANDLINE_MODE)
        message (FATAL_ERROR "MODE must be set in the options for "
                             "_verapp_get_commandline_list")
    endif (NOT GET_COMMANDLINE_MODE)

    if (NOT GET_COMMANDLINE_PROFILE)
        message (FATAL_ERROR "PROFILE must be set in the options for "
                             "_verapp_get_commandline_list")
    endif (NOT GET_COMMANDLINE_PROFILE)

    if (NOT GET_COMMANDLINE_SOURCES)
        message (FATAL_ERROR "SOURCES must be set in the options for "
                             "_verapp_get_commandline_list")
    endif (NOT GET_COMMANDLINE_SOURCES)

    # ERROR passes --error to vera++ so that it
    # returns a nonzero exit code on failure
    if (GET_COMMANDLINE_MODE STREQUAL "ERROR")
        set (_verapp_failure_mode
             --error)
    # WARN_ONLY mode just runs vera++ and lets it
    # print to the stderr. It always returns success
    # so the build will never fail
    elseif (GET_COMMANDLINE_MODE STREQUAL "WARN_ONLY")
        set (_verapp_failure_mode
             --warning)
    endif (GET_COMMANDLINE_MODE STREQUAL "ERROR")

    set (CHECK_GENERATED_OPTION)
    if (GET_COMMANDLINE_CHECK_GENERATED)
        set (CHECK_GENERATED_OPTION ALLOW_GENERATED)
    endif (GET_COMMANDLINE_CHECK_GENERATED)

    # Double dereference SOURCES_VAR as SOURCES_VAR
    # just refers to the list name and not the list itself
    _filter_sources_list (FILTERED_SOURCES
                          SOURCES ${GET_COMMANDLINE_SOURCES}
                          ${CHECK_GENERATED_OPTION})

    set (COMMAND_LIST)

    foreach (SOURCE ${FILTERED_SOURCES})

        list (APPEND COMMAND_LIST
              COMMAND
              ${VERAPP_EXECUTABLE}
              ${SOURCE}
              --profile
              ${GET_COMMANDLINE_PROFILE}
              --show-rule
              ${_verapp_failure_mode})

    endforeach ()

    set (${COMMANDLINES_RETURN} ${COMMAND_LIST} PARENT_SCOPE)

endfunction (_verapp_get_commandline_list)

function (_verapp_profile_check_sources_conformance_for_target VERAPP_DIRECTORY
                                                               SOURCES_VAR
                                                               PROFILE
                                                               TARGET
                                                               IMPORT_TARGET
                                                               MODE)

    get_property (TARGET_TYPE
                  TARGET ${TARGET}
                  PROPERTY TYPE)

    set (WHEN PRE_LINK)

    if (TARGET_TYPE STREQUAL "UTILITY")

        set (WHEN PRE_BUILD)

    endif (TARGET_TYPE STREQUAL "UTILITY")

    set (CHECK_CONFORMANCE_OPTIONS CHECK_GENERATED)

    cmake_parse_arguments (CHECK_CONFORMANCE
                           "${CHECK_CONFORMANCE_OPTIONS}"
                           ""
                           ""
                           ${ARGN})
    set (CHECK_GENERATED_OPTION)
    if (CHECK_CONFORMANCE_CHECK_GENERATED)
        set (CHECK_GENERATED_OPTION CHECK_GENERATED)
    endif (CHECK_CONFORMANCE_CHECK_GENERATED)

    _verapp_get_commandline_list (COMMAND_LIST
                                  SOURCES ${${SOURCES_VAR}}
                                  PROFILE ${PROFILE}
                                  MODE ${MODE}
                                  ${CHECK_GENERATED_OPTION})

    add_custom_command (TARGET ${TARGET}
                        ${WHEN}
                        ${COMMAND_LIST}
                        DEPENDS ${IMPORT_TARGET}
                        WORKING_DIRECTORY ${VERAPP_DIRECTORY})

endfunction (_verapp_profile_check_sources_conformance_for_target)

# verapp_profile_check_source_files_list_conformance_for_target
# Run vera++ on the source files provided after building the target
# specified
#
# VERAPP_DIRECTORY : The directory where the vera++ scripts and profiles
#                    are stored
# SOURCES : The sources to check for conformance
# PROFILE : The vera++ profile to run
# TARGET : The target to create
# MODE : Either "WARN_ONLY" or "ERROR", the former printing a
#        warning and continuing or the latter forcing an error
# [Optional] CHECK_GENERATED : Whether or not to check generated
#                              source files too.
function (verapp_profile_check_source_files_conformance_for_target VERAPP_DIRECTORY
                                                                   SOURCES_LIST_VAR
                                                                   PROFILE
                                                                   TARGET
                                                                   IMPORT_TARGET
                                                                   MODE)

    _verapp_check_sources_conformance_invariants (${MODE})

    set (CHECK_CONFORMANCE_OPTIONS CHECK_GENERATED)

    cmake_parse_arguments (CHECK_CONFORMANCE
                           "${CHECK_CONFORMANCE_OPTIONS}"
                           ""
                           ""
                           ${ARGN})
    set (CHECK_GENERATED_OPTION)
    if (CHECK_CONFORMANCE_CHECK_GENERATED)
        set (CHECK_GENERATED_OPTION CHECK_GENERATED)
    endif (CHECK_CONFORMANCE_CHECK_GENERATED)

    _verapp_get_commandline_list (COMMAND_LIST
                                  SOURCES ${${SOURCES_LIST_VAR}}
                                  PROFILE ${PROFILE}
                                  MODE ${MODE}
                                  ${CHECK_GENERATED_OPTION})

    set (STAMPFILE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.stamp)

    add_custom_command (OUTPUT ${STAMPFILE}
                        ${COMMAND_LIST}
                        COMMAND ${CMAKE_COMMAND} -E touch ${STAMPFILE}
                        WORKING_DIRECTORY
                        ${VERAPP_DIRECTORY}
                        DEPENDS
                        ${${SOURCES_LIST_VAR}}
                        ${IMPORT_TARGET}
                        COMMENT "Vera++ check for source group: ${TARGET}")

    add_custom_target (${TARGET} ALL
                       DEPENDS
                       ${STAMPFILE})

endfunction (verapp_profile_check_source_files_conformance_for_target)

# verapp_profile_check_source_files_conformance
#
# Run vera++ on the source files used to build the target
# with the specified profile.
#
# VERAPP_DIRECTORY : The directory where the vera++ scripts and profiles
#                    are stored
# PROFILE : The vera++ profile to run
# TARGET : The target to scan
# MODE : Either "WARN_ONLY" or "ERROR", the latter printing
#        a warning and continuing, the latter forcing an error
# [Optional] CHECK_GENERATED : Whether or not to check generated
#                              source files too.
function (verapp_profile_check_source_files_conformance VERAPP_DIRECTORY
                                                        PROFILE
                                                        TARGET
                                                        IMPORT_TARGET
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

    get_target_property (_verapp_profile_check_target_type
                         ${TARGET}
                         TYPE)

    # UTILITY targets are created by add_custom_target. They have
    # one source, which is the stamp file created by the target
    # which it outputs later. Remove that stamp file, as there may
    # be other sources which we are about.
    if (_verapp_profile_check_target_type STREQUAL "UTILITY")
        list (REMOVE_AT _sources 0)
    endif (_verapp_profile_check_target_type STREQUAL "UTILITY")

    _verapp_profile_check_sources_conformance_for_target (${VERAPP_DIRECTORY}
                                                          _sources
                                                          ${PROFILE}
                                                          ${TARGET}
                                                          ${IMPORT_TARGET}
                                                          ${MODE}
                                                          ${ARGN})

endfunction (verapp_profile_check_source_files_conformance)
        
