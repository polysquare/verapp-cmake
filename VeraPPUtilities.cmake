# VeraPPUtilities.cmake
# Copyright (c) 2013 Sam Spilsbury <smspillaz@gmail.com>
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
function (verapp_list_files_in_external_directory DIRECTORY MATCH RETURN_FILES)
    find_program (_verapp_ls ls)

    if (${_verapp_ls} STREQUAL "_verapp_ls-NOTFOUND")
        message (FATAL_ERROR "A Unix userland containing 'ls' was not found")
    endif (${_verapp_ls} STREQUAL "_verapp_ls-NOTFOUND")

    find_program (_verapp_grep grep)

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
        set (_verapp_out_file ${_verapp_import_output_file})
        add_custom_command (OUTPUT ${_verapp_import_output_file}
                            COMMAND ${_verapp_import_cmake}
                            ARGS -E copy_if_different
                                    ${_verapp_import_input_file_path}
                                    ${_verapp_import_output_file}
                            COMMENT
                            "Importing ${WHAT} ${_verapp_import_output_file}")

        # Add the imported file as a source for the input file target
        list (APPEND _verapp_import_target_srcs
              ${_verapp_import_output_file})
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
        message (SEND_ERROR "VERAPP_RULES must be set before using "
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
        message (SEND_ERROR "VERAPP_TRANSFORMATIONS must be set before using "
                            "this command")
    endif (NOT VERAPP_TRANSFORMATIONS)

    message (${VERAPP_TRANSFORMATIONS})

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
        message (SEND_ERROR "VERAPP_PROFILES must be set before using "
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
