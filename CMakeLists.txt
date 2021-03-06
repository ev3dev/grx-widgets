cmake_minimum_required (VERSION 3.5)

# config

project ("grx-widgets" VERSION "0.1.0" LANGUAGES C)
set (ABI_VERSION 0)
set (GIR_NAME "Gw")
set (GIR_VERSION "0.1")
set (PACKAGE_NAME "gw-${GIR_VERSION}")


# Set environment variables based on install path.
#
# The intention here is that if you want to use a local install of GRX3,
# then you can use the same CMAKE_INSTALL_PREFIX for GRX3 and this library.
# Build and install GRX3 first, then run cmake for this library and it will
# pick up the GRX3 library that you just installed.

set (ENV{PKG_CONFIG_PATH} ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig)
set (ENV{XDG_DATA_DIRS} ${CMAKE_INSTALL_PREFIX}/share:$ENV{XDG_DATA_DIRS})

# global stuff

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(GNUInstallDirs)
set (CMAKE_INSTALL_DATAPKGDIR ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME})
set (CMAKE_INSTALL_LIBPKGDIR ${CMAKE_INSTALL_LIBDIR}/${PACKAGE_NAME})

set (SHARED_LIBRARY_TARGET ${PACKAGE_NAME}-shared)
set (STATIC_LIBRARY_TARGET ${PACKAGE_NAME}-static)
set (GIR_TARGET ${PACKAGE_NAME}-gir)
set (TYPELIB_TARGET ${PACKAGE_NAME}-typelib)


# macOS/brew stuff

if (APPLE)
    # see `brew info gettext` caveats
    link_directories (/usr/local/opt/gettext/lib)
    include_directories (/usr/local/opt/gettext/include)
    # .typelib does not work without this
    set (CMAKE_MACOSX_RPATH No)
endif (APPLE)


# subdirectories

# src goes first for depedency reasons
add_subdirectory (src)

add_subdirectory (data)
add_subdirectory (example)


# old stuff

# set (UI_DEMO_EXEC_NAME "demo")

# add_subdirectory (data)
# set (XDG_DATA_DIR data)

# convert CMake list to space separated string for pkgconfig file
# string(REPLACE ";" " " PKGCONFIG_DEPS "${COMMON_MODULES}")
# configure_file (${PROJECT_NAME}.pc.in ${PROJECT_NAME}-${GIR_VERSION}.pc @ONLY)

# set (UI_DEMO_COMMON_SOURCE_FILES
#     demo/UiDemoWindow.vala
# )

# set (UI_DEMO_SOURCE_FILES
#     demo/ui_demo.vala
#     ${UI_DEMO_COMMON_SOURCE_FILES}
# )

# if (EV3DEVKIT_BUILD_DEMO)
#     set (EXEC_PACKAGES ${COMMON_PACKAGES} ${EV3DEVKIT_PACKAGE})
#     set (EXEC_LIBRARY_DEPENDS ${LIBRARY_NAME}-shared)

#     # Device driver demo program

#     vala_precompile(DEVICES_DEMO_EXEC_VALA_C ${DEVICES_DEMO_EXEC_NAME}
#         ${DEVICES_DEMO_SOURCE_FILES}
#     PACKAGES
#         ${EXEC_PACKAGES}
#     CUSTOM_VAPIS
#         bindings/*.vapi
#     OPTIONS
#         --target-glib=${TARGET_GLIB}
#         --thread
#         --vapidir=${CMAKE_CURRENT_BINARY_DIR}
#     )

#     add_executable (${DEVICES_DEMO_EXEC_NAME} ${DEVICES_DEMO_EXEC_VALA_C})
#     target_link_libraries (${DEVICES_DEMO_EXEC_NAME} ${EXEC_LIBRARY_DEPENDS})
#     if (CMAKE_CROSSCOMPILING)
#         # These are not picked up automatically when cross compiling for some reason
#         target_link_libraries (${DEVICES_DEMO_EXEC_NAME} "-pthread" "-lresolv")
#     endif (CMAKE_CROSSCOMPILING)

#     add_custom_target (run-${DEVICES_DEMO_EXEC_NAME}
#         COMMAND
#             XDG_DATA_DIRS=${XDG_DATA_DIR}:/usr/local/share:/usr/share
#             ./${DEVICES_DEMO_EXEC_NAME}
#         DEPENDS ${DEVICES_DEMO_EXEC_NAME}
#         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
#     )

#     install (TARGETS ${DEVICES_DEMO_EXEC_NAME} RUNTIME DESTINATION bin)


#     # User interface demo program

#     vala_precompile(UI_DEMO_EXEC_VALA_C ${UI_DEMO_EXEC_NAME}
#         ${UI_DEMO_SOURCE_FILES}
#     PACKAGES
#         ${EXEC_PACKAGES}
#     CUSTOM_VAPIS
#         bindings/*.vapi
#     OPTIONS
#         --target-glib=${TARGET_GLIB}
#         --thread
#         --vapidir=${CMAKE_CURRENT_BINARY_DIR}
#     )

#     add_executable (${UI_DEMO_EXEC_NAME} ${UI_DEMO_EXEC_VALA_C})
#     target_link_libraries (${UI_DEMO_EXEC_NAME} ${EXEC_LIBRARY_DEPENDS})
#     if (CMAKE_CROSSCOMPILING)
#         # These are not picked up automatically when cross compiling for some reason
#         target_link_libraries (${UI_DEMO_EXEC_NAME} "-pthread" "-lresolv")
#     endif (CMAKE_CROSSCOMPILING)

#     add_custom_target (run-${UI_DEMO_EXEC_NAME}
#         COMMAND
#             XDG_DATA_DIRS=${XDG_DATA_DIR}:/usr/local/share:/usr/share
#             ./${UI_DEMO_EXEC_NAME}
#         DEPENDS ${UI_DEMO_EXEC_NAME}
#         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
#     )

#     install (TARGETS ${UI_DEMO_EXEC_NAME} RUNTIME DESTINATION bin)

# endif (EV3DEVKIT_BUILD_DEMO)

# find_package (Valadoc)
# if (VALADOC_FOUND)
#     include (ValadocGenerate)
#     generate_valadoc (
#         ${LIBRARY_SOURCE_FILES}
#         bindings/*.vapi
#     PACKAGE_NAME
#         ${PROJECT_NAME}
#     PACKAGE_VERSION
#         ${GIR_VERSION}
#     OPTIONS
#         --target-glib=${TARGET_GLIB}
#     PACKAGES
#         ${COMMON_PACKAGES}
#     )
#     add_custom_target (doc ALL DEPENDS valadoc)
# endif (VALADOC_FOUND)
