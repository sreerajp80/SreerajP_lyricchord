# Dependencies — LyricChord

This document records the approved third-party dependencies and libraries used in
LyricChord. It defines the strict offline boundary and lists prohibited packages. Read
this before considering adding any package to `pubspec.yaml`.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — project hard rules and offline stance.
- [security.md](security.md) — minimal permissions and offline security posture.
- [architecture.md](architecture.md) — architectural layers and design decisions.

---

## 1. Strict Offline Boundary

LyricChord is designed and built as a **100% offline application**:

- The app makes zero network connections.
- It never requests the Android `INTERNET` permission.
- It contains no analytics, telemetry, remote crash reporting, or remote ads.
- All song sheets, settings, and generated audio run entirely on the user's device.

Any dependency that introduces network I/O or transitively depends on network libraries
is strictly rejected.

---

## 2. Declared And Integrated Dependencies

The runtime dependencies in `pubspec.yaml` are organized by functional concern:

### 2.1 State Management & Routing
- `flutter_riverpod` (^3.3.2): Unidirectional data flow and declarative state management across widgets, repositories, and audio services.
- `go_router` (^18.1.1): Declarative URL/path-based navigation for screens and deep links. Version 18 is the first built on `material_ui`; older versions cannot find the `material_ui` `MaterialApp` and drop page transitions.

### 2.1a Logging
- `logger` (^2.8.0): Levelled logging behind `AppLogger`. Depends only on `meta` and
  `clock`; MIT licence; no network code and no build hooks. Only its console output is used.

### 2.1b Material widgets
- `cupertino_ui` (^1.1.4): Only for `GlobalCupertinoLocalizations`, used by the Sanskrit
  fallback delegate (`lib/l10n/fallback_localizations.dart`). The app shows no Cupertino
  widgets. Comes with `material_ui` anyway; no network code.
- `material_ui` (^1.8.0): Material widgets and `GlobalMaterialLocalizations`, moved out of the Flutter SDK (engineering standard §6.1). Brings `cupertino_ui` in as a transitive package. Local UI code only — no network I/O.

### 2.2 Local Persistence
- `drift` (^2.34.2): Type-safe SQLite database abstraction for song sheets, setlists, and search indexes.
- `sqlite3_flutter_libs` (^0.6.0+eol) & `sqlite3` (^3.4.0): Bundled native SQLite C library bindings. Local execution only.
- `path_provider` (^2.1.5): Standard local storage directories for database files and cached documents.
- `path` (^1.9.1): File and directory path string manipulation.
- `shared_preferences` (^2.5.5): Key-value storage for user display preferences (theme mode, scroll speeds).

### 2.3 Audio Synthesis & Playback
- `audioplayers` (^6.1.0): Local low-latency playback of in-memory PCM drone audio buffers and melody audio.
- `wakelock_plus` (^1.3.3, resolves to 1.8.x): Keeps the device screen awake during live musical performance and auto-scrolling.

### 2.4 Document Export & System Integration
- `pdf` (^3.12.0): Programmatic generation of vector PDF song sheets with custom Malayalam and Latin font support.
- `printing` (^5.14.3): System print dialog and share sheet dispatch for exported PDF documents.
- `file_picker` (^13.1.0): Scoped system document picker for importing ChordPro, text, and backup files, and the system Save dialog for exports. Version 12+ uses static methods (`FilePicker.pickFiles()`, `FilePicker.saveFile()`) and needs iOS 14.0 or later.
- `image_picker` (^1.1.2): Lets the user pick one photo so the AirQR receiver can find a QR code in it. No upload; see [security.md](security.md) §3.
- `mobile_scanner` (^6.0.4) & `qr_flutter` (^4.1.0): Local offline QR code generation and camera scanning for AirQR song sharing. The camera is asked for only when the scanner opens; see [security.md](security.md) §3. Uses the bundled ML Kit model (works offline). ML Kit pulls in Google's usage logger (`com.google.android.datatransport`), which adds `INTERNET` and `ACCESS_NETWORK_STATE`; `android/app/src/release/AndroidManifest.xml` removes both from release builds — see [security.md](security.md) §2.
- `local_auth` (^3.0.0): Device biometric and screen lock authentication for Stage Lock mode. Needs `MainActivity` to extend `FlutterFragmentActivity` and AppCompat launch themes (`androidx.appcompat` in `android/app/build.gradle.kts`).
- `package_info_plus` (^10.2.2): Reads version and build numbers from the app bundle for About screen verification.
- `url_launcher` (^6.3.2): Dispatches email composition to the system mail handler from the About screen.
- `cupertino_icons` (^1.0.8): Standard vector iconography.

### 2.5 Localization
- `flutter_localizations` (SDK): Material and Cupertino localization delegates.
- `intl`: String formatting, message lookups, and pluralization.

---

## 3. Dev Dependencies And Tooling

Build-time tools that do not ship in the application binary:

- `flutter_test` (SDK): Unit and widget testing framework.
- `flutter_lints` (^6.0.0): Dart and Flutter static analysis lint suite.
- `drift_dev` (^2.34.0): Code generation for Drift database tables, queries, and DAOs.
- `build_runner` (^2.15.1): Dart code generation runner.
- `flutter_launcher_icons` (^0.14.4): Automated icon generation for Android and iOS.

---

## 4. Prohibited Dependencies List

The following categories of packages MUST NEVER be added to `pubspec.yaml`, either
directly or transitively:

| Category | Reason | Examples of Prohibited Packages |
|---|---|---|
| HTTP / Networking Clients | Violates offline guarantee | `http`, `dio`, `chopper`, `retrofit` |
| Cloud BaaS & Sync | Violates local-only data ownership | `firebase_core`, `firebase_auth`, `supabase_flutter`, `amplify_flutter` |
| Analytics & Telemetry | Collects user behavior without need | `firebase_analytics`, `mixpanel_flutter`, `segment` |
| Crash Reporting | Uncontrolled background network reporting | `firebase_crashlytics`, `sentry_flutter`, `bugsnag_flutter` |
| Ad Networks | Inappropriate for performance notebook | `google_mobile_ads`, `unity_ads_plugin` |
| AI / LLM SDKs | Unnecessary network dependency | `google_generative_ai`, `dart_openai`, `langchain` |
| Network Status Monitors | App is offline; network status is irrelevant | `connectivity_plus`, `internet_connection_checker` |
