# Device sepolicies
BOARD_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy

# Platform-domain policy additions (zygote, storaged, ...).
BOARD_PLAT_PRIVATE_SEPOLICY_DIR := $(DEVICE_PATH)/sepolicy_platform
