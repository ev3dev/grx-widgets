/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2017 David Lechner <david@lechnology.com>
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

using Gw;

class DemoWindow : Window {
    public DemoWindow () {
        var menu = new Gw.Menu ();

        var quit_item = new Gw.MenuItem ("Quit");
        quit_item.button.pressed.connect (() => {
            close ();
        });
        menu.add_menu_item (quit_item);

        add (menu);
    }
}

public static int main (string[] args) {
    try {
        var app = new Gw.Application ();

        // basic apps need to handle the "activate" signal
        var activate_id = app.activate.connect (() => {
            message ("activated");
            var window = new DemoWindow ();
            window.closed.connect (() => {
                app.release ();
            });
            app.screen.push_window (window);
            app.hold ();
        });

        var ret = app.run (args);

        // there is a reference cycle on app in the activate callback, so we
        // need to disconnect in order to free the app object.
        app.disconnect (activate_id);

        return ret;
    }
    catch (Error err) {
        critical ("%s", err.message);
        return 1;
    }
}
