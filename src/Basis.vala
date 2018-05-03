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
        int last_touch_x;
        int last_touch_y;

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
            status_bar_context = Context.new_subcontext (0, 0, context.max_x, 0, context);
            if (status_bar_context == null) {
                critical ("Failed to create status bar subcontext for basis");
            }
        }

        /**
         * Handle an event
         */
        public bool do_event (Event event) {
            switch (event.type) {
            case EventType.KEY_DOWN:
                var widget = get_focused_widget ();
                if (widget != null) {
                    widget.key_pressed (event.key);
                }
                break;
            case EventType.KEY_UP:
                var widget = get_focused_widget ();
                if (widget != null) {
                    widget.key_released (event.key);
                }
                break;
            case EventType.BUTTON_PRESS:
                int x, y;
                event.get_coords (out x, out y);
                var widget = get_widget_at(x, y);
                if (widget != null) {
                    widget.button_pressed (event.button);
                }
                break;
            case EventType.BUTTON_RELEASE:
                int x, y;
                event.get_coords (out x, out y);
                var widget = get_widget_at(x, y);
                if (widget != null) {
                    widget.button_released (event.button);
                }
                break;
            case EventType.TOUCH_DOWN:
                event.get_coords (out last_touch_x, out last_touch_y);
                var widget = get_widget_at(last_touch_x, last_touch_y);
                if (widget != null) {
                    // convert to button event
                    ButtonEvent button_event = ButtonEvent() {
                        type = EventType.BUTTON_PRESS,
                        button = 1,
                        x = last_touch_x,
                        y = last_touch_y,
                        modifiers = event.touch.modifiers,
                        device = event.touch.device
                    };
                    widget.button_pressed (button_event);
                }
                break;
            case EventType.TOUCH_MOTION:
                // need to keep track of last position for TOUCH_UP event
                event.get_coords (out last_touch_x, out last_touch_y);
                break;
            case EventType.TOUCH_UP:
                // TOUCH_UP event coords x, y are always 0, 0 so we need to
                // use the saved values instead
                var widget = get_widget_at(last_touch_x, last_touch_y);
                if (widget != null) {
                    // convert to button event
                    ButtonEvent button_event = ButtonEvent() {
                        type = EventType.BUTTON_RELEASE,
                        button = 1,
                        x = last_touch_x,
                        y = last_touch_y,
                        modifiers = event.touch.modifiers,
                        device = event.touch.device
                    };
                    widget.button_released (button_event);
                }
                break;
            default:
                return false;
            }

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
            var window = window_stack.peek_head ();
            if (window != null) {
                set_current_context (window_context);

                if (!is_layout_valid) {
                    window.do_layout ();
                    is_layout_valid = true;
                }

                window.do_draw ();
            }

            unowned Context screen = get_screen_context ();
            var flags = Mouse.block (screen, 0, 0, context.max_x, context.max_y);
            screen.fast_bit_blt (0, 0, context, 0, 0, context.max_x, context.max_y);
            Mouse.unblock (flags);

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
            window.on_top = true;
            invalidate_layout ();
            window_added (window);
        }

        /**
         * Remove the window from the window stack.
         *
         * @param window The window to add to the stack.
         * @return True if the window was removed.
         */
        internal bool close_window (Window window) {
            // the last reference to window could be freed by pop_nth(), so
            // use a local variable to take a reference.
            var local_ref = window;

            var was_top_window = window_stack.peek_head () == window;
            var index = window_stack.index (window);
            if (index >= 0) {
                window_stack.pop_nth (index);
                window.basis = null;
                window.on_top = false;
                window.closed ();
                if (was_top_window && !window_stack.is_empty ()) {
                    window_stack.peek_head ().on_top = true;
                }
                invalidate_layout ();
                window_removed (window);
                return true;
            }

            // have to use local_ref to keep compiler from complaining
            local_ref = null;
            return false;
        }

        public signal void window_added (Window window);
        public signal void window_removed (Window window);

        Widget? get_focused_widget ()
        {
            var top_window = window_stack.peek_head ();
            if (top_window == null) {
                return null;
            }
            return top_window.get_focused_descendant ();
        }

        /**
         * Get the widget at the specified x/y coordinates.
         * 
         * @param x     The x coordinate
         * @param y     The y coordinate
         * @returns     The widget at the coordinate or ``null`` if there was
         *              no widget (e.g. x/y is in the status bar).
         */
        Widget? get_widget_at (int x, int y) requires (x >= 0 && x < context.width && y >= 0 && y < context.height) {
            y -= status_bar_context.height;
            if (y < 0) {
                // in the status bar
                return null;
            }
            var top_window = window_stack.peek_head ();
            if (top_window == null) {
                return null;
            }
            return top_window.recursive_get_widget_at (x, y);
        }
    }
}
