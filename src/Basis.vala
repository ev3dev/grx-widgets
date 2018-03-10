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

/* Basis.vala - The basis for everything */

using Grx;

/**
 * Library for building user interfaces on small screens (like the LEGO
 * MINDSTORMS EV3 LCD).
 *
 * This library is modeled after GTK (and other modern UI toolkits). It uses
 * {@link Widget}s as the basic building blocks for building the user interface.
 * {@link Container}s are used to group and layout widgets. {@link Window}s are
 * the top-level Container and are displayed to the user using a {@link Screen}
 * that represents a physical screen.
 */
namespace Gw {
    /**
     * The basis class serves as a global context for GRX Widgets based
     * programs. It keeps track of shared information, like fonts and colors
     * and controls drawing and events for any displayed widgets.
     *
     * Note: the GRX3 library must be initialized before creating an instance
     * of {@link Basis}. If you are using {@link Application}, this is done
     * for you.
     */
    public class Basis : Object {
        Queue<Window> window_stack;
        Context context;
        Context window_context;
        Context status_bar_context;
        uint draw_timeout_id;
        bool is_layout_valid;
        bool is_clean;

        /**
         * Gets and sets the global foreground color.
         */
        public Color fg_color { get; set; default = Color.BLACK; }

        /**
         * Gets and sets the global background color.
         */
        public Color bg_color { get; set; default = Color.WHITE; }

        /**
         * Gets and sets the global selection highlight foreground color.
         */
        public Color select_fg_color { get; set; default = Color.WHITE; }

        /**
         * Gets and sets the global selection highlight background color.
         */
        public Color select_bg_color { get; set; default = Color.build_rgb (0, 0, 255); }

        construct {
            window_stack = new Queue<Window> ();
            context = Context.@new (get_screen_width (), get_screen_height ());
            if (context == null) {
                critical ("Failed to create context for basis");
            }
            window_context = Context.new_subcontext (0, 0, context.max_x, context.max_y, context);
            if (window_context == null) {
                critical ("Failed to create window subcontext for basis");
            }
            status_bar_context = Context.new_subcontext (0, 0, 0, context.max_y, context);
            if (status_bar_context == null) {
                critical ("Failed to create status bar subcontext for basis");
            }
        }

        /**
         * Handle an event
         */
        public bool do_event (Event event) {
            //  message ("%s", event.type.to_string ());
            return true;
        }

        /**
         * Flag the layout as invalid. The layout will be updated during the
         * next redraw.
         */
        public void invalidate_layout () {
            is_layout_valid = false;
            redraw ();
        }

        /**
         * Schedule a redraw where the widgets will be redrawn and updated
         * to the screen.
         */
        public void redraw () {
            is_clean = false;

            // rate-limit layout/draw
            if (draw_timeout_id != 0) {
                return;
            }

            draw_timeout_id = Timeout.add (50, do_redraw, Priority.HIGH);
        }

        bool do_redraw () {
            context.clear (bg_color);

            set_current_context (status_bar_context);
            // TODO: draw status bar

            var window = window_stack.peek_head ();
            if (window != null) {
                set_current_context (window_context);
                if (!is_layout_valid) {
                    window.do_layout ();
                    is_layout_valid = true;
                }

                window.do_draw ();
            }

            get_screen_context ().fast_bit_blt (0, 0, context, 0, 0, context.width, context.height);
            is_clean = true;

            draw_timeout_id = 0;

            return Source.REMOVE;
        }

        /**
         * Put window on top of visible window stack.
         *
         * @param window The window to add to the stack.
         */
        public void show_window (Window window) {
            if (window.basis != null) {
                window.basis.close_window (window);
            }
            window.basis = this;
            window_stack.push_head (window);
            invalidate_layout ();
        }

        /**
         * Remove the window from the window stack.
         *
         * @param window The window to add to the stack.
         * @return True if the window was removed.
         */
        internal bool close_window (Window window) {
            var was_top_window = window_stack.peek_head () == window;
            var index = window_stack.index (window);
            if (index >= 0) {
                window_stack.pop_nth (index);
                if (window.ref_count > 0) {
                    window.basis = null;
                    window.on_top = false;
                    window.closed ();
                }
                if (was_top_window && !window_stack.is_empty ()) {
                    window_stack.peek_head ().shown ();
                }
                invalidate_layout ();
                return true;
            }
            return false;
        }
    }
}
