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

/* MessageDialog.vala - Dialog that displays message to user */

using Grx;

namespace Gw {
    /**
     * A dialog for displaying a message.
     *
     * The dialog contains a title and message separated by a horizontal line.
     */
    public class MessageDialog : Gw.Dialog {
        Scroll vscroll;
        Label title_label;

        construct {
            var content_vbox = new Box.vertical ();
            add (content_vbox);
            title_label = new Label () {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            content_vbox.add (title_label);
            vscroll = new Scroll.vertical () {
                can_focus = false,
                margin_bottom = 9
            };
            content_vbox.add (vscroll);
        }

        /**
         * Creates a new message dialog.
         *
         * @param title The title text.
         * @param message The message text.
         */
        public MessageDialog (string title, string message) {
            vscroll.add (new Label (message));
            title_label.text = title;
        }

        /**
         * Creates a new message dialog with the given widget as content.
         *
         * @param title The title text.
         * @param content The content widget.
         */
        public MessageDialog.with_content (string title, Widget content) {
            vscroll.add (content);
            title_label.text = title;
        }

        /**
         * Default handler for the key_pressed signal.
         */
        public override bool key_pressed (uint key_code) {
            switch (key_code) {
            case Key.UP:
                vscroll.scroll_backward ();
                break;
            case Key.DOWN:
                vscroll.scroll_forward ();
                break;
            case Key.RETURN:
                return base.key_pressed (Key.BACK_SPACE);
            default:
                return base.key_pressed (key_code);
            }
            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }
    }
}
