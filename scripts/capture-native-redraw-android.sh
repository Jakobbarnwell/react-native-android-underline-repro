#!/usr/bin/env bash
set -euo pipefail
: "${ANDROID_SERIAL:?Set ANDROID_SERIAL to your allocated Android device}"
: "${INSERT_X:?Set the INSERT SIBLINGS button coordinates for your screen}"
: "${INSERT_Y:?Set the INSERT SIBLINGS button coordinates for your screen}"
output=${1:-evidence/native-redraw}
mkdir -p "$output"
package=com.jakobbarnwell.underlinerepro
reset_layout() {
  adb -s "$ANDROID_SERIAL" shell setprop debug.layout false
  adb -s "$ANDROID_SERIAL" shell service call activity 1599295570 > /dev/null
}
trap reset_layout EXIT
for run in $(seq 1 4); do
  adb -s "$ANDROID_SERIAL" shell am force-stop "$package"
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$output/run-$run.txt"
  adb -s "$ANDROID_SERIAL" shell am start -W -n "$package/.MainActivity" >> "$output/run-$run.txt"
  sleep 5
  adb -s "$ANDROID_SERIAL" shell pidof "$package" >> "$output/run-$run.txt"
  adb -s "$ANDROID_SERIAL" shell input tap "$INSERT_X" "$INSERT_Y"
  sleep 2
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-before.png"
  sleep 10
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-before-10s.png"
  adb -s "$ANDROID_SERIAL" shell setprop debug.layout true
  adb -s "$ANDROID_SERIAL" shell service call activity 1599295570 > "$output/run-$run-service.txt"
  sleep 1
  reset_layout
  sleep 2
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-after.png"
  echo "Captured native redraw $run/4: $output"
done
