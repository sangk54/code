# parse a keyword delimited list of arguments into single list
# results are in ${BEGIN}_ARGS
macro (sagase_parse_arguments BEGIN END)
    set (take_ FALSE)
    foreach (variable_ ${ARGN})
        if (${variable_} STREQUAL ${BEGIN})
            set (take_ TRUE)
        elseif (${variable_} STREQUAL ${END})
            set (take_ FALSE)
        else ()
            if (take_)
                set (${BEGIN}_ARGS ${${BEGIN}_ARGS} ${variable_})
            endif ()
        endif ()
    endforeach ()
endmacro ()


# generates a set of likely paths for a files (includes or libraries)
# "NAMES" is a list of names by which the package is known
# "PREFIXES" is a list of path prefixes where the components might be found
# results are in ${PREFIX}_INCLUDE_PATHS, ${PREFIX}_LIBRARY_PATHS  
macro (sagase_generate_paths PREFIX)
    sagase_parse_arguments ("NAMES" "PREFIXES" ${ARGN})
    sagase_parse_arguments ("PREFIXES" none ${ARGN})
    
    set (PATH_NAMES ${NAMES_ARGS})
    set (PATH_PREFIXES ${PREFIXES_ARGS})

    if (MSVC)
        set (PATH_PREFIXES ${PATH_PREFIXES} "C:/")
    elseif (APPLE)
        message (FATAL_ERROR "sagase: " ${PREFIX} ": MacOS Support incomplete")
    elseif (UNIX)
        set (PATH_PREFIXES ${PATH_PREFIXES} "/usr" "/usr/local" "/opt")
    else ()
        message (FATAL_ERROR "sagase: " ${PREFIX} ": Unable to detect OS type")
    endif ()

    # add prefix paths
    foreach (prefix_ ${PATH_PREFIXES})
        set (${PREFIX}_INCLUDE_PATHS ${${PREFIX}_INCLUDE_PATHS} ${prefix_}/include)
        set (${PREFIX}_LIBRARY_PATHS ${${PREFIX}_LIBRARY_PATHS} ${prefix_}/lib)
    endforeach ()

    # add prefix+name paths
    foreach (prefix_ ${PATH_PREFIXES})
        foreach (pkgname_ ${PATH_NAMES})
            set (${PREFIX}_INCLUDE_PATHS ${${PREFIX}_INCLUDE_PATHS} ${prefix_}/${pkgname_}/include ${prefix_}/include/${pkgname_})
            set (${PREFIX}_LIBRARY_PATHS ${${PREFIX}_LIBRARY_PATHS} ${prefix_}/${pkgname_}/lib ${prefix_}/lib/${pkgname_})
        endforeach ()
    endforeach ()
endmacro ()

