
find_package (PkgConfig REQUIRED)

set (VALA_DEMO_PUBLIC_MODULES glib-2.0 gobject-2.0 gio-2.0 grx-3.0)
pkg_check_modules (VALA_DEMO_PUBLIC_DEPS REQUIRED ${VALA_DEMO_PUBLIC_MODULES})


find_package (Valac REQUIRED)

vala2c(gw-demo-vala SOURCE_FILES demo.vala
    PACKAGES
        glib-2.0
        gobject-2.0
        gio-2.0
        gw-0.1
        grx-3.0
    VAPI_DIRS
        ${CMAKE_BINARY_DIR}/src
        ${CMAKE_INSTALL_PREFIX}/share/vala/vapi
    TARGET_GLIB 2.48
    DEPENDS
        ${CMAKE_BINARY_DIR}/src/${PACKAGE_NAME}.vapi
)

add_executable(vala-demo $<TARGET_PROPERTY:gw-demo-vala,C_FILES>)
set_target_properties(vala-demo PROPERTIES
    OUTPUT_NAME demo
)
target_include_directories(vala-demo
    PUBLIC
        ${CMAKE_BINARY_DIR}/src
        ${VALA_DEMO_PUBLIC_DEPS_INCLUDE_DIRS}
)
target_link_libraries(vala-demo
    ${SHARED_LIBRARY_TARGET}
    ${VALA_DEMO_PUBLIC_DEPS_LIBRARIES}
)

install(TARGETS vala-demo DESTINATION ${CMAKE_INSTALL_LIBPKGDIR}/example/vala)

add_custom_target (run-vala-demo
    COMMAND
        ${CMAKE_COMMAND} -E env
            XDG_CONFIG_HOME=${CMAKE_SOURCE_DIR}/.vscode
            LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src:${CMAKE_INSTALL_PREFIX}/lib
            ${CMAKE_CURRENT_BINARY_DIR}/demo
    DEPENDS
        vala-demo
)
