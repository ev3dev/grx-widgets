


# Comment this out to enable C compiler warnings
add_definitions (-w)

set (SOURCE_FILES
    # Window.vala is not in alphabetical order to avoid compiler bug!
    # We will get error messages like "error: Gw.VBox.key_released: no suitable
    # method found to override" if we put it in order.
    Window.vala
    Application.vala
    Basis.vala
    Button.vala
    # CheckboxMenuItem.vala
    # CheckButton.vala
    Container.vala
    # Dialog.vala
    FileBrowser.vala
    # Grid.vala
    HBox.vala
    Image.vala
    IconSize.vala
    # InputDialog.vala
    Label.vala
    MenuWindow.vala
    # MenuItem.vala
    # MessageDialog.vala
    # OnScreenKeyboard.vala
    # RadioMenuItem.vala
    Rectangle.vala
    Resource.vala
    # Stack.vala
    # StatusBar.vala
    # StatusBarItem.vala
    # TextEntry.vala
    TitleBar.vala
    VBox.vala
    VScroll.vala
    VScrollBar.vala
    VTrough.vala
    Widget.vala
    ${CMAKE_CURRENT_BINARY_DIR}/Version.vala
)

configure_file (Version.vala.in Version.vala)


# library deps

find_package (PkgConfig REQUIRED)

set (PUBLIC_MODULES glib-2.0 gobject-2.0 gio-2.0 grx-3.0)
pkg_check_modules (PUBLIC_DEPS REQUIRED ${PUBLIC_MODULES})


# vala compiler

find_package(Valac REQUIRED)
find_package(GirScanner REQUIRED)
find_package(GirCompiler REQUIRED)

vala2c(gw-vala SOURCE_FILES ${SOURCE_FILES}
    PACKAGES
        glib-2.0
        gobject-2.0
        gio-2.0
        grx-3.0
    TARGET_GLIB 2.48
    LIBRARY ${PACKAGE_NAME}
    GIR ${GIR_NAME}-${GIR_VERSION}
    VAPI_DIRS
        ${CMAKE_INSTALL_PREFIX}/share/vala/vapi
)

add_typelib(gw-typelib gw-vala
    ARGS
        "--includedir=${CMAKE_INSTALL_PREFIX}/share/gir-1.0"
)

# add_custom_command (
#     OUTPUT
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.typelib"
#     COMMAND
#         ${G_IR_COMPILER_EXECUTABLE}
#     ARGS
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.gir"
#         "--shared-library=$<TARGET_SONAME_FILE_NAME:${LIBRARY_NAME}-shared>"
#         "--output=${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.typelib"
#         "--includedir=${CMAKE_CURRENT_BINARY_DIR}"
#     DEPENDS
#         "${LIBRARY_NAME}-shared"
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.gir"
#     COMMENT
#         "Genterating typelib."
# )

# add_custom_target ("${LIBRARY_NAME}-typelib"
#     ALL
#     DEPENDS
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.typelib"
# )

# end of workaround


# Library targets

# common object code
set (LIBRARY_OBJECT_TARGET ${PACKAGE_NAME}-object)
add_library(${LIBRARY_OBJECT_TARGET} OBJECT $<TARGET_PROPERTY:gw-vala,C_FILES>)
target_compile_options(${LIBRARY_OBJECT_TARGET} PUBLIC ${PUBLIC_DEPS_CFLAGS})
set_target_properties (${LIBRARY_OBJECT_TARGET} PROPERTIES POSITION_INDEPENDENT_CODE 1)

# shared library
add_library (${SHARED_LIBRARY_TARGET} SHARED $<TARGET_OBJECTS:${LIBRARY_OBJECT_TARGET}>)
target_link_libraries(${SHARED_LIBRARY_TARGET} PUBLIC ${PUBLIC_DEPS_LDFLAGS})
set_target_properties(${SHARED_LIBRARY_TARGET} PROPERTIES
    VERSION "${VERSION}"
    SOVERSION "${ABI_VERSION}"
    OUTPUT_NAME ${PACKAGE_NAME})

install(TARGETS ${SHARED_LIBRARY_TARGET} LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

# static libarary
add_library(${STATIC_LIBRARY_TARGET} STATIC $<TARGET_OBJECTS:${LIBRARY_OBJECT_TARGET}>)
target_link_libraries(${STATIC_LIBRARY_TARGET} ${PUBLIC_DEPS_LIBRARIES})
set_target_properties(${STATIC_LIBRARY_TARGET} PROPERTIES
    OUTPUT_NAME ${PACKAGE_NAME})

install(TARGETS ${STATIC_LIBRARY_TARGET} ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(FILES $<TARGET_PROPERTY:gw-vala,HEADER_FILE> DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-${GIR_VERSION}.pc DESTINATION lib/pkgconfig/)
install_vapi(gw-vala DESTINATION ${CMAKE_INSTALL_DATAROOTDIR})
install_gir(gw-vala DESTINATION ${CMAKE_INSTALL_DATAROOTDIR})
install_typelib(gw-typelib DESTINATION ${CMAKE_INSTALL_LIBDIR})
