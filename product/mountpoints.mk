# Ensure firmware/persist mount points exist in both the boot ramdisk and the
# system image. Keep normal files; hidden files alone are not enough for the
# image builder to create and label the directory.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/keep:root/firmware/keep \
    $(LOCAL_PATH)/rootdir/keep:root/persist/keep \
    $(LOCAL_PATH)/rootdir/keep:system/firmware/keep \
    $(LOCAL_PATH)/rootdir/keep:system/persist/keep
