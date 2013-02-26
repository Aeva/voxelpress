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


from backend_tools import *


class SerialDevice(BackendDevice):
    def __init__(self):
        BackendDevice.__init__(self)
        self.hw_info = self.get_hardware_info()
        self.device_id = None
        self.device_path = None

        if self.hw_info["listener"] == "udev":
            self.device_path = self.hw_info["tty_path"]
            self.device_id = self.hw_info["usb_path"]
        
        self.register_handler("disconnect_event", self.disconnect_handler)
        self.activate()


    def disconnect_handler(self, event_info):
        if event_info["listener"] == "udev":
            if event_info["usb_path"] == self.device_id:
                log("Device Disconnected.")
                self.shutdown()


if __name__ == "__main__":
    SerialDevice()
