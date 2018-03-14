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

using Grx;
using Gw;

class ImageWindow : Window {
    public ImageWindow () {
        var vbox = new VBox ();
        add (vbox);

        var nav = new TitleBar ("Image Demo");
        vbox.add (nav);

        var hbox = new HBox ();
        vbox.add (hbox);

        /* built-in icons */

        Image img;

        img = new Image.from_icon_name ("arrow-left", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("arrow-right", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("arrow-up", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("arrow-down", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("bluetooth", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("bluetooth-connected", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("folder", IconSize.SMALL);
        hbox.add (img);
        img = new Image.from_icon_name ("folder-open", IconSize.SMALL);
        hbox.add (img);
    }
}
