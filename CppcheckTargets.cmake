# - Run cppcheck on C/C++ source files as a custom target
#
# Requires these CMake modules:
#  Findcppcheck
#
# Tested to work with cppcheck version 1.7x.
#
# Original Author:
# 2009-2010 Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
# http://academic.cleardefinition.com
# Iowa State University HCI Graduate Program/VRAC
#
# Copyright Iowa State University 2009-2010.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

cmake_minimum_required(VERSION 2.8)

if(NOT CPPCHECK_FOUND)
    find_package(cppcheck REQUIRED)
    # Reset its value if it is on the cache
    set(CPPCHECK_EXCLUDED_HEADERS "" CACHE INTERNAL "")
    set(CPPCHECK_PROJECT_OPTIONS "" CACHE INTERNAL "")
endif()

set(CPPCHECK_REPORT_DIR ${CMAKE_BINARY_DIR}/cppcheck-reports CACHE STRING
        "The directory where to put the cppcheck reports.")

set(CPPCHECK_MODULE_DIRECTORY_STRUCTURE FALSE CACHE BOOL
        "Whether the directory was a module type of structure. \
         If the directory has this type of structure - separate \
         directories containing independent sets of sources - \
         an analyse-<module> target will be created for each \
         module")

set(CPPCHECK_CHECK_CONFIG FALSE CACHE BOOL
        "Whether the config should be checked (--check-config cppcheck option.")

if(NOT TARGET analyse-all)
    add_custom_target(analyse-all)
    set_target_properties(analyse-all PROPERTIES EXCLUDE_FROM_ALL TRUE)
endif()

# ::
#
#     add_cppcheck_project_option(<header> ...)
#
#
# Adds additional options to run cppcheck with
#
function(add_cppcheck_project_option)
     set(CPPCHECK_PROJECT_OPTIONS "${CPPCHECK_PROJECT_OPTIONS};${ARGN}" CACHE INTERNAL "")
endfunction()

# ::
#
#     add_cppcheck_header_exclusion(<header> ...)
#
#
# Causes warnings about missing includes for an header or list of header
# files to be removed.  Useful to ignore auto-generated header files.
#
function(add_cppcheck_header_exclusion)
     set(CPPCHECK_EXCLUDED_HEADERS "${CPPCHECK_EXCLUDED_HEADERS};${ARGN}" CACHE INTERNAL "")
endfunction()

