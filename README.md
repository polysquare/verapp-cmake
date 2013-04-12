Vera++ CMake Modules
=============

veracpp-cmake is a both a Find* and Utilities module to integrate with the
CMake Buildsystem. Import this as a git submodule and change your
CMAKE_MODULE_PATH as appropriate. A find_package (VeraPP) will become
available, as will include (VeraPPUtilities). The following commands are
available:

1. Workaround for CMake's inability to list files in directories 
   external to the source directory

        verapp_list_files_in_external_directory DIRECTORY MATCH RETURN_FILES

2. Create a new target that copies all files from one directory matching
   some criteria to the destination directory when a target is executed

        verapp_copy_files_in_dir_to_subdir_on_target SOURCE DESTINATION
                                                     MATCH TARGET WHAT

3. Import vera++ rules into a new subdirectory before a target is executed

        verapp_import_default_rules_into_subdirectory_on_target SUBDIRECTORY
                                                                TARGET

4. Import vera++ transformations into a new subdirectory before a target is
   executed

        verapp_import_default_transformations_into_subdirectory_on_target SUB
                                                                       TARGET

5. Import vera++ profiles into a new subdirectory before a target is executed

        verapp_import_default_profiles_into_subdirectory_on_target SUBDIRECTORY
                                                                   TARGET

6. Run vera++ on the source files build by a target

        verapp_profile_check_source_files_conformance VERAPP_DIRECTORY
                                                      SOURCES_DIRECTORY
                                                      PROFILE
                                                      TARGET
                                                      MODE
