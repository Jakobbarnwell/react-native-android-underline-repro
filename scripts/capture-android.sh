#!/usr/bin/env bash
set -euo pipefail
: "${ANDROID_SERIAL:?Set ANDROID_SERIAL to your allocated Android device}"
output=${1:-evidence/cold}
mkdir -p "$output"
package=com.jakobbarnwell.underlinerepro
for run in $(seq 1 10); do
  adb -s "$ANDROID_SERIAL" shell am force-stop "$package"
  adb -s "$ANDROID_SERIAL" shell am start -W -n "$package/.MainActivity" > "$output/run-$run.txt"
  sleep 5
  adb -s "$ANDROID_SERIAL" shell pidof "$package" >> "$output/run-$run.txt"
  adb -s "$ANDROID_SERIAL" exec-out screencap -p > "$output/run-$run.png"
  echo "Captured $run/10: $output/run-$run.png"
done
