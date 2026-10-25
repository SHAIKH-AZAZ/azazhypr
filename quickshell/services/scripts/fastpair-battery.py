#!/usr/bin/env python3
# Left bud, right bud and case charge of connected earbuds that speak Google
# Fast Pair. Opens each one's Fast Pair message stream (an RFCOMM channel)
# through BlueZ and prints a JSON line whenever the earbuds report levels:
#   {"address": "...", "left": 99, "right": 99, "case": 98,
#    "leftCharging": false, "rightCharging": false, "caseCharging": false}
# A level is -1 when unknown (a bud out of range, the case closed). When the
# stream closes, {"address": "..."} alone says the levels are gone.
# Runs until killed; earbuds that connect later are picked up too.

import ctypes
import json
import os
import signal

import dbus
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib

MESSAGE_STREAM = "df21fe2c-2515-4fdb-8886-f12c4d67927c"
PROFILE_PATH = "/latto/fastpair/" + str(os.getpid())
DEVICE = "org.bluez.Device1"

# Message group "device information", code "battery updated".
GROUP_DEVICE_INFO, CODE_BATTERY = 0x03, 0x03


def emit(**fields):
    print(json.dumps(fields), flush=True)


def level(byte):
    value = byte & 0x7F
    return -1 if value == 0x7F else value


def parse(buffer, address):
    """Handles the complete messages in buffer and returns the rest."""
    while len(buffer) >= 4:
        size = buffer[2] << 8 | buffer[3]
        if len(buffer) < 4 + size:
            break
        group, code, data = buffer[0], buffer[1], buffer[4:4 + size]
        buffer = buffer[4 + size:]
        if group == GROUP_DEVICE_INFO and code == CODE_BATTERY and size == 3:
            emit(address=address,
                 left=level(data[0]), right=level(data[1]), case=level(data[2]),
                 leftCharging=bool(data[0] & 0x80), rightCharging=bool(data[1] & 0x80),
                 caseCharging=bool(data[2] & 0x80))
    return buffer


class Profile(dbus.service.Object):
    def __init__(self, bus):
        super().__init__(bus, PROFILE_PATH)
        self.streams = {}  # device path -> fd

    @dbus.service.method("org.bluez.Profile1", in_signature="oha{sv}", out_signature="")
    def NewConnection(self, path, fd, properties):
        fd = fd.take()
        self.streams[path] = fd
        address = str(bus.get_object("org.bluez", path).Get(DEVICE, "Address", dbus_interface=dbus.PROPERTIES_IFACE))
        pending = [b""]

        def read(_fd, condition):
            data = b""
            if not condition & (GLib.IO_HUP | GLib.IO_ERR):
                try:
                    data = os.read(fd, 1024)
                except OSError:
                    pass
            if not data:
                self.close(path)
                emit(address=address)
                return False
            pending[0] = parse(pending[0] + data, address)
            return True

        GLib.io_add_watch(fd, GLib.IO_IN | GLib.IO_HUP | GLib.IO_ERR, read)

    @dbus.service.method("org.bluez.Profile1", in_signature="o", out_signature="")
    def RequestDisconnection(self, path):
        self.close(path)

    @dbus.service.method("org.bluez.Profile1", in_signature="", out_signature="")
    def Release(self):
        pass

    def close(self, path):
        fd = self.streams.pop(path, None)
        if fd is not None:
            os.close(fd)


def open_stream(path, tries=3):
    if path in profile.streams:
        return

    def failed(_error):
        if tries > 1:
            GLib.timeout_add_seconds(5, lambda: open_stream(path, tries - 1) and False)

    device = dbus.Interface(bus.get_object("org.bluez", path), DEVICE)
    device.ConnectProfile(MESSAGE_STREAM, reply_handler=lambda: None, error_handler=failed)


def consider(path, properties):
    uuids = [str(uuid).lower() for uuid in properties.get("UUIDs", [])]
    if properties.get("Connected") and MESSAGE_STREAM in uuids:
        # Let the audio profiles settle first.
        GLib.timeout_add_seconds(2, lambda: open_stream(path) and False)


def on_properties_changed(interface, changed, _invalidated, path):
    if interface == DEVICE and changed.get("Connected"):
        device = bus.get_object("org.bluez", path)
        consider(path, device.GetAll(DEVICE, dbus_interface=dbus.PROPERTIES_IFACE))


# Exit along with the shell that started this: BlueZ takes the profile from
# one owner only, so a leftover copy would lock out the next one.
PR_SET_PDEATHSIG = 1
ctypes.CDLL(None).prctl(PR_SET_PDEATHSIG, signal.SIGTERM)

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()
profile = Profile(bus)
dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), "org.bluez.ProfileManager1").RegisterProfile(
    PROFILE_PATH, MESSAGE_STREAM, {"Role": "client", "AutoConnect": False})

bus.add_signal_receiver(on_properties_changed, "PropertiesChanged", dbus.PROPERTIES_IFACE,
                        "org.bluez", path_keyword="path")
objects = dbus.Interface(bus.get_object("org.bluez", "/"), "org.freedesktop.DBus.ObjectManager").GetManagedObjects()
for object_path, interfaces in objects.items():
    if DEVICE in interfaces:
        consider(object_path, interfaces[DEVICE])

GLib.MainLoop().run()
