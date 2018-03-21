
import gi

gi.require_version('Gw', '0.1')
from gi.repository import Gw


class ImageWindow(Gw.Window):
    def __init__(self):
        super(Gw.Window, self).__init__(create_title_bar='Image Demo')

        vbox = self.get_child()

        hbox = Gw.HBox.new()
        vbox.add(hbox)

        img = Gw.Image.from_icon_name('arrow-up', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('arrow-down', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('arrow-left', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('arrow-right', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('bluetooth', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('bluetooth-connected', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('folder', Gw.IconSize.SMALL)
        hbox.add(img)
        img = Gw.Image.from_icon_name('folder-open', Gw.IconSize.SMALL)
        hbox.add(img)
