# LineageOS 16.0 — Sony Xperia L (taoshan)

## Status

Port jest **bootowalny i testowany na telefonie**:

- system wstaje do UI,
- **WiFi działa** (połączenie z siecią, IP przez DHCP),
- **WiFi hotspot działa** (`hostapd` HIDL, `wlan0` AP `192.168.43.x`),
- **Bluetooth działa** (`state: ON`, MAC `1C:7B:21:A2:6A:7C`),
- **SELinux enforcing działa stabilnie** (brak Watchdog/ANR `system_server`),
- **ADB po WiFi działa** (`adb connect <IP>:5555`),
- **sleep/wake działa** po poprawkach sensorów i linkera,
- **USB ADB i MTP działają** (functionfs + alias `adb`),
- **obie kamery działają** (przednia i tylna, Camera2/Snap).

Gałąź: `zwirzaky/android_device_sony_taoshan`, `lineage-16.0-bringup`.

## Artefakt

```
out/target/product/taoshan/lineage-16.0-20261102-UNOFFICIAL-taoshan.zip
```

- rozmiar: 441 004 784 B (~421 MiB)
- MD5: `007e2f48ad1e31633c79da7320ef635e`
- Android 9 (SDK 28), `userdebug`
- podpisany test-keyami AOSP
- `androidboot.selinux=enforcing`

## Drzewo

```
<source>
```

- LineageOS 16.0 upstream
- `device/sony/common` — LineageOS `lineage-16.0`
- `device/qcom/common` — LineageOS `lineage-15.1` + poprawki power HAL
- `kernel/sony/msm8930` — `zwirzaky/android_kernel_sony_msm8930`,
  `lineage-16.0-bringup` (3.4, working `oreo` base)
- `vendor/sony` — `zwirzaky/proprietary_vendor_sony`, `lineage-16.0`
- `bionic`, `device/qcom/common`, `hardware/ril-caf` — patche w forkach
  `zwirzaky/*`, gałąź `lineage-16.0-bringup`
- `device/sony/taoshan` — ten port, gałąź `lineage-16.0-bringup`
  (zawiera też `tools/` z manifestem, patchami i skryptami builda)

## Najważniejsze poprawki

1. Device tree przeniesione na 16.0: `AndroidProducts.mk`, `Android.bp`,
   `lineage_taoshan.mk`, flagi legacy blobów, `PRODUCT_SHIPPING_API_LEVEL := 17`.
2. Power HAL `device/qcom/common` pod API Androida 9.
3. Sensors: retry `poll()` na `EINTR`, dłuższy sleep na `ENOSYS` (wcześniej
   system_server abortował albo kręcił pętlę w `SensorService`).
4. SELinux: `device/qcom/sepolicy-legacy`, poprawki typów i `sysfs_vibrator`.
5. Bionic: fallback `O_TMPFILE` oraz zezwolenie na text relocations dla starych
   blobów Sony (`linker/linker.cpp`). To zatrzymało crash-loop
   `mm-qcamera-daemon` po `libmmjpeg.so`.
6. RIL: usunięte nieeksportowane `initWithMmapSize()`.
7. Bluetooth:
   - MAC z `/data/etc/bluetooth_bdaddr` kopiowany do
     `/data/misc/bluetooth/bdaddr` (rootowy `btmac` service),
   - `ro.bt.bdaddr_path` na tę ścieżkę,
   - trigger `vendor.bluetooth.hciattach=true` → `hciattach`/`hci_qcomm_init`,
   - `vendor.qcom.bluetooth.soc=smd`.
8. WiFi:
   - `wpa_supplicant` jako HIDL: `interface
     android.hardware.wifi.supplicant@1.0::ISupplicant default`,
   - `-O/data/vendor/wifi/wpa/sockets`,
   - katalogi `/data/vendor/wifi/wpa/sockets`,
   - `p2p_supplicant.conf`/`wpa_supplicant.conf` tworzone przy starcie.
9. `logcatd` uruchamiany z init do `/data/misc/logd/logcat` (debug).
10. ccache: `CCACHE_TEMPDIR=/tmp`; Docker: `python3`, `xz-utils`, `squashfs-tools`.
11. Sleep/wake: po powyższych poprawkach `system_server` zszedł ze 158% do ~3%
    CPU, a wake wraca w ~4 s.
12. USB ADB/MTP: port functionfs do `android.c` (funkcja `ffs`, alias `adb`),
    montowanie functionfs i `f_ffs/aliases=adb` w init. Działa jako
    `0fce:5192` (`mtp,adb`).
13. Camera/SELinux: `/system/bin/mm-qcamera-daemon` dostał etykietę
    `mm-qcamerad_exec` (wcześniej `system_file`, więc daemon działał w domenie
    `init` i nie mógł otworzyć `/dev/video100`). Dodano też odczyt
    generycznego `sysfs` dla `mm-qcamerad` (węzeł `id`).
