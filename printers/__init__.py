import json, os
import dbus, dbus.service


class PrintJob():
    """A pending or active print job."""

    def __init__(self):
        self.status = None
        self.job_name = None
        self.job_file = None


class VoxelpressPrinter(dbus.service.Object):
    
    def __init__(self, uuid):
        self.__uuid = uuid
        self.__queue = []
        self.__config = json.load(open(os.path.join("settings", str(uuid) + ".json")))
        self.__connected = None

    
    def __save(self):
        """Save the running config."""
        json.dump(self.__config, open(os.path.join("settings", str(uuid) + ".json")),"w")


    def on_connect(self, device):
        """A device that matches this config was connected."""
        self.__connected = device
        
        name = str(self.__uuid)
        if self.__config.has_key("printer name"):
            name = self.__config["printer name"]

        print name, "is now online."


    def on_disconnect(self):
        """The associated device is now offline."""
        self.__connected = None
