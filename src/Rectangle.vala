/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
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

/* Rectangle.vala - Struct for rectangles */

namespace Gw {
    /**
     * The bounds of a rectangle.
     */
    public struct Rectangle {
        /**
         * The leftmost x-axis value.
         */
        public int x1;

        /**
         * The topmost y-axis value.
         */
        public int y1;

        /**
         * The rightmost x-axis value.
         */
        public int x2;

        /**
         * The bottommost y-axis value.
         */
        public int y2;

        /**
         * Gets the width of the rectangle.
         */
        public int width { get { return x2 - x1 + 1; } }

        /**
         * Gets the height of the rectangle.
         */
        public int height { get { return y2 - y1 + 1; } }
    }
}