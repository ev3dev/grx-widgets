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

from image import ImageWindow


class DemoWindow(Gw.MenuWindow):
    def __init__(self):
        super(Gw.Window, self).__init__()

        content_box = self.get_content_box()

        label = Gw.Label.new('hello world!')
        content_box.add(label)

        btn1 = Gw.Button.with_label('Images')
        btn1.set_margin(3)
        btn1.connect('pressed', self.show_image_window)
        content_box.add(btn1)

        btn2 = Gw.Button.with_label('Quit')
        btn2.set_margin(3)
        btn2.connect('pressed', lambda _: self.close())
        content_box.add(btn2)

        for _ in range(10):
            test = Gw.Label.new('test')
            content_box.add(test)

    def show_image_window(self, btn):
        self.get_basis().show_window(ImageWindow())


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
