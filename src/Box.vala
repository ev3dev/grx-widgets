/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* Box.vala - {@link Container} for displaying widgets horizontally or vertically */

using Grx;

namespace Gw {

    /**
     * Specifies the number of children a container can have.
     */
    public enum BoxDirection {
        /**
         * The Box lays out widgets in a horizontal row.
         */
        HORIZONTAL,
        /**
         * The Box lays out widgets in a vertical column.
         */
        VERTICAL;
    }

    /**
     * Container for laying out widgets horizontally or vertically.
     *
     * A horizontal draw_box with 3 children might look like this:
     *
     * {{{
     * +-----+-----+----------------+
     * |     |     |                |
     * |  1  |  2  |       3        |
     * |     |     |                |
     * +-----+-----+----------------+
     * }}}
     *
     * If the last child Widget has ``horizontal_align == WidgetAlign.FILL``
     * and there are no {@link Spacer} child widgets, the last widget will be
     * stretched to fill the remaining space. Otherwise, the {@link Widget.horizontal_align}
     * property will have no effect.
     *
     * The {@link Widget.vertical_align} property can be used to position the
     * child widgets vertically. {@link WidgetAlign.START} will align the widget
     * to the top of the Box, {@link WidgetAlign.CENTER} will align it in the
     * middle of the Box, {@link WidgetAlign.END} will align it to the bottom of
     * the draw_box and {@link WidgetAlign.FILL} will use the entire height of the draw_box.
     *
     * Vertical boxes work similarly except the vertical and horizontal properties
     * are swapped.
     */
    public class Box : Gw.Container {
        HashTable<weak Widget, int> _width_map = new HashTable<weak Widget, int> (null, null);
        HashTable<weak Widget, int> _height_map = new HashTable<weak Widget, int> (null, null);

        /**
         * Gets the layout direction of the Box.
         */
        public BoxDirection direction { get; construct; }

        /**
         * Gets and sets the spacing in pixels between the widgets in the draw_box.
         *
         * Default value is 2 pixels.
         */
        public int spacing { get; set; default = 2; }

        /**
         * Create a new instance of Box.
         */
        construct {
            if (container_type != ContainerType.MULTIPLE)
                critical ("Requires container_type == ContainerType.MULTIPLE.");
             notify["spacing"].connect (redraw);
        }

        private Box (BoxDirection direction) {
            Object (container_type: ContainerType.MULTIPLE, direction: direction);
        }

        /**
         * Create a new instance of Box with widgets laid out vertically.
         */
        public Box.vertical () {
            this (BoxDirection.VERTICAL);
        }

