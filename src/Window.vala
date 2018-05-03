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
        string? title;
        ulong notify_on_top_id;

        protected TitleBar? title_bar;

        /**
         * Gets the {@link Basis} that this Window is attached to.
         *
         * Returns ``null`` if the Window is not associated with {@link Basis}
         */
        public Basis? basis { get; internal set; }

        /**
         * Returns true if the Window is currently displayed.
         *
         * In other words, this Window is on top of the window stack. Only one
         * Window and one Dialog can be ``on-top`` at a time.
         */
        public bool on_top { get; set; default = false; }

        /**
         * Construct-only property to optionally create a title bar during
         * initialization.
         */
        public string create_title_bar { construct { title = value; } }

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
            warn_if_fail (container_type == ContainerType.SINGLE);
            notify_on_top_id = notify["on-top"].connect (handle_on_top);

            if (title != null) {
                var vbox = new VBox ();
                add (vbox);
    
                title_bar = new TitleBar (title);
                vbox.add (title_bar);
    
                key_pressed.connect (handle_key_pressed);
            }
        }

        /**
         * Creates a new instance of a Window.
         */
        public Window () {
            Object (container_type: ContainerType.SINGLE);
        }

        /**
         * Creates a new Window with a title bar.
         *
         * Additional key bindings are added to close the window via the
         * {@link TitleBar}.
         *
         * The {@link child} will be populated a {@link VBox} containing a
         * {@link TitleBar}. The window content should be added to this
         * {@link VBox}. Attempting to use the usual {@link add} method
         * on the {@link Window} directly will remove the {@link VBox} and
         * the {@link TitleBar}.
         */
        public Window.with_title_bar (string title) {
            Object (container_type: ContainerType.SINGLE, create_title_bar: title);
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
        public override void invalidate_layout () {
            if (_basis != null && on_top) {
                _basis.invalidate_layout ();
            }
        }

        /**
         * {@inheritDoc}
         */
        public override void redraw () {
            if (_basis != null && on_top) {
                _basis.redraw ();
            }
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
            var color = Resource.get_bg_color ();
            draw_filled_box (border_bounds.x1, border_bounds.y1, border_bounds.x2,
                border_bounds.y2, color);
        }

        internal void do_layout () {
            layout ();
        }

        internal void do_draw () {
            draw ();
        }

        void handle_on_top () {
            if (on_top && never_shown) {
                never_shown = false;
                Idle.add (() => {
                    shown ();
                    return Source.REMOVE;
                });
                disconnect (notify_on_top_id);
            }
        }

        bool handle_key_pressed (KeyEvent event) {
            // this list should match TitleBar.handle_back_button_key_released()
            switch (event.keysym) {
            case Key.BACK_SPACE:
            case Key.ESCAPE:
            case Key.LEFT:
            case Key.KP_LEFT:
                title_bar.focus_first ();
                break;
            default:
                return false;
            }
            Signal.stop_emission_by_name (this, "key-pressed");
            return true;
        }
    }
}
