#!/usr/bin/env python

# This file is part of VoxelPress.
#
# VoxelPress is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VoxelPress is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with VoxelPress.  If not, see <http://www.gnu.org/licenses/>.
#
# Have a nice day!


import sys, os


def tk_error(message):
    try:
        root = Tk()
        showerror("Fatal Error", message)
        return True
    except ImportError:
        return False


if os.environ.has_key("DISPLAY") and not sys.argv.count("--nogui"):
    toolkit = None
    fallback = None

    try:
        from gi.repository import Gtk
        from gtk_gui import main
        toolkit = main
    except ImportError:
        from Tkinter import Tk
        from tkMessageBox import showerror
        toolkit = None
        fallback = tk_error

    if toolkit:
        toolkit()
    elif fallback:
        msg = """Vpp was unable to import gtk or another usable toolkit.
Please be sure all dependencies have been correctly installed.
A commandline interface is also available by running vpp with the --nogui
option."""
        fallback(msg)
else:
    import no_gui
    no_gui.main()