# tries a series of methods to find correct compile and link info
# "NAMES" is a list of names by which the package is known
# "COMPONENTS" is a list of sub-components that are required
# "PREFIXES" is a list of path prefixes where the components might be found
# results are in ${PREFIX}_INCLUDE_DIRS, ${PREFIX}_LIBRARY_DIRS, 
# ${PREFIX}_LIBRARIES, ${PREFIX}_DEFINITIONS, or fatal error
macro (sagase_configure_package PREFIX)
    sagase_parse_arguments ("NAMES" "COMPONENTS" ${ARGN})
    sagase_parse_arguments ("COMPONENTS" "PREFIXES" ${ARGN})
    sagase_parse_arguments ("PREFIXES" none ${ARGN})
    
    set (PKG_NAMES ${NAMES_ARGS})
    set (PKG_COMPONENTS ${COMPONENTS_ARGS})
    set (PKG_PREFIXES ${PREFIXES_ARGS})

    set (found_ FALSE)
    foreach (name_ ${PKG_NAMES})

        if (found_)
            break ()
        endif ()

        message (STATUS "trying find_package: " ${name_})

        # try built-in CMake modules first
        find_package (${name_} QUIET COMPONENTS ${PKG_COMPONENTS})

        if (${name_}_FOUND)
            message (STATUS "sagase: configured " ${PREFIX})
            set (${PREFIX}_INCLUDE_DIRS ${${name_}_INCLUDE_DIRS})
            set (${PREFIX}_LIBRARIES ${${name_}_LIBRARIES})
            set (${PREFIX}_LIBRARY_DIRS ${${name_}_LIBRARY_DIRS})
            set (${PREFIX}_DEFINITIONS ${${name_}_CFLAGS_OTHER})
            set (found_ TRUE)

        else ()
            # try system module manager

            if (MSVC)
                # MS has no automatic module management

            elseif (APPLE)
                # I don't know how to use Apple "Framework"
                message (FATAL_ERROR "sagase: " ${PREFIX} ": MacOS Support incomplete")

            elseif (UNIX)
                # what else is there besides pkg-config?
                # non-linux OSes may be a problem
                message (STATUS "tring pkg_check_modules: " ${name_})

                if (PKG_CONFIG_FOUND)
                    pkg_check_modules(${PREFIX} ${name_})
                else ()
                    message (STATUS "pkg-config cannot be found.")
                endif ()

                if (${PREFIX}_FOUND)
                    message (STATUS "sagase: configured " ${PREFIX})
                    # already set: ${PREFIX}_INCLUDE_DIRS, 
                    # ${PREFIX}_LIBRARY_DIRS, ${PREFIX}_LIBRARIES
                    set (${PREFIX}_DEFINITIONS ${${PREFIX}_CFLAGS_OTHER})
                    set (found_ TRUE)
                endif ()

            else ()
                message (FATAL_ERROR "sagase: " ${PREFIX} ": Unable to detect OS type")
            endif ()

        endif ()
    endforeach ()

    if (NOT found_)
        # results are in ${PREFIX_INCLUDE_PATHS}/${PREFIX_LIBRARY_PATHS}
        message (STATUS "trying brute-force search ")

        sagase_generate_paths (${PREFIX} NAMES ${PKG_NAMES} PREFIXES ${PKG_PREFIXES})

        # follow platform library naming
        if (MSVC)
            set (LIB_PREFIX "")
            set (LIB_POSTFIXES ".lib")
        elseif (UNIX)
            set (LIB_PREFIX "lib")
            set (LIB_POSTFIXES ".so" ".a")
        else ()
            message (FATAL_ERROR "sagase: " ${PREFIX} ": Unable to detect OS type")
        endif ()

        # try using "components" as file names (without prefix or extension)
        foreach (component_ ${PKG_COMPONENTS})
            
            # get header path
            find_path (${PREFIX}_${component_}_INCLUDE_DIR ${component_}".h" ${${PREFIX}_INCLUDE_PATHS})
            
            if (${PREFIX}_${component_}_INCLUDE_DIR)
                set (${PREFIX}_INCLUDE_DIRS ${{PREFIX}_INCLUDE_DIRS} ${PREFIX}_${component_}_INCLUDE_DIR)
            endif ()

            # get library path
            foreach (extension_ ${LIB_POSTFIXES})
                find_path (${PREFIX}_${component_}_LIBRARY_DIR ${LIB_PREFIX}${component_}${extension_} ${${PREFIX}_LIBRARY_PATHS})

                if (${PREFIX}_${component_}_LIBRARY_DIR)
                    set (${PREFIX}_LIBRARY_DIRS ${{PREFIX}_LIBRARY_DIRS} ${PREFIX}_${component_}_LIBRARY_DIR)
                endif ()
            endforeach ()
        endforeach ()
    endif ()

    if (NOT ${PREFIX}_INCLUDE_DIRS OR NOT ${PREFIX}_LIBRARY_DIRS OR NOT ${PREFIX}_LIBRARIES)
        message (FATAL_ERROR "sagase: unable to configure " ${PREFIX}) 
    endif ()
endmacro ()