/*
 * GRX Widgets - Widget toolkit for small displays
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* ConsoleApp.vala - Graphics mode console application */

/**
 * Toolkit for developing applications for small screens.
 */
namespace Gw {
    /**
     * Does all of the low level setting up of a virtual console so you don't
     * have to.
     *
     * To use it, your main function should look something like this:
     * {{{
     * using Ev3devKit;
     *
     * static int main (string[] args) {
     *     try {
     *         ConsoleApp.init ();
     *
     *         // Program-specific initialization goes here. It must include something
     *         // that calls ConsoleApp.quit () when the program is finished.
     *
     *         ConsoleApp.run ();
     *
     *         // Any additional cleanup needed before application exits goes here.
     *
     *         return 0;
     *     } catch (ConsoleAppError err) {
     *         critical ("%s", err.message);
     *         return 1;
     *     }
     * }
     * }}}
     */
    public class ConsoleApp : Grx.Application {
        public ConsoleApp () throws GLib.Error {
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
