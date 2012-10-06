#!/usr/bin/env python

import daemon

import os, glob, json
import socket, uuid
import gobject
import dbus, dbus.service
from dbus.mainloop.glib import DBusGMainLoop

import hardware
from printers import VoxelpressPrinter


class VoxelpressServer(dbus.service.Object):

    def __init__(self, main_loop):
        self.__loop = main_loop
        namespace = "org.voxelpress.daemon"
        bus_name = dbus.service.BusName(namespace, bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/" + namespace.replace(".", "/"))
        self.devices = {}
        self.printers = {}

        saved_printers = glob.glob("settings/*.json")
        for path in saved_printers:
            puuid = uuid.UUID(os.path.split(path)[1][:-5])
            self.printers[puuid] = VoxelpressPrinter(puuid)


    def hw_connect_event(self, device):
        namespace = uuid.uuid5(uuid.NAMESPACE_DNS, socket.getfqdn())
        device.uuid = uuid.uuid5(namespace, device.hw_info+"."+device.driver)

        printer = None
        if self.printers.has_key(device.uuid):
            printer = self.printers[device.uuid]
        else:
            config_path = os.path.join("hardware/drivers", device.driver, "config.json")
            with open(config_path, "r") as config_file:
                config = json.load(config_file)
            json.dump(config, open(os.path.join("settings", str(device.uuid) + ".json"), "w"))
            printer = VoxelpressPrinter(device.uuid)

        if printer:
            self.devices[device.hw_path] = device
            print "New device attached:"
            print "  driver:", device.driver
            print "    hwid:", device.hw_path
            print "    uuid:", device.uuid
            printer.on_connect(device)


    def hw_disconnect_event(self, hw_path):
        if self.devices.has_key(hw_path):
            device = self.devices[hw_path]
            device.on_disconnect()
            del self.devices[hw_path]
            print "Printer disconnected:"
            print "  driver:", device.driver
            print "    hwid:", device.hw_path
            print "    uuid:", device.uuid

            self.printers[device.uuid].on_disconnect()


    @dbus.service.method("org.voxelpress.daemon")
    def hello(self):
        return "Hello,World!"


if __name__ == "__main__":
    main_loop = gobject.MainLoop()
    DBusGMainLoop(set_as_default=True)
    voxelpress = VoxelpressServer(main_loop)
    hardware.CONNECT_HW_EVENTS(voxelpress)
    main_loop.run()


