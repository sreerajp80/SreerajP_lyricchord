# Change Log: Fix Android App Startup Crash (ClassNotFoundException: MainActivity)

**Date:** 2026-07-23  
**Plan:** `plans/20260723_191200_fix-mainactivity-package-crash.md`

## Summary
Fixed the startup crash on Android devices caused by a package name mismatch in `MainActivity.kt`.

## Changes Made
- Created `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt` with package declaration `package in.sreerajp.lyricchord`.
- Removed old `android/app/src/main/kotlin/in/sreerajp/lyriccord/MainActivity.kt` directory and file (which mistakenly used package `in.sreerajp.lyriccord`).

## Verification
- `flutter analyze` completed with no issues.
- `flutter build apk --flavor dev` compiled the Android APK successfully.
