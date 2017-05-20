cmake_minimum_required(VERSION 2.8.12)

project(lab3)

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build configuration" FORCE)
endif()

if(CMAKE_BUILD_TYPE)
  message(STATUS "Build configuration: ${CMAKE_BUILD_TYPE}")
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")
endif()

if (CMAKE_BUILD_TYPE)
  message(STATUS "Build configuration: ${CMAKE_BUILD_TYPE}")
endif()

include_directories(
  ${CMAKE_INCLUDE_PATH}
  ${OpenCL_INCLUDE_DIR}
  )

set(OCLTEST_SRCS
  CMakeLists.txt
  float.h
  main.cpp
  )

set(CMAKE_CXX__FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wextra")

if (NOT MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")

add_executable(lab3
  ${OCLTEST_SRCS}
  )

# Do no add an rpath to any of the binaries
set(CMAKE_SKIP_RPATH true)

install(TARGETS lab3
  DESTINATION bin
  )
