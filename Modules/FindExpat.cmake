# - Find expat
# Find the native EXPAT headers and libraries.
#
#  EXPAT_INCLUDE_DIRS - where to find expat.h, etc.
#  EXPAT_LIBRARIES    - List of libraries when using expat.
#  EXPAT_LIBRARY_DEBUG - Debug version of Library
#  EXPAT_LIBRARY_RELEASE - Release Version of Library
#  EXPAT_FOUND        - True if expat found.

# Look for the header file.

# MESSAGE (STATUS "Finding expat library and headers..." )
SET (EXPAT_DEBUG 0)

SET(EXPAT_INCLUDE_SEARCH_DIRS
  $ENV{EXPAT_INSTALL}/include
)

SET (EXPAT_LIB_SEARCH_DIRS
  $ENV{EXPAT_INSTALL}/lib
  )

SET (EXPAT_BIN_SEARCH_DIRS
  $ENV{EXPAT_INSTALL}/bin
)

FIND_PATH(EXPAT_INCLUDE_DIR 
  NAMES expat.h
  PATHS ${EXPAT_INCLUDE_SEARCH_DIRS} 
  NO_DEFAULT_PATH
)

IF (WIN32 AND NOT MINGW)
    SET (EXPAT_SEARCH_DEBUG_NAMES "expatdll_D;libexpat_D")
    SET (EXPAT_SEARCH_RELEASE_NAMES "expatdll;libexpat")
ELSE (WIN32 AND NOT MINGW)
    SET (EXPAT_SEARCH_DEBUG_NAMES "expat_debug")
    SET (EXPAT_SEARCH_RELEASE_NAMES "expat")
ENDIF(WIN32 AND NOT MINGW)


IF (EXPAT_DEBUG)
message (STATUS "EXPAT_INCLUDE_SEARCH_DIRS: ${EXPAT_INCLUDE_SEARCH_DIRS}")
message (STATUS "EXPAT_LIB_SEARCH_DIRS: ${EXPAT_LIB_SEARCH_DIRS}")
message (STATUS "EXPAT_BIN_SEARCH_DIRS: ${EXPAT_BIN_SEARCH_DIRS}")
message (STATUS "EXPAT_SEARCH_RELEASE_NAMES: ${EXPAT_SEARCH_RELEASE_NAMES}")
message (STATUS "EXPAT_SEARCH_DEBUG_NAMES: ${EXPAT_SEARCH_DEBUG_NAMES}")
ENDIF (EXPAT_DEBUG)

# Look for the library.
FIND_LIBRARY(EXPAT_LIBRARY_DEBUG 
  NAMES ${EXPAT_SEARCH_DEBUG_NAMES}
  PATHS ${EXPAT_LIB_SEARCH_DIRS} 
  NO_DEFAULT_PATH
  )
  
FIND_LIBRARY(EXPAT_LIBRARY_RELEASE 
  NAMES ${EXPAT_SEARCH_RELEASE_NAMES}
  PATHS ${EXPAT_LIB_SEARCH_DIRS} 
  NO_DEFAULT_PATH
  )

SET (EXPAT_XMLWF_PROG_NAME "xmlwf")
IF (WIN32)
    SET (EXPAT_XMLWF_PROG_NAME "xmlwf.exe")
ENDIF(WIN32)

FIND_PROGRAM(EXPAT_XMLWF_PROG
    NAMES ${EXPAT_XMLWF_PROG_NAME}
    PATHS ${EXPAT_BIN_SEARCH_DIRS} 
    NO_DEFAULT_PATH
)
MARK_AS_ADVANCED(EXPAT_XMLWF_PROG)

