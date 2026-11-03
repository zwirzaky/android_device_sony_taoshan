# Linker shims for legacy Sony camera blobs
TARGET_LD_SHIM_LIBS := \
    /system/bin/mediaserver|libshim_unwind.so \
    /system/bin/mm-qcamera-daemon|libshim_unwind.so \
    /system/lib/libcald_pal.so|libshim_cald.so \
    /system/lib/hw/camera.vendor.msm8960.so|libshim_camera.so
