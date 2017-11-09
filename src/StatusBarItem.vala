/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * StatusBarItem.vala - Base class for items shown in StatusBar
 */

namespace Gw {
    /**
     * Represents an item that is displayed in a {@link StatusBar}.
     */
    public abstract class StatusBarItem : Object {
        public const int HEIGHT = StatusBar.HEIGHT - 3;

        /**
         * Gets the status bar this item has been assigned to.
         *
         * Returns ``null`` if it has not assigned to a status bar.
         */
        public weak StatusBar? status_bar { get; internal set; }

        /**
         * Gets and sets the visibility of this item.
         */
        public bool visible { get; set; default = true; }

        construct {
            notify["visible"].connect (() => {
                if (status_bar != null)
                    status_bar.redraw ();
            });
        }

        /**
         * Creates a new status bar item.
         */
        protected StatusBarItem () {
        }

        /**
         * Notifies the status bar that this item has changed and needs to be
         * redrawn.
         *
         * Does nothing if this item has not been added to a status bar or this
         * item is not visible.
         */
        protected void redraw () {
            if (_visible && status_bar != null)
                status_bar.redraw ();
        }

        /**
         * Draws the status bar item.
         *
         * This is called by the status bar and should not be called manually.
         *
         * @param x The starting position for the status bar item
         * @param align The alignment of the status bar item
         * @return The width of the status bar item
         */
        public abstract int draw (int x, StatusBar.Align align);
    }
}
