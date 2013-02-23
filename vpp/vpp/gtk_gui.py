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


import sys
from os.path import join, split, abspath
from gi.repository import Gtk


state = "config"
glade_path = join(
    abspath(split(sys.argv[0])[0]), 
    "../vpp/glade/")


def on_close(widget, prevent_exit=False):
    """Event handler for when the main window is closed."""
    
    if state != "printing":
        Gtk.main_quit


def on_print(widget):
    """Event handler for when the user requests a print job."""

    global state
    state = "printing"
    print "Print was clicked."
    win = builder.get_object("vpp_window")
    print "debug: closing wind
    
    
def main():
    """Create the main window and hookup events."""

    builder = Gtk.Builder()
    builder.add_from_file(join(glade_path, "print_setup.glade"))
    builder.connect_signals({
        "close_event" : on_close,
        "print_event" : on_print,
        })    
    win = builder.get_object("vpp_window")
    win.show_all()
    Gtk.main()
