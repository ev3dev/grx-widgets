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

/* Image.vala - Widget to display an image */

using Grx;

namespace Gw {

    /**
     * Widget to display an image.
     */
    public class Image : Gw.Widget {
        static HashTable<string, Context> cache = new HashTable<string, Context> (str_hash, str_equal);

        Context context;

        /**
         * Creates a new image widget for the given icon name.
         *
         * @param name  The name of the icon to look up
         * @param size  The size of the icon
         *
         * Loads an icon scaled for the current DPI.
         *
         * If the icon is not found, a default icon will be used.
         */
        public Image.from_icon_name (string name, IconSize size) {
            var px = size.get_pixels ();
            // directory and file like: 16x16/name.png
            var file = "%ux%u%c%s.png".printf (px, px, Path.DIR_SEPARATOR, name);

            context = cache[file];
            if (context != null) {
                return;
            }

            var filename = Path.build_filename (Environment.get_user_data_dir (),
                DATA_DIR, "icons", file);

            if (!FileUtils.test (filename, FileTest.EXISTS)) {
                foreach (var dir in Environment.get_system_data_dirs ()) {
                    filename = Path.build_filename (dir, DATA_DIR, "icons", file);
                    if (FileUtils.test (filename, FileTest.EXISTS)) {
                        break;
                    }
                }
            }

            context = Context.@new (px, px);
            return_if_fail (context != null);

            try {
                context.load_from_png (filename);
            }
            catch {
                var current = save_current_context ();
                set_current_context (context);
                clear_context (Color.WHITE);
                draw_box (0, 0, context.max_x, context.max_y, Color.BLACK);
                draw_line (0, 0, context.max_x, context.max_y, Color.BLACK);
                draw_line (0, context.max_y, context.max_x, 0, Color.BLACK);
                set_current_context (current);
                warning ("could not load icon '%s'", name);
            }
            cache[file] = context;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            return context.width + get_margin_border_padding_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            return context.height + get_margin_border_padding_height ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            if (parent.draw_children_as_focused) {
                // invert the colors in the icon
                context.clear (Color.WHITE.to_xor_mode ());
                bit_blt (content_bounds.x1, content_bounds.y1, context, 0, 0,
                    context.max_x, context.max_y, Color.BLACK.to_image_mode ());
                // restore the colors in the icon
                context.clear (Color.WHITE.to_xor_mode ());
            } else {
                bit_blt (content_bounds.x1, content_bounds.y1, context, 0, 0,
                    context.max_x, context.max_y, Color.WHITE.to_image_mode ());
            }
        }
    }
}
