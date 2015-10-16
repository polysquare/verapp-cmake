# Vera++ CMake Modules #

[![Travis](https://travis-ci.org/polysquare/veracpp-cmake.svg?branch=master)](https://travis-ci.org/polysquare/veracpp-cmake)

verapp-cmake is a both a Find and Utilities module to integrate with the
CMake build system. Use this module as a bii block in your project.
The following commands are available:

* Workaround for CMake's inability to list files in directories
  external to the source directory

        verapp_list_files_in_external_directory DIRECTORY MATCH RETURN_FILES

* Create a new target that copies all files from one directory matching
  some criteria to the destination directory when a target is executed

        verapp_copy_files_in_dir_to_subdir_on_target SOURCE DESTINATION
                                                     MATCH TARGET WHAT

* Import vera++ rules into a new subdirectory before a target is executed

        verapp_import_default_rules_into_subdir_on_target SUBDIRECTORY
                                                          TARGET

* Import vera++ transformations into a new subdirectory before a target is
  executed

        verapp_import_default_transformations_into_subdir_on_target SUB
                                                                    TARGET

* Import vera++ profiles into a new subdirectory before a target is executed

        verapp_import_default_profiles_into_subdir_on_target SUBDIRECTORY
                                                             TARGET

* Run vera++ on the source files build by a target

        verapp_profile_check_source_files_conformance VERAPP_DIRECTORY
                                                      SOURCES_DIRECTORY
                                                      PROFILE
                                                      TARGET
                                                      MODE
