# /tests/ImportDefaultTransformationsIntoSubdirOnTargetWithComment.cmake
# Creates a new target to import vera++ default transformations on.
#
# See LICENCE.md for Copyright information

include (${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}/VeraPPUtilities.cmake)
include (${VERAPP_COMMON_UNIVERSAL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (CMAKE_MODULE_PATH
     ${VERAPP_COMMON_UNIVERSAL_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

find_package (VeraPP REQUIRED)

add_custom_target (on_all ALL)

set (SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/subdirectory)

verapp_import_default_transformations_into_subdirectory_on_target (${SUBDIR}
                                                                   on_all)