# Android Text underline reproducer

Independent Expo SDK **58.0.16**, React Native **0.88.0**, React **19.3.0** app.
Only Expo, React and React Native are dependencies. No accounts, network data,
custom fonts, styling libraries, or proprietary application code are needed.
The exact npm dependency graph is in `package-lock.json`.

On Android 11/API 30, all three underlines were present after **10/10 cold
process launches** of the ScrollView variant. Inserting eight sibling rows
then removed all three in **4/10 trials** (6/10 retained them). The fixed-View
control retained them in 10/10 cold launches and 10/10 further insertion trials.
See [full counts and PNG evidence](evidence/README.md).

## Build

Use Node 22 or later, npm, Java 21, and an Android SDK configured through
`ANDROID_HOME`. The measured build used Android Studio's bundled Java 21.

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

Tap **INSERT SIBLINGS** after a fresh launch. Eight
rows mount below the existing text without changing its text or styles. Capture
the result. If A loses its underline, try **REDRAW A (OPACITY)**, which changes its
opacity from 1 to 0.99 without changing its text. Record what actually happens;
this is a probe, not a fix.

Related upstream report: [react-native#58999](https://github.com/react/react-native/issues/58999).
The current app uses a `ScrollView`. The earlier fixed-`View` control is at
[`a4a2ee4`](https://github.com/Jakobbarnwell/react-native-android-underline-repro/tree/a4a2ee499dbab05297ce9326ca6dea28c72df437).
Measured results and full screenshots are in [evidence](evidence/README.md).
The proposed relationship to
`ReactTextView.onDraw` and a null Android text layout is a hypothesis, not an
instrumented root-cause finding in this reproducer.

For ten repeated insertion captures, first locate both buttons on your device
(the redraw button moves after insertion). On the tested 1080x2400, 420-dpi
emulator:

```sh
export INSERT_X=540 INSERT_Y=1070 REDRAW_X=540 REDRAW_Y=1605
bash scripts/capture-layout-android.sh evidence/scroll
```

This also waits another ten seconds in run 1, and captures the opacity probe in
runs 1–4. Changing opacity is not guaranteed to invalidate Android's recorded
text drawing; its result alone cannot establish whether a native redraw helps.

An additional emulator-only probe requests native layout-bound drawing, then
turns it off again, without changing React state or remounting the app:

```sh
bash scripts/capture-native-redraw-android.sh evidence/native-redraw
```

This runs four fresh processes, inserts the siblings, captures immediately and
after another ten seconds, toggles `debug.layout` through Android's
system-property transaction, and captures again. It restores
`debug.layout=false` on exit. This is a
diagnostic command for the allocated emulator, not an application workaround.
