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

using Grx;

namespace Gw {
    /**
     * {@link Window} with {@link VScroll} for creating menus.
     */
    public class MenuWindow : Window {
        VScroll vscroll;

        /**
         * Gets the content box of the {@VScroll} for this window.
         */
        public VBox content_box { get { return vscroll.content_box; } }

        construct {
            vscroll = new VScroll();

            var vbox = child as VBox;
            if (vbox == null) {
                // no title bar
                add (vscroll);
            }
            else {
                vbox.add (vscroll);
            }
        }

        public MenuWindow () {
        }

        public MenuWindow.with_title_bar (string title) {
            Object (create_title_bar: title);
        }
    }
}
