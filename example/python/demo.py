#!/usr/bin/env python3

import sys

import gi

gi.require_version('GObject', '2.0')
from gi.repository import GObject
gi.require_version('Grx', '3.0')
from gi.repository import Grx
gi.require_version('Gw', '0.1')
from gi.repository import Gw


def on_activate(app):
    print('activated')


def main():
    app = Gw.Application.new()
    app.connect('activate', on_activate)
    exit_code = app.run(sys.argv)
    sys.exit(exit_code)

if __name__ == '__main__':
    main()
