# LineageOS 16.0 — Sony Xperia L (taoshan)

## Status

Port jest **bootowalny i testowany na telefonie**:

- system wstaje do UI,
- **WiFi działa** (połączenie z siecią, IP przez DHCP),
- **Bluetooth działa** (`state: ON`, MAC `1C:7B:21:A2:6A:7C`),
- **ADB po WiFi działa** (`adb connect <IP>:5555`),
- **sleep/wake działa** po poprawkach sensorów i linkera,
- **USB ADB i MTP działają** (functionfs + alias `adb`),
- **obie kamery działają** (przednia i tylna, Camera2/Snap).

Gałąź: `zwirzaky/android_device_sony_taoshan`, `lineage-16.0-bringup`.

## Artefakt

```
out/target/product/taoshan/lineage-16.0-20261101-UNOFFICIAL-taoshan.zip
```

- rozmiar: 441 005 355 B (~421 MiB)
- MD5: `3fc5d9d8cf561aab16eb762683ed5e39`
- Android 9 (SDK 28), `userdebug`
- podpisany test-keyami AOSP

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

## CPU / stany zasilania

- governor `ondemand`, min 384 MHz, max 1026 MHz (cap zamiast 1188 MHz),
  `io_is_busy=0`, `sampling_down_factor=1`, `optimal_freq=810000` — polityka
  CPU jest ustawiona.
- **Deep sleep nadal nie wchodzi.** Po zgaszeniu ekranu:
  - `mWakefulness=Asleep`, `Display Power: state=OFF`,
  - ale `request_suspend_state: sleep (3->3)` leci co ~100 ms,
  - brak `PM: suspend entry/exit` i CPU pozostaje aktywne,
  - `time_in_state` zdominowany przez 1026 MHz.
- Wcześniej blokował to `DOZE_WAKE_LOCK` (`DreamManagerService`) oraz
  `GnssLocationProvider`; po wyłączeniu screensavera/doze wakelocki zniknęły,
  ale pętla suspend została. To wygląda na legacy `CONFIG_EARLYSUSPEND`
  w kernelu 3.4 (zamiast `pm_suspend`); 15.1 miało ten sam problem.
- Kandydat na poprawkę: wyłączyć `CONFIG_EARLYSUSPEND` albo podłączyć
  `early_suspend` do `pm_suspend`; ewentualnie obniżyć cap do 810/918 MHz
  jako tymczasowe ograniczenie grzania.

## Znane problemy

- `avc: denied { ioctl }` dla `hci_qcomm_init` na `/dev/smd3` — nie blokuje
  działania BT, ale można dodać allow w sepolicy.
- RIL wymaga SIM i testu.
- Brak HIDL `vendor.lineage.camera.motor` — tylko log ostrzeżenia, nie
  blokuje kamer.
- **Bateria:** brak deep sleep; telefon na ekranie off nadal pracuje na
  wysokim CPU, więc bateria będzie drenowana (problem odziedziczony z 15.1).
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
