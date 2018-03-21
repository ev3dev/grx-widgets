/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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
     * Container for laying out widgets vertically.
     *
     * A {@link VBox} with 3 children might look like this:
     *
     * {{{
     * +-----+
     * |  1  |
     * +-----+
     * |  2  |
     * +-----+
     * |     |
     * |  3  |
     * |     |
     * +-----+
     * }}}
     */
    public class VBox : Gw.Container {
        HashTable<weak Widget, int> _height_map = new HashTable<weak Widget, int> (null, null);

        /**
         * Gets and sets the spacing in pixels between the widgets in the {@link VBox}.
         *
         * Default value is 2 pixels.
         */
        public int spacing { get; set; default = 2; }

        construct {
            warn_if_fail (container_type == ContainerType.MULTIPLE);
            notify["spacing"].connect (redraw);
        }

        /**
         * Create a new instance of {@link VBox}.
         */
        public VBox () {
            Object (container_type: ContainerType.MULTIPLE);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            int width = 0;
            foreach (var item in _children) {
                width = int.max (width, item.get_preferred_width ());
            }
            return int.max (1, width + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            int height = 0;
            foreach (var item in _children) {
                height += item.get_preferred_height () + spacing;
            }
            height -= spacing;
            return int.max (1, height + get_margin_border_padding_height ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0)  ensures (result > 0)
        {
            int width = 0;
            var height_map = get_child_heights (get_preferred_width () - get_margin_border_padding_width (),
                height - get_margin_border_padding_height ());
            foreach (var item in _children) {
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
            foreach (var item in _children) {
                height += item.get_preferred_height_for_width (width - get_margin_border_padding_width ()) + spacing;
            }
            height -= spacing;
            return int.max (1, height + get_margin_border_padding_height ());
        }

        HashTable<weak Widget, int> get_child_heights (int container_width, int container_height) {
            int total_height = 0;
            int fill_count = 0;
            _height_map.remove_all ();
            foreach (var child in _children) {
                _height_map[child] = child.get_preferred_height_for_width (content_bounds.get_width ());
                total_height += _height_map[child];
                total_height += spacing;
                if (child.v_align == WidgetAlign.FILL) {
                    fill_count++;
                }
            }
            total_height -= spacing;
            var extra_space = content_bounds.get_height () - total_height;
            foreach (var child in _children) {
                if (fill_count > 0 && child.v_align == WidgetAlign.FILL) {
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
        protected override void layout () {
            var y = content_bounds.y1;
            var height_map = get_child_heights (content_bounds.get_width (), content_bounds.get_height ());
            foreach (var child in _children) {
                set_child_bounds (child, content_bounds.x1, y,
                    content_bounds.x2, y + height_map[child] - 1);
                y += height_map[child] + spacing;
                child.layout ();
            }
        }

        /**
         * {@inheritDoc}
         */
        public override bool key_released (KeyEvent event) {
            switch (event.keysym) {
            case Key.UP:
            case Key.KP_UP:
                if (focus_prev ()) {
                    Signal.stop_emission_by_name (this, "key-released");
                    return true;
                }
                break;
            case Key.DOWN:
            case Key.KP_DOWN:
                if (focus_next ()) {
                    Signal.stop_emission_by_name (this, "key-released");
                    return true;
                }
                break;
            }

            return base.key_released (event);
        }
    }
}
