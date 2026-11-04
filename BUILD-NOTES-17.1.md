# taoshan — LineageOS 17.1 bring-up notes

Current state: **boots to UI**, Bluetooth ON, audio policy XML loaded,
rear/front camera preview works, Snap takes still photos and is the only
camera app in the product. SELinux is still permissive for the bring-up.

## Build

```sh
cd /home/zwirzaky/Documents/taoshan-17.1
device/sony/taoshan/tools/build.sh
```

The Docker image is `lineage171-builder` (Ubuntu 20.04), see
`tools/Dockerfile-17.1`.

## 17.1-specific fixes

- 32-bit binder (`TARGET_USES_64_BIT_BINDER := false`); the msm8930 kernel
  exposes the legacy binder protocol 7.
- custom boot ramdisk keeps the first-stage init and the full root files.
- HIDL services added for sensors, vibrator, keymaster, GNSS (temporarily
  disabled) and Bluetooth.
- audio policy/effects/engine configuration is XML on 17.1.
- JIT is disabled on the first 17.1 bring-up (kernel 3.4 + ART 10).
- `netd` gets `bpf.progs_loaded=1` because the 3.4 kernel has no eBPF.
- `/firmware` and `/persist` mount points are part of the boot/system image.
- Camera runs the legacy QCamera HAL from `mediaserver` with the huashan
  linker shims and `camera.qcom` wrapper. `media` and `qcamerasvr` are started
  from init.
- The prebuilt QCamera HAL needs the `releaseHeapMem` workaround described in
  `camera/README-camera-17.1.md`; run `camera/patch-vendor-camera-hal.sh` after
  importing vendor blobs.
- Snap is the only camera app (`Camera2` is filtered out in
  `lineage_taoshan.mk`). Its launcher receiver was removed so the icon is not
  disabled when the camera service is not ready at boot.
- Front/rear preview orientation is handled by the HAL; the Snap
  `persist.camera.*.preview_rotation` values remain 0 and
  `persist.camera.front.hal_rotation=90`.

## Known issues

- GPS is disabled (`product/qcom-gps.mk`); the legacy GNSS HAL blocks
  `system_server` in `GnssLocationProvider.native_init`.
- SELinux is permissive; enforcing is a later step.

## Local-only pieces

`vendor/sony` and `kernel/sony/msm8930` in this tree were copied from the
16.0 bring-up. The kernel fork is published separately; vendor blobs are not
part of this device-tree branch.

## Published 17.1 branches

- device: `zwirzaky/android_device_sony_taoshan`, branch `lineage-17.1`
- bionic: `zwirzaky/android_bionic`, branch `lineage-17.1`
- RIL: `zwirzaky/android_hardware_ril`, branch `lineage-17.1`
- camera HAL: `zwirzaky/proprietary_vendor_sony`, branch `lineage-17.1`
- Snap: `zwirzaky/android_packages_apps_Snap`, branch `lineage-17.1`
- native: `zwirzaky/android_frameworks_native`, branch `lineage-17.1`

The camera changes are also mirrored as patches under `camera/patches/` for
reference.

The kernel in this local tree is from the 16.0 bring-up and is published in
`zwirzaky/android_kernel_sony_msm8930` on the 16.0 branch. `vendor/sony` is a
local copy of the 16.0 proprietary tree and is not part of this branch.

## WiFi

WiFi uses the legacy WCNSS stack. `wcnss-service` is a late-start oneshot
service and must be started explicitly; the boot image now does that. The
WCNSS config is copied to both `/system/etc/wifi` and `/vendor/etc/wifi`, and
`/dev/wcnss_ctrl` is exposed as `system:system 0660`.

`wificond`/`wpa_supplicant` are started by the framework when WiFi is enabled
from the UI. A cold `svc wifi enable` issued before `wificond` is ready can
report "Wi-Fi service is not ready"; wait for boot completion and toggle WiFi
from Settings.
