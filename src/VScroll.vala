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

/* VScroll.vala - Container that can scroll vertically */

using Grx;

namespace Gw {
    /**
     * A scrollable container for displaying content that is too large to fit
     * on the screen.
     */
    public class VScroll : Gw.HBox {
        VBox _content_box;
        VScrollBar scroll_bar;
        int scroll_offset;

        /**
         * Gets the context box.
         *
         * Child widgets should be added to this instead of the {@link VScroll}
         * widget.
         */
        public VBox content_box { get { return _content_box; } }

        /**
         * Gets and sets the maximum preferred height for the content box.
         */
        public int max_preferred_height { get; set; default = 50; }

        /**
         * Gets and sets the default scroll distance in pixels used by
         * {@link scroll_forward} and {@link scroll_backward}.
         */
        public int scroll_amount { get; set; default = 16; }

        construct {
            _content_box = new VBox () {
                h_align = WidgetAlign.FILL
            };
            add (_content_box);
            scroll_bar = new VScrollBar () {
                h_align = WidgetAlign.END
            };
            scroll_bar.up_button.pressed.connect (() => scroll_up ());
            scroll_bar.down_button.pressed.connect (() => scroll_down ());
            add (scroll_bar);

            notify["max-preferred-height"].connect (invalidate_layout);
        }

        /**
         * Creates a new scroll area that scrolls vertically.
         */
        public VScroll () {
            Object (container_type: ContainerType.MULTIPLE);
        }

        /**
         * Scroll down by the specified amount.
         *
         * @param amount The amount to scroll in pixels.
         */
        public void scroll_down (int amount = scroll_amount) {
            scroll_offset += amount;
            invalidate_layout ();
        }

        /**
         * Scroll backwards up by the specified amount.
         *
         * @param amount The amount to scroll in pixels.
         */
        public void scroll_up (int amount = scroll_amount) {
            scroll_offset -= amount;
            invalidate_layout ();
        }

        /**
         * Ensure that a child widget is visible.
         *
         * @param child The child widget to scroll to.
         */
        public void scroll_to_child (Widget child) {
            // check if scroll has been laid out
            if (content_bounds.x1 == content_bounds.x2 || content_bounds.y1 == content_bounds.y2) {
                return;
            }

            // make sure this is really a child of this
            var found_child = _content_box.do_recursive_children ((widget) => {
                if (widget == child) {
                    return widget;
                }
                return null;
            });
            if (found_child == null) {
                return;
            }

            // make sure layout is up to date.
            _content_box.layout ();

            // Make sure that the whole widget is visible. If the widget is
            // larger than the visible area, prefer showing the top and left.
            if (_content_box.bounds.y2 > content_bounds.y2) {
                scroll_offset += _content_box.bounds.y2 - content_bounds.y2;
            }
            if (_content_box.bounds.y1 < content_bounds.y1) {
                scroll_offset += _content_box.bounds.y1 - content_bounds.y1;
            }
            invalidate_layout ();
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height () ensures (result > 0) {
            result = int.min (base.get_preferred_height (), _max_preferred_height);
            return result;
        }

        /**
         * {@inheritDoc}
         */
        protected override int get_preferred_height_for_width (int width)
            requires (width > 0) ensures (result > 0)
        {
            result = int.min (base.get_preferred_height_for_width (width), _max_preferred_height);
            return result;
        }

        protected override void layout () {
            var scroll_bar_width = scroll_bar.get_preferred_width ();
            var content_width = content_bounds.get_width () - scroll_bar_width;
            var content_height = content_box.get_preferred_height_for_width (content_width);

            scroll_offset = int.max (0, scroll_offset);
            scroll_offset = int.min (scroll_offset, content_height - content_bounds.get_height () + 1);
            var y = content_bounds.y1 - scroll_offset;

            set_child_bounds (content_box, content_bounds.x1, y,
                content_bounds.x2 - scroll_bar_width, y + content_height);
            content_box.layout ();
            set_child_bounds (scroll_bar, content_bounds.x2 - scroll_bar_width, content_bounds.y1,
                content_bounds.x2, content_bounds.y2);
            scroll_bar.layout ();
        }

        protected override void draw_content () {
            set_clip_box (content_bounds.x1, content_bounds.y1,
                content_bounds.x2 - scroll_bar.bounds.get_width (), content_bounds.y2);
            _content_box.draw ();
            reset_clip_box ();
            scroll_bar.draw ();
        }

        /**
         * {@inheritDoc}
         */
        public override bool key_released (KeyEvent event) {
            switch (event.keysym) {
            case Key.UP:
            case Key.KP_UP:
                scroll_up ();
                break;
            case Key.DOWN:
            case Key.KP_DOWN:
                scroll_down ();
                break;
            case Key.PAGE_UP:
            case Key.KP_PAGE_UP:
                scroll_up (scroll_amount * 3);
                break;
            case Key.PAGE_DOWN:
            case Key.KP_PAGE_DOWN:
                scroll_down (scroll_amount * 3);
                break;
            default:
                return base.key_released (event);
            }
            redraw ();
            Signal.stop_emission_by_name (this, "key-released");
            return true;
        }
    }
}
