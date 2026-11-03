# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8960

# Vendor platform
BOARD_VENDOR := sony
BOARD_VENDOR_PLATFORM := taoshan

# Legacy blobs
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true
TARGET_PROCESS_SDK_VERSION_OVERRIDE := \
    /system/bin/mediaserver=22

# Dumpstate
BOARD_LIB_DUMPSTATE := libdumpstate.sony

# Images
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# Binder API
# msm8930 has the legacy 32-bit binder (protocol 7), so userspace must not
# use the 64-bit binder protocol. This is required on Android 10 too.
TARGET_USES_64_BIT_BINDER := false
