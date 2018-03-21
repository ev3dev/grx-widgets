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

using Grx;

namespace Gw {
    /**
     * The trough component of a VScrollBar.
     */
    public class VScrollBar : Gw.VBox {
        Button _up_button;
        VTrough trough;
        Button _down_button;

        public Button up_button { get { return _up_button; } }

        public Button down_button { get { return _down_button; } }

        construct {
            _up_button = new Button.with_icon ("arrow-up") {
                v_align = WidgetAlign.START,
                border_radius = 0,
                margin = 0
            };
            add (_up_button);

            trough = new VTrough () {
                v_align = WidgetAlign.FILL
            };
            add (trough);

            _down_button = new Button.with_icon ("arrow-down") {
                v_align = WidgetAlign.END,
                border_radius = 0,
                margin = 0
            };
            add (_down_button);
        }

        /**
         * Creates a new vertical scroll bar.
         */
        public VScrollBar () {
            Object (container_type: ContainerType.MULTIPLE);
        }
    }
}
