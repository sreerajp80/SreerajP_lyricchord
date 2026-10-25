# Plan: Remove the INTERNET permission that ML Kit adds to release builds

**Status:** completed

## The issue

Hard rule 1 says the app is fully offline and the release build must have no
`INTERNET` permission. But the production release APK has both
`android.permission.INTERNET` and `android.permission.ACCESS_NETWORK_STATE`.

The Android build's manifest merge report
(`build/app/outputs/logs/manifest-merger-prod-release-report.txt`) shows where
they come from:

- `com.google.android.datatransport:transport-backend-cct` (and
  `transport-runtime`) add both permissions.
- These are Google's usage-logging libraries. ML Kit
  (`com.google.mlkit:barcode-scanning`) brings them in, and ML Kit comes from
  `mobile_scanner`, which AirQR uses to read QR codes.

The app's own code makes no network calls, and the barcode model is the
**bundled** one (it ships inside the APK and works offline). But with the
permission present, ML Kit's logger is allowed to send usage data to Google.
That breaks the offline promise and the "no analytics" rule.

This was already in the build before the robustness work; it was found while
checking the APK permissions for that work.

## The fix

1. Add a **release-only** manifest,
   `android/app/src/release/AndroidManifest.xml`, that removes the two
   permissions with `tools:node="remove"`:

   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       xmlns:tools="http://schemas.android.com/tools">
       <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
       <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove" />
   </manifest>
   ```

   Release-only, so debug builds keep `INTERNET` for hot reload (Flutter needs
   it there). This applies to both `dev` and `prod` release builds.

2. Also stop the logger's background parts from being registered in release,
   in the same file, with `tools:node="remove"` on its service and receiver
   (`TransportBackendDiscovery`, `JobInfoSchedulerService`,
   `AlarmManagerSchedulerBroadcastReceiver` — exact names taken from the merge
   report). Without the permission they could not send anything anyway; this
   just keeps them from waking up.

   I will **not** exclude the `datatransport` libraries from Gradle: ML Kit's
   code calls them directly, so removing the classes could crash the scanner.

3. Docs:
   - `docs/security.md` §2: note that ML Kit adds these permissions and that the
     release manifest removes them; the `aapt2` check must also show no
     `ACCESS_NETWORK_STATE`.
   - `docs/dependencies.md`: note on `mobile_scanner` about this.
   - `docs/release_process.md`: add `ACCESS_NETWORK_STATE` to the permission
     check step.

## Files to change

- `android/app/src/release/AndroidManifest.xml` (new)
- `docs/security.md`
- `docs/dependencies.md`
- `docs/release_process.md`

## Checks

- `flutter build apk --flavor prod --release` (without obfuscation is enough
  for this check), then `aapt2 dump permissions` on the APK: must show no
  `INTERNET` and no `ACCESS_NETWORK_STATE`.
- `flutter build apk --flavor dev --debug` still has `INTERNET` (hot reload).
- `flutter analyze` and `flutter test` still clean.
- Stop the Gradle daemons afterwards.
- Not possible here: scanning a real AirQR code with the release build on a
  phone. Please try that once — the bundled scanner should still work offline.

## Change log

`change_log/<timestamp>_remove-mlkit-internet-permission.md` after the work.
