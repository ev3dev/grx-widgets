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

/* Box.vala - {@link Container} for displaying widgets horizontally or vertically */

using Grx;

namespace Gw {
    /**
     * Container for laying out widgets horizontally.
     *
     * An {@link HBox} with 3 children might look like this:
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
     * then the last widget will be stretched to fill the remaining space.
     */
    public class HBox : Gw.Container {
        HashTable<weak Widget, int> _width_map = new HashTable<weak Widget, int> (null, null);

        /**
         * Gets and sets the spacing in pixels between the widgets in the {@link HBox}.
         *
         * Default value is 2 pixels.
         */
        public int spacing { get; set; default = 2; }

        construct {
            if (container_type != ContainerType.MULTIPLE) {
                critical ("Requires container_type == ContainerType.MULTIPLE.");
            }
            notify["spacing"].connect (invalidate_layout);
        }

        /**
         * Create a new instance of {@link HBox}.
         */
        public HBox () {
            Object (container_type: ContainerType.MULTIPLE);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            int width = 0;
            foreach (var item in _children) {
                width += item.get_preferred_width () + spacing;
            }
            width -= spacing;
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            int height = 0;
            foreach (var item in _children) {
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
            foreach (var item in _children) {
                width += item.get_preferred_width_for_height (height - get_margin_border_padding_height ()) + spacing;
            }
            width -= spacing;
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            int height = 0;
            var width_map = get_child_widths (width - get_margin_border_padding_width (),
                get_preferred_height () - get_margin_border_padding_height ());
            foreach (var item in _children) {
                height = int.max (height, item.get_preferred_height_for_width (width_map[item]));
            }
            return int.max (1, height + get_margin_border_padding_height ());
        }

        HashTable<weak Widget,int> get_child_widths (int container_width, int container_height) {
            int total_width = 0;
            int fill_count = 0;
            _width_map.remove_all ();
            foreach (var child in _children) {
                _width_map[child] = child.get_preferred_width_for_height (container_height);
                total_width += _width_map[child];
                total_width += spacing;
                if (child.horizontal_align == WidgetAlign.FILL) {
                    fill_count++;
                }
            }
            total_width -= spacing;
            var extra_space = container_width - total_width;
            foreach (var child in _children) {
               if (fill_count > 0 && child.horizontal_align == WidgetAlign.FILL) {
                    var fill_width = extra_space / fill_count;
                    _width_map[child] = _width_map[child] + fill_width; // += does not work!
                    extra_space -= fill_width;
                    fill_count--;
                }
                _width_map[child] = int.max (_width_map[child], 1);
            }
            return _width_map;
        }

        /**
         * {@inheritDoc}
         */
        protected override void layout () {
            var x = content_bounds.x1;
            var width_map = get_child_widths (content_bounds.get_width (), content_bounds.get_height ());
            foreach (var child in _children) {
                set_child_bounds (child, x, content_bounds.y1,
                    x + width_map[child] - 1, content_bounds.y2);
                x += width_map[child] + spacing;
            }
        }
    }
}
