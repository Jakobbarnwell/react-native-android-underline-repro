#!/usr/bin/env bash
set -euo pipefail
: "${ANDROID_SERIAL:?Set ANDROID_SERIAL to your allocated Android device}"
: "${INSERT_X:?Set the INSERT SIBLINGS button coordinates for your screen}"
: "${INSERT_Y:?Set the INSERT SIBLINGS button coordinates for your screen}"
: "${REDRAW_X:?Set the REDRAW A button coordinates after insertion}"
: "${REDRAW_Y:?Set the REDRAW A button coordinates after insertion}"
output=${1:-evidence/scroll}
mkdir -p "$output"
package=com.jakobbarnwell.underlinerepro
for run in $(seq 1 10); do
  adb -s "$ANDROID_SERIAL" shell am force-stop "$package"
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$output/run-$run.txt"
  adb -s "$ANDROID_SERIAL" shell am start -W -n "$package/.MainActivity" >> "$output/run-$run.txt"
  sleep 5
  adb -s "$ANDROID_SERIAL" shell pidof "$package" >> "$output/run-$run.txt"
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-before.png"
  adb -s "$ANDROID_SERIAL" shell input tap "$INSERT_X" "$INSERT_Y"
  sleep 2
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-after.png"
  if [ "$run" -eq 1 ]; then
    sleep 10
    adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-after-10s.png"
  fi
  if [ "$run" -le 4 ]; then
    adb -s "$ANDROID_SERIAL" shell input tap "$REDRAW_X" "$REDRAW_Y"
    sleep 2
    adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run-redraw.png"
  fi
  echo "Captured layout $run/10: $output"
done
