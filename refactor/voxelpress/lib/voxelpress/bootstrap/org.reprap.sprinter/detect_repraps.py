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
import json
import uuid
import socket # for uuid generation
from serial import Serial


BAUDS = (
    250000,
    115200,
    57600,
    38400,
    19200,
    9600,
    2400
   )


def get_port(path, baud, hw_info):
    """Attempt to determine the baud rate of a tty port."""

    timeout = 1
    if not hw_info.lower().count("arduino"):
        # sanguino's seem to need a longer timeout to initialize
        # they also only provide a generic name under hw_info
        timeout = 5
    try:
        com = Serial(path, baud, timeout=timeout)
        if not (com.readable() and com.writable()):
            return None
    except IOError:
        return None
    return com


def get_info(com, gcode="M115"):
    """Attempt to poll the device's capabilities."""

    com.write(gcode + "\n")
    info = []
    while True:
        line = com.readline().strip()
        if line:
            if line == "ok":
                break
            else:
                info.append(line)
    return info


def get_uuid(info, firmware_name, hw_info):
    """Generate a uuid for the printer, favoring one provided by the
    firmware if possible"""

    device_id = None
    for line in info:
        if line.count("UUID:"):
            uuid_i = line.index("UUID:")
            uuid_str = info[uuid_i+5:uuid_i+5+36]
            if uuid_str != "00000000-0000-0000-0000-000000000000":
                device_id = uuid.UUID(uuid_str)
                break
    if not device_id:
        namespace = uuid.uuid5(uuid.NAMESPACE_DNS, socket.getfqdn())
        device_id = uuid.uuid5(namespace, hw_info+"."+firmware_name)
    return str(device_id)

    
def scan_port(com, hw_info):
    post = str(com.readlines())
    com.timeout = .1

    device_info = None
    firmware = None
    if post.count("Sprinter"):
        firmware = "Sprinter"
    elif post.count("Marlin"):
        firmware = "Marlin"
    
    if firmware:
        info = get_info(com)
        device_info = {
            "firmware" : firmware,
            "uuid" : get_uuid(info, firmware, hw_info),
            "post" : post,
            "info" : info,
            }

    return device_info


def find_reprap(tty_path, hw_info):
    for baud in BAUDS:
        com = get_port(tty_path, baud, hw_info)
        if com:
            found = scan_port(com, hw_info)
            if found:
                found["tty_path"] = tty_path
                found["baud"] = baud
                found["terminus"] = "org.reprap.sprinter"
                return found




if __name__ == "__main__":
    found = find_reprap(*sys.argv[1:3])
    if found:
        json.dump(found, sys.stdout)
        exit(0)
    else:
        exit(1)
