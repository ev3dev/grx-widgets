/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014-2015,2017 David Lechner <david@lechnology.com>
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

/* Application.vala - Graphics mode console application */

using Grx;

/**
 * Library for building user interfaces on small screens (like the EV3 LCD).
 *
 * This library is modeled after GTK (and other modern UI toolkits). It uses
 * {@link Widget}s as the basic building blocks for building the user interface.
 * {@link Container}s are used to group and layout widgets. {@link Window}s are
 * the top-level Container and are displayed to the user using a {@link Screen}
 * that represents a physical screen.
 */
namespace Gw {
    /**
     * Does all of the low level setting up so you don't have to.
     *
     * To use it, your main function should look something like this:
     * {{{
     * static int main (string[] args) {
     *     try {
     *         var app = new Gw.Application ();
     *
     *         // Program-specific initialization goes here. It must include something
     *         // that calls Application.quit () when the program is finished.
     *
     *         var exit_code = Application.run (args);
     *
     *         // Any additional cleanup needed before application exits goes here.
     *
     *         return exit_code;
     *     } catch (Error err) {
     *         critical ("%s", err.message);
     *         return 1;
     *     }
     * }
     * }}}
     */
    public class Application : Grx.Application {
        //  Screen _screen;

        //  /**
        //   * Gets the screen for this application.
        //   */
        //  public Screen screen { get { return _screen; } }

        public Application () throws GLib.Error {
            Object ();
            init ();
            //  _screen = new Screen ();
            //  _screen.refresh.connect (() => {
            //      if (!is_active) {
            //          // Don't update to screen if app is not active
            //          Signal.stop_emission_by_name (_screen, "refresh");
            //      }
            //  });
        }

        public override void startup () {
            base.startup ();
            hold ();
        }

        public override bool event (Grx.Event event) {
            if (base.event (event)) {
                return true;
            }
            switch (event.type) {
            case Grx.EventType.KEY_DOWN:
                //  _screen.queue_key_code (event.key.keysym);
                var keychar = event.keychar.to_string ();
                message ("key down: %d, %s", event.keysym, keychar);
                break;
            case Grx.EventType.KEY_UP:
                //  _screen.queue_key_code (event.key.keysym);
                var keychar = event.keychar.to_string ();
                message ("key up: %d, %s", event.keysym, keychar);
                break;
            case Grx.EventType.BUTTON_PRESS:
                int x, y;
                event.get_coords (out x, out y);
                message ("button press: %d, %d", x, y);
                //  var widget = _screen.get_widget_at (x, y);
                //  if (widget != null) {
                //      widget.button_pressed (event.button);
                //  }
                break;
            case Grx.EventType.BUTTON_RELEASE:
                int x, y;
                event.get_coords (out x, out y);
                message ("button release: %d, %d", x, y);
                //  var widget = _screen.get_widget_at (x, y);
                //  // FIXME: this should trigger an event on the widget
                //  if (widget != null) {
                //      widget.button_released (event.button);
                //  }
                break;
            default:
                return false;
            }

            return true;
        }
    }
}
