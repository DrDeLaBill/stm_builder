cmake_minimum_required(VERSION 3.26)


###################### MACROS #########################################
MACRO(FILE_DIRECTORIES_EXT return_list target_path extension)
    SET(${return_list} "")
    SET(_full_regexp "${target_path}/*.${extension}")
    MESSAGE(STATUS "Search directories for ${_full_regexp}")
    FILE(GLOB_RECURSE _new_list "${_full_regexp}")
    SET(_dir_list "")
    FOREACH(_file_path ${_new_list})
        GET_FILENAME_COMPONENT(_dir_path ${_file_path} PATH)
        SET(_dir_list "${_dir_list};${_dir_path}")
    ENDFOREACH()
    FOREACH(_dir_path ${_dir_list})
        WHILE(NOT ${_dir_path} STREQUAL "${target_path}")
            GET_FILENAME_COMPONENT(_dir_path ${_dir_path} DIRECTORY)
            SET(_dir_list "${_dir_list};${_dir_path}")
        ENDWHILE()
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES _dir_list)
    FOREACH(_dir ${_dir_list})
        MESSAGE(STATUS "DIR FOUND    : ${_dir}")
    ENDFOREACH()
    SET(${return_list} ${_dir_list})
    LIST(LENGTH ${return_list} _cnt)
    MESSAGE(STATUS "Found ${_cnt} directories")
    UNSET(extension)
    UNSET(_full_regexp)
    UNSET(_new_list)
    UNSET(_file_path)
    UNSET(_dir_path)
    UNSET(_dir_list)
    UNSET(_dir)
    UNSET(_cnt)
ENDMACRO()

MACRO(FILE_PATHS_EXT return_list target_path extention)
    SET(${return_list} "")
    message(STATUS "Search file paths for \"${target_path}/*.${extention}\"")
    set(_files_list "")
    FILE(GLOB_RECURSE _files_list "${target_path}/*.${extention}")
    LIST(REMOVE_DUPLICATES _files_list)
    FOREACH(_file_path ${_files_list})
        MESSAGE(STATUS "PATH FOUND   : ${_file_path}")
    ENDFOREACH()
    SET(${return_list} ${_files_list})
    list(LENGTH ${return_list} _cnt)
    message(STATUS "Found ${_cnts} file paths")
    UNSET(_files_list)
    UNSET(_file_path)
    UNSET(_cnt)
ENDMACRO()

MACRO(FILE_PATHS return_list target_path filename extension)
    SET(${return_list} "")
    MESSAGE(STATUS "Search file paths for \"${target_path}/*${filename}.${extension}\"")
    SET(_files_list "")
    FILE(GLOB_RECURSE _files_list "${target_path}/*.${extension}")
    LIST(REMOVE_DUPLICATES ${return_list})
    SET(_new_list "")
    FOREACH(_file_path ${_files_list})
        IF(${_file_path} MATCHES "^${CMAKE_CURRENT_SOURCE_DIR}.+${filename}\.${extension}$")
            LIST(APPEND _new_list ${_file_path})
            MESSAGE(STATUS "PATH FOUND   : ${_file_path}")
        ENDIF()
    ENDFOREACH()
    SET(${return_list} ${_new_list})
    LIST(LENGTH ${return_list} _cnt)
    MESSAGE(STATUS "Found ${_cnt} file paths")
    UNSET(_files_list)
    UNSET(_new_list)
    UNSET(_file_path)
    UNSET(_cnt)
ENDMACRO()

MACRO(EXCLUDE_PATHS target_list regexp_path_name)
    SET(_new_list "")
    SET(_regex "^${CMAKE_CURRENT_SOURCE_DIR}.+${regexp_path_name}.*$")
    MESSAGE(STATUS "EXCLUDE PATH : \"${_regex}\"")
    FOREACH(_curr_path ${${target_list}})
        IF(NOT ${_curr_path} MATCHES "${_regex}")
            SET(_new_list "${_new_list};${_curr_path}")
        ELSE()
            MESSAGE(STATUS "REMOVED      : ${_curr_path}")
        ENDIF()
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES _new_list)
    SET(${target_list} ${_new_list})
    MESSAGE(STATUS "EXCLUDE DONE .")
    UNSET(_new_list)
    UNSET(_regex)
    UNSET(_curr_path)
