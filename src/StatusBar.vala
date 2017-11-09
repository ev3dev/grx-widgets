/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * StatusBar.vala - status bar that can be displayed at the top of a screen
 */

using Grx;

namespace Gw {
    /**
     * A status bar that displays at the top of a {@link Screen}.
     */
    public class StatusBar : Object {
        /**
         * The height of the status bar.
         */
        public const int HEIGHT = 19;
        const int PADDING = 2;

        SList<StatusBarItem> left_items;
        SList<StatusBarItem> right_items;

        /**
         * Gets the screen the status bar is assigned to.
         *
         * Returns ``null`` if the status bar is not assined to a screen.
         */
        public weak Screen? screen { get; internal set; }

        /**
         * Gets or sets the visibility of the status bar.
         */
        public bool visible { get; set; default = true; }

        /**
         * Tells the screen to refresh.
         *
         * Does nothing if the status bar is not attached to a screen or is not
         * visible.
         */
        public void redraw () {
            if (_visible && screen != null)
                screen.dirty = true;
        }

        internal void draw () {
            draw_filled_box (0, 0, screen.width - 1, HEIGHT - 1, screen.bg_color);
            var x = 0;
            foreach (var item in left_items) {
                if (item.visible)
                    x += item.draw (x, Align.LEFT) + PADDING;
            }
            x = screen.width - 1;
            foreach (var item in right_items) {
                if (item.visible)
                    x -= item.draw (x, Align.RIGHT) + PADDING;
            }
            draw_line (0, HEIGHT - 1, screen.width - 1, HEIGHT - 1, screen.fg_color);
        }

        /**
         * Adds a status bar item to the left side of the status bar.
         *
         * @param item The status bar item to add.
         */
        public void add_left (StatusBarItem item) {
            left_items.append (item);
            item.status_bar = this;
        }

        /**
         * Adds a status bar item to the right side of the status bar.
         *
         * @param item The status bar item to add.
         */
        public void add_right (StatusBarItem item) {
            right_items.append (item);
            item.status_bar = this;
        }

        construct {
            left_items = new SList<StatusBarItem> ();
            right_items = new SList<StatusBarItem> ();
        }

        /**
         * Creates a new status bar.
         */
        public StatusBar () {
        }

        /**
         * Specifies if a status bar item is in the group on the right or left
         * side of the status bar.
         */
        public enum Align {
            /**
             * The status bar item is in the left hand group.
             */
            LEFT,
            /**
             * The status bar item is in the right hand group.
             */
            RIGHT
        }
    }
}
