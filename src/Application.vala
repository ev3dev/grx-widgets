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
        Basis _basis;

        public Basis basis { get { return _basis; } }

        public Application () throws GLib.Error {
            Object ();
            init ();
            _basis = new Basis ();
        }

        public override void startup () {
            base.startup ();
            hold ();
            notify["is-active"].connect ((s, p) => _basis.redraw ());
        }

        public override bool event (Event event) {
            // handle APP_* events and ignore events when app is not active
            if (base.event (event)) {
                return true;
            }

           return _basis.do_event (event);
        }
    }
}
