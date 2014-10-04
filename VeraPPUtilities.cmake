# VeraPPUtilities.cmake
#
# Some utility functions to scan projects using vera++

# verapp_list_files_in_external_directory
#
# Searches any external directory path, relative or absolute for
# files which match MATCH.
#
# RETURN_FILES : The name of a variable to store a list
#                of fully-qualified files
# [Optional] DIRECTORY : Directory to list files from. Must end with a "/". If
#                        not specified, the CMAKE_CURRENT_SOURCE_DIR is used.
# [Optional] MATCH : Globbing expression used to match files.
#
# See LICENCE.md for Copyright info

include (CMakeParseArguments)
include (${CMAKE_CURRENT_LIST_DIR}/tooling-cmake-util/PolysquareToolingUtil.cmake)

function (verapp_list_files_in_external_directory RETURN_FILES)
    set (VERAPP_LIST_FILES_SINGLVAR_ARGS DIRECTORY MATCH)

    cmake_parse_arguments (VERAPP_LIST_FILES
                           ""
                           "${VERAPP_LIST_FILES_SINGLVAR_ARGS}"
                           ""
                           ${ARGN})

    get_filename_component (ABSOLUTE_PATH
                            ${VERAPP_LIST_FILES_DIRECTORY}
                            ABSOLUTE)

    if (NOT VERAPP_LIST_FILES_MATCH)

        set (VERAPP_LIST_FILES_MATCH *)

    endif (NOT VERAPP_LIST_FILES_MATCH)

    file (GLOB RESULT "${ABSOLUTE_PATH}/${VERAPP_LIST_FILES_MATCH}")
    set (${RETURN_FILES} ${RESULT} PARENT_SCOPE)
endfunction (verapp_list_files_in_external_directory)

