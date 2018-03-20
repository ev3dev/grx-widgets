/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014-2015,2018 David Lechner <david@lechnology.com>
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

/* Widget.vala - Base class for all widgets */

using Grx;

namespace Gw {
    /**
     * Used by {@link Widget.do_recursive_parent} and {@link Widget.do_recursive_children}
     * to traverse the widget tree.
     *
     * @param widget The current widget in the recursion.
     * @return ``null`` to continue the recursion or ``widget`` to stop the recursion.
     */
    public delegate Widget? WidgetFunc (Widget widget);

    /**
     * Specifies the direction to use for focusing the next widget.
     */
    public enum FocusDirection {
        /**
         * Focus the next widget above the current widget.
         */
        UP,
        /**
         * Focus the next widget below the current widget.
         */
        DOWN,
        /**
         * Focus the next widget to the left of the current widget.
         */
        LEFT,
        /**
         * Focus the next widget to the right of the current widget.
         */
        RIGHT;
    }

    /**
     * Specifies how a {@link Widget} should be laid out in a {@link Container}.
     */
    public enum WidgetAlign {
        /**
         * The widget should fill the entire container.
         */
        FILL,
        /**
         * The widget should be aligned to the start (top or left) of the container.
         */
        START,
        /**
         * The widget should be aligned to the center (middle) of the container.
         */
        CENTER,
        /**
         * The widget should be aligned to the end (bottom or right) of the container.
         */
        END;
    }

    /**
     * The base class for all UI components.
     *
     * Widgets are modeled after GTK (and other modern UI toolkits). Some of the
     * layout properties should also be familiar to those that use CSS.
     *
     * Each Widget is essentially three concentric rectangles.
     * {{{
     * +---------------------------------+
     * |             margin              |
     * |   +---------border----------+   |
     * |   |         padding         |   |
     * |   |   +-----------------+   |   |
     * |   |   |     content     |   |   |
     * |   |   +-----------------+   |   |
     * |   |                         |   |
     * |   +-------------------------+   |
     * |                                 |
     * +---------------------------------+
     * }}}
     *
     * The margin is used to control spacing between widgets. Nothing should
     * be drawn in the margin. The border is optional and can also have rounded
     * corners. The padding area should be filled with a background color unless
     * the widget is "transparent". The actual graphical representation of the
     * widget is drawn in the content area.
     *
     * Widgets also have a preferred width and height that is used to help
     * {@link Container}s layout child widgets. Widgets that can reflow their
     * contents, such as widgets displaying text, can also provide a preferred
     * width and height for a specified height or width respectively. A
     * Container will try to make each widget at least the requested size. It
     * may stretch the widget if needed but should not make it smaller that the
     * requested size. If a Container does not have enough room for each widget
     * to be at least the requested size, unexpected results my occur. In this
     * case, you should consider using a {@link Scroll} Container.
     */
    public abstract class Widget : Object {
        static int widget_count = 0;

        /* layout properties */

        /* bounding rectangles - set by parent container */

        /**
         * The outermost bounding rectangle.
         */
        protected Rectangle bounds;

        /**
         * The bounding rectangle for the border.
         */
        protected Rectangle border_bounds;

        /**
         * The bounding rectangle for the content area.
         */
        protected Rectangle content_bounds;

        /**
         * Gets and sets the top margin for the widget.
         */
        public int margin_top { get; set; default = 0; }

        /**
         * Gets and sets the bottom margin for the widget.
         */
        public int margin_bottom { get; set; default = 0; }

        /**
         * Gets and sets the left margin for the widget.
         */
        public int margin_left { get; set; default = 0; }

        /**
         * Gets and sets the right margin for the widget.
         */
        public int margin_right { get; set; default = 0; }

        /**
         * Sets all margins (top, bottom, left, right) for the widget.
         */
        public int margin {
            set {
                margin_top = value;
                margin_bottom = value;
                margin_left = value;
                margin_right = value;
            }
        }

        /**
         * Gets and sets the top border width for the widget.
         */
        public int border_top { get; set; default = 0; }