# ::
#
#     add_cppcheck(<target>
#                  [ALL]
#                  [IGNORE_WARNINGS]
#                  [IGNORE_STYLE]
#                  [IGNORE_PERFORMANCE]
#                  [IGNORE_PORTABILITY]
#                  [IGNORE_INFORMATION]
#                  [IGNORE_UNUSED_FUNC]
#                  [IGNORE_MISSING_INCLUDE]
#                  [WARNINGS]
#                  [STYLE]
#                  [PERFORMANCE]
#                  [PORTABILITY]
#                  [INFORMATION]
#                  [UNUSED_FUNC]
#                  [MISSING_INCLUDE]
#                  [FORCE_CHECK]
#                  [INCLUDES])
#
# Adds a CMake target that causes the sources and header files used to
# build <target> to be static analysed with the cppcheck tool.
#
# The checks to be performed can be controlled by giving some options.
# If <ALL> was given, all checks will be performed.  It is possible to
# exclude a check by passing IGNORE_<CHECK>.
#
# If <ALL> was not given, then only the checks specified will be
# performed.  If no check was specified, then the static analysis will
# not produce any warning.
#
# <FORCE_CHECK> runs cppcheck with the `--force` option.
#
# <INCLUDES> allows to specify an additional list of directories to look
# for header files.  This may be required as CMake does not return the
# include directories for a library, when it is being linked with an
# executable.
#
function(add_cppcheck _name)
    if(NOT TARGET ${_name})
        message(FATAL_ERROR
            "add_cppcheck given a target name that does not exist: '${_name}' !")
    endif()

    # Find out the module name
    if (CPPCHECK_MODULE_DIRECTORY_STRUCTURE)
        file(RELATIVE_PATH rel ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
        set(dirname ${rel})
        while(NOT ${dirname} STREQUAL "" )
            set(prev_dirname ${dirname})
            get_filename_component(dirname ${prev_dirname} DIRECTORY)
        endwhile()
        set(_module_name "${prev_dirname}")
        set(_module_cppcheck_tgt "analyse-${_module_name}")

        if(NOT TARGET ${_module_cppcheck_tgt})
            add_custom_target(${_module_cppcheck_tgt})
            set_target_properties(${_module_cppcheck_tgt} PROPERTIES EXCLUDE_FROM_ALL TRUE)
        endif()
    endif()

    set(_cppcheck_args)
    list(APPEND _cppcheck_args "--xml")
    list(APPEND _cppcheck_args "--xml-version=2")
    foreach(_cppcheck_opt ${CPPCHECK_PROJECT_OPTIONS})
        list(APPEND _cppcheck_args ${_cppcheck_opt})
    endforeach()

    set(options
        IGNORE_WARNINGS
        IGNORE_STYLE
        IGNORE_PERFORMANCE
        IGNORE_PORTABILITY
        IGNORE_INFORMATION
        IGNORE_UNUSED_FUNC
        IGNORE_MISSING_INCLUDE
        WARNINGS
        STYLE
        PERFORMANCE
        PORTABILITY
        INFORMATION
        UNUSED_FUNC
        MISSING_INCLUDE
        FORCE_CHECK)
    set(multi_value_keywords INCLUDES)
    cmake_parse_arguments(CPPCHECK "${options}" "" "${multi_value_keywords}" ${ARGN})

    if(CPPCHECK_ALL)
        if(NOT CPPCHECK_IGNORE_WARNINGS)
            list(APPEND _cppcheck_args ${CPPCHECK_WARNINGS_ARG})
        endif()
        if(NOT CPPCHECK_IGNORE_STYLE)
            list(APPEND _cppcheck_args ${CPPCHECK_STYLE_ARG})
        endif()
        if(NOT CPPCHECK_IGNORE_PERFORMANCE)
            list(APPEND _cppcheck_args ${CPPCHECK_PERFORMANCE_ARG})
        endif()
        if(NOT CPPCHECK_IGNORE_PORTABILITY)
            list(APPEND _cppcheck_args ${CPPCHECK_PORTABILITY_ARG})
        endif()
        if(NOT CPPCHECK_IGNORE_INFORMATION)
            list(APPEND _cppcheck_args ${CPPCHECK_INFORMATION_ARG})
        endif()
        if(NOT CPPCHECK_IGNORE_UNUSED_FUNC)
            list(APPEND _cppcheck_args ${CPPCHECK_UNUSEDFUNC_ARG})
        endif()
        if(NOT CPPCHECK_IGNORE_MISSING_INCLUDE)
            list(APPEND _cppcheck_args ${CPPCHECK_MISSINGINCLUDE_ARG})
        endif()
    else()
        if(CPPCHECK_WARNINGS)
            list(APPEND _cppcheck_args ${CPPCHECK_WARNINGS_ARG})
        endif()
        if(CPPCHECK_STYLE)
            list(APPEND _cppcheck_args ${CPPCHECK_STYLE_ARG})
        endif()
        if(CPPCHECK_PERFORMANCE)
            list(APPEND _cppcheck_args ${CPPCHECK_PERFORMANCE_ARG})
        endif()
        if(CPPCHECK_PORTABILITY)
            list(APPEND _cppcheck_args ${CPPCHECK_PORTABILITY_ARG})
        endif()
        if(CPPCHECK_INFORMATION)
            list(APPEND _cppcheck_args ${CPPCHECK_INFORMATION_ARG})
        endif()
        if(CPPCHECK_UNUSED_FUNC)
            list(APPEND _cppcheck_args ${CPPCHECK_UNUSEDFUNC_ARG})
        endif()
        if(CPPCHECK_MISSING_INCLUDE)
            list(APPEND _cppcheck_args ${CPPCHECK_MISSINGINCLUDE_ARG})
        endif()
    endif()

    if(CPPCHECK_FORCE_CHECK)
        list(APPEND _cppcheck_args "--force")
    endif()

    get_target_property(_cppcheck_includes "${_name}" INCLUDE_DIRECTORIES)
    get_target_property(_cppcheck_sources "${_name}" SOURCES)

    list(APPEND _cppcheck_includes ${CPPCHECK_INCLUDES})

    set(_files)
    foreach(_source ${_cppcheck_sources})
        get_source_file_property(_cppcheck_lang "${_source}" LANGUAGE)
        get_source_file_property(_cppcheck_loc "${_source}" LOCATION)
        if("${_cppcheck_lang}" MATCHES "CXX" OR "${_cppcheck_lang}" MATCHES "C")
            list(APPEND _files "${_cppcheck_loc}")
        endif()
    endforeach()

    if (CPPCHECK_MODULE_DIRECTORY_STRUCTURE)
        set(cppcheck_target ${_module_cppcheck_tgt}-${_name})
        set(cppcheck_report_file ${CPPCHECK_REPORT_DIR}/${_module_name}-${_name})
    else()
        set(cppcheck_target analyse-${_name})
        set(cppcheck_report_file ${CPPCHECK_REPORT_DIR}/${_name})
    endif()

    if(CPPCHECK_CHECK_CONFIG)
        set(_cppcheck_check_config "true")
    else()
        set(_cppcheck_check_config "false")
    endif()

    add_custom_target(
        ${cppcheck_target}
        COMMAND
        ${CMAKE_SOURCE_DIR}/scripts/cppcheck-wrapper
        ${CPPCHECK_EXECUTABLE}
        ${_cppcheck_check_config}
        "${_cppcheck_includes}"
        "${CPPCHECK_EXCLUDED_HEADERS}"
        ${cppcheck_report_file}
        ${CPPCHECK_QUIET_ARG}
        ${CPPCHECK_TEMPLATE_ARG}
        ${_cppcheck_args}
        ${_files}
        WORKING_DIRECTORY
        "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT
        "${cppcheck_target}: Running cppcheck on target ${_name}..."
        VERBATIM)
    set_target_properties(${cppcheck_target} PROPERTIES FOLDER "Code Analysis")

    add_dependencies(analyse-all ${cppcheck_target})

    if (CPPCHECK_MODULE_DIRECTORY_STRUCTURE)
        add_dependencies(${_module_cppcheck_tgt} ${cppcheck_target})
    endif()
endfunction()
