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

/* MenuItem.vala - Base class for menu items used by Menu widget */

namespace Gw {
    /**
     * Object used by {@link Menu} to represent a menu item.
     *
     * Note: MenuItems do not inherit from {@link Widget}.
     */
    public class MenuItem : Object {
        static int menu_item_count = 0;

        internal ulong notify_has_focus_signal_id;

        /**
         * Gets the Menu that this menu item belongs to.
         *
         * Returns ``null`` if this MenuItem has not been added to a Menu.
         */
        public weak Menu? menu { get; internal set; }

        /**
         * Gets the Button that is the Container for the menu item.
         */
        public Button button { get; construct; default = new Button (); }

        /**
         * Gets the Label for the menu item.
         */
        public Label label { get; construct; default = new Label (); }

        /**
         * Gets and sets a user-defined object that the menu item represents.
         */
        public Object? represented_object { get; set; }

        construct {
            // using weak reference to prevent reference cycle.
            button.weak_represented_object = this;
            weak_ref (weak_notify);
            menu_item_count++;
            //debug ("Created MenuItem: %p", this);
        }

        /**
         * Creates a new menu item with the specified text.
         *
         * @param text The text for the menu item's label.
         */
        public MenuItem (string text) {
            this.with_button (new Button () {
                border = 0,
                border_radius = 0
            }, new Label (text) {
                text_horizontal_align = Grx.TextHAlign.LEFT
            });
            button.add (label);
        }

        /**
         * Creates a new menu item with an arrow pointing to the right.
         *
         * This should be used for menu items that open a new window.
         *
         * @param text The text for the menu item's label.
         */
        public MenuItem.with_right_arrow (string text) {
            this.with_button (new Button () {
                border = 0,
                border_radius = 0
            }, new Label (text) {
                text_horizontal_align = Grx.TextHAlign.LEFT
            });
            var hbox = new Box.horizontal ();
            button.add (hbox);
            hbox.add (label);
            hbox.add (new Spacer ());
            var arrow_label = new Label (">") {
                horizontal_align = WidgetAlign.END
            };
            hbox.add (arrow_label);
        }

        /**
         * Creates a new menu item using the provided button and label.
         *
         * This is the main constructor that should be called by superclasses.
         *
         * Note: MenuItem uses ``button.weak_represented_object`` internally, so
         * implementations must not set that property.
         */
        protected MenuItem.with_button (Button button, Label label) {
            Object (button: button, label: label);
        }

        static void weak_notify (Object obj) {
            var menu_item = obj as MenuItem;
            if (menu_item.notify_has_focus_signal_id != 0)
                SignalHandler.disconnect (menu_item.button, menu_item.notify_has_focus_signal_id);
        }

        ~MenuItem () {
            //debug ("Finalized MenuItem: %p", this);
            //debug ("MenuItem count %d", --menu_item_count);
        }
    }
}