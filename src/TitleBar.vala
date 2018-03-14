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

/* TitleBar.vala - Title with back button */

using Grx;

namespace Gw {
    /**
     * Title bar widget that contains a label for a title and a back button.
     */
    public class TitleBar : HBox {
        Button back_button;
        Label title_label;

        construct {
            v_align = WidgetAlign.START;
            border_bottom = 1;

            back_button = new Button.with_icon ("arrow-left") {
                h_align = WidgetAlign.START,
                border = 0,
                border_radius = 0,
                border_right = 1,
                margin = 0
            };
            back_button.pressed.connect (handle_back_button_pressed);
            add (back_button);
    
            title_label = new Label () {
                margin_bottom = 4,
                margin_left = 4,
                text_h_align = TextHAlign.LEFT
            };
            add (title_label);
        }

        /**
         * Creates a new title bar with the given title text.
         *
         * @title: the text to display
         */
        public TitleBar (string title) {
            title_label.text = title;
        }

        void handle_back_button_pressed () {
            window.close ();
        }
    }
}