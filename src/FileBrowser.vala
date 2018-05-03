/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2018 David Lechner <david@lechnology.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 */

/* FileBrowser.vala - window for browsing the filesystem */

using Grx;

namespace Gw {
    /**
     * Button shaped {@link Container} to get user input.
     *
     * The colors of a button (except for the border) are inverted when it has
     * focus. Pressing ``ENTER`` will trigger the {@link pressed} signal.
     */
    public class FileBrowser : MenuWindow, AsyncInitable {
        const string file_attrs = FileAttribute.STANDARD_NAME + ","
                                + FileAttribute.STANDARD_IS_HIDDEN + ","
                                + FileAttribute.STANDARD_ICON + ","
                                + FileAttribute.STANDARD_TYPE;
        const FileQueryInfoFlags query_flags = FileQueryInfoFlags.NOFOLLOW_SYMLINKS;

        string root_path;
        string current_path;
        FileMonitor monitor;

        /**
         * Emitted when the user selects a file.
         */
        public signal void file_selected ();

        construct {
            root_path = Path.DIR_SEPARATOR_S;
            current_path = ".";
        }

        /**
         * Creates a new FileBrowser window.
         *
         * @param root_path     The root directory for the file browser (cannot
         *                      browse the parent of this directory)
         * @param starting_path The starting directory for the file browser.
         *                      If null, then starts at the root path.
         */
        public FileBrowser (string root_path, string? starting_path = null) {
            Object (create_title_bar: starting_path ?? root_path);
            this.root_path = root_path;
            this.current_path = starting_path ?? root_path;
        }

        public async bool init_async (int io_priority = Priority.DEFAULT, Cancellable? cancellable = null) throws GLib.Error {
            yield set_current_directory (current_path, io_priority, cancellable);
            return true;
        }

        async void set_current_directory (string path, int io_priority = Priority.DEFAULT, Cancellable? cancellable = null) throws GLib.Error {
            var directory = File.new_for_path (path);
            if (monitor != null) {
                monitor.cancel ();
                monitor.dispose ();
            }
            content_box.remove_all ();
            title_bar.title = path;
            current_path = path;

            monitor = directory.monitor_directory (FileMonitorFlags.NONE);
            monitor.changed.connect (handle_changed);

            if (current_path != root_path) {
                var parent_path = Path.get_dirname (current_path);
                var button = new Button.with_label ("..");
                button.pressed.connect (() => {
                    set_current_directory.begin (parent_path);
                });
                content_box.add (button);
            }

            var enumerator = yield directory.enumerate_children_async (file_attrs,
                query_flags, io_priority, cancellable);

            while (true) {
                var count = 0;
                foreach (var info in yield enumerator.next_files_async (10, io_priority, cancellable)) {
                    monitor.changed (enumerator.get_child (info), null, FileMonitorEvent.CREATED);
                    count++;
                }
                if (count == 0) {
                    break;
                }
            }
            yield enumerator.close_async (io_priority, cancellable);
            content_box.focus_first ();
            vscroll.scroll_to_child (vscroll.child);
        }

        void handle_changed (File file, File? other_file, FileMonitorEvent event_type) {
            switch (event_type) {
            case FileMonitorEvent.CREATED:
                try {
                    var file_info = file.query_info (file_attrs, query_flags);

                    // don't show hidden files
                    if (file_info.get_is_hidden ()) {
                        break;
                    }

                    //  var file_name = file.get_basename ();
                    //  var mode = file_info.get_attribute_uint32 (FileAttribute.UNIX_MODE);
                    //  if (file_info.get_file_type ()  == FileType.DIRECTORY) {
                    //      // add '/' to the end of directories
                    //      file_name += "/";
                    //  } else if ((mode & Posix.S_IXUSR) == Posix.S_IXUSR) {
                    //      // add '*' to the end of executable files
                    //      file_name += "*";
                    //  }
                    add_file (file_info);
                } catch (GLib.Error err) {
                    // If file was deleted immediately after creation, no need
                    // to show error message.
                    if (err is IOError.NOT_FOUND) {
                        break;
                    }
                    warning ("%s", err.message);
                }
                break;
            case FileMonitorEvent.DELETED:
                //  file_browser_window.remove_file (file);
                break;
            }
        }

        void add_file (FileInfo info) {
            var file_name = info.get_name ();
            var icon = info.get_icon ();
            message ("%s", icon.to_string ());
            var button = new Button.with_label (file_name);
            var type = info.get_file_type ();
            if (type == FileType.DIRECTORY) {
                weak FileBrowser weak_this = this;
                button.pressed.connect (() => {
                    var new_path = Path.build_filename (weak_this.current_path, file_name);
                    weak_this.set_current_directory.begin (new_path);
                });
            }
            content_box.add (button);
            button.weak_ref (() => message ("bye"));
        }
    }
}
