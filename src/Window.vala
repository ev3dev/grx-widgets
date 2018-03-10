/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014,2017-2018 David Lechner <david@lechnology.com>
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
     * Top level widget for displaying other widgets on the {@link basis}.
     *
     * All other widgets must be contained in a Window in order to be displayed
     * on the {@link basis}. Windows are displayed in a stack. A new Window is
     * added to the stack by calling {@link show} and removed from the stack
     * by calling {@link close}. Only the top-most Window is visible to the user
     * and only that Window receives user input.
     */
    public class Window : Gw.Container {
        /*
         * A flag to defer emitting shown() after the window has been laid out
         * and drawn. This ensures that one can e.g. setup focused widgets
         * from a signal handler.
         */
        bool never_shown = true;

        /**
         * Gets the {@link Basis} that this Window is attached to.
         *
         * Returns ``null`` if the Window is not associated with {@link Basis}
         */
        public weak Basis? basis { get; internal set; }

        /**
         * Returns true if the Window is currently displayed.
         *
         * In other words, this Window is on top of the window stack. Only one
         * Window and one Dialog can be ``on-top`` at a time.
         */
        public bool on_top { get; set; default = false; }

        /**
         * Emitted the first time this window is shown.
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
            notify["on-top"].connect (() => {
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
         * Remove the window from the window stack.
         *
         * If it was the top Window on the stack, the next window will become
         * visible.
         *
         * @return True if the window was removed.
         */
        public bool close () {
            if (_basis == null)
                return false;
            return _basis.close_window (this);
        }

        /**
         * {@inheritDoc}
         */
        public override void redraw () {
            if (_basis != null && on_top)
                _basis.redraw ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void layout () {
            set_bounds (0, 0, get_max_x (), get_max_y ());
            base.layout ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_background () {
            var color = basis.bg_color;
            draw_filled_box (border_bounds.x1, border_bounds.y1, border_bounds.x2,
                border_bounds.y2, color);
        }

        internal void do_layout () {
            layout ();
        }

        internal void do_draw () {
            draw ();
        }
    }
}
