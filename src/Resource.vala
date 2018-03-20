/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2015,2018 David Lechner <david@lechnology.com>
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

/* Resource.vala - Namespace to global resources */

using Grx;

/**
 * Namespace for getting common fonts.
 */
namespace Gw.Resource {
    Color blue;
    Font default_font;
    Font small_font;
    Font big_font;

    /**
     * Gets the global foreground color.
     */
    public Color get_fg_color () {
        return Color.BLACK;
    }

    /**
     * Gets the global background color.
     */
    public Color get_bg_color () {
        return Color.WHITE;
    }

    /**
     * Gets the global selection highlight foreground color.
     */
    public Color get_select_fg_color () {
        return Color.WHITE;
    }

    /**
     * Gets the global selection highlight background color.
     */
    public Color get_select_bg_color () {
        if (blue == 0) {
            blue = Color.@get (0, 0, 255);
        }
        return blue;
    }

    /**
     * Gets the default font.
     */
    public unowned Font get_default_font () {
        if (default_font == null) {
            try {
                default_font = Font.load ("fixed sans", 8);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }
        return default_font;
    }

    /**
     * Gets the small font.
     */
    public unowned Font get_small_font () {
        if (small_font == null) {
            try {
                small_font = Font.load ("fixed sans", 6);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }
        return small_font;
    }

    /**
     * Gets the big font.
     */
    public unowned Font get_big_font () {
        if (big_font == null) {
            try {
                big_font = Font.load ("fixed sans", 10);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }
        return big_font;
    }
}
