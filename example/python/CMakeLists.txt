
add_custom_target(run-python-demo
    COMMAND
        ${CMAKE_COMMAND} -E env
        XDG_CONFIG_HOME=${CMAKE_SOURCE_DIR}/.vscode
        LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src:${CMAKE_INSTALL_PREFIX}/lib
        GI_TYPELIB_PATH=${CMAKE_BINARY_DIR}/src:${CMAKE_INSTALL_PREFIX}/lib/girepository-1.0
        ${CMAKE_CURRENT_SOURCE_DIR}/demo.py
    DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/demo.py
)