        /**
         * Create a new instance of Box with widgets laid out horizontally.
         */
        public Box.horizontal () {
            this (BoxDirection.HORIZONTAL);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            int width = 0;
            if (direction == BoxDirection.HORIZONTAL) {
                foreach (var item in _children)
                    width += item.get_preferred_width () + spacing;
                width -= spacing;
            } else {
                foreach (var item in _children)
                    width = int.max (width, item.get_preferred_width ());
            }
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            int height = 0;
            if (direction == BoxDirection.VERTICAL) {
                foreach (var item in _children)
                    height += item.get_preferred_height () + spacing;
                height -= spacing;
            } else {
                foreach (var item in _children)
                    height = int.max (height, item.get_preferred_height ());
            }
            return int.max (1, height + get_margin_border_padding_height ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0)  ensures (result > 0)
        {
            int width = 0;
            if (direction == BoxDirection.HORIZONTAL) {
                foreach (var item in _children)
                    width += item.get_preferred_width_for_height (height - get_margin_border_padding_height ()) + spacing;
                width -= spacing;
            } else {
                var height_map = get_child_heights (get_preferred_width () - get_margin_border_padding_width (),
                    height - get_margin_border_padding_height ());
                foreach (var item in _children)
                    width = int.max (width, item.get_preferred_width_for_height (height_map[item]));
            }
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            int height = 0;
            if (direction == BoxDirection.VERTICAL) {
                foreach (var item in _children)
                    height += item.get_preferred_height_for_width (width - get_margin_border_padding_width ()) + spacing;
                height -= spacing;
            } else {
                var width_map = get_child_widths (width - get_margin_border_padding_width (),
                    get_preferred_height () - get_margin_border_padding_height ());
                foreach (var item in _children)
                    height = int.max (height, item.get_preferred_height_for_width (width_map[item]));
            }
            return int.max (1, height + get_margin_border_padding_height ());
        }

        HashTable<weak Widget,int> get_child_widths (int container_width, int container_height) {
            int total_width = 0;
            int spacer_count = 0;
            int fill_count = 0;
            _width_map.remove_all ();
            foreach (var child in _children) {
                _width_map[child] = child.get_preferred_width_for_height (container_height);
                total_width += _width_map[child];
                total_width += spacing;
                if (child is Spacer)
                    spacer_count++;
                else if (child.horizontal_align == WidgetAlign.FILL)
                    fill_count++;
            }
            total_width -= spacing;
            var extra_space = container_width - total_width;
            foreach (var child in _children) {
                if (spacer_count > 0 && extra_space > 0) {
                    if (child is Spacer) {
                        var spacer_width = extra_space / spacer_count;
                        _width_map[child] = spacer_width;
                        extra_space -= spacer_width;
                        spacer_count--;
                    }
                } else if (fill_count > 0 && child.horizontal_align == WidgetAlign.FILL) {
                    var fill_width = extra_space / fill_count;
                    _width_map[child] = _width_map[child] + fill_width; // += does not work!
                    extra_space -= fill_width;
                    fill_count--;
                }
                _width_map[child] = int.max (_width_map[child], 1);
            }
            return _width_map;
        }

        HashTable<weak Widget, int> get_child_heights (int container_width, int container_height) {
            int total_height = 0;
            int spacer_count = 0;
            int fill_count = 0;
            _height_map.remove_all ();
            foreach (var child in _children) {
                _height_map[child] = child.get_preferred_height_for_width (content_bounds.width);
                total_height += _height_map[child];
                total_height += spacing;
                if (child is Spacer)
                    spacer_count++;
                else if (child.vertical_align == WidgetAlign.FILL)
                    fill_count++;
            }
            total_height -= spacing;
            var extra_space = content_bounds.height - total_height;
            foreach (var child in _children) {
                if (spacer_count > 0 && extra_space > 0) {
                    if (child is Spacer) {
                        var spacer_height = extra_space / spacer_count;
                        _height_map[child] = spacer_height;
                        extra_space -= spacer_height;
                        spacer_count--;
                    }
                } else if (fill_count > 0 && child.vertical_align == WidgetAlign.FILL) {
                    var fill_height = extra_space / fill_count;
                    _height_map[child] = _height_map[child] + fill_height; // += does not work!
                    extra_space -= fill_height;
                    fill_count--;
                }
                _height_map[child] = int.max (_height_map[child], 1);
            }
            return _height_map;
        }

        /**
         * {@inheritDoc}
         */
        protected override void do_layout () {
            if (direction == BoxDirection.HORIZONTAL) {
                var x = content_bounds.x1;
                var width_map = get_child_widths (content_bounds.width, content_bounds.height);
                foreach (var child in _children) {
                    set_child_bounds (child, x, content_bounds.y1,
                        x + width_map[child] - 1, content_bounds.y2);
                    x += width_map[child] + spacing;
                }
            } else {
                var y = content_bounds.y1;
                var height_map = get_child_heights (content_bounds.width, content_bounds.height);
                foreach (var child in _children) {
                    set_child_bounds (child, content_bounds.x1, y,
                        content_bounds.x2, y + height_map[child] - 1);
                    y += height_map[child] + spacing;
                }
            }
        }
    }
}
