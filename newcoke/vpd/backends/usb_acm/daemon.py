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
from backend_tools import *

# FIXME try to detect what method makes most sense for
# the current os instead of just defaulting to udev.
from udev_listener import HardwareListener


class Switchboard(HardwareListener):
    def __init__(self):
        HardwareListener.__init__(self)
        self.activate()


    def connect_event(self, event_info):
        for key, value in event_info.items():
            log("Connect event info: {0}={1}".format(key, value))

        self.new_device(event_info)
        

    def disconnect_event(self, event_info):
        BackendDaemon.disconnect_event(self, event_info)
        for key, value in event_info.items():
            log("Disconnect event info: {0}={1}".format(key, value))



if __name__ == "__main__":
    Switchboard()

