# /CMakeLists.txt
#
# Main entry point for VeraPP tests.
#
# See /LICENCE.md for Copyright information

include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

set (_CURRENT_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}")

include ("cmake/cmake-module-common/Common" OPTIONAL)
include (VeraPPUtilities)


if (NOT CMAKE_SCRIPT_MODE_FILE)

    verapp_validate (HAVE_VERAPP)

else ()

    set (HAVE_VERAPP TRUE)

endif ()

# Check conformance against the boost profile.
function (verapp_test_check_conformance_for_library_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (SOURCE_FILE_CONTENTS
             "/* Copyright */\n"
             "void function ()\n"
             "{\n"
             "}\n")
        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_write_if_newer (${SOURCE_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${SOURCE_FILE_CONTENTS})
        add_library (library SHARED ${SOURCE_FILE_NAME})
        set (RULES_DIR "${BINARY_DIR}/scripts/rules")
        set (PROF_DIR "${BINARY_DIR}/scripts/profiles")
        add_custom_target (on_all ALL)
        verapp_import_default_rules_into_subdir_on_target ("${RULES_DIR}"
                                                           on_all)
        verapp_import_default_profiles_into_subdir_on_target ("${PROF_DIR}"
                                                              on_all)
        set (VERAPP_DIR "${BINARY_DIR}")
        verapp_profile_check_source_files_conformance ("${VERAPP_DIR}"
                                                       PROFILE default
                                                       TARGET library
                                                       DEPENDS on_all
                                                       WARN_ONLY)

    endfunction ()

    function (verapp_verify)

        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "vera++ ${SOURCE_FILE_NAME}")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                variable_contains
                                "--profile default")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new custom target with our own sources and add vera++
# checks to it.
function (verapp_test_check_conformance_for_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (SOURCE_FILE_CONTENTS "/* Copyright */\n" "void function ()\n"
             "{\n"
             "}\n")
        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_write_if_newer (${SOURCE_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${SOURCE_FILE_CONTENTS})
        set (RULES_DIR "${BINARY_DIR}/scripts/rules")
        set (PROF_DIR "${BINARY_DIR}/scripts/profiles")
        add_custom_target (on_all ALL)
        add_custom_target (other_target ALL SOURCES ${SOURCE_FILE_NAME})
        verapp_import_default_rules_into_subdir_on_target ("${RULES_DIR}"
                                                           on_all)
        verapp_import_default_profiles_into_subdir_on_target ("${PROF_DIR}"
                                                              on_all)
        set (VERAPP_DIR "${BINARY_DIR}")
        verapp_profile_check_source_files_conformance ("${VERAPP_DIR}"
                                                       PROFILE default
                                                       TARGET other_target
                                                       DEPENDS on_all
                                                       WARN_ONLY)

    endfunction ()

    function (verapp_verify)

        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "vera++ ${SOURCE_FILE_NAME}")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                variable_contains
                                "--profile default")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new custom target but specifies a list of sources.
# Exit-with-error mode is turned on.
function (verapp_test_check_conformance_for_target_error_mode)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (SOURCE_FILE_CONTENTS "/* Copyright */\n" "void function ()\n"
             "{\n"
             "}\n")
        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_write_if_newer (${SOURCE_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${SOURCE_FILE_CONTENTS})
        set (RULES_DIR "${BINARY_DIR}/scripts/rules")
        set (PROF_DIR "${BINARY_DIR}/scripts/profiles")
        add_custom_target (other_target ALL SOURCES ${SOURCE_FILE_NAME})
        add_custom_target (on_all ALL)
        verapp_import_default_rules_into_subdir_on_target ("${RULES_DIR}"
                                                           on_all)
        verapp_import_default_profiles_into_subdir_on_target ("${PROF_DIR}"
                                                              on_all)
        set (VERAPP_DIR "${BINARY_DIR}")
        verapp_profile_check_source_files_conformance ("${VERAPP_DIR}"
                                                       PROFILE default
                                                       TARGET other_target
                                                       DEPENDS on_all)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "--error")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new custom target with our own native and generated sources and
