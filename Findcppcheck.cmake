# - Try to find cppcheck tool
#
# Cache Variables:
#  CPPCHECK_EXECUTABLE
#
# Non-cache variables you might use in your CMakeLists.txt:
#  CPPCHECK_FOUND
#  CPPCHECK_ENABLEALL_ARG
#  CPPCHECK_WARNINGS_ARG
#  CPPCHECK_STYLE_ARG
#  CPPCHECK_PERFORMANCE_ARG
#  CPPCHECK_PORTABILITY_ARG
#  CPPCHECK_INFORMATION_ARG
#  CPPCHECK_UNUSEDFUNC_ARG
#  CPPCHECK_MISSINGINCLUDE_ARG
#  CPPCHECK_QUIET_ARG
#  CPPCHECK_INCLUDEPATH_ARG
#  CPPCHECK_MARK_AS_ADVANCED - whether to mark our vars as advanced even
#    if we don't find this program.
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)
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

file(TO_CMAKE_PATH "${CPPCHECK_ROOT_DIR}" CPPCHECK_ROOT_DIR)
set(CPPCHECK_ROOT_DIR
    "${CPPCHECK_ROOT_DIR}"
    CACHE
    PATH
    "Path to search for cppcheck")

# cppcheck app bundles on Mac OS X are GUI, we want command line only
set(_oldappbundlesetting ${CMAKE_FIND_APPBUNDLE})
set(CMAKE_FIND_APPBUNDLE NEVER)

if(CPPCHECK_EXECUTABLE AND NOT EXISTS "${CPPCHECK_EXECUTABLE}")
    set(CPPCHECK_EXECUTABLE "notfound" CACHE PATH FORCE "")
endif()

# If we have a custom path, look there first.
if(CPPCHECK_ROOT_DIR)
    find_program(CPPCHECK_EXECUTABLE
        NAMES
        cppcheck
        cli
        PATHS
        "${CPPCHECK_ROOT_DIR}"
        PATH_SUFFIXES
        cli
        NO_DEFAULT_PATH)
endif()

find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)

# Restore original setting for appbundle finding
set(CMAKE_FIND_APPBUNDLE ${_oldappbundlesetting})

function(_cppcheck_set_arg_var _argvar _arg)
    set(${_argvar} "${_arg}" PARENT_SCOPE)
endfunction()

if(CPPCHECK_EXECUTABLE)
    set(CPPCHECK_ENABLEALL_ARG "--enable=all")
    set(CPPCHECK_WARNINGS_ARG "--enable=warning")
    set(CPPCHECK_STYLE_ARG "--enable=style")
    set(CPPCHECK_PERFORMANCE_ARG "--enable=performance")
    set(CPPCHECK_PORTABILITY_ARG "--enable=portability")
    set(CPPCHECK_INFORMATION_ARG "--enable=information")
    set(CPPCHECK_UNUSEDFUNC_ARG "--enable=unusedFunction")
    set(CPPCHECK_MISSINGINCLUDE_ARG "--enable=missingInclude")

    if(MSVC)
        set(CPPCHECK_TEMPLATE_ARG --template vs)
    elseif(CMAKE_COMPILER_IS_GNUCXX)
        set(CPPCHECK_TEMPLATE_ARG --template gcc)
    else()
        set(CPPCHECK_TEMPLATE_ARG --template gcc)
    endif()

    set(CPPCHECK_QUIET_ARG "--quiet")
    set(CPPCHECK_INCLUDEPATH_ARG "-I")

endif()

set(CPPCHECK_ALL
    "${CPPCHECK_EXECUTABLE} ${CPPCHECK_ENABLEALL_ARG} ${CPPCHECK_UNUSEDFUNC_ARG} ${CPPCHECK_STYLE_ARG} ${CPPCHECK_QUIET_ARG} ${CPPCHECK_INCLUDEPATH_ARG} some/include/path")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(cppcheck
    DEFAULT_MSG
    CPPCHECK_ALL
    CPPCHECK_EXECUTABLE
    CPPCHECK_ENABLEALL_ARG
    CPPCHECK_UNUSEDFUNC_ARG
    CPPCHECK_STYLE_ARG
    CPPCHECK_INCLUDEPATH_ARG
    CPPCHECK_QUIET_ARG)

if(CPPCHECK_FOUND OR CPPCHECK_MARK_AS_ADVANCED)
    mark_as_advanced(CPPCHECK_ROOT_DIR)
endif()

mark_as_advanced(CPPCHECK_EXECUTABLE)