        /**
         * Gets and sets the bottom border width for the widget.
         */
        public int border_bottom { get; set; default = 0; }

        /**
         * Gets and sets the left border width for the widget.
         */
        public int border_left { get; set; default = 0; }

        /**
         * Gets and sets the right border width for the widget.
         */
        public int border_right { get; set; default = 0; }

        /**
         * Sets all border widths (top, bottom, left, right) for the widget.
         */
        public int border {
            set {
                border_top = value;
                border_bottom = value;
                border_left = value;
                border_right = value;
            }
        }

        /**
         * Gets and sets the border radius for the widget.
         */
        public int border_radius { get; set; default = 0; }

        /**
         * Gets and sets the top padding for the widget.
         */
        public int padding_top { get; set; default = 0; }

        /**
         * Gets and sets the bottom padding for the widget.
         */
        public int padding_bottom { get; set; default = 0; }

        /**
         * Gets and sets the left padding for the widget.
         */
        public int padding_left { get; set; default = 0; }

        /**
         * Gets and sets the right padding for the widget.
         */
        public int padding_right { get; set; default = 0; }

        /**
         * Sets all padding (top, bottom, left, right) for the widget.
         */
        public int padding {
            set {
                padding_top = value;
                padding_bottom = value;
                padding_left = value;
                padding_right = value;
            }
        }

        /**
         * Gets and sets the horizontal alignment for the widget.
         *
         * This is used by the parent container to help layout the widget.
         */
        public WidgetAlign h_align {
            get; set; default = WidgetAlign.FILL;
        }

        /**
         * Gets and sets the vertical alignment for the widget.
         *
         * This is used by the parent container to help layout the widget.
         */
        public WidgetAlign v_align {
            get; set; default = WidgetAlign.FILL;
        }

        /* navigation properties */

        /**
         * This widget can take the focus.
         *
         * Widgets must also be visible in order to take focus.
         */
        public bool can_focus { get; set; }

        /**
         * Gets and sets the focus of this widget.
         *
         * Setting ``has_focus`` has no effect if either {@link can_focus} or
         * {@link visible} is ``false``.
         */
        public bool has_focus { get; protected set; default = false; }

        /**
         * Gets the parent Container of this widget.
         *
         * Returns ``null`` if this widget has not been added to a Container.
         */
        public weak Container? parent { get; protected set; }

        /**
         * Gets the top level window for this widget.
         *
         * Returns ``null`` if this widget or none of its Container ancestors
         * have been added to a Window.
         */
        public Window? window {
            owned get {
                return do_recursive_parent ((widget) => {
                    return widget as Window;
                }) as Window;
            }
        }

        /* Other properties */

        /**
         * Gets and sets the visibility of this widget.
         *
         * When a widget is not visible, it still takes up the same amount of
         * space when the parent Container does its layout - it is just not
         * drawn.
         */
        public bool visible { get; set; default = true; }

        /**
         * Gets and sets a weak reference to a user-defined value.
         *
         * This can be used to attach arbitrary data to a widget.
         *
         * If the user data is an Object, then {@link represented_object} should
         * be used instead (so that it will increase the reference count).
         */
        public void *weak_represented_object { get; set; }

        /**
         * Gets and sets a reference to a user-defined Object.
         *
         * This can be used to attach arbitrary data to a widget.
         *
         * If you do not want this widget to have a reference to the Object, then
         * {@link weak_represented_object} should be used instead.
         */
        public Object? represented_object { get; set; }

        construct {
            notify["margin-top"].connect (invalidate_layout);
            notify["margin-bottom"].connect (invalidate_layout);
            notify["margin-left"].connect (invalidate_layout);
            notify["margin-right"].connect (invalidate_layout);
            notify["border-top"].connect (invalidate_layout);
            notify["border-bottom"].connect (invalidate_layout);
            notify["border-left"].connect (invalidate_layout);
            notify["border-right"].connect (invalidate_layout);
            notify["border-radius"].connect (invalidate_layout);
            notify["padding-top"].connect (invalidate_layout);
            notify["padding-bottom"].connect (invalidate_layout);
            notify["padding-left"].connect (invalidate_layout);
            notify["padding-right"].connect (invalidate_layout);
            notify["horizontal-align"].connect (redraw);
            notify["vertical-align"].connect (redraw);
            notify["visible"].connect (() => {
                if (parent != null) {
                    parent.redraw ();
                }
            });
            widget_count++;
            //debug ("Created %s widget: %p", get_type ().name (), this);
        }

