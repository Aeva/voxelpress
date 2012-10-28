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
import sys
import time
import json
from printcore import printcore
CONFIG = json.loads(os.environ["FILTER_CONFIG"])
BAUD = int(CONFIG["hardware"]["baud"])
PORT = CONFIG["hardware"]["tty_path"]


def main(port, baud):
    p = printercore(port, baud)
    p.loud = False
    time.sleep(2)
    
    preface = [] # do things like home the printer

    gcode = []    
    for line in sys.stdin.readlines():
        gcode.append(line.strip())

    p.startprint(preface + gcode)
    p.disconnect()


if __name__ == "__main__":
    for key, value in CONFIG["hardware"].items():
        print >> sys.stderr, "==>", key, value

    foo = sys.stdin.readlines()
    print >> sys.stderr, "----> {0} lines".format(len(foo))
    sys.exit(0)
    #    sys.exit(main(PORT, BAUD))
