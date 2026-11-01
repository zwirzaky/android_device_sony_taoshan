#!/system/bin/sh
# Android 9's wpa_supplicant expects both config files.  The old Sony
# init.qcom.wifi.sh used to create them; create minimal ones from the
# device overlay files at post-fs-data.
DIR=/data/misc/wifi
[ -d "$DIR" ] || exit 0

if [ ! -f "$DIR/wpa_supplicant.conf" ]; then
    {
        echo "ctrl_interface=$DIR/sockets"
        echo "driver_param=use_p2p_group_interface=1"
        echo "update_config=1"
        echo "device_name=Xperia L"
        cat /system/etc/wifi/wpa_supplicant_overlay.conf 2>/dev/null
    } > "$DIR/wpa_supplicant.conf"
fi

if [ ! -f "$DIR/p2p_supplicant.conf" ]; then
    {
        echo "ctrl_interface=$DIR/sockets"
        echo "driver_param=use_p2p_group_interface=1"
        echo "update_config=1"
        echo "device_name=Xperia L"
        cat /system/etc/wifi/p2p_supplicant_overlay.conf 2>/dev/null
    } > "$DIR/p2p_supplicant.conf"
fi

chown wifi:wifi "$DIR/wpa_supplicant.conf" "$DIR/p2p_supplicant.conf"
chmod 0660 "$DIR/wpa_supplicant.conf" "$DIR/p2p_supplicant.conf"
