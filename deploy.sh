#!/usr/bin/env bash
set -e

bash ./third_party/build.sh

echo "Pushing APKs to temporary storage..."
adb shell mkdir -p /data/local/tmp/ov/
adb push apks/overlay-s10.apk /data/local/tmp/ov/
adb push apks/overlay-s10-systemui.apk /data/local/tmp/ov/

echo "Installing overlays..."
adb shell "su -c 'mount -o remount,rw /product 2>/dev/null || mount -o remount,rw / 2>/dev/null || true; cp /data/local/tmp/ov/overlay-s10.apk /product/overlay/overlay-s10.apk; cp /data/local/tmp/ov/overlay-s10-systemui.apk /product/overlay/overlay-s10-systemui.apk; chmod 644 /product/overlay/overlay-s10.apk /product/overlay/overlay-s10-systemui.apk; rm -rf /data/local/tmp/ov /data/resource-cache/*'"

echo "Restarting framework..."
adb shell "su -c 'stop && start'"

exit 0