/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2017-2018 David Lechner <david@lechnology.com>
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

        var hbox = new HBox ();
        vbox.add (hbox);

        var image1 = new Image.from_icon_name ("bluetooth", IconSize.SMALL);
        hbox.add (image1);

        var image2 = new Image.from_icon_name ("bluetooth-connected", IconSize.SMALL);
        hbox.add (image2);

        var button1 = new Button.with_label ("Click me!") {
            margin = 3
        };
        button1.pressed.connect (() => {
            message ("button1 pressed");
        });
        vbox.add (button1);

        var button2 = new Button.with_label ("Click me too!") {
            margin = 3
        };
        button2.pressed.connect (() => {
            message ("button2 pressed");
        });
        vbox.add (button2);
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
