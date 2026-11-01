# Bluetooth configurations
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init.qcom.bt.sh:system/etc/init.qcom.bt.sh \
    $(LOCAL_PATH)/rootdir/etc/btmac.sh:system/etc/btmac.sh

# Bluetooth properties
PRODUCT_PROPERTY_OVERRIDES += \
    qcom.bluetooth.soc=smd \
    vendor.qcom.bluetooth.soc=smd \
    ro.bt.bdaddr_path=/data/misc/bluetooth/bdaddr \
    ro.bluetooth.hfp.ver=1.6 \
    ro.qualcomm.bt.hci_transport=smd
