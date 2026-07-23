# Create key.properties with dummy values

**Status:** completed

## Issue

The user asked for a "keystore.properties" file with dummy values. The Gradle
build does not read a file with that name. [build.gradle.kts:16](android/app/build.gradle.kts#L16)
reads `android/key.properties`. If that file exists, the release build signs
with the keystore it points to; if not, it falls back to the debug key.

So the correct file to create is `android/key.properties`. It is already
gitignored (`android/key.properties` is listed in `.gitignore`), so it will
never be committed.

## Files to change

- **Create:** `android/key.properties` (gitignored, local only)

## Plan

Create `android/key.properties` with the four keys Gradle expects, using
dummy placeholder values:

```properties
storeFile=sreecord-keystore.jks
storePassword=CHANGE_ME
keyAlias=CHANGE_ME
keyPassword=CHANGE_ME
```

Notes:

- `storeFile` points at `android/sreecord-keystore.jks`, which already exists
  in the `android/` folder (the path is resolved against the `android/`
  project root).
- With dummy passwords present, a **release** build will now try to sign with
  the real keystore and **fail** until the real password and alias are filled
  in. Debug builds are not affected.
- No change log entry is strictly needed for a gitignored local file, but one
  will be written to follow the workflow rules.
