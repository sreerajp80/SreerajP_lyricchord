# Created android/key.properties with dummy values

**Plan:** plans/20260722_000001_dummy-key-properties.md

## What changed

- Created `android/key.properties` (local only, gitignored — confirmed with
  `git check-ignore`). It holds the four keys the release signing config in
  `android/app/build.gradle.kts` reads:
  - `storeFile=sreecord-keystore.jks` (the keystore already in `android/`)
  - `storePassword=CHANGE_ME`
  - `keyAlias=CHANGE_ME`
  - `keyPassword=CHANGE_ME`

## Notes

- The user asked for "keystore.properties", but Gradle reads
  `android/key.properties`, so that name was used (approved by the user).
- Release builds will fail to sign until the real password and alias replace
  the `CHANGE_ME` placeholders. Debug builds are unaffected.
