# Plan: Upgrade Flutter SDK to 3.44.8 and Dart SDK to 3.12.2

**Status:** completed

## Overview
Upgrade the LyricChord project SDK constraints and documentation to reflect Flutter 3.44.8 (stable channel) and Dart 3.12.2.

## Files to Change
- `pubspec.yaml`: Update Dart SDK constraint under `environment:` from `^3.11.5` to `^3.12.2`.
- `AGENTS.md`: Update project identity table for Flutter SDK (3.44.8) and Dart SDK (3.12.2).
- `CLAUDE.md`: Update project identity table for Flutter SDK (3.44.8) and Dart SDK (3.12.2).
- `docs/architecture.md`: Update toolchain reference to Flutter 3.44.8 and Dart 3.12.2.
- `docs/feature_analysis_and_innovations.md`: Update UI & Rendering toolchain reference to Flutter 3.44.8 and Dart 3.12.2.
- `docs/features.md`: Update Platform & Framework toolchain reference to Flutter 3.44.8 and Dart 3.12.2.
- `docs/implementation_plan.md`: Update Phase 0 reference to Flutter 3.44.8 and Dart 3.12.2.

## Verification Strategy
1. Run `flutter pub get` to update dependency resolution with the new SDK constraint.
2. Run `dart run build_runner build --delete-conflicting-outputs` to verify generated Drift code.
3. Run `flutter analyze` to ensure zero static analysis warnings/errors.
4. Run `flutter test` to verify all tests pass on the upgraded SDK.
