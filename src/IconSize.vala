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

/* IconSize.vala - The preferred size of an icon */

namespace Gw {
    /**
     * Icon sizes.
     */
    public enum IconSize {
        /**
         * Small icons (16x16px@100dpi)
         */
        SMALL,

        /**
         * Medium icons (32x32px@100dpi)
         */
        MEDIUM,

        /**
         * Large icons for (64x64px@100dpi)
         */
        LARGE;

        /**
         * Gets the size in pixels, adjusted for the current display DPI.
         */
        public int get_pixels () {
            var dpi = Grx.get_dpi ();
            
            switch (this) {
            default:
                if (dpi >= 200) {
                    return 32;
                }
                if (dpi >= 175) {
                    return 28;
                }
                if (dpi >= 150) {
                    return 24;
                }
                if (dpi >= 125) {
                    return 20;
                }
                return 16;
            case MEDIUM:
                if (dpi >= 200) {
                    return 64;
                }
                if (dpi >= 175) {
                    return 56;
                }
                if (dpi >= 150) {
                    return 48;
                }
                if (dpi >= 125) {
                    return 40;
                }
                return 32;
            case LARGE:
                if (dpi >= 200) {
                    return 128;
                }
                if (dpi >= 175) {
                    return 112;
                }
                if (dpi >= 150) {
                    return 96;
                }
                if (dpi >= 125) {
                    return 80;
                }
                return 64;
            }
        }
    }
}
