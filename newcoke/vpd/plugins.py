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


import os, glob, json
import util




class PluginKind:
    """Represents all plugin types."""

    group = None

    def __init__(self, group, name):
        assert group in ("backends", "drivers", "filters")

        self.name = name
        self.__path = os.path.join(os.path.split(__file__)[0], group, name)
       
        with open(os.path.join(self.__path, "manifest.json"), "r") as manifest_file:
            self.__manifest = json.load(manifest_file)

        self.__components = self.__manifest.keys()


    def invoke(self, component, args=[], env=None):
        """Invokes a script from the plugin's manifest."""
        
        script = os.path.join(self.__path, self.__manifest[component])
        common = os.path.abspath(os.path.split(self.__path)[0])
        if not env:
            env = {}
        if not os.environ.has_key("PYTHONPATH"):
            env["PYTHONPATH"] = common
        else:
            env["PYTHONPATH"] = common + ":" + os.environ["PYTHONPATH"]
        env["PLUGIN_PATH"] = self.__path
        util.spawn(script, args, env)




class BackendPlugin (PluginKind):
    """Represents backend plugins."""

    group = "backends"

    def __init__(self, name):
        PluginKind.__init__(self, "backends", name)




class DriverPlugin (PluginKind):
    """Represents driver plugins."""

    group = "drivers"

    def __init__(self, name):
        PluginKind.__init__(self, "drivers", name)




class FilterPlugin (PluginKind):
    """Represents filter plugins."""

    group = "filters"
    
    def __init__(self, name):
        PluginKind.__init__(self, "filters", name)




def find_plugins():
    """Returns a dictionary of known plugins."""

    def extract(manifest_path):
        "Extract a plugin name from a manifest path."""        
        plugin_path = os.path.split(manifest_path)[0]
        return os.path.split(plugin_path)[1]

    def build(constructor, registry):
        """List all plugins for a given plugin type."""        
        base_path = os.path.split(__file__)[0]
        group = constructor.group
        found = glob.glob(os.path.join(base_path, group, "*", "manifest.json"))
        names = map(extract, found)
        plugins = []
        for name in names:
            try:
                plugin = constructor(name)
            except:
                # FIXME better error reporting please
                print "Plugin blew up:",group, name
                continue
            plugins.append(plugin)
        
        registry[group] = plugins
    
    plugins = {}

    build(BackendPlugin, plugins)
    build(DriverPlugin, plugins)
    build(FilterPlugin, plugins)

    return plugins