        /**
         * Creates a new instance of a widget.
         */
        protected Widget () {
        }
/*
        ~Widget () {
            debug ("Finalized %s widget %p", get_type ().name (), this);
            debug ("Widget count %d", --widget_count);
        }
*/
        /* layout functions */

        /**
         * Gets the combined width of margins, borders and paddings.
         *
         * Specifically, it is the sum of the left and right margins, the left
         * and right borders and the left and right paddings. It does not
         * include the width of the content area.
         */
        public inline int get_margin_border_padding_width () {
            return _margin_left + _margin_right + _border_left
                + _border_right + _padding_left + _padding_right;
        }

        /**
         * Gets the combined height of margins, borders and paddings.
         *
         * Specifically, it is the sum of the top and bottom margins, the top
         * and bottom borders and the top and bottom paddings. It does not
         * include the width of the content area.
         */
        public inline int get_margin_border_padding_height () {
            return _margin_top + _margin_bottom + _border_top
                + _border_bottom + _padding_top + _padding_bottom;
        }

        /**
         * Gets the preferred width of the widget.
         *
         * This is used by the parent Container to help layout the widget.
         */
        protected virtual int get_preferred_width () ensures (result > 0) {
            return int.max (1, get_margin_border_padding_width ());
        }

        /**
         * Gets the preferred height of the widget.
         *
         * This is used by the parent Container to help layout the widget.
         */
        protected virtual int get_preferred_height () ensures (result > 0) {
            return int.max (1, get_margin_border_padding_height ());
        }

        /**
         * Gets the preferred width of the widget for the specified height.
         *
         * This is used by the parent Container to help layout the widget.
         *
         * @param height The height to be used by the widget.
         */
        protected virtual int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            return get_preferred_width ();
        }

