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

/* Label.vala - Widget to display text */

using Grx;

namespace Gw {
    /**
     * Widget to display text.
     *
     * The text will be automatically wrapped if the parent Container is not
     * wide enough to fit the entire text value.
     */
    public class Label : Gw.Widget {
        TextOptions text_option;
        SList<string>? cached_lines;
        int last_width = 0;

        /**
         * Gets and sets the text displayed by this Label.
         */
        public string? text { get; set construct; }

        /**
         * Gets and sets the Font.
         */
        public unowned Font font {
            get { return text_option.font; }
            set { text_option.font = value; }
        }

        /**
         * Gets and sets the horizontal text alignment.
         */
        public TextHAlign text_h_align {
            get { return text_option.h_align; }
            set { text_option.h_align = value; }
        }

        /**
         * Gets and sets the vertical text alignment.
         */
        public TextVAlign text_v_align {
            get { return text_option.v_align; }
            set { text_option.v_align = value; }
        }

        construct {
            text_option = new TextOptions (
                Fonts.get_default (),
                Color.BLACK,
                Color.NONE,
                TextHAlign.CENTER,
                TextVAlign.MIDDLE
            );
            notify["text"].connect (invalidate_layout);
            notify["font"].connect (invalidate_layout);
            notify["text-horizontal-align"].connect (redraw);
            notify["text-vertical-align"].connect (redraw);
        }

        /**
         * Creates a new instance of a Label widget.
         *
         * @param text The text displayed by this Label.
         */
        public Label (string? text = null) {
            Object (text: text);
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width () ensures (result > 0) {
            return int.max(1, font.get_text_width (text ?? "")
                + get_margin_border_padding_width ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            return int.max(1, (int)font.height + get_margin_border_padding_height ());
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_width_for_height (int height)
            requires (height > 0) ensures (result > 0)
        {
            // TODO: create get_lines_for_height () method
            return get_preferred_width ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            unowned SList<string> lines = get_lines_for_width (width);
            return int.max(1, (int)font.height * (int)lines.length ()
                + get_margin_border_padding_height ());
        }

        unowned SList<string> get_lines_for_width (int width) requires (width > 0) {
            if (cached_lines != null && width == last_width)
                return cached_lines;
            cached_lines = new SList<string> ();
            if (text == null)
                return cached_lines;
            var hard_lines = text.split ("\n");
            foreach (var line in hard_lines)
                cached_lines.concat (get_substring_lines_for_width (line, width));

            return cached_lines;
        }

        SList<string> get_substring_lines_for_width (string substring, int width) {
            var lines = new SList<string> ();
            // if everything fits on one line...
            if (font.get_text_width (substring) <= width) {
                lines.append (substring);
                return lines;
            }
            // otherwise we have to spilt it into multiple lines
            var builder = new StringBuilder ();
            int i = 0;
            while (i < substring.length) {
                while (font.get_text_width (builder.str) < width) {
                    if (i == substring.length)
                        break;
                    builder.append_c (substring[i++]);
                }
                if (i < substring.length || font.get_text_width (builder.str) > width) {
                    var last_space_index = builder.str.last_index_of (" ");
                    if (last_space_index >= 0) {
                        i -= (int)builder.len;
                        builder.truncate (last_space_index);
                        i += last_space_index + 1;
                    } else if (builder.len > 1) {
                        builder.truncate (builder.len - 1);
                        i--;
                    }
                }
                lines.append (builder.str);
                builder.truncate ();
            }
            return lines;
        }

        /**
         * {@inheritDoc}
         */
        protected override void invalidate_layout ()
        {
            cached_lines = null;
            base.invalidate_layout ();
        }

        /**
         * {@inheritDoc}
         */
        protected override void draw_content () {
            if (_text == null)
                return;
            if (parent.draw_children_as_focused)
                text_option.fg_color = window.basis.select_fg_color;
            else
                text_option.fg_color = window.basis.fg_color;
            int x = 0;
            switch (text_h_align) {
            case TextHAlign.LEFT:
                x = content_bounds.x1;
                break;
            case TextHAlign.CENTER:
                x = content_bounds.x1 + content_bounds.get_width () / 2;
                break;
            case TextHAlign.RIGHT:
                x = content_bounds.x2;
                break;
            }
            unowned SList<string> lines = get_lines_for_width (content_bounds.get_width ());
            int y = 0;
            switch (text_v_align) {
            case TextVAlign.TOP:
                y = content_bounds.y1;
                break;
            case TextVAlign.MIDDLE:
                y = content_bounds.y1 + (content_bounds.get_height () + 1) / 2
                    - (int)font.height * ((int)lines.length () - 1) / 2;
                break;
            case TextVAlign.BOTTOM:
                y = content_bounds.y2;
                break;
            }
            foreach (var item in lines) {
                draw_text (item, x, y, text_option);
                y += (int)font.height;
            }
        }
    }
}