ENDMACRO()

MACRO(EXCLUDE_DIRS target_list regexp_dir_name)
    SET(_new_list "")
    SET(_regex "^${regexp_dir_name}.*$")
    MESSAGE(STATUS "EXCLUDE DIR  : \"${_regex}\"")
    FOREACH(_curr_dir ${${target_list}})
        IF(NOT ${_curr_dir} MATCHES "${_regex}")
            SET(_new_list "${_new_list};${_curr_dir}")
        ELSE()
            MESSAGE(STATUS "REMOVED      : ${_curr_dir}")
        ENDIF()
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES _new_list)
    SET(${target_list} ${_new_list})
    MESSAGE(STATUS "EXCLUDE DONE .")
    UNSET(_new_list)
    UNSET(_regex)
    UNSET(_curr_dir)
ENDMACRO()

MACRO(SORT_PATHS result_list target_list)
    SET(${result_list} "")
    SET(_last_path "")
    SET(_target_list_copy ${target_list})
    FOREACH(_tmp ${_target_list_copy})
        SET(_last_path "")
        SET(_target_list_tmp "")
        FOREACH(_cur_path ${_target_list_copy})
            STRING(LENGTH "${_last_path}" _last_path_length)
            IF(${_last_path_length} EQUAL 0)
                SET(_last_path "${_cur_path}")
                CONTINUE()
            ENDIF()
            STRING(LENGTH "${_last_path}" _last_path_length)
            STRING(LENGTH "${_cur_path}" _cur_path_length)
            IF(${_cur_path_length} LESS ${_last_path_length})
                LIST(APPEND _target_list_tmp "${_cur_path}")
                SET(_last_path "${_last_path}")
            ELSE()
                LIST(APPEND _target_list_tmp "${_last_path}")
                SET(_last_path "${_cur_path}")
            ENDIF()
        ENDFOREACH()
        LIST(APPEND _target_list_tmp "${_last_path}")
        SET(_target_list_copy ${_target_list_tmp})
    ENDFOREACH()
    SET(${result_list} "${_target_list_copy}")
    MESSAGE(STATUS "SORT RESULT START")
    FOREACH(_cur_path ${${result_list}})
        MESSAGE(STATUS "SORT PATH: ${_cur_path}")
    ENDFOREACH()
    MESSAGE(STATUS "SORT RESULT END")
    UNSET(_last_path)
    UNSET(_target_list_copy)
    UNSET(_tmp)
    UNSET(_target_list_tmp)
    UNSET(_cur_path)
    UNSET(_last_path_length)
    UNSET(_cur_path_length)
ENDMACRO()

MACRO(FIND_CMAKE_LIBS result_list target_dir)
    FILE_PATHS(_cmake_paths "${target_dir}" "CMakeLists" "txt")
    EXCLUDE_PATHS(_cmake_paths "test")
    EXCLUDE_PATHS(_cmake_paths "build")
    SET(_cmake_dirs, "")
    SORT_PATHS(_cmake_paths_copy "${_cmake_paths}")
    FOREACH(_curr_path ${_cmake_paths_copy})
        get_filename_component(_cur_dir ${_curr_path} PATH)
        LIST(APPEND _cmake_dirs ${_cur_dir})
        EXCLUDE_DIRS(_cmake_paths ${_cur_dir})
        LIST(LENGTH _cmake_paths _cmake_length)
        IF (${_cmake_length} EQUAL 0)
            BREAK()
        ENDIF()
    ENDFOREACH()
    MESSAGE(STATUS "RESULT CMakeLists.txt dirs")
    SET(${result_list} "${_cmake_dirs}")
    FOREACH(_cmake_dir ${${result_list}})
        MESSAGE(STATUS "${_cmake_dir}")
    ENDFOREACH()
    LIST(LENGTH _cmake_dirs _cnt)
    MESSAGE(STATUS "Found ${_cnt} CMakeLists.txt paths")
    UNSET(_cmake_paths)
    UNSET(_cmake_dirs)
    UNSET(_cmake_paths_copy)
    UNSET(_curr_path)
    UNSET(_cur_dir)
    UNSET(_cmake_length)
    UNSET(_cnt)
ENDMACRO()
#######################################################################