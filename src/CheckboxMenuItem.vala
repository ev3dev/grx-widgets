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

/* CheckboxMenuItem.vala - Menu item used by Menu widget that has a checkbox */

namespace Gw {
    /**
     * {@link MenuItem} with a checkbox.
     */
    public class CheckboxMenuItem : Gw.MenuItem {
        /**
         * Gets the checkbox widget for this menu item.
         */
        public CheckButton checkbox { get; construct; }

        construct {
            var hbox = new Box.horizontal ();
            button.add (hbox);
            label.horizontal_align = WidgetAlign.START;
            hbox.add (label);
            hbox.add (new Spacer ());
            if (checkbox == null) {
                critical ("checkbox is null");
            } else {
                hbox.add (checkbox);
                button.pressed.connect (() => checkbox.checked = !checkbox.checked);
            }
        }

        /**
         * Creates a new checkbox menu item.
         *
         * @param text The text for the label of the menu item.
         */
        public CheckboxMenuItem (string text) {
            Object (button: new Button () {
                border = 0,
                border_radius = 0
            }, label: new Label (text),
            checkbox: new CheckButton.checkbox () {
                padding = 0,
                margin_top = 1,
                can_focus = false
            });
        }
    }
}