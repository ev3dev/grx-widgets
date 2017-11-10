/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* Menu.vala - Menu widget */

namespace Gw {
    /**
     * A scrollable menu widget that displays a list of {@link MenuItem}s.
     *
     * The menu is basically a {@link Scroll} with a vertical {@link Box} that
     * contains buttons. It automatically handles things like making sure the
     * focused {@link MenuItem} is visible on the screen.
     */
    public class Menu : Gw.Scroll {
        Box menu_vbox;

        /**
         * Gets and sets the spacing in pixels between menu items.
         */
        public int spacing {
            get { return menu_vbox.spacing; }
            set { menu_vbox.spacing = value; }
        }

        /**
         * Used by find_menu_item<T> (MenuItem, T) method.
         *
         * @return true if ``value`` matches ``menu_item``.
         */
        public delegate bool FindFunc<T> (MenuItem menu_item, T value);

        construct {
            if (direction != ScrollDirection.VERTICAL)
                critical ("Unexpected direction.");
            can_focus = false;
            menu_vbox = new Box.vertical () {
                spacing = 0
            };
            menu_vbox.child_added.connect ((child) => {
                var id = child.notify["has-focus"].connect (() => {
                    if (child.has_focus)
                        scroll_to_child (child);
                });
                var menu_item = child.weak_represented_object as MenuItem;
                menu_item.notify_has_focus_signal_id = id;
                // Break reference cycle
                unref ();
            });
            menu_vbox.child_removed.connect ((child) => {
                // restore missing reference from above
                ref ();
                var menu_item = child.weak_represented_object as MenuItem;
                var id = menu_item.notify_has_focus_signal_id;
                if (id != 0) {
                    SignalHandler.disconnect (child, id);
                    menu_item.notify_has_focus_signal_id = 0;
                }
            });
            add (menu_vbox);
            weak_ref (weak_notify);
        }

        /**
         * Creates a new menu widget.
         */
        public Menu () {
            Object (direction: ScrollDirection.VERTICAL);
        }

        static void weak_notify (Object obj) {
            var menu = obj as Menu;
            while (menu.menu_vbox.child != null) {
                // if we still have children at this point, the child_removed handler
                // is no longer connected, so we have to restore the missing reference
                // here as well to prevent crashes.
                menu.ref ();
                menu.remove_menu_item (menu.menu_vbox.child.weak_represented_object as MenuItem);
            }
        }

        /**
         * Find a MenuItem that matches ``value``.
         *
         * @param value The value to pass to ``func``.
         * @param func The function that compares ``value`` to each MenuItem in
         * in the Menu.
         * @return The MenuItem if a match was found, otherwise ``null``.
         */
        public MenuItem? find_menu_item<T> (T value, FindFunc<T> func) {
            foreach (var widget in menu_vbox.children) {
                var menu_item = widget.weak_represented_object as MenuItem;
                if (menu_item != null && func (menu_item, value)) {
                    return menu_item;
                }
            }
            return null;
        }

        /**
         * Searches for the specified menu item.
         *
         * @param item The menu item to search for.
         * @return ``true`` if the menu item was found.
         */
        public bool has_menu_item (MenuItem item) {
            foreach (var widget in menu_vbox.children) {
                var obj = widget.weak_represented_object as MenuItem;
                if (obj == item) {
                    return true;
                }
            }
            return false;
        }

        /**
         * Adds a menu item to the end of the menu.
         *
         * If the menu item is already in another menu, it will be removed from
         * that menu before being added to this menu.
         *
         * @param item The menu item to add.
         */
        public void add_menu_item (MenuItem item)
            requires (item.button.weak_represented_object == item)
        {
            if (item.menu != null)
                item.menu.remove_menu_item (item);
            item.ref ();
            menu_vbox.add (item.button);
            item.menu = this;
        }

        /**
         * Inserts a menu item before an existing menu item.
         *
         * If the new menu item is already in another menu, it will be removed
         * from that menu before being added to this menu.
         *
         * @param new_item The menu item to add.
         * @param existing_item The existing menu item that the new menu item
         * will be inserted before.
         */
        public void insert_menu_item (MenuItem new_item, MenuItem existing_item)
            requires (new_item.button.weak_represented_object == new_item)
        {
            if (new_item.menu != null)
                new_item.menu.remove_menu_item (new_item);
            new_item.ref ();
            menu_vbox.insert_before (new_item.button, existing_item.button);
            new_item.menu = this;
        }

        /**
         * Removes the specified menu item from this menu.
         *
         * @param item The menu item to remove.
         * @return ``true`` if the menu item was removed or ``false`` if the
         * menu item was not found in this menu.
         */
        public bool remove_menu_item (MenuItem item) {
            foreach (var child in menu_vbox.children) {
                var obj = child.weak_represented_object as MenuItem;
                if (obj == item) {
                    if (child.has_focus) {
                        child.focus_next (child == menu_vbox.children.last ().data
                            ? FocusDirection.UP : FocusDirection.DOWN);
                    }
                    item.menu = null;
                    menu_vbox.remove (child);
                    item.unref ();
                    return true;
                }
            }
            return false;
        }

        /**
         * Removes all menu items from this menu.
         */
        public void remove_all_menu_items () {
            var iter = menu_item_iter ();
            while (iter.size > 0)
                remove_menu_item (iter[0]);
        }

        /**
         * Sorts the items in this menu using the specified function.
         *
         * @param func The function to use for sorting.
         */
        public void sort_menu_items (CompareDataFunc<MenuItem> func) {
            menu_vbox.sort ((a, b) => {
                var menu_item_a = a.weak_represented_object as MenuItem;
                var menu_item_b = b.weak_represented_object as MenuItem;
                return func (menu_item_a, menu_item_b);
            });
        }

        /**
         * Gets an iterator for iterating the items in this menu.
         */
        public MenuItemIterator menu_item_iter () {
            return new MenuItemIterator (this);
        }

        /**
         * Object used to iterate {@link MenuItem}s.
         */
        public class MenuItemIterator {
            Menu menu;

            internal MenuItemIterator (Menu menu) {
                this.menu = menu;
            }

            /**
             * Gets the number of items in the Menu.
             */
            public uint size { get { return menu.menu_vbox.children.length (); } }

            /**
             * Gets the item at the specified index.
             *
             * @param index The index of the item.
             * @return The item at the specified index.
             */
            public MenuItem get (int index) {
                return menu.menu_vbox.children.nth_data (index).weak_represented_object as MenuItem;
            }
        }
    }
}