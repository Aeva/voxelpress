
from serial import Serial
from device_kind import DeviceKind
import drivers



class SerialDevice(DeviceKind):
    """Serial device backend."""

    baud_rates = (
        2400,
        9600,
        19200,
        38400,
        57600,
        115200,
        250000,
        )


    def __init__(self, *args, **kwords):
        DeviceKind.__init__(self, *args, **kwords)
        self.__path = None
        self.__baud = None
        self.__usb = None


    def __detect_driver(self, baud):
        """Used by on_connect to attempt to discover the baud rate of
        the port and applicable firmware."""

        def connect():
            return Serial(self.__path, baud)

        return drivers.select_driver("serial", connect)
        

    def on_connect(self, tty_path):
        self.__path = tty_path

        for baud in self.baud_rates[::-1]:
            try:
                self.driver = self.__detect_driver(baud)
                if self.driver:
                    self.__baud = baud
                    break
            except IOError:
                continue

        if self.driver:
            return True