14. Camera/CameraService: `config_allowMediaUidForCameraServiceProxy=true`.
    W tym legacy porcie `CameraService` działa w `mediaserver` (UID 1013),
    a domyślna wartość `false` powodowała odrzucenie `pingForUserUpdate()`
    i puste `mAllowedUsers` — kamera odrzucała każdą aplikację.
15. Camera/gralloc: `GraphicBufferAllocator` maskuje `usage` do 32 bitów.
    Legacy klient kamery przekazuje 32-bitowy usage ze znakiem; przy
    rozszerzeniu do `uint64_t` powstawało `0xffff00000000`, które
    `Gralloc2` odrzucał i preview nie mógł zaalokować bufora 640x480.
16. Kernel/PM: `CONFIG_EARLYSUSPEND=n` (tak jak huashan). Legacy
    earlysuspend ustawiał `mfd->suspend.op_suspend=true`, ale Android 9 nie
    wołał `early_resume`, więc `FBIOBLANK(FB_BLANK_UNBLANK)` czekał w pętli
    `msleep`; SurfaceFlinger blokował `createSurface`, system_server trzymał
    `WindowHashMap` i ginął od Watchdoga. Bez earlysuspend display korzysta
    z normalnego PM suspend/resume. Build19: `PM: suspend entry/exit`,
    screen off→wake stabilne, ten sam system_server.
17. WiFi hotspot: usunięty stary service `hostapd /system/bin/hostapd` z
    `init.qcom.rc`. W Android 9 hostapd jest HIDL w
    `/vendor/bin/hw/hostapd`; legacy wpis go przesłaniał, a wificond dostawał
    `Cannot find '/system/bin/hostapd'`. Build20: `hostapd` startuje jako
    `hal_wifi_hostapd_default`, `wlan0` AP `192.168.43.246/24`,
    `hostapd: AP-ENABLED`.
18. SELinux enforcing (build30):
    - `btmac.sh` uruchamiany synchronicznie z init, a `bdaddr` dostaje
      `bluetooth:bluetooth 0644` (wcześniej `root:root 0600`),
    - `toolbox` dostaje dostęp do `bluetooth_prop`/`property_service`,
      pipe'ów init, plików WiFi/BT i `sysfs_wlan_fwpath`,
    - trigger `init.svc.wificond=running` i `sys.boot_completed=1` poprawia
      właściciela `/sys/module/wlan/parameters/fwpath` (WiFi startuje sama),
    - `qcom-post-boot` działa w `qti_init_shell` (CPU/sysfs/thermal);
      build32: `ondemand`, max 1026 MHz, min 384 MHz, `optimal_freq=810000`,
    - `mediaserver` może znaleźć HIDL `ICameraMotor`.
19. Fingerprint: `BUILD_FINGERPRINT` ustawiony globalnie na stock Sony, więc
    `ro.build.fingerprint` == `ro.vendor.build.fingerprint`. Usuwa to po
    bootcie dialog „There's an internal problem with your device…”.
    Build30/31: dialog nie występuje, bez wipe danych.

## CPU / stany zasilania

- governor `ondemand`, min 384 MHz, max 1026 MHz (cap zamiast 1188 MHz),
  `io_is_busy=0`, `sampling_down_factor=1`, `optimal_freq=810000` — polityka
  CPU jest ustawiona. **Build32 potwierdzone na urządzeniu** (`cpu0/cpu1`).
- **Deep sleep (build19):** po zgaszeniu ekranu pojawia się prawdziwy
  `PM: suspend entry` / `PM: suspend exit`; nie ma już pętli
  `request_suspend_state: sleep (3->3)`. `mWakefulness=Asleep`,
  `Display Power: state=OFF`, a `hwc_setPowerMode: mode 2` kończy się
  `Done`. System_server pozostaje ten sam po wake.
- W logu nadal widać częste wakeupy na timery; trzeba zmierzyć realny
  drain w idle. Opcjonalnie można później obniżyć cap do 810/918 MHz.

## Znane problemy

- `avc: denied { ioctl }` dla `hci_qcomm_init` na `/dev/smd3` — nie blokuje
  działania BT, ale można dodać allow w sepolicy.
- RIL wymaga SIM i testu.
- Brak HIDL `vendor.lineage.camera.motor` — tylko log ostrzeżenia, nie
  blokuje kamer.
- **Bateria:** build19 wchodzi w prawdziwy `PM: suspend` (nie tylko
  early-suspend), więc deep sleep jest możliwy. W logu widać częste
  wakeupy na timery; zużycie w idle trzeba jeszcze zmierzyć.
- **System_server Watchdog:** naprawiony w build19 przez
  `CONFIG_EARLYSUSPEND=n`; wcześniejszy HWC workaround został cofnięty.
- 1 GB RAM / 8 GB storage — ROM jest ciężki.

## Flashowanie

W TWRP **odmontuj `/system`** przed install — inaczej `block_image_update`
kończy się `E1001`.

```bash
adb shell twrp unmount /system
adb shell twrp install /sdcard/lineage-16.0-taoshan.zip
```

## ADB po WiFi

W Developer options włącz „ADB over network”, potem:

```bash
adb connect <IP>:5555
adb devices
```
