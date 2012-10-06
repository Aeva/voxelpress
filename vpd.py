#!/usr/bin/env python

import daemon

import socket, uuid
import gobject
import dbus, dbus.service
from dbus.mainloop.glib import DBusGMainLoop

import hardware

NAMESPACE = "org.voxelpress.daemon"


class VoxelpressServer(dbus.service.Object):

    def __init__ (self, main_loop):
        self.__loop = main_loop
        bus_name = dbus.service.BusName(NAMESPACE, bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/" + NAMESPACE.replace(".", "/"))
        self.devices = {}


    def hw_connect_event(self, device):
        namespace = uuid.uuid5(uuid.NAMESPACE_DNS, socket.getfqdn())
        device.uuid = uuid.uuid5(namespace, device.hw_info+"."+device.driver)
        self.devices[device.hw_path] = device
        print "New printer attached:"
        print "  driver:", device.driver
        print "    hwid:", device.hw_path
        print "    uuid:", device.uuid


    def hw_disconnect_event(self, hw_path):
        if self.devices.has_key(hw_path):
            device = self.devices[hw_path]
            device.on_disconnect()
            del self.devices[hw_path]
            print "Printer disconnected:"
            print "  driver:", device.driver
            print "    hwid:", device.hw_path
            print "    uuid:", device.uuid


    @dbus.service.method(NAMESPACE)
    def hello(self):
        return "Hello,World!"


if __name__ == "__main__":
    main_loop = gobject.MainLoop()
    DBusGMainLoop(set_as_default=True)
    voxelpress = VoxelpressServer(main_loop)
    hardware.CONNECT_HW_EVENTS(voxelpress)
    main_loop.run()


