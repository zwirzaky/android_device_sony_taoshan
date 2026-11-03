# Taoshan camera port (LineageOS 17.1)

The camera stack is the legacy Qualcomm QCamera HAL, run from `mediaserver`
(`TARGET_HAS_LEGACY_CAMERA_HAL1 := true`), with the Linker shims and the
camera wrapper from the huashan 17.1 tree.

## Vendor HAL workaround

The prebuilt `camera.vendor.msm8960.so` double-frees the Morpho posture
buffer in `QCameraStream_preview::freeBufferMorphoPostureDetect()` while
closing. The port replaces the call to `releaseHeapMem` at file offset
`0x272ae` with two Thumb NOPs. Apply it on a fresh vendor import with:

```
./camera/patch-vendor-camera-hal.sh
```

## External repos

The required changes to `frameworks/native` and `packages/apps/Snap` are in
`camera/patches/`. They are also committed locally on their respective
`lineage-17.1-camera` branches when publishing from the build tree.

## Apps

Snap is the only camera app in the product; `Camera2` is filtered out in
`lineage_taoshan.mk`. `DisableCameraReceiver` is removed so the launcher icon
is not disabled when the camera service is not ready at boot.