# verapp_copy_files_in_dir_to_subdir_on_target
#
# Creates a new target that copies all of the files
# matching the criteria to the destination directory
#
# TARGET : The name of the target to create, not run by default
# DIRECTORY : The source directory to scan for files
# DESTINATION : The directory to copy the files into
# MATCH : The globbing expression to match files
# [Optional] COMMENT : A brief description of what is being copied
function (verapp_copy_files_in_dir_to_subdir_on_target TARGET)
    set (COPY_FILES_SINGLEVAR_ARGS
         DESTINATION
         DIRECTORY
         MATCH
         COMMENT)
    cmake_parse_arguments (COPY_FILES
                           ""
                           "${COPY_FILES_SINGLEVAR_ARGS}"
                           ""
                           ${ARGN})
    psq_assert_set (COPY_FILES_DESTINATION "Must specify a DESTINATION")
    psq_assert_set (COPY_FILES_DIRECTORY "Must specify source DIRECTORY")

    psq_forward_options (COPY_FILES LIST_FILES_FORWARD_OPTIONS
                         SINGLEVAR_ARGS ${COPY_FILES_SINGLEVAR_ARGS})

    # Collect all the files to copy
    set (_verapp_import_files)
    verapp_list_files_in_external_directory (_verapp_import_files
                                             ${LIST_FILES_FORWARD_OPTIONS})

    # Set the source files for the new "import" target to none
    set (_verapp_import_target_srcs)

    # On each individual file ...
    foreach (_verapp_import_file ${_verapp_import_files})

        # Get basename out output file.
        get_filename_component (_output_file_name
                                ${_verapp_import_file}
                                NAME)

        # Get the fully-qualified output filename path
        set (_verapp_import_output_file_path
             ${COPY_FILES_DESTINATION}/${_output_file_name})

        # Add a new custom command to generate the imported rule within the
        # build directory
        add_custom_command (OUTPUT ${_verapp_import_output_file_path}
                            COMMAND ${CMAKE_COMMAND}
                            ARGS -E copy_if_different
                                    ${_verapp_import_file}
                                    ${_verapp_import_output_file_path}
                            DEPENDS ${_verapp_import_file}
                            COMMENT
                            "Importing ${COPY_FILES_COMMENT} ${_verapp_import_output_file}")

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

    verapp_copy_files_in_dir_to_subdir_on_target (${_new_target}
                                                  COMMENT "Vera++ rule"
                                                  DIRECTORY ${VERAPP_RULES}
                                                  DESTINATION ${SUBDIRECTORY}
                                                  MATCH *.tcl)

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

    verapp_copy_files_in_dir_to_subdir_on_target (${_new_target}
                                                  COMMENT
                                                  "Vera++ transformation"
                                                  DIRECTORY
                                                  ${VERAPP_TRANSFORMATIONS}
                                                  DESTINATION ${SUBDIRECTORY}
                                                  MATCH *.tcl)

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

    verapp_copy_files_in_dir_to_subdir_on_target (${_new_target}
                                                  COMMENT "Vera++ profile"
                                                  DIRECTORY ${VERAPP_PROFILES}
                                                  DESTINATION ${SUBDIRECTORY})

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
         CHECK_GENERATED
         WARN_ONLY)
    set (GET_COMMANDLINE_SINGLEVAR_ARGS
         PROFILE)
    set (GET_COMMANDLINE_MULTIVAR_ARGS
         SOURCES)

    cmake_parse_arguments (GET_COMMANDLINE
                           "${GET_COMMANDLINE_OPTIONS}"
                           "${GET_COMMANDLINE_SINGLEVAR_ARGS}"
                           "${GET_COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    psq_assert_set (GET_COMMANDLINE_PROFILE
                    "PROFILE must be set in the options for "
                    "_verapp_get_commandline_list")
    psq_assert_set (GET_COMMANDLINE_SOURCES
                    "SOURCES must be set in the options for "
                    "_verapp_get_commandline_list")

    # WARN_ONLY mode just runs vera++ and lets it
    # print to the stderr. It always returns success
    # so the build will never fail. If WARN_ONLY
    # is not set, then --error is passed and a nonzero
    # exit code is always returned on failure.
    psq_add_switch (_verapp_failure_mode WARN_ONLY
                    ON --warning
                    OFF --error)

    psq_handle_check_generated_option (GET_COMMANDLINE FILTERED_SOURCES
                                       SOURCES ${GET_COMMANDLINE_SOURCES})

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

    psq_get_target_command_attach_point (${TARGET} WHEN)

    set (CHECK_CONFORMANCE_OPTIONS CHECK_GENERATED)

    cmake_parse_arguments (CHECK_CONFORMANCE
                           "${CHECK_CONFORMANCE_OPTIONS}"
                           ""
                           ""
                           ${ARGN})
    psq_forward_options (CHECK_CONFORMANCE GET_COMMANDLINE_FORWARD_OPTIONS
                         OPTION_ARGS ${CHECK_CONFORMANCE_OPTIONS})

    _verapp_get_commandline_list (COMMAND_LIST
                                  SOURCES ${${SOURCES_VAR}}
                                  PROFILE ${PROFILE}
                                  MODE ${MODE}
                                  ${GET_COMMANDLINE_FORWARD_OPTIONS})

    # Ensure that the directory always exists.
    file (MAKE_DIRECTORY ${VERAPP_DIRECTORY})

    # DEPENDS with a target name doesn't quite work on this situation
    # so just add a dependency on the normal target.
    add_custom_command (TARGET ${TARGET}
                        ${WHEN}
                        ${COMMAND_LIST}
                        WORKING_DIRECTORY ${VERAPP_DIRECTORY})

    add_dependencies (${TARGET} ${IMPORT_TARGET})

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
    psq_forward_options (CHECK_CONFORMANCE GET_COMMANDLINE_FORWARD_OPTIONS
                         OPTION_ARGS ${CHECK_CONFORMANCE_OPTIONS})

    _verapp_get_commandline_list (COMMAND_LIST
                                  SOURCES ${${SOURCES_LIST_VAR}}
                                  PROFILE ${PROFILE}
                                  MODE ${MODE}
                                  ${GET_COMMANDLINE_FORWARD_OPTIONS})

    set (STAMPFILE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.stamp)

    # Ensure that the directory always exists.
    file (MAKE_DIRECTORY ${VERAPP_DIRECTORY})

    add_custom_command (OUTPUT ${STAMPFILE}
                        ${COMMAND_LIST}
                        COMMAND ${CMAKE_COMMAND} -E touch ${STAMPFILE}
                        WORKING_DIRECTORY
                        ${VERAPP_DIRECTORY}
                        DEPENDS
                        ${${SOURCES_LIST_VAR}}
                        COMMENT "Vera++ check for source group: ${TARGET}")

    add_custom_target (${TARGET} ALL
                       DEPENDS
                       ${STAMPFILE}
                       ${IMPORT_TARGET})

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
    psq_strip_add_custom_target_sources (_verapp_profile_check_target_sources
                                         ${TARGET})

    set (_sources)
    foreach (_verapp_target_source ${_verapp_profile_check_target_sources})
        list (APPEND _sources
              ${_verapp_target_source})
    endforeach (_verapp_target_source)

    _verapp_profile_check_sources_conformance_for_target (${VERAPP_DIRECTORY}
                                                          _sources
                                                          ${PROFILE}
                                                          ${TARGET}
                                                          ${IMPORT_TARGET}
                                                          ${MODE}
                                                          ${ARGN})

endfunction (verapp_profile_check_source_files_conformance)
        
