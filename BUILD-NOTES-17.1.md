# taoshan — LineageOS 17.1 bring-up notes

Current state: **boots to UI**, Bluetooth ON, audio policy XML loaded.
SELinux is still permissive for the bring-up.

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

## Known issues

- Camera: `mm-qcamera-daemon` still crashes with SIGILL.
- GPS is disabled (`product/qcom-gps.mk`); the legacy GNSS HAL blocks
  `system_server` in `GnssLocationProvider.native_init`.
- SELinux is permissive; enforcing is a later step.

## Local-only pieces

`vendor/sony` and `kernel/sony/msm8930` in this tree were copied from the
16.0 bring-up. The kernel fork is published separately; vendor blobs are not
part of this device-tree branch.
