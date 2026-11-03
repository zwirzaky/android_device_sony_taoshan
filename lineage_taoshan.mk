#
# Copyright (C) 2013-2016 The CyanogenMod Project
#           (C) 2017 The LineageOS Project
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

# Inherit common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_mini_phone.mk)

# Inherit device configurations
$(call inherit-product, device/sony/taoshan/device.mk)

# Device display
TARGET_SCREEN_HEIGHT := 854
TARGET_SCREEN_WIDTH := 480

# Device identifications
PRODUCT_DEVICE := taoshan
PRODUCT_NAME := lineage_taoshan
PRODUCT_BRAND := Sony
PRODUCT_MANUFACTURER := Sony
PRODUCT_MODEL := Xperia L

# Init a dummy BT MAC address, will be overwritten later
BOARD_BT_MAC_ADDR := "00:00:00:00:00:00"

# Build fingerprints.  Keep the stock Sony fingerprint for blob compatibility,
# but apply it globally so ro.vendor.build.fingerprint matches ro.build.fingerprint.
BUILD_FINGERPRINT := Sony/C2105/C2105:4.2.2/15.3.A.1.17/Android.1016:user/release-keys
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=C2105 \
    BUILD_FINGERPRINT="Sony/C2105/C2105:4.2.2/15.3.A.1.17/Android.1016:user/release-keys" \
    PRIVATE_BUILD_DESC="C2105-user 4.2.2 JDQ39 Android.1016 test-keys"

# Snap is the camera app for this port. Keep AOSP Camera2 out of the image so
# camera intents resolve directly to Snap instead of an app chooser.
PRODUCT_PACKAGES := $(filter-out Camera2,$(PRODUCT_PACKAGES))
