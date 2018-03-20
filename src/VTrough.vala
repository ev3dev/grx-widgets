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

 using Grx;

namespace Gw {
    /**
     * The trough component of a VScrollBar.
     */
    public class VTrough : Gw.Container {
        construct {
            if (container_type != ContainerType.SINGLE) {
                critical ("Requires container_type == ContainerType.SINGLE.");
            }

            // TODO: add thumb button
        }

        /**
         * Creates a new vertical trough.
         */
        public VTrough () {
            Object (container_type: ContainerType.SINGLE);
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            var fg_color = has_focus ? Resource.get_select_fg_color () : Resource.get_fg_color ();
            var bg_color = has_focus ? Resource.get_select_bg_color () : Resource.get_bg_color ();

            draw_filled_box (content_bounds.x1, content_bounds.y1,
                content_bounds.x2, content_bounds.y2, bg_color);
            draw_box (content_bounds.x1, content_bounds.y1,
                content_bounds.x2, content_bounds.y2, fg_color);

            if (child != null) {
                child.draw ();
            }
        }
    }
}
