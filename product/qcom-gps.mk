# GPS is disabled for the first 17.1 bring-up: the legacy gps.msm8960 HAL
# blocks SystemServer in GnssLocationProvider.native_init() and triggers a
# watchdog reboot. Re-enable once the GNSS HAL is ported.
