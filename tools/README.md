# LineageOS 16.0 — Sony Xperia L (taoshan)

Bring-up branch based on the working 15.1 device tree, adapted for
LineageOS 16.0 (Android 9).

- Device tree: `zwirzaky/android_device_sony_taoshan`, branch
  `lineage-16.0-bringup`
- Kernel: `zwirzaky/android_kernel_sony_msm8930`, branch
  `lineage-16.0-bringup` (3.4, based on the working `oreo` base)
- Vendor blobs: `zwirzaky/proprietary_vendor_sony`, `lineage-16.0`
- Patched forks: `zwirzaky/android_bionic`,
  `zwirzaky/android_device_qcom_common`, `zwirzaky/android_hardware_ril`
  (branch `lineage-16.0-bringup`)
- Shared: LineageOS `device/sony/common` `lineage-16.0`,
  `device/qcom/common` `lineage-15.1`
- `frameworks/native`: local patch `0004-frameworks-native-legacy-gralloc-usage.patch`
  (32-bit camera usage mask for the msm8960 gralloc)
- `kernel/sony/msm8930`: local patch `0005-kernel-disable-earlysuspend.patch`
  (use PM suspend/resume instead of legacy earlysuspend)

## Status

- boots to UI,
- WiFi works,
- WiFi hotspot works (HIDL hostapd),
- Bluetooth works,
- ADB over WiFi works,
- sleep/wake works after the sensor/linker fixes,
- PM suspend/resume works after disabling legacy earlysuspend,
- screen off→wake is stable and system_server no longer restarts,
- both cameras work (rear and front),
- RIL still needs a SIM and testing,
- USB ADB/MTP work through functionfs (`0fce:5192`, `mtp,adb`).

See `BUILD-NOTES-16.0.md` for the full change list and known issues.

## Build from a clean tree

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-16.0

mkdir -p .repo/local_manifests
curl -fsSL \
  https://raw.githubusercontent.com/zwirzaky/android_device_sony_taoshan/lineage-16.0-bringup/tools/local_manifests/taoshan.xml \
  -o .repo/local_manifests/taoshan.xml

repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

# WebView APKs are Git LFS pointers
device/sony/taoshan/tools/fetch-lfs.sh

# Apply the local compatibility patches (bionic, qcom/common, ril-caf,
# frameworks/native gralloc legacy usage).
device/sony/taoshan/tools/apply-patches.sh

# Build
device/sony/taoshan/tools/build.sh
```

## Flash

In TWRP, unmount `/system` first, otherwise `block_image_update` reports
`E1001`:

```bash
adb shell twrp unmount /system
adb shell twrp install /sdcard/lineage-16.0-taoshan.zip
```

## ADB

USB ADB and MTP now work through functionfs (`0fce:5192`, `mtp,adb`).
ADB over WiFi also works: enable “ADB over network” in Developer options,
then

```bash
adb connect <phone-ip>:5555
```
