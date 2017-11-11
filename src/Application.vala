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
     *         var ret = Application.run (args);
     *
     *         // Any additional cleanup needed before application exits goes here.
     *
     *         return ret;
     *     } catch (Error err) {
     *         critical ("%s", err.message);
     *         return 1;
     *     }
     * }
     * }}}
     */
    public class Application : Grx.Application {
        public Application () throws GLib.Error {
            Object ();
            init ();
            Screen.active_screen = new Screen ();
            notify["is-active"].connect ((s, p) => {
                Screen.can_draw = is_active;
            });
        }

        public override bool event (Grx.Event event) {
            if (base.event (event)) {
                return true;
            }
            if (event.type == Grx.EventType.KEY_DOWN) {
                Screen.active_screen.queue_key_code (event.key.keysym);
                return true;
            }
            return false;
        }
    }
}
