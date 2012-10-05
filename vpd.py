#!/usr/bin/env python

import daemon
import gobject
import dbus, dbus.service
from dbus.mainloop.glib import DBusGMainLoop

NAMESPACE = org.voxelpress.daemon




class VoxelpressServer(dbus.service.Object):

    def __init__(self):
        bus_name = dbus.service.BusName(NAMESPACE, bus=dbus.SystemBus())
        dbus.service.Object.__init(self, bus_name, "/" + NAMESPACE.replace(".", "/"))


    @dbus.service.method(NAMESPACE)
    def hello(self):
        return "Hello,World!"




if __name__ == "__main__":
    DBusGMainLoop(set_as_default=True)
    myservice = VoxelpressServer()
