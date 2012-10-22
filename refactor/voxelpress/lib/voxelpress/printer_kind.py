

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
import glob
import uuid
import json


PRINTER_STATES = (
    "offline",
    "idle",
    "printing",
    "error",
    )

JOB_STATES = (
    "pending",
    "printing",
    "error",
)


class PrintJob:
    
    def __init__(self, file_path, mime_type):
        self.mime_type = mime_type
        self.file_path = file_path
        self.queue_file = ""
        self.state = 0


class VoxelpressPrinter:
    
    def __init__(self, uuid):
        self.__uuid = uuid
        self.name = "Unknown Printer"
        self.state = 0
        self.hardware_config = {}
        self.pipeline_config = {}
        self.__queue = []

        config_name = str(uuid) + ".json"
        self.__config_path = os.path.join(
            LIBPATH, "../../etc/voxelpress/printers/", config_name)

        self.__load_config()

    def __load_config(self):
        """
        Load a saved configuration for this printer, if such exists.
        """
        try:
            with open(self.__config_path, "rb") as config_file:
                config = json.load(config_file)
        except IOError:
            return

        if config.has_key("name"):
            self.name = config["name"]
        if config.has_key("filter_settings"):
            for filter_config in config["filter_settings"]:
                try:
                    filter_name = filter_config["filter"]
                    self.pipeline_config[filter_name] = filter_config
                except:
                    # FIXME maybe log the error?
                    pass
            
    def __save_config(self):
        """
        Save the configuration for this printer.
        """
        printer_config = {
            "name" : self.name,
            "filter_settings" : [ f for f in self.pipeline_config.values() ],
            }
        with open(self.__config_path, "wb") as config_file:
            json.dump(printer_config, config_file)

    def __get_or_load_filter(self, filter_name):
        if not self.pipeline_config.has_key(filter_name):
            # FIXME error if filter doesn't exist
            path = os.path.join(LIBPATH, "filters", filter_name, "options.json")
            with open(path, "rb") as config_file:
                defaults = json.load(config_file)
            defaults["filter"] = filter_name
            self.pipeline_config[filter_name] = defaults
        return self.pipeline_config[filter_name]

    def build_pipeline(self, mime_type):
        """
        Creates a basic configuration for a given print job mime type.
        This is indirectly called by the user interface prior to
        requesting a print job.
        """

        # FIXME totally cheating by hardcoding a pipeline =(
        return map(self.__get_or_load_filter, [
            "org.slic3r",
            "org.reprap.sprinter",
            ])

    def update_filter_configs(self, pipeline):
        """
        Updates the stored settings for individual filters.  This
        would be called after a print job is created.
        """
        
        for config in pipeline:
            self.pipeline_config[config["filter"]] = config

    def on_connect(self, device_config):
        self.__load_config()
        print "Printer connected:", self.name

    def on_disconnect(self):
        self.__save_config()
        print "Printer disconnected:", self.name