IF (EXPAT_DEBUG)
MESSAGE(STATUS "EXPAT_INCLUDE_DIR: ${EXPAT_INCLUDE_DIR}")
MESSAGE(STATUS "EXPAT_LIBRARY_DEBUG: ${EXPAT_LIBRARY_DEBUG}")
MESSAGE(STATUS "EXPAT_LIBRARY_RELEASE: ${EXPAT_LIBRARY_RELEASE}")
MESSAGE(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
endif(EXPAT_DEBUG)

# include the macro to adjust libraries
get_filename_component(CURRENT_PARENT_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
INCLUDE ( ${CURRENT_PARENT_DIR}/cmpAdjustLibVars.cmake)
cmp_ADJUST_LIB_VARS(EXPAT)

# MESSAGE( STATUS "EXPAT_LIBRARY: ${EXPAT_LIBRARY}")

# Copy the results to the output variables.
IF(EXPAT_INCLUDE_DIR AND EXPAT_LIBRARY)
  SET(EXPAT_FOUND 1)
  SET(EXPAT_LIBRARIES ${EXPAT_LIBRARY})
  SET(EXPAT_INCLUDE_DIRS ${EXPAT_INCLUDE_DIR})
  IF (EXPAT_LIBRARY_DEBUG)
    GET_FILENAME_COMPONENT(EXPAT_LIBRARY_PATH ${EXPAT_LIBRARY_DEBUG} PATH)
    SET(EXPAT_LIB_DIR  ${EXPAT_LIBRARY_PATH})
  ELSEIF(EXPAT_LIBRARY_RELEASE)
    GET_FILENAME_COMPONENT(EXPAT_LIBRARY_PATH ${EXPAT_LIBRARY_RELEASE} PATH)
    SET(EXPAT_LIB_DIR  ${EXPAT_LIBRARY_PATH})
  ENDIF(EXPAT_LIBRARY_DEBUG)
  
  IF (EXPAT_XMLWF_PROG)
    GET_FILENAME_COMPONENT(EXPAT_BIN_PATH ${EXPAT_XMLWF_PROG} PATH)
    SET(EXPAT_BIN_DIR  ${EXPAT_BIN_PATH})
  ENDIF (EXPAT_XMLWF_PROG)
  
ELSE(EXPAT_INCLUDE_DIR AND EXPAT_LIBRARY)
  SET(EXPAT_FOUND 0)
  SET(EXPAT_LIBRARIES)
  SET(EXPAT_INCLUDE_DIRS)
ENDIF(EXPAT_INCLUDE_DIR AND EXPAT_LIBRARY)

# Report the results.
IF(NOT EXPAT_FOUND)
  SET(EXPAT_DIR_MESSAGE
    "EXPAT was not found. Make sure EXPAT_LIBRARY and EXPAT_INCLUDE_DIR are set or set the EXPAT_INSTALL environment variable.")
  IF(NOT EXPAT_FIND_QUIETLY)
    MESSAGE(STATUS "${EXPAT_DIR_MESSAGE}")
  ELSE(NOT EXPAT_FIND_QUIETLY)
    IF(EXPAT_FIND_REQUIRED)
      # MESSAGE(FATAL_ERROR "${EXPAT_DIR_MESSAGE}")
      MESSAGE(FATAL_ERROR "Expat was NOT found and is Required by this project")
    ENDIF(EXPAT_FIND_REQUIRED)
  ENDIF(NOT EXPAT_FIND_QUIETLY)
ENDIF(NOT EXPAT_FOUND)


IF (EXPAT_FOUND)
  INCLUDE(CheckSymbolExists)
  #############################################
  # Find out if EXPAT was build using dll's
  #############################################
  # Save required variable
  SET(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
  SET(CMAKE_REQUIRED_FLAGS_SAVE    ${CMAKE_REQUIRED_FLAGS})
  # Add EXPAT_INCLUDE_DIR to CMAKE_REQUIRED_INCLUDES
  SET(CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES};${EXPAT_INCLUDE_DIRS}")

  CHECK_SYMBOL_EXISTS(EXPAT_BUILT_AS_DYNAMIC_LIB "expat_config.h" HAVE_EXPAT_DLL)

  if (HAVE_EXPAT_DLL)
   SET (EXPAT_IS_SHARED 1 CACHE INTERNAL "Expat Built as DLL or Shared Library")
  endif()

  # Restore CMAKE_REQUIRED_INCLUDES and CMAKE_REQUIRED_FLAGS variables
  SET(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})
  SET(CMAKE_REQUIRED_FLAGS    ${CMAKE_REQUIRED_FLAGS_SAVE})
  #
  #############################################

ENDIF (EXPAT_FOUND)
