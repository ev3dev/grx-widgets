#!/usr/bin/env python3

import sys

import gi

gi.require_version('GLib', '2.0')
from gi.repository import GLib
gi.require_version('GObject', '2.0')
from gi.repository import GObject
gi.require_version('Grx', '3.0')
from gi.repository import Grx
gi.require_version('Gw', '0.1')
from gi.repository import Gw


class DemoWindow(Gw.Window):
    def __init__(self):
        super(Gw.Window, self).__init__()

        vbox = Gw.VBox.new()
        self.add(vbox)

        label = Gw.Label.new('hello world!')
        vbox.add(label)

        button1 = Gw.Button.with_label('Click me!')
        button1.set_margin(3)
        button1.connect('pressed', lambda _: print('button1 pressed'))
        vbox.add(button1)

        button2 = Gw.Button.with_label('Click me too!')
        button2.set_margin(3)
        button2.connect('pressed', lambda _: print('button2 pressed'))
        vbox.add(button2)


def on_activate(app):
    window = DemoWindow()
    app.get_basis().show_window(window)


def main():
    GLib.set_application_name('demo.py')
    GLib.set_prgname('demo.py')
    app = Gw.Application.new()
    app.connect('activate', on_activate)
    exit_code = app.run(sys.argv)
    sys.exit(exit_code)

if __name__ == '__main__':
    main()
