# Change log: Remove the INTERNET permission that ML Kit adds to release builds

Implements [plans/20261022_133507_remove-mlkit-internet-permission.md](../plans/20261022_133507_remove-mlkit-internet-permission.md).

## What changed

- New `android/app/src/release/AndroidManifest.xml` (applies to every release
  build, `dev` and `prod`):
  - removes `android.permission.INTERNET` and
    `android.permission.ACCESS_NETWORK_STATE`, which Google's usage logger
    (`com.google.android.datatransport`, brought in by ML Kit through
    `mobile_scanner`) was adding;
  - removes the logger's `TransportBackendDiscovery` service, so it finds no
    upload backend and drops events instead of queueing them.
- `docs/security.md` §2: names the source of the two permissions, the release
  manifest that removes them, and says to re-check the merge report after any
  package change.
- `docs/release_process.md`: the permission check now also looks for
  `ACCESS_NETWORK_STATE`.
- `docs/dependencies.md`: note on `mobile_scanner`.

## Change from the plan

The plan also said to remove the logger's `JobInfoSchedulerService` and
`AlarmManagerSchedulerBroadcastReceiver`. They were kept. An install that
already has an upload job queued could crash if Android tries to start a job
whose service no longer exists. Removing the discovery service and the
permissions is enough: the logger cannot send anything.

## Checks

- `flutter build apk --flavor prod --release`: builds. `aapt2 dump permissions`
  lists only `ACCESS_NOTIFICATION_POLICY`, `USE_BIOMETRIC`, `USE_FINGERPRINT`,
  `CAMERA` and the app's own receiver permission — no `INTERNET`, no
  `ACCESS_NETWORK_STATE`. The discovery service is not in the APK manifest.
- The dev debug merged manifest still has `INTERNET` (needed for hot reload).
- No Dart code changed, so `flutter analyze` / `flutter test` were not re-run
  (last run: clean, 943 tests pass).
- Gradle and Kotlin daemons stopped.
- Not checked here: scanning a real AirQR code with the release build on a
  phone.
