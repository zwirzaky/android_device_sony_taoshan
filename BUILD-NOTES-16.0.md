# LineageOS 16.0 — Sony Xperia L (taoshan)

## Status

Port jest **bootowalny i testowany na telefonie**:

- system wstaje do UI,
- **WiFi działa** (połączenie z siecią, IP przez DHCP),
- **Bluetooth działa** (`state: ON`, MAC `1C:7B:21:A2:6A:7C`),
- **ADB po WiFi działa** (`adb connect <IP>:5555`),
- **sleep/wake działa** po poprawkach sensorów i linkera,
- MTP/USB ADB — nadal znany problem starego kernela (patrz niżej).

Gałąź: `zwirzaky/android_device_sony_taoshan`, `lineage-16.0-bringup`.

## Artefakt

```
out/target/product/taoshan/lineage-16.0-20261101-UNOFFICIAL-taoshan.zip
```

- rozmiar: 440 993 299 B (~421 MiB)
- MD5: `b9d0dfb4a775f70c9801100c63b0027b`
- Android 9 (SDK 28), `userdebug`
- podpisany test-keyami AOSP

## Drzewo

```
<source>
```

- LineageOS 16.0 upstream
- `device/sony/common` — LineageOS `lineage-16.0`
- `device/qcom/common` — LineageOS `lineage-15.1` + poprawki power HAL
- `kernel/sony/msm8930` — TeamButter `oreo` (3.4)
- `vendor/sony` — TeamButter `lineage-15.1`
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

## Znane problemy

- **USB ADB / MTP**: kernel ma legacy `f_adb` (`/dev/android_adb`), a Android 9
  `adbd` używa functionfs. Po włączeniu USB debugging gadget się wyłącza.
  MTP działa, ADB po WiFi działa. Naprawa wymaga portu functionfs w kernelu.
- `avc: denied { ioctl }` dla `hci_qcomm_init` na `/dev/smd3` — nie blokuje
  działania BT, ale można dodać allow w sepolicy.
- Camera i RIL są do dokończenia (camera daemon już się linkuje, ale sama
  kamera nie była testowana; RIL wymaga SIM).
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
