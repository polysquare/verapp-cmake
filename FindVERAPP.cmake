# /FindVERAPP.cmake
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
#                       that contains the vera++ binary. Eg /opt/ not
#                       /opt/bin/
#
# See /LICENCE.md for Copyright information

include ("cmake/tooling-find-pkg-util/ToolingFindPackageUtil")

function (verapp_find)

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

        psq_find_tool_extract_version ("${VERAPP_EXECUTABLE}" VERAPP_VERSION
                                       VERSION_ARG --version
                                       VERSION_HEADER ""
                                       VERSION_END_TOKEN "\n")
        psq_find_executable_installation_root ("${VERAPP_EXECUTABLE}"
                                               INSTALL_ROOT
                                               PREFIX_SUBDIRECTORY
                                               ${BIN_SUBDIR})

        set (LIB_SUBDIR "lib/vera++")
        set (SCRIPTS_SUBDIR_LOC ${LIB_SUBDIR})
        set (RULES_SUBDIR rules)
        set (RULES_SUBDIR_LOC
             "${INSTALL_ROOT}/${SCRIPTS_SUBDIR_LOC}/")
        set (TRANSFORMATIONS_SUBDIR transformations)
        set (TRANSFORMATIONS_SUBDIR_LOC
             "${INSTALL_ROOT}/${SCRIPTS_SUBDIR_LOC}/")
        set (PROFILES_SUBDIR profiles)
        set (PROFILES_SUBDIR_LOC
             "${INSTALL_ROOT}/${LIB_SUBDIR}/")

        # Find the other parts of the Vera++ installation
        psq_find_path_in_installation_root (${TRANSFORMATIONS_SUBDIR_LOC}
                                            ${TRANSFORMATIONS_SUBDIR}
                                            VERAPP_TRANSFORMATIONS)
        psq_find_path_in_installation_root (${RULES_SUBDIR_LOC}
                                            ${RULES_SUBDIR}
                                            VERAPP_RULES)
        psq_find_path_in_installation_root (${PROFILES_SUBDIR_LOC}
                                            ${PROFILES_SUBDIR}
                                            VERAPP_PROFILES)

        # Report any NOTFOUND paths
        psq_report_not_found_if_not_quiet (VeraPP VERAPP_TRANSFORMATIONS
                                           "Path to vera++ transformations was "
                                           "not found in ${INSTALL_ROOT}")
        psq_report_not_found_if_not_quiet (VeraPP VERAPP_RULES
                                           "Path to vera++ rules was not "
                                           "found in ${INSTALL_ROOT}")
        psq_report_not_found_if_not_quiet (VeraPP VERAPP_PROFILES
                                           "Path to vera++ profiles was not "
                                           "found in ${INSTALL_ROOT}")

    endif ()

    psq_check_and_report_tool_version (VeraPP
                                       "${VERAPP_VERSION}"
                                       REQUIRED_VARS
                                       VERAPP_EXECUTABLE
                                       VERAPP_VERSION
                                       VERAPP_TRANSFORMATIONS
                                       VERAPP_RULES
                                       VERAPP_PROFILES)

    set (VERAPP_FOUND ${VeraPP_FOUND} PARENT_SCOPE)

endfunction ()

verapp_find ()
