cmake_minimum_required(VERSION 3.26)


include("arm-none-eabi.cmake")
include("search.cmake")


# Первичная настройка проекта
string(LENGTH "${PROJECT_NAME}" project_name_length)
if (${project_name_length} EQUAL 0)
    project(firmware VERSION 0.0.0)
else()
    project(${PROJECT_NAME} VERSION 0.0.0)
endif()
set(BUILD_VERSION_length 0)
if (DEFINED BUILD_VERSION)
    string(LENGTH "${BUILD_VERSION}" BUILD_VERSION_length)
endif()
if (BUILD_VERSION_length EQUAL 0)
    message(STATUS "BUILD_VERSION: not defined - set v0.0.0")
    set(BUILD_VERSION "0.0.0")
endif()
if("${BUILD_VERSION}" MATCHES "v[0-9]+\.[0-9]+\.[0-9]+")
    string(LENGTH ${BUILD_VERSION} BUILD_VERSION_length)
    math(EXPR BUILD_VERSION_length "${BUILD_VERSION_length} - 1" OUTPUT_FORMAT DECIMAL)
    string(SUBSTRING ${BUILD_VERSION} 1 ${BUILD_VERSION_length} sub_build_version)
    project(${PROJECT_NAME} VERSION ${sub_build_version})
elseif("${BUILD_VERSION}" MATCHES "[0-9]+\.[0-9]+\.[0-9]+")
    project(${PROJECT_NAME} VERSION "${BUILD_VERSION}")
else()
    message(FATAL_ERROR "BUILD_VERSION has not matches regexp")
endif()
string(LENGTH ${BUILD_VERSION} BUILD_VERSION_length)
if (NOT ${BUILD_VERSION_length} EQUAL OFF)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -DBUILD_VERSION=\"\\\"${BUILD_VERSION}\\\"\"")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBUILD_VERSION=\"\\\"${BUILD_VERSION}\\\"\"")
endif()
set(CMAKE_PROJECT_NAME "${PROJECT_NAME}.elf")

# Включаем Assembler
enable_language(ASM)

# Поиск библиотек со своим сборщиком
FIND_CMAKE_LIBS(cmake_dirs "${CMAKE_SOURCE_DIR}/Modules")

# Ищем директории с заголовочными файлами
FILE_DIRECTORIES_EXT(h_dirs   "${CMAKE_SOURCE_DIR}" "h")
FILE_DIRECTORIES_EXT(hpp_dirs "${CMAKE_SOURCE_DIR}" "hpp")
set(${PROJECT_NAME}_INCLUDES "${h_dirs};${hpp_dirs}")
foreach(arm_exclude_path ${ARM_PREDEFINED_EXCLUDE_PATHS})
    EXCLUDE(${PROJECT_NAME}_INCLUDES ${arm_exclude_path})
endforeach()
foreach(cmake_dir ${cmake_dirs})
    EXCLUDE_DIRS(${PROJECT_NAME}_INCLUDES ${cmake_dir})
endforeach()

include_directories(${${PROJECT_NAME}_INCLUDES})
# Ищем исходные файлы проекта
FILE_PATHS_EXT(c_paths   "${CMAKE_SOURCE_DIR}" "c")
FILE_PATHS_EXT(cpp_paths "${CMAKE_SOURCE_DIR}" "cpp")
FILE_PATHS_EXT(s_paths   "${CMAKE_SOURCE_DIR}" "s")
set(${PROJECT_NAME}_SOURCES "${c_paths};${cpp_paths};${s_paths}")
EXCLUDE_PATHS(${PROJECT_NAME}_SOURCES "test")
EXCLUDE_PATHS(${PROJECT_NAME}_SOURCES "build")
foreach(arm_exclude_path ${ARM_PREDEFINED_EXCLUDE_PATHS})
    EXCLUDE(${PROJECT_NAME}_SOURCES ${arm_exclude_path})
endforeach()
foreach(cmake_dir ${cmake_dirs})
    EXCLUDE_DIRS(${PROJECT_NAME}_SOURCES ${cmake_dir})
endforeach()

# Добавляем исполняемые файлы
add_executable(${CMAKE_PROJECT_NAME} ${${PROJECT_NAME}_SOURCES})

# Импорт заранее объявленных библиотек
foreach(lib ${ARM_PREDEFINED_LIBS})
    file(GLOB_RECURSE _libs "*${lib}")
    target_link_libraries(${CMAKE_PROJECT_NAME} ${_libs})
endforeach()

# Указываем путь к файлу компоновщика
file(GLOB LINKER_SCRIPT_PATH "${CMAKE_SOURCE_DIR}/*FLASH.ld")
set(LINKER_SCRIPT ${LINKER_SCRIPT_PATH})
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})
# Указываем флаги компоновщика
set(CMAKE_EXE_LINKER_FLAGS "-T\"${LINKER_SCRIPT}\" ${CMAKE_LINKER_FLAGS}")
set(CMAKE_LINKER_FLAGS "-T\"${LINKER_SCRIPT}\" ${CMAKE_LINKER_FLAGS}")

# Указываем дополнительные библиотеки, если необходимо
foreach(cur_dir ${cmake_dirs})
    message(STATUS "ADD SUB      : ${cur_dir}")
    add_subdirectory("${cur_dir}")
endforeach()

message(STATUS "${PROJECT_NAME} includes:")
foreach(dir ${${PROJECT_NAME}_INCLUDES})
    message(STATUS "${dir}")
endforeach()
message(STATUS "${PROJECT_NAME} sources:")
foreach(src ${${PROJECT_NAME}_SOURCES})
    message(STATUS "${src}")
endforeach()

message(STATUS "C compiler   : ${CMAKE_C_COMPILER}")
message(STATUS "C++ compiler : ${CMAKE_CXX_COMPILER}")
message(STATUS "Building     : ${PROJECT_NAME}")
message(STATUS "Build version: ${CMAKE_PROJECT_VERSION}")
message(STATUS "C FLAGS      : ${CMAKE_C_FLAGS}")
message(STATUS "C++ FLAGS    : ${CMAKE_CXX_FLAGS}")
message(STATUS "ASM FLAGS    : ${CMAKE_ASM_FLAGS}")
message(STATUS "Linker FLAGS : ${CMAKE_LINKER_FLAGS}")

# Добавляем команду для генерации bin файла
add_custom_command(
    TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ./${CMAKE_PROJECT_NAME} ./${PROJECT_NAME}.bin
    COMMENT "Building ${PROJECT_NAME}.bin"
)