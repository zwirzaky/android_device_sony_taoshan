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
  `system_server` in `GnssLocationProvider.native_init`, even with QMI/RIL
  and the GNSS HIDL service running. It needs a HAL port.
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

`wificond_ready` is a small oneshot service that waits 8 seconds after boot and
starts `wificond` and `wpa_supplicant`, whose rc files are imported after
`init.qcom.rc`. This makes the first UI WiFi toggle work without a manual
`ctl.start`.

## Video recording (17.1)

Video recording uses the legacy QCamera path in `mediaserver` together with
the QC OMX encoder. Two details are required:

- Do **not** run a separate `cameraserver` on this tree. The legacy camera
  recording callback passes a `VideoNativeHandleMetadata` whose
  `native_handle_t` lives in the camera HAL address space. With the HAL in
  `cameraserver`, `mediaserver` dereferences a foreign pointer and crashes in
  `libhidlbase` (`writeNativeHandleNoDup`). Keep
  `TARGET_HAS_LEGACY_CAMERA_HAL1 := true` so the HAL and the encoder share
  `mediaserver`.
- Codec2's software encoder rejects the legacy camera metadata buffers
  (`Only ANW buffers are supported for legacy metadata mode`), so
  `debug.stagefright.ccodec=0` forces the OMX path. `vendor.media.omx` must
  have the `audio` and `system` groups to open `/dev/msm_vidc_{enc,dec}` and
  `/dev/ion`.

`vendor.media.omx`, `mediaextractor` and `media.swcodec` are imported after
`class_start main` on this boot image; `init.qcom.rc` starts them explicitly.
`media.swcodec` is kept running so `MediaRecorderClient::setListener()` can
create its Codec2 death listeners without blocking; the actual video codecs
still come from OMX. `MediaRecorderClient::setListener()` also uses
`checkService("media.camera")` instead of the blocking `getService()`.

A 1280x720 H.264/AAC recording was verified end-to-end (16.7 s, ~23.7 MB,
valid moov atom). The MediaProvider database is still being rebuilt after the
17.1 upgrade, so newly recorded files may not appear in MediaStore until the
provider is repaired; the MP4/JPEG files themselves are written correctly.

## Late init services and first-boot traps

Several rc files are imported after `class_start main` on this boot image.
`init.qcom.rc` therefore starts `media`, `qcamerasvr`, `vendor.media.omx`,
`mediaextractor`, `media.swcodec`, `storaged`, `mediametrics` and
`gatekeeperd` explicitly. In particular:

- Without `gatekeeperd`, `LockSettingsService$DeviceProvisionedObserver`
  crashes `system_server` with a null `IGateKeeperService` when the setup
  wizard marks the device provisioned. This looks like a spontaneous reboot.
- Without `storaged`, `StorageManagerService` retries for a long time and
  user 0 can remain locked (`RUNNING_LOCKED`).

When a package is removed from `PRODUCT_PACKAGES`, its files can remain in
`out/target/product/taoshan/system` from an earlier build. This bit us with
`cameraserver` and the GPS HAL: a stale `cameraserver` owned `media.camera`
and rejected user 0, and stale GPS files kept the GNSS watchdog alive. Before
switching these features off, delete the stale files from the output tree (or
run `make installclean`).

`btmac.sh` now falls back to a fixed valid BD address when the stock Sony
`/data/etc/bluetooth_bdaddr` is missing after a data wipe. Without a BD
address the Bluetooth stack aborts with `startup_timer_expired`.

## Bluetooth timeout

The legacy SMD firmware load often takes longer than the 2.9 s default in
`system/bt/hci/src/hci_layer.cc`. `bluetooth.enable_timeout_ms=15000` in
`product/bluetooth.mk` prevents the `startup_timer_expired` abort at boot.
The fallback BD address in `btmac.sh` is still needed after a data wipe.

## QMI/RIL status

`qmuxd`, `netmgrd` and `rild` are started from init. The legacy Qualcomm RIL
initializes (`gsm.version.ril-impl=Qualcomm RIL 1.0`, radio power on) and the
repeated `com.android.phone` ANR is gone. With no SIM inserted the service
state is naturally OUT_OF_SERVICE. `rild` may abort once in
`qcril_qmi_voice_request_set_tty_mode` during startup and then restart; this
is harmless for a no-SIM bring-up.

GPS is still not functional: the legacy `gps.msm8960` HAL blocks
`GnssLocationProvider.native_init` even when qmuxd/netmgrd/rild and
`android.hardware.gnss@1.0-service` are running. A GNSS HAL port is required.

## USB and MTP

USB ADB now works after a normal reboot without unplugging the cable. The
earlier replug requirement was caused by the boot-time `usb_reenum` USB
soft-connect toggle and by `persist.sys.usb.config=mtp,adb`; both are gone.
Keep `persist.sys.usb.config=adb` and do not toggle the UDC during boot.

MTP/file transfer is still limited by MediaProvider. The primary public
volume is `C808-06D4`, but MediaStore's `external` volume previously resolved
to `A501-0DEE`. `tools/patches/0007-mediaprovider-primary-volume.patch`
makes `extractVolumeName()` return `external_primary` for the physical
primary volume, so the scanner and gallery see files on `C808-06D4`.

## First boot timing

After a cache/dalvik wipe the first boot can take 3-4 minutes on this device;
the system eventually reports `RUNNING_UNLOCKED` and ADB comes up late.

## SELinux status

SELinux is still **permissive**. Policy additions cover the main bring-up
denials (zygote writing cpuset tasks, storaged reading block stats, the
sensor HAL's compass sysfs writes, akmd calibration data, and system_server's
init binder calls). Platform-domain rules live in `sepolicy_platform`
(`BOARD_PLAT_PRIVATE_SEPOLICY_DIR`), vendor-domain rules in `sepolicy`.

Runtime `setenforce 1` reaches Enforcing, but CameraService then deadlocks
and USB/ADB becomes unavailable. Booting with `androidboot.selinux=enforcing`
does not complete boot yet. Do not make enforcing permanent until the camera
and adb policy holes are fixed.
