# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := qcom

# Vendor platform
BOARD_VENDOR := sony
BOARD_VENDOR_PLATFORM := taoshan

# Images
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Legacy blobs
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true
TARGET_PROCESS_SDK_VERSION_OVERRIDE := \
    /system/bin/mediaserver=22

# Shipping API (stock Android 4.2.2)
PRODUCT_SHIPPING_API_LEVEL := 17
