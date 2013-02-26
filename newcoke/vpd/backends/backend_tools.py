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


import os
import json
import uuid
import subprocess

import gobject
import dbus, dbus.service
from dbus.mainloop.glib import DBusGMainLoop


def get_bus():
    dbus_mode = os.environ["BUS_MODE"]
    return dbus.SessionBus() if dbus_mode=="session" else dbus.SystemBus()      
    

def get_bus_name():
    return dbus.service.BusName(os.environ["BUS_NAME"], bus=get_bus())


def get_proxy(bus_name, bus_path):
    return get_bus().get_object(bus_name, bus_path)


def get_voxelpress():
    """Returns a proxy of vpd's switchboard object."""
    return get_proxy("org.voxelpress", "/org/voxelpress")


def get_parent():
    """Returns a proxy of whatever non-vpd daemon which spawned this process."""
    return get_proxy(os.environ["PARENT_NAME"], os.environ["PARENT_PATH"])


def get_manifest():
    """Returns the plugin's manifest."""
    manifest_path = os.path.join(os.environ["PLUGIN_PATH"], "manifest.json")
    with open(manifest_path, "r") as manifest_file:
        return json.load(manifest_file)
    

def create_mainloop():
    main_loop = gobject.MainLoop()
    DBusGMainLoop(set_as_default=True)
    return main_loop


def spawn(component, args=[], env=None):
    """Opens a script in a separate process."""

    manifest = get_manifest()
    plugin_path = os.environ["PLUGIN_PATH"]
    target = os.path.join(plugin_path, manifest[component])

    assert os.path.exists(target)
    _args = ["python", target] + map(str, list(args))
    _cwd = os.path.split(target)[0]

    _env = {}
    for ctx in (os.environ, env):
        if ctx:
            for key, value in ctx.items():
                _env[key] = value

    child_uuid = str(uuid.uuid4()).replace("-", "_")
    _env["BUS_PATH"] = os.environ["BUS_PATH"] + "/" + child_uuid
    _env["PARENT_NAME"] = os.environ["BUS_NAME"]
    _env["PARENT_PATH"] = os.environ["BUS_PATH"]
            
    subprocess.Popen(_args, cwd=_cwd, env=_env)


def log(message):
    """Log a message with the server."""
    prox = get_voxelpress()
    prox.debug_log(os.environ["BUS_PATH"], message)




class BackendComponent(dbus.service.Object):
    def __init__(self): 
        self.__main_loop = create_mainloop()
        self.__running = False
        dbus.service.Object.__init__(self, get_bus_name(), os.environ["BUS_PATH"])
        self.voxelpress = get_voxelpress()

    def activate(self):
        """Activates the main loop."""
        assert self.__running == False
        self.__main_loop.run()

    def shutdown(self):
        self.__main_loop.quit()
        exit(0)
        
    def spinoff(self, args=[], env=None, component="device"):
        """Start a subprocess."""
        spawn(component, args, env)




class BackendDaemon(BackendComponent):
    """Basic functional daemon for backend plugins."""

    def __init__(self):
        BackendComponent.__init__(self)
        log("Daemon started.")

    def new_device(self, hw_info):
        """Create a new device subprocess."""
        self.spinoff(env={"HARDWARE_INFO" : json.dumps(hw_info)})

    @dbus.service.signal(dbus_interface='org.voxelpress.backends', signature='a{ss}')
    def disconnect_event(self, event_info):
        pass




class BackendDevice(BackendComponent):
    """A basic device wrapper entity for a backend plugin."""

    def __init__(self):
        BackendComponent.__init__(self)
        self.parent = get_parent()
        log("Device initializing.")

    def register_handler(self, signal_name, handler):
        bus = get_bus()
        bus.add_signal_receiver(
            handler,
            signal_name, 
            "org.voxelpress.backends",
            None, #os.environ["PARENT_NAME"],
            os.environ["PARENT_PATH"])

    def get_hardware_info(self):
        return json.loads(os.environ["HARDWARE_INFO"])
