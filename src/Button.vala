/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014,2018 David Lechner <david@lechnology.com>
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

/* Button.vala - Widget that represents a selectable button */

using Grx;

namespace Gw {
    /**
     * Button shaped {@link Container} to get user input.
     *
     * The colors of a button (except for the border) are inverted when it has
     * focus. Pressing ``ENTER`` will trigger the {@link pressed} signal.
     */
    public class Button : Gw.Container {
        /**
         * Emitted when the Button has been pressed by the user.
         */
        public signal void pressed ();

        construct {
            if (container_type != ContainerType.SINGLE) {
                critical ("Requires container_type == ContainerType.SINGLE");
            }
            border = 1;
            border_radius = 3;
            padding = 2;
            can_focus = true;
        }

        /**
         * Creates a new Button.
         *
         * @param child The child for the button {@link Container}.
         */
        public Button (Widget? child = null) {
            Object (container_type: ContainerType.SINGLE);
            if (child != null) {
                add (child);
            }
        }

        /**
         * Creates a new Button with a {@link Label} as the child.
         *
         * @param text The text for the {@link Label}.
         * @param font The font to use for the widget or ``null`` to use the
         * default font.
         */
        public Button.with_label (string? text = null, Font? font = null) {
            this (new Label (text) {
                margin_left = 3,
                margin_right = 3,
                font = font ?? Fonts.get_default ()
            });
        }

        /**
         * Creates a new Button with a {@link Image} as the child.
         *
         * @param icon_name The name of the icon
         */
        public Button.with_icon (string icon_name) {
            this (new Image.from_icon_name (icon_name, IconSize.SMALL));
        }

        /**
         * {@inheritDoc}
         */
        protected override bool draw_children_as_focused {
            get {
                if (has_focus) {
                    return true;
                }
                return base.draw_children_as_focused;
            }
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_background () {
            if (draw_children_as_focused) {
                var color = window.basis.select_bg_color;
                draw_filled_rounded_box (border_bounds.x1, border_bounds.y1,
                    border_bounds.x2, border_bounds.y2, border_radius, color);
            }
        }

        /**
         * Default handler for the key_pressed signal.
         */
        internal override bool key_pressed (KeyEvent event) {
            switch (event.keysym) {
            case Key.RETURN:
            case Key.SPACE:
            case Key.KP_ENTER:
                pressed ();
                break;
            default:
                return base.key_pressed (event);
            }

            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }

        /**
         * {@inheritDoc}
         */
        public override bool button_pressed (ButtonEvent event) {
            switch (event.button) {
            case 1:
                focus ();
                break;
            default:
                return false;
            }

            Signal.stop_emission_by_name (this, "button-pressed");
            return true;
        }

        /**
         * {@inheritDoc}
         */
        public override bool button_released (ButtonEvent event) {
            switch (event.button) {
                case 1:
                    if (has_focus) {
                        pressed ();
                    }
                    break;
                default:
                    return false;
                }

                Signal.stop_emission_by_name (this, "button-released");
                return true;
        }
    }
}
