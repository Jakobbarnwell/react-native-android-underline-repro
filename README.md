# Android Text underline reproducer

Independent Expo SDK **58.0.16**, React Native **0.88.0**, React **19.3.0** app.
Only Expo, React and React Native are dependencies. No accounts, network data,
custom fonts, styling libraries, or proprietary application code are needed.
The exact npm dependency graph is in `package-lock.json`.

## Build

Use Node 22 or later, npm, Java 17, and an Android SDK configured through
`ANDROID_HOME`. On macOS Android Studio's bundled Java also works.

```sh
export ANDROID_SERIAL=emulator-5572  # replace with your own device
npm ci
npm run prebuild
cd android
./gradlew :app:assembleRelease -PreactNativeArchitectures=arm64-v8a
cd ..
adb -s "$ANDROID_SERIAL" install -r android/app/build/outputs/apk/release/app-release.apk
```

The example ABI is for an ARM64 emulator/device; use `x86_64` for an x86 emulator.
This uses Expo's generated Android project and default local debug signing for
the release variant. The JS bundle is embedded: Metro and Expo Go are not used.

## Reproduce

```sh
bash scripts/capture-android.sh evidence/cold
```

The script force-stops the app before each of ten launches and waits five seconds
before saving a lossless screenshot. These are cold **process** launches, not
emulator reboots or app-data clears. Compare the visible underline in:

* A: nested `Text` in the default system font.
* B: standalone underlined `Text` as a control.
* C: centered, wrapping nested `Text`, with semibold weight.

For a bounded layout variant, tap **INSERT SIBLINGS** after a fresh launch. Eight
rows mount below the existing text without changing its text or styles. Capture
the result. If A loses its underline, try **REDRAW A (OPACITY)**, which changes its
opacity from 1 to 0.99 without changing its text. Record what actually happens;
this is a probe, not a fix.

Related upstream report: [react-native#58999](https://github.com/react/react-native/issues/58999).
Measurement results will be recorded after testing. The proposed relationship to
`ReactTextView.onDraw` and a null Android text layout is a hypothesis, not an
instrumented root-cause finding in this reproducer.
