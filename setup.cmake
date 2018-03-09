# Create the build directory and initialize it
#
# run this file with `cmake -P setup.cmake`


file (MAKE_DIRECTORY build)

execute_process (
    COMMAND ${CMAKE_COMMAND}
        -DCMAKE_BUILD_TYPE=Debug
        ..
    WORKING_DIRECTORY build
)
