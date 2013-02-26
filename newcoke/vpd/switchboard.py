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


import dbus, dbus.service
from plugins import find_plugins




class Switchboard(dbus.service.Object):
    """Handler for dbus events, and is responsible for routing
    requests to different components of the server."""

    def __init__(self, dbus_mode):
        bus = dbus.SessionBus() if dbus_mode=="session" else dbus.SystemBus()    
        bus_name = dbus.service.BusName("org.voxelpress", bus=bus)
        dbus.service.Object.__init__(self, bus_name, "/org/voxelpress")
        
        def launch_daemon(plugin):
            base_path = "/org/voxelpress/backends/"
            bus_path = base_path + plugin.name
            bus_path = bus_path.replace(".", "_")
            plugin.invoke("daemon", env={
                    "BUS_MODE" : dbus_mode,
                    "BUS_NAME" : "org.voxelpress",
                    "BUS_PATH" : bus_path,
                    })

        self.plugins = find_plugins()
        map(launch_daemon, self.plugins["backends"])
        map(launch_daemon, self.plugins["drivers"])


    @dbus.service.method("org.voxelpress.debug", in_signature='ss')
    def debug_log(self, component, message):
        print "{0} says: {1}".format(component, message)


    @dbus.service.method("org.voxelpress.events", in_signature='s')
    def on_connect(self, device_info):
        print "some event"

