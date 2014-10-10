# FindVeraPP.cmake
#
# This CMake script will search for vera++ and set the following
# variables
#
# VERAPP_FOUND : Whether or not vera++ is available on the target system
# VERAPP_VERSION : Version of vera++
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

include (${CMAKE_CURRENT_LIST_DIR}/tooling-find-package-cmake-util/ToolingFindPackageUtil.cmake)

function (_find_verapp)

    # Set-up the directory tree of the vera++ installation
    set (BIN_SUBDIR bin)
    set (VERAPP_EXECUTABLE_NAME vera++)

    psq_find_tool_executable (${VERAPP_EXECUTABLE_NAME}
                              VERAPP_EXECUTABLE
                              PATHS ${VERAPP_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_report_not_found_if_not_quiet (VeraPP VERAPP_EXECUTABLE
                                       "The 'vera++' executable was not found"
                                       "in any search or system paths.\n.."
                                       "Please adjust VERAPP_SEARCH_PATHS"
                                       "to the installation prefix of the"
                                       "'vera++'\n.. executable or install"
                                       "Vera++")

    if (VERAPP_EXECUTABLE)

        psq_find_tool_extract_version (${VERAPP_EXECUTABLE} VERAPP_VERSION
                                       VERSION_ARG --version
                                       VERSION_HEADER ""
                                       VERSION_END_TOKEN "\n")
        psq_check_and_report_tool_version (VeraPP
                                           ${VERAPP_VERSION}
                                           FOUND_APPROPRIATE_VERSION)

        psq_find_executable_installation_root (${VERAPP_EXECUTABLE}
                                               INSTALL_ROOT
                                               PREFIX_SUBDIRECTORY
                                               ${BIN_SUBDIR})

        set (LIB_SUBDIR lib/vera++)
        set (SCRIPTS_SUBDIR scripts)
        set (SCRIPTS_SUBDIR_LOC ${LIB_SUBDIR})
        set (RULES_SUBDIR rules)
        set (RULES_SUBDIR_LOC
             ${INSTALL_ROOT}/${SCRIPTS_SUBDIR_LOC}/${SCRIPTS_SUBDIR}/)
        set (TRANSFORMATIONS_SUBDIR transformations)
        set (TRANSFORMATIONS_SUBDIR_LOC
             ${INSTALL_ROOT}/${SCRIPTS_SUBDIR_LOC}/${SCRIPTS_SUBDIR}/)
        set (PROFILES_SUBDIR profiles)
        set (PROFILES_SUBDIR_LOC
             ${INSTALL_ROOT}/${LIB_SUBDIR}/)

        # Find the other parts of the Vera++ installation
        psq_find_path_in_installation_root (${TRANSFORMATIONS_SUBDIR_LOC}
                                            ${TRANSFORMATIONS_SUBDIR}
                                            TRANSFORMATIONS_PATH)
        psq_find_path_in_installation_root (${RULES_SUBDIR_LOC}
                                            ${RULES_SUBDIR}
                                            RULES_PATH)
        psq_find_path_in_installation_root (${PROFILES_SUBDIR_LOC}
                                            ${PROFILES_SUBDIR}
                                            PROFILES_PATH)

        # Report any NOTFOUND paths
        psq_report_not_found_if_not_quiet (VeraPP TRANSFORMATIONS_PATH
                                           "Path to vera++ transformations was "
                                           "not found in ${INSTALL_ROOT}")
        psq_report_not_found_if_not_quiet (VeraPP RULES_PATH
                                           "Path to vera++ rules was not "
                                           "found in ${INSTALL_ROOT}")
        psq_report_not_found_if_not_quiet (VeraPP PROFILES_PATH
                                           "Path to vera++ profiles was not "
                                           "found in ${INSTALL_ROOT}")

        # If we found all the paths set VeraPP_FOUND and other related variables
        if (FOUND_APPROPRIATE_VERSION AND
            TRANSFORMATIONS_PATH AND
            RULES_PATH AND
            PROFILES_PATH)

            set (VeraPP_FOUND TRUE)
            set (VERAPP_FOUND TRUE PARENT_SCOPE)
            set (VERAPP_EXECUTABLE ${VERAPP_EXECUTABLE} PARENT_SCOPE)
            set (VERAPP_VERSION ${VERAPP_VERSION} PARENT_SCOPE)
            set (VERAPP_RULES ${RULES_PATH} PARENT_SCOPE)
            set (VERAPP_TRANSFORMATIONS ${TRANSFORMATIONS_PATH} PARENT_SCOPE)
            set (VERAPP_PROFILES ${PROFILES_PATH} PARENT_SCOPE)

            psq_print_if_not_quiet (VeraPP "Vera++ version ${VERAPP_VERSION}"
                                           "found at ${VERAPP_EXECUTABLE}")

        else (FOUND_APPROPRIATE_VERSION AND
              TRANSFORMATIONS_PATH AND
              RULES_PATH AND
              PROFILES_PATH)

            set (VeraPP_FOUND FALSE)

        endif (FOUND_APPROPRIATE_VERSION AND
               TRANSFORMATIONS_PATH AND
               RULES_PATH AND
               PROFILES_PATH)

    endif (VERAPP_EXECUTABLE)

    set (VeraPP_FOUND ${VeraPP_FOUND} PARENT_SCOPE)

    if (NOT VeraPP_FOUND)

        psq_report_tool_not_found (VeraPP "Vera++ was not found")

    endif (NOT VeraPP_FOUND)

endfunction (_find_verapp)

_find_verapp ()
