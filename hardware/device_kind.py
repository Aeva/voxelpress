

class DeviceKind():
    """Baseclass for all printer device backends."""
    
    def __init__(self, hw_path, hw_info):
        self.hw_path = hw_path
        self.hw_info = hw_info
        self.driver = None
        self.uuid = None

    def on_connect(self):
        """Called when the device is first connected to the system.
        Return False if no useful configurating can be determined."""

        return False

    def on_disconnect(self):
        """Called when the device is physically disconected for
        cleanup purposes."""

        pass
