/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
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

/* RadioMenuItem.vala - Menu items used by Menu widget with radio button */

namespace Gw {
    /**
     * A menu item that includes a radio button.
     */
    public class RadioMenuItem : Gw.MenuItem {
        /**
         * Gets the radio button for the menu item.
         */
        public CheckButton radio { get; construct; }

        construct {
            var hbox = new Box.horizontal ();
            button.add (hbox);
            label.horizontal_align = WidgetAlign.START;
            hbox.add (label);
            hbox.add (new Spacer ());
            if (radio == null) {
                critical ("radio is null.");
            } else {
                hbox.add (radio);
                button.pressed.connect (() => radio.checked = !radio.checked);
            }
        }

        /**
         * Creates a new radio button menu item.
         *
         * @param text The text for the menu item Label.
         * @param group The CheckButtonGroup for the radio button.
         */
        public RadioMenuItem (string text, CheckButtonGroup group) {
            Object (button: new Button () {
                border = 0,
                border_radius = 0
            }, label: new Label (text),
            radio: new CheckButton.radio (group) {
                padding = 0,
                margin_top = 1,
                can_focus = false
            });
        }
    }
}