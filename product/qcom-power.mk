# Power package
PRODUCT_PACKAGES += \
    android.hardware.power@1.0-impl \
    android.hardware.power@1.0-service \
    power.qcom

# QCOM-perf properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so
