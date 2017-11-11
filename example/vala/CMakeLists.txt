
find_package (PkgConfig REQUIRED)

set (VALA_DEMO_PUBLIC_MODULES glib-2.0 gobject-2.0 gio-2.0 grx-3.0)
pkg_check_modules (VALA_DEMO_PUBLIC_DEPS REQUIRED ${VALA_DEMO_PUBLIC_MODULES})


find_package (Valac REQUIRED)
find_package (PkgConfig REQUIRED)

vala2c (VALA_DEMO_C_FILES SOURCE_FILES demo.vala
    PACKAGES
        glib-2.0
        gobject-2.0
        gio-2.0
        gw-0.1
        grx-3.0
    VAPI_DIRS
        ${CMAKE_BINARY_DIR}/src
    TARGET_GLIB 2.48
    DEPENDS
        ${CMAKE_BINARY_DIR}/src/${PACKAGE_NAME}.vapi
)

add_executable (VALA_DEMO ${VALA_DEMO_C_FILES})
set_target_properties (VALA_DEMO PROPERTIES
    OUTPUT_NAME demo
)
target_include_directories (VALA_DEMO
    PUBLIC
        ${CMAKE_BINARY_DIR}/src
        ${VALA_DEMO_PUBLIC_DEPS_INCLUDE_DIRS}
)
target_link_libraries (VALA_DEMO
    ${SHARED_LIBRARY_TARGET}
    ${VALA_DEMO_PUBLIC_DEPS_LIBRARIES}
)

add_custom_target (run-vala-demo
    COMMAND
        ${CMAKE_CURRENT_BINARY_DIR}/demo
    DEPENDS
        VALA_DEMO
)