# add vera++ checks to it, with the CHECK_GENERATED to check generated
# sources too.
function (verapp_test_check_conformance_for_target_generated)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (SOURCE_FILE_CONTENTS
             "/* Copyright */\n"
             "void function ()\n"
             "{\n"
             "}\n")
        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_write_if_newer (${SOURCE_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${SOURCE_FILE_CONTENTS})
        set (GENERATED_SOURCE_FILE_NAME
             "${SOURCE_DIR}/GeneratedSource.cpp")
        set (GENERATED_SOURCE_INPUT_FILE_NAME
             "${SOURCE_DIR}/GeneratedSourceInput.cpp")
        set (GENERATED_SOURCE_INPUT_FILE_CONTENTS
             "/* Copyright */\n"
             "void other_function ()\n"
             "{\n"
             "}\n")
        cmake_unit_write_if_newer (${GENERATED_SOURCE_INPUT_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${GENERATED_SOURCE_INPUT_FILE_CONTENTS})
        add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE_NAME} COMMAND
                            "${CMAKE_COMMAND}"
                            -E
                            copy
                            ${GENERATED_SOURCE_INPUT_FILE_NAME}
                            ${GENERATED_SOURCE_FILE_NAME})
        add_custom_target (other_target ALL SOURCES ${SOURCE_FILE_NAME}
                           ${GENERATED_SOURCE_FILE_NAME})
        set (RULES_DIR "${BINARY_DIR}/scripts/rules")
        set (PROF_DIR "${BINARY_DIR}/scripts/profiles")
        add_custom_target (on_all ALL)
        verapp_import_default_rules_into_subdir_on_target ("${RULES_DIR}"
                                                           on_all)
        verapp_import_default_profiles_into_subdir_on_target ("${PROF_DIR}"
                                                              on_all)
        set (VERAPP_DIR "${BINARY_DIR}")
        verapp_profile_check_source_files_conformance ("${VERAPP_DIR}"
                                                       DEPENDS on_all
                                                       PROFILE default
                                                       TARGET other_target
                                                       WARN_ONLY
                                                       CHECK_GENERATED)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*vera.. .*Source.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                any_line
                                matches_regex
                                "^.*vera.. .*GeneratedSource.cpp.*$")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new custom target with our own sources and generated sources but
# do not add the CHECK_GENERATED flag to vera++ checks.
function (verapp_test_check_conformance_for_target_no_generated)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (SOURCE_FILE_CONTENTS "/* Copyright */\n" "void function ()\n"
             "{\n"
             "}\n")
        set (SOURCE_FILE_NAME "${SOURCE_DIR}/Source.cpp")
        cmake_unit_write_if_newer (${SOURCE_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${SOURCE_FILE_CONTENTS})
        set (GENERATED_SOURCE_FILE_NAME
             "${SOURCE_DIR}/GeneratedSource.cpp")
        set (GENERATED_SOURCE_INPUT_FILE_NAME
             "${SOURCE_DIR}/GeneratedSourceInput.cpp")
        set (GENERATED_SOURCE_INPUT_FILE_CONTENTS "/* Copyright */\n"
             "void other_function ()\n"
             "{\n"
             "}\n")
        cmake_unit_write_if_newer (${GENERATED_SOURCE_INPUT_FILE_NAME}
                                   "${_CURRENT_LIST_FILE}"
                                   ${GENERATED_SOURCE_INPUT_FILE_CONTENTS})
        add_custom_command (OUTPUT ${GENERATED_SOURCE_FILE_NAME} COMMAND
                            "${CMAKE_COMMAND}"
                            -E
                            copy
                            ${GENERATED_SOURCE_INPUT_FILE_NAME}
                            ${GENERATED_SOURCE_FILE_NAME})
        add_custom_target (other_target ALL
                           SOURCES ${SOURCE_FILE_NAME}
                                   ${GENERATED_SOURCE_FILE_NAME})
        set (RULES_DIR "${BINARY_DIR}/scripts/rules")
        set (PROF_DIR "${BINARY_DIR}/scripts/profiles")
        add_custom_target (on_all ALL)
        verapp_import_default_rules_into_subdir_on_target ("${RULES_DIR}"
                                                           on_all)
        verapp_import_default_profiles_into_subdir_on_target ("${PROF_DIR}"
                                                              on_all)
        set (VERAPP_DIR "${BINARY_DIR}")
        verapp_profile_check_source_files_conformance ("${VERAPP_DIR}"
                                                       PROFILE default
                                                       TARGET other_target
                                                       DEPENDS on_all
                                                       WARN_ONLY)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*vera.. .*Source.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                not
                                file_contents
                                any_line
                                matches_regex
                                "^.*vera.. .*GeneratedSource.cpp.*$")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Tests setting up a new target to attach a custom command to copy
