


# Comment this out to enable C compiler warnings
add_definitions (-w)

set (SOURCE_FILES
    Application.vala
    Box.vala
    Button.vala
    CheckboxMenuItem.vala
    CheckButton.vala
    Container.vala
    Dialog.vala
    Fonts.vala
    Grid.vala
    Icon.vala
    InputDialog.vala
    Label.vala
    Menu.vala
    MenuItem.vala
    MessageDialog.vala
    OnScreenKeyboard.vala
    RadioMenuItem.vala
    Rectangle.vala
    Screen.vala
    Scroll.vala
    Spacer.vala
    Stack.vala
    StatusBar.vala
    StatusBarItem.vala
    TextEntry.vala
    Widget.vala
    Window.vala
    ${CMAKE_CURRENT_BINARY_DIR}/Version.vala
)

configure_file (Version.vala.in Version.vala)


# library deps

find_package (PkgConfig REQUIRED)

set (PUBLIC_MODULES glib-2.0 gobject-2.0 gio-2.0 grx-3.0)
pkg_check_modules (PUBLIC_DEPS REQUIRED ${PUBLIC_MODULES})


# vala compiler

find_package (Valac REQUIRED)
find_package(GirCompiler REQUIRED)

vala2c (VALA_C_FILES SOURCE_FILES ${SOURCE_FILES}
    PACKAGES
        glib-2.0
        gobject-2.0
        gio-2.0
        grx-3.0
    TARGET_GLIB 2.48
    LIBRARY ${PACKAGE_NAME}
    VAPI_DIRS
        ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_VAPIDIR}
# GENERATE_GIR
    # ${GIR_NAME}-buggy-${GIR_VERSION}
)

# Work around bug in valac where .gir is missing the "shared-library" attribute
# in the namespace node. This is needed by dh_girepository to generate the
# {shlibs:Depends} variable.

# add_custom_command (
#     OUTPUT
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.gir"
#     COMMAND
#         "${CMAKE_CURRENT_SOURCE_DIR}/fix-gir.sh"
#     ARGS
#         "$<TARGET_SONAME_FILE_NAME:${LIBRARY_NAME}-shared>"
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-buggy-${GIR_VERSION}.gir"
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.gir"
#     DEPENDS
#         "${CMAKE_CURRENT_SOURCE_DIR}/fix-gir.sh"
#         "${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-buggy-${GIR_VERSION}.gir"
#     COMMENT
#         "Fixing ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-buggy-${GIR_VERSION}.gir"
# )

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
add_library (${LIBRARY_OBJECT_TARGET} OBJECT ${VALA_C_FILES})
target_include_directories (${LIBRARY_OBJECT_TARGET} PUBLIC ${PUBLIC_DEPS_INCLUDE_DIRS})
set_target_properties (${LIBRARY_OBJECT_TARGET} PROPERTIES POSITION_INDEPENDENT_CODE 1)

# shared library
add_library (${SHARED_LIBRARY_TARGET} SHARED $<TARGET_OBJECTS:${LIBRARY_OBJECT_TARGET}>)
target_link_libraries (${SHARED_LIBRARY_TARGET} PUBLIC ${PUBLIC_DEPS_LIBRARIES})
set_target_properties(${SHARED_LIBRARY_TARGET} PROPERTIES
    VERSION "${VERSION}"
    SOVERSION "${ABI_VERSION}"
    OUTPUT_NAME ${PACKAGE_NAME})

install (TARGETS ${SHARED_LIBRARY_TARGET} LIBRARY DESTINATION lib)

# static libarary
add_library(${STATIC_LIBRARY_TARGET} STATIC $<TARGET_OBJECTS:${LIBRARY_OBJECT_TARGET}>)
target_link_libraries(${STATIC_LIBRARY_TARGET} ${PUBLIC_DEPS_LIBRARIES})
set_target_properties(${STATIC_LIBRARY_TARGET} PROPERTIES
    OUTPUT_NAME ${PACKAGE_NAME})

install (TARGETS ${STATIC_LIBRARY_TARGET} ARCHIVE DESTINATION lib)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.h DESTINATION include/)
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-${GIR_VERSION}.pc DESTINATION lib/pkgconfig/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.vapi DESTINATION ${CMAKE_INSTALL_VAPIDIR})
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.gir DESTINATION share/gir-1.0/)
# install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GIR_NAME}-${GIR_VERSION}.typelib DESTINATION lib/girepository-1.0/)
