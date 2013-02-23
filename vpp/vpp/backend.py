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


import argparse
import json
import dbus


VPD = dbus.SessionBus().get_object('org.voxelpress', '/org/voxelpress')
printers = {}


def __vpd_call(method, *args, **kwords):
    method = VPD.get_dbus_method(method, 'org.voxelpress.api')
    if len(args) == 0:
        if len(kwords.keys()):
            return method(json.dumps(kwords))
        else:
            return method()
    elif len(args) == 1:
        return method(args[0])
    else:
        return method(json.dumps(args))


class Printer:
    def __init__(self, uuid):
        self.__id = uuid
        self.config = {}
        self.state = "virtual"
        self.__load()

    def __load(self):
        """Fetch the printer's config from the server."""
        self.config = json.loads(vpd_call("get_printer_info", uuid_))


    def __save(self):
        """Update the printer's config on the server."""
        pass

    def request(self, path):
        """Send a print request to the server."""
        pass


def refresh():
    global printers
    uuids = json.loads(vpd_call("get_printers"))
    for uuid in uuids:
        printers[uuid] = Printer(uuid)