# files in a directory to a subdirectory.
function (verapp_test_copy_files_in_dir_to_subdir_on_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (DIRECTORY_WITH_FILES "${BINARY_DIR}/Directory/")
        set (DESTINATION_DIRECTORY "${DIRECTORY_WITH_FILES}Destination/")
        set (FIRST_FILE ${DIRECTORY_WITH_FILES}FirstFile)
        set (SECOND_FILE ${DIRECTORY_WITH_FILES}SecondFile)
        file (MAKE_DIRECTORY ${DIRECTORY_WITH_FILES})
        file (MAKE_DIRECTORY "${DESTINATION_DIRECTORY}")
        cmake_unit_write_if_newer ("${FIRST_FILE}" "${_CURRENT_LIST_FILE}" "")
        cmake_unit_write_if_newer ("${SECOND_FILE}" "${_CURRENT_LIST_FILE}" "")
        verapp_copy_files_in_dir_to_subdir_on_target (copy_files COMMENT
                                                      "My File"
                                                      DIRECTORY
                                                      ${DIRECTORY_WITH_FILES}
                                                      DESTINATION
                                                      "${DESTINATION_DIRECTORY}"
                                                      MATCH
                                                      "*File")
        add_custom_target (on_all ALL)
        add_dependencies (on_all copy_files)

    endfunction ()

    function (verapp_verify)

        set (DESTINATION_DIRECTORY "${BINARY_DIR}/Directory/Destination")
        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/FirstFile"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/SecondFile"
                                exists_as_file)

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND verapp_configure
                               VERIFY COMMAND verapp_verify)

endfunction ()

# Tests setting up a new target to attach a custom command to copy
# files in a directory to a subdirectory.
function (verapp_test_copy_files_in_dir_to_subdir_on_target_with_comment)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (DIRECTORY_WITH_FILES "${BINARY_DIR}/Directory/")
        set (DESTINATION_DIRECTORY "${DIRECTORY_WITH_FILES}Destination/")
        set (FIRST_FILE ${DIRECTORY_WITH_FILES}FirstFile)
        file (MAKE_DIRECTORY ${DIRECTORY_WITH_FILES})
        file (MAKE_DIRECTORY "${DESTINATION_DIRECTORY}")
        cmake_unit_write_if_newer ("${FIRST_FILE}" "${_CURRENT_LIST_FILE}" "")
        verapp_copy_files_in_dir_to_subdir_on_target (copy_files
                                                      COMMENT "My File"
                                                      DIRECTORY
                                                      ${DIRECTORY_WITH_FILES}
                                                      DESTINATION
                                                      "${DESTINATION_DIRECTORY}"
                                                      MATCH
                                                      "*FirstFile")
        add_custom_target (on_all ALL)
        add_dependencies (on_all copy_files)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "Importing My File")

    endfunction ()

    cmake_unit_configure_test (PRECONFIGURE OPTIONS
                                            SKIP_GENERATOR_REGEX
                                            "Ninja"
                               CONFIGURE COMMAND verapp_configure
                               VERIFY COMMAND verapp_verify)

endfunction ()

# Creates a new target to import vera++ default rules on.
function (verapp_test_import_default_profiles_into_subdir_on_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        add_custom_target (on_all ALL)
        set (SUBDIR "${BINARY_DIR}/subdirectory")
        verapp_import_default_profiles_into_subdir_on_target (${SUBDIR}
                                                              on_all)
        cmake_unit_assert_that (on_all_verapp_import_default_profiles
                                target_exists)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (DESTINATION_DIRECTORY "${BINARY_DIR}/subdirectory")
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/boost" exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/default"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/full"
                                exists_as_file)

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new target to import vera++ default rules on.
function (verapp_test_import_default_profiles_into_subdir_with_comment)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        add_custom_target (on_all ALL)
        set (SUBDIR "${BINARY_DIR}/subdirectory")
        verapp_import_default_profiles_into_subdir_on_target (${SUBDIR}
                                                              on_all)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "Importing Vera++ profile")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (PRECONFIGURE OPTIONS
                                                SKIP_GENERATOR_REGEX
                                                "Ninja"
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new target to import vera++ default rules on.
function (verapp_test_import_default_rules_into_subdir_on_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        add_custom_target (on_all ALL)
        set (SUBDIR "${BINARY_DIR}/subdirectory")
        verapp_import_default_rules_into_subdir_on_target (${SUBDIR}
                                                           on_all)
        cmake_unit_assert_that (on_all_verapp_import_default_rules
                                target_exists)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (DESTINATION_DIRECTORY "${BINARY_DIR}/subdirectory")
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/F001.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/F002.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/L001.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/L002.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/L003.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/L004.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/L005.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/L006.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T001.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T002.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T003.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T004.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T005.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T006.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T007.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T008.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T009.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T010.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T011.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T012.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T013.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T014.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T015.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T016.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T017.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T018.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/T019.tcl"
                                exists_as_file)

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new target to import vera++ default rules on.
function (verapp_test_import_default_rules_into_subdir_on_target_with_comment)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        add_custom_target (on_all ALL)
        set (SUBDIR "${BINARY_DIR}/subdirectory")
        verapp_import_default_rules_into_subdir_on_target (${SUBDIR}
                                                           on_all)

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "Importing Vera++ rule")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (PRECONFIGURE OPTIONS
                                                SKIP_GENERATOR_REGEX
                                                "Ninja"
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new target to import vera++ default rules on.
function (verapp_test_import_default_transformations_into_subdir_on_target)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        add_custom_target (on_all ALL)
        set (S "${BINARY_DIR}/subdirectory")
        set (T on_all)
        verapp_import_default_transformations_into_subdir_on_target (${S}
                                                                     ${T})
        cmake_unit_assert_that (on_all_verapp_import_default_transformations
                                target_exists)

    endfunction ()

    function (verapp_verify)

        set (DESTINATION_DIRECTORY "${BINARY_DIR}/subdirectory")
        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/move_includes.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/move_macros.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/move_namespace.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/to_lower.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/to_xml.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/to_xml2.tcl"
                                exists_as_file)
        cmake_unit_assert_that ("${DESTINATION_DIRECTORY}/trim_right.tcl"
                                exists_as_file)

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Creates a new target to import vera++ default transformations on.
function (verapp_test_import_default_transformations_into_subdir_with_comment)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        add_custom_target (on_all ALL)
        set (S "${BINARY_DIR}/subdirectory")
        set (T on_all)
        verapp_import_default_transformations_into_subdir_on_target (${S}
                                                                     ${T})

    endfunction ()

    function (verapp_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents variable_contains
                                "Importing Vera++ transformation")

    endfunction ()

    if (HAVE_VERAPP)

        cmake_unit_configure_test (PRECONFIGURE OPTIONS
                                                SKIP_GENERATOR_REGEX
                                                "Ninja"
                                   CONFIGURE COMMAND verapp_configure
                                   VERIFY COMMAND verapp_verify)

    endif ()

