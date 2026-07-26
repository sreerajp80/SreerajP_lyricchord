# Plan: Fix Android App Startup Crash (ClassNotFoundException: MainActivity)

**Status:** Implemented

## Issue
App crashes on launch on Android with logcat exception:
`java.lang.RuntimeException: Unable to instantiate activity ComponentInfo{in.sreerajp.lyricchord/in.sreerajp.lyricchord.MainActivity}: java.lang.ClassNotFoundException: Didn't find class "in.sreerajp.lyricchord.MainActivity"`

## Root Cause
`build.gradle.kts` sets `namespace = "in.sreerajp.lyricchord"`. `AndroidManifest.xml` references `.MainActivity`, resolving to `in.sreerajp.lyricchord.MainActivity`.
`MainActivity.kt` was in `in/sreerajp/lyriccord/MainActivity.kt` with package `in.sreerajp.lyriccord` (misspelled `lyriccord` without 'h').

## Fix
1. Create `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt` with `package in.sreerajp.lyricchord`.
2. Delete `android/app/src/main/kotlin/in/sreerajp/lyriccord/MainActivity.kt`.
