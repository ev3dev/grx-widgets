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
        var vbox = new VBox ();
        add (vbox);

        var label = new Label ("hello world!");
        vbox.add (label);
//          var menu = new Gw.Menu ();

//          var button_item = new Gw.MenuItem ("Buttons");
//          menu.add_menu_item (button_item);

//          var dialog_item = new Gw.MenuItem ("Dialogs");
//          menu.add_menu_item (dialog_item);

//          var font_item = new Gw.MenuItem ("Fonts");
//          menu.add_menu_item (font_item);

//          var label_item = new Gw.MenuItem ("Labels");
//          menu.add_menu_item (label_item);

//          var menu_item = new Gw.MenuItem ("Menus");
//          menu.add_menu_item (menu_item);

//          var status_bar_item = new Gw.MenuItem ("Status Bar");
//          menu.add_menu_item (status_bar_item);

//          var text_entry_item = new Gw.MenuItem ("Text Entry");
//          menu.add_menu_item (text_entry_item);

//          var quit_item = new Gw.MenuItem ("Quit");
//          quit_item.button.pressed.connect (() => {
//              close ();
//          });
//          menu.add_menu_item (quit_item);

//          add (menu);
    }
}

public static int main (string[] args) {
    try {
        var app = new Gw.Application ();

        // basic apps need to handle the "activate" signal
        var activate_id = app.activate.connect (() => {
            var window = new DemoWindow ();
            app.basis.show_window (window);
        });

        var exit_code = app.run (args);

        // there is a reference cycle on app in the activate callback, so we
        // need to disconnect in order to free the app object.
        app.disconnect (activate_id);

        return exit_code;
    }
    catch (Error err) {
        critical ("%s", err.message);
        return 1;
    }
}
