#!/system/bin/sh
# Copy the stock Sony Bluetooth MAC address into the path used by the
# Android 9 Bluetooth HAL (owned/labelled for the bluetooth domain).
mkdir -p /data/misc/bluetooth
if [ -r /data/etc/bluetooth_bdaddr ]; then
    cat /data/etc/bluetooth_bdaddr > /data/misc/bluetooth/bdaddr
    chown bluetooth:bluetooth /data/misc/bluetooth/bdaddr
    chmod 0644 /data/misc/bluetooth/bdaddr
fi
