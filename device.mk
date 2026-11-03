#
# Copyright (C) 2013-2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Screen density
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := hdpi
PRODUCT_AAPT_PREBUILT_DPI := hdpi tvdpi mdpi ldpi

# Device specific overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp,adb \
    persist.logd.logpersistd=logcatd \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1

# Product common configurations
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit common Android Go configurations
$(call inherit-product, build/target/product/go_defaults.mk)

# Device product elements
include $(LOCAL_PATH)/product/*.mk

# Vendor product configurations
$(call inherit-product, vendor/sony/taoshan/taoshan-vendor.mk)

# Old 3.4 kernel / ART 10: JIT crashes in Jit thread pool on taoshan.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    dalvik.vm.usejit=false \
    dalvik.vm.usejitprofiles=false

# Override any dalvik defaults from base product makefiles.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.usejit=false \
    dalvik.vm.usejitprofiles=false
