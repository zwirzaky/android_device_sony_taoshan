# NFC permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.xml:system/etc/permissions/android.hardware.nfc.xml

# NFC HAL
PRODUCT_PACKAGES += \
    android.hardware.nfc@1.0-impl

# NFC packages
PRODUCT_PACKAGES += \
    com.android.nfc_extras \
    libnfc \
    libnfc_jni \
    Nfc \
    Tag

# NFC FW
PRODUCT_PACKAGES += \
    libpn544_fw
    
# NFC HAL
PRODUCT_PACKAGES += \
    nfc.msm8960
