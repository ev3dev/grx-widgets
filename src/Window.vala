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

/* Window.vala - Top level widget */

using Grx;

namespace Gw {
    /**
     * Top level widget for displaying other widgets on the {@link Screen}.
     *
     * All other widgets must be contained in a Window in order to be displayed
     * on the {@link Screen}. Windows are displayed in a stack. A new Window is
     * added to the stack by calling {@link show} and removed from the stack
     * by calling {@link close}. Only the top-most Window is visible to the user
     * and only that Window receives user input.
     */
    public class Window : Gw.Container {
        /*
         * A flag to defer emitting shown() after the window has been
         * layouted and drawn. This ensure that one can e.g. setup focused
         * widgets from a signal handler.
         */
        internal bool never_shown = true;

        /**
         * Gets the Screen that this Window is attached to.
         *
         * Returns ``null`` if the Window is not in the window stack of a Screen.
         */
        public weak Screen? screen { get; internal set; }

        /**
         * Returns true if the Window is currently displayed on the Screen.
         *
         * In other words, this Window is on top of the Window stack. Only one
         * Window and one Dialog can be ``on_screen`` at a time.
         */
        public bool on_screen { get; set; default = false; }

        /**
         * Emitted the first time this Window is shown on a Screen.
         */
        public virtual signal void shown () {
            if (!descendant_has_focus)
                focus_first ();
        }

        /**
         * Emitted when this window is closed (removed from the window stack).
         */
        public virtual signal void closed () {
        }

        construct {
            if (container_type != ContainerType.SINGLE) {
                critical ("Requires container_type == ContainerType.SINGLE.");
            }
            notify["on-screen"].connect (() => {
                if (never_shown) {
                    never_shown = false;
                    Idle.add (() => {
                        shown ();
                        return Source.REMOVE;
                    });
                }
            });
        }

        /**
         * Creates a new instance of a Window.
         */
        public Window () {
            Object (container_type: ContainerType.SINGLE);
        }

        /**
         * Default handler for the key_pressed signal.
         */
        internal override bool key_pressed (uint key_code) {
            switch (key_code) {
            case Key.UP:
            case Key.DOWN:
            case Key.LEFT:
            case Key.RIGHT:
                focus_first ();
                break;
            case Key.BACK_SPACE:
                // screen.close_window () can release the reference to this,
                // so don't do anything that references this after here.
                screen.close_window (this);
                break;
            default:
                return base.key_pressed (key_code);
            }
            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }

        /**
         * Make the window visible by putting it on top of the window stack of
         * the active screen.
         */
        public void show () {
            show_on_screen (Screen.active_screen);
        }

        /**
         * Make the window visible by putting it on top of the window stack.
         *
         * @param screen The screen to show the window on.
         */
        public void show_on_screen (Screen screen) {
            if (screen == null) {
                critical ("No active screen.");
                return;
            }
            screen.show_window (this);
        }

        /**
         * Remove the window from the window stack.
         *
         * If it was the top Window on the stack, the next window will become
         * visible.
         *
         * @return True if the window was removed.
         */
        public bool close () {
            if (_screen == null)
                return false;
            return _screen.close_window (this);
        }

        /**
         * {@inheritDoc}
         */
        public override void redraw () {
            if (_screen != null && on_screen)
                _screen.dirty = true;
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            set_bounds (0, _screen.window_y, _screen.width - 1,
                _screen.window_y + _screen.window_height - 1);
            base.do_layout ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_background () {
            var color = screen.bg_color;
            draw_filled_box (border_bounds.x1, border_bounds.y1, border_bounds.x2,
                border_bounds.y2, color);
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            base.draw_content ();
        }
    }
}