endfunction ()

# Tests getting a list of files in some external directory
# using verapp_list_files_in_external_directory
function (verapp_test_list_files_in_external_directory)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (DIRECTORY_WITH_FILE "${BINARY_DIR}/Directory/")
        set (FILE_TO_MAKE "${DIRECTORY_WITH_FILE}File")
        file (MAKE_DIRECTORY "${DIRECTORY_WITH_FILE}")
        cmake_unit_write_if_newer (${FILE_TO_MAKE} "${_CURRENT_LIST_FILE}" "")
        verapp_list_files_in_external_directory (RETURN_VALUE DIRECTORY
                                                 "${DIRECTORY_WITH_FILE}")
        cmake_unit_assert_that (RETURN_VALUE
                                list_contains_value STRING EQUAL
                                "${FILE_TO_MAKE}")

    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND verapp_configure)

endfunction ()

# Tests getting a list of files in some external directory
# using verapp_list_files_in_external_directory
function (verapp_test_list_files_in_external_directory_matching)

    cmake_unit_get_dirs (BINARY_DIR SOURCE_DIR)

    function (verapp_configure)

        set (DIRECTORY_WITH_FILE "${BINARY_DIR}/Directory/")
        set (FILE_TO_MAKE "${DIRECTORY_WITH_FILE}File")
        set (UNMATCHED_FILE_TO_MAKE "${DIRECTORY_WITH_FILE}AUnmatched")
        file (MAKE_DIRECTORY "${DIRECTORY_WITH_FILE}")
        cmake_unit_write_if_newer (${FILE_TO_MAKE} "${_CURRENT_LIST_FILE}" "")
        file (MAKE_DIRECTORY "${DIRECTORY_WITH_FILE}")
        cmake_unit_write_if_newer (${UNMATCHED_FILE_TO_MAKE}
                                   "${_CURRENT_LIST_FILE}"
                                   "")
        verapp_list_files_in_external_directory (MATCH "File" DIRECTORY
                                                 "${DIRECTORY_WITH_FILE}"
                                                 RETURN_VALUE)
        foreach (FILE ${RETURN_VALUE})
            cmake_unit_assert_that (FILE
                                    not compare_as
                                    STRING EQUAL ${UNMATCHED_FILE_TO_MAKE})
        endforeach ()


    endfunction ()

    cmake_unit_configure_config_only_test (CONFIGURE COMMAND verapp_configure)

endfunction ()

set (CMAKE_FILES
     "${CMAKE_CURRENT_LIST_DIR}/VeraPPUtilities.cmake"
     "${CMAKE_CURRENT_LIST_DIR}/FindVERAPP.cmake"
     "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")
set (MARKDOWN_FILES
     "${CMAKE_CURRENT_LIST_DIR}/LICENCE.md"
     "${CMAKE_CURRENT_LIST_DIR}/README.md")

if (COMMAND cmake_module_add_common_targets)

    cmake_module_add_common_targets (NAMESPACE "verapp"
                                     CMAKE_FILES ${CMAKE_FILES}
                                     DOCUMENTATION_FILES ${MARKDOWN_FILES})

endif ()
