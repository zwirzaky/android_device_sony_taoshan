#!/system/bin/sh
# Copy the stock Sony Bluetooth MAC address into the path used by the
# Android 9 Bluetooth HAL (owned/labelled for the bluetooth domain).
mkdir -p /data/misc/bluetooth
if [ -r /data/etc/bluetooth_bdaddr ]; then
    cat /data/etc/bluetooth_bdaddr > /data/misc/bluetooth/bdaddr
else
    # Keep a usable BD address after a data wipe; the stock Sony file lives
    # in /data and is lost by a factory reset.
    printf '00:0A:F5:89:8A:00' > /data/misc/bluetooth/bdaddr
fi
chown bluetooth:bluetooth /data/misc/bluetooth/bdaddr
chmod 0644 /data/misc/bluetooth/bdaddr
