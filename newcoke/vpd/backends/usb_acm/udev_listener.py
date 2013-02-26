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


import json
import gudev
import dbus
from backend_tools import *


class HardwareListener(BackendDaemon):
    """Handler for dbus events, and is responsible for routing
    requests to different components of the server."""

    def __init__(self):
        BackendDaemon.__init__(self)
        self.__udev = gudev.Client(["tty", "usb/usb_device"])
        self.__udev.connect("uevent", self.__udev_callback, None)
        self.__scan()


    def __udev_callback(self, client, action, device, user_data):
        hw_info = device.get_property("ID_SERIAL")
        subsystem = device.get_subsystem()

        if action == "add" and subsystem == "tty":
            event = dbus.Dictionary(signature="ss")
            event["listener"] = "udev"
            event["usb_path"] = device.get_parent().get_parent().get_device_file()
            event["tty_path"] = dbus.String(device.get_device_file())
            event["hw_info"] = dbus.String(hw_info)
            self.connect_event(event)
                
        elif action == "remove" and subsystem == "usb":
            event = dbus.Dictionary(signature="ss")
            event["listener"] = "udev"
            event["usb_path"] = device.get_device_file()
            self.disconnect_event(event)


    def __scan(self):
        """Iterate over available serial ports and try to find repraps."""
        for device in self.__udev.query_by_subsystem("tty"):
            hw_info = device.get_property("ID_SERIAL")
            if hw_info:
                try:
                    usb_path = device.get_parent().get_parent().get_device_file()
                    tty_path = device.get_device_file()
                except:
                    # FIXME ... not sure what to do =)
                    continue
                event = dbus.Dictionary(signature="ss")
                event["listener"] = "udev"
                event["usb_path"] = usb_path
                event["tty_path"] = tty_path
                event["hw_info"] = hw_info
                self.connect_event(event)
