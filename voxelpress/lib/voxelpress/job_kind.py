

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
LIBPATH = os.path.split(os.path.abspath(__file__))[0]


JOB_STATES = (
    "pending",
    "printing",
    "error",
)


class PrintJob:
    
    def __init__(self, printer, file_path, pipeline, context_env):
        self.printer = printer
        self.file_path = file_path
        self.queue_file = ""
        self.pipeline = pipeline
        self.context = context_env
        self.state = 0