        /**
         * Gets the preferred height of the widget for the specified width.
         *
         * This is used by the parent Container to help layout the widget.
         *
         * @param width The width to be used by the widget.
         */
        protected virtual int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            return get_preferred_height ();
        }

        /**
         * Called by the parent Container to layout this widget.
         */
        protected void set_bounds (int x1, int y1, int x2, int y2)
            requires (x1 <= x2 && y1 <= y2)
        {
            bounds.x1 = x1;
            bounds.y1 = y1;
            bounds.x2 = x2;
            bounds.y2 = y2;
            border_bounds.x1 = x1 + margin_left;
            border_bounds.y1 = y1 + margin_top;
            border_bounds.x2 = x2 - margin_right;
            border_bounds.y2 = y2 - margin_bottom;
            content_bounds.x1 = x1 + margin_left + border_left + padding_left;
            content_bounds.y1 = y1 + margin_top + border_top + padding_top;
            content_bounds.x2 = x2 - margin_right - border_right - padding_right;
            content_bounds.y2 = y2 - margin_bottom - border_bottom - padding_bottom;
        }

        /* navigation functions */

        /**
         * Focuses this widget.
         *
         * @return ``true`` if this widget {@link can_focus} and is {@link visible}
         * or ``false`` if this widget can't be focused.
         */
        public bool focus () {
            if (!can_focus) {
                return false;
            }

            // if this widget or any ancestor is not visible, then it can't be focused.
            var not_visible = do_recursive_parent ((widget) => {
                return widget.visible ? null : widget;
            });
            if (not_visible != null) {
                return false;
            }

            // at this point, we know we can focus this widget, so unfocus all
            // other widgets.
            if (window != null) {
                window.do_recursive_children ((widget) => {
                    widget.has_focus = false;
                    return null;
                });
            }

            has_focus = true;
            redraw ();

            return true;
        }

        /**
         * Searches this Widget and its children for the currently focused widget.
         *
         * @return The focused widget or ``null`` if no widget is focused.
         */
        public Widget? get_focused_descendant () {
            return do_recursive_children ((widget) => {
                if (widget.has_focus) {
                    return widget;
                }
                return null;
            });
        }

        /* tree traversal functions */

        /**
         * Run a function recursively over widget and all of its children.
         *
         * The recursion stops when ``func`` returns a non-null value.
         *
         * @param func The function to call for each recursion.
         * @param reverse If ``true`` containers with more than one child will
         * be iterated starting with the last child first.
         * @return The return value of the last call to ``func``.
         */
        public Widget? do_recursive_children (WidgetFunc func, bool reverse = false) {
            return do_recursive_children_internal (this, func, reverse);
        }

        static Widget? do_recursive_children_internal (
            Widget widget, WidgetFunc func, bool reverse)
        {
            var result = func (widget);
            if (result != null)
                return result;
            var container = widget as Container;
            if (container != null && container.children.first () != null) {
                unowned List<Widget> iter;
                if (reverse) {
                    iter = container.children.last ();
                    do {
                        result = do_recursive_children_internal (iter.data, func, reverse);
                        if (result != null) {
                            return result;
                        }
                    } while ((iter = iter.prev) != null);
                } else {
                    iter = container.children.first ();
                    do {
                        result = do_recursive_children_internal (iter.data, func, reverse);
                        if (result != null) {
                            return result;
                        }
                    } while ((iter = iter.next) != null);
                }
            }
            return null;
        }

        /**
         * Run a function recursively over widget and all of its ancestors.
         *
         * The recursion stops when ``func`` returns a non-null value.
         *
         * @param func The function to call for each recursion.
         * @return The return value of the last call to ``func``.
         */
        public Widget? do_recursive_parent (WidgetFunc func) {
            return do_recursive_parent_internal (this, func);
        }

        static Widget? do_recursive_parent_internal (
            Widget widget, WidgetFunc func)
        {
            var result = func (widget);
            if (result != null) {
                return result;
            }
            if (widget.parent != null) {
                return do_recursive_parent_internal (widget.parent, func);
            }
            return null;
        }

        internal Widget? recursive_get_widget_at (int x, int y) {
            var container = this as Container;
            if (container != null) {
                foreach (var child in container.children) {
                    var match = child.recursive_get_widget_at (x, y);
                    if (match != null) {
                        return match;
                    }
                }
            }
            if (x < border_bounds.x1 || x > border_bounds.x2) {
                return null;
            }
            if (y < border_bounds.y1 || y > border_bounds.y2) {
                return null;
            }
            return this;
        }


        /* drawing functions */

        /**
         * Invalidates the layout. The layout will be re-calculated the next
         * time the widget is drawn.
         */
        public virtual void invalidate_layout () {
            if (parent != null) {
                parent.invalidate_layout ();
            }
        }

        /**
         * Notifies that this widget has changed and needs to be redrawn.
         *
         * If this widget is displayed, the basis will be redrawn.
         */
        public virtual void redraw () {
            if (_visible && parent != null) {
                parent.redraw ();
            }
        }

        /**
         * Implementations should override this method if they need to handle
         * laying out its contents.
         *
         * Mostly just {@link Container}s need to do this.
         */
        protected virtual void layout () {
        }

        /**
         * Implementations can override this method if they need to have a
         * a background.
         *
         * Care should be taken to not draw in the margin area and should
         * respect the border radius.
         */
        protected virtual void draw_background () {
        }

        /**
         * Implementations should override this method.
         *
         * Care should be taken to not draw outside of the content area.
         */
        protected virtual void draw_content () {
        }

        /**
         * Implementations can override this if they need special handling for
         * the border.
         *
         * For example Grid also draws a border between rows and columns.
         */
        protected virtual void draw_border (Grx.Color color = Resource.get_fg_color ()) {
            if (border_top != 0) {
                draw_filled_box (border_bounds.x1 + border_radius, border_bounds.y1,
                    border_bounds.x2 - border_radius,
                    border_bounds.y1 + border_top - 1, color);
            }
            if (border_bottom != 0) {
                draw_filled_box (border_bounds.x1 + border_radius,
                    border_bounds.y2 - border_bottom + 1,
                    border_bounds.x2 - border_radius, border_bounds.y2, color);
            }
            if (border_left != 0) {
                draw_filled_box (border_bounds.x1, border_bounds.y1 + border_radius,
                    border_bounds.x1 + border_left- 1,
                    border_bounds.y2 - border_radius, color);
            }
            if (border_right != 0) {
                draw_filled_box (border_bounds.x2 - border_right + 1,
                    border_bounds.y1 + border_radius, border_bounds.x2,
                    border_bounds.y2 - border_radius, color);
            }
            if (border_radius != 0) {
                draw_circle_arc (border_bounds.x2 - border_radius,
                    border_bounds.y1 + border_radius, border_radius, 0, 900,
                    ArcStyle.OPEN, color);
                draw_circle_arc (border_bounds.x1 + border_radius,
                    border_bounds.y1 + border_radius, border_radius, 900, 1800,
                    ArcStyle.OPEN, color);
                draw_circle_arc (border_bounds.x1 + border_radius,
                    border_bounds.y2 - border_radius, border_radius, 1800, 2700,
                    ArcStyle.OPEN, color);
                draw_circle_arc (border_bounds.x2 - border_radius,
                    border_bounds.y2 - border_radius, border_radius, 2700, 3600,
                    ArcStyle.OPEN, color);
            }
        }

        /**
         * Draws the widget on the current context.
         */
        protected void draw () {
            if (!visible) {
                return;
            }

            int x1, y1, x2, y2;
            get_clip_box (out x1, out y1, out x2, out y2);
            if (bounds.x1 > x2 || bounds.y1 > y2 || bounds.x2 < x1 || bounds.y2 < y1) {
                return;
            }
            draw_background ();
            draw_content ();
            draw_border ();
        }

        /* input handling */

        /**
         * Emitted when a key is pressed.
         *
         * This event is propagated to all parent widgets until a signal handler
         * returns ``true`` to indicate that the key has been handled.
         *
         * Due to a shortcoming in vala, you currently also have to call
         * {{{
         * Signal.stop_emission_by_name (this, "key-pressed");
         * }}}
         * in addition to returning ``true``.
         */
        public virtual signal bool key_pressed (KeyEvent event) {
            if (parent != null) {
                return parent.key_pressed (event);
            }

            return false;
        }

        /**
         * Emitted when a key is released.
         *
         * This event is propagated to all parent widgets until a signal handler
         * returns ``true`` to indicate that the key has been handled.
         *
         * Due to a shortcoming in vala, you currently also have to call
         * {{{
         * Signal.stop_emission_by_name (this, "key-released");
         * }}}
         * in addition to returning ``true``.
         */
        public virtual signal bool key_released (KeyEvent event) {
            if (parent != null) {
                return parent.key_released (event);
            }

            return false;
        }

        /**
         * Emitted when a button is pressed.
         *
         * This event is propagated to all parent widgets until a signal handler
         * returns ``true`` to indicate that the key has been handled.
         *
         * Due to a shortcoming in vala, you currently also have to call
         * {{{
         * Signal.stop_emission_by_name (this, "button-pressed");
         * }}}
         * in addition to returning ``true``.
         */
        public virtual signal bool button_pressed (ButtonEvent event) {
            if (focus ()) {
                Signal.stop_emission_by_name (this, "button-pressed");
                return true;
            }

            if (parent != null) {
                return parent.button_pressed (event);
            }

            return false;
        }

        /**
         * Emitted when a button is released.
         *
         * This event is propagated to all parent widgets until a signal handler
         * returns ``true`` to indicate that the key has been handled.
         *
         * Due to a shortcoming in vala, you currently also have to call
         * {{{
         * Signal.stop_emission_by_name (this, "button-released");
         * }}}
         * in addition to returning ``true``.
         */
        public virtual signal bool button_released (ButtonEvent event) {
            if (parent != null) {
                return parent.button_released (event);
            }

            return false;
        }
    }
}
