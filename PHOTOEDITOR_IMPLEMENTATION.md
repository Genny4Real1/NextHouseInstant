# PhotoEditor Native Wrapper — Implementation Summary

Date: 2026-06-08

This file summarizes the changes made to integrate and expose burhanrashid52's PhotoEditor (MIT) to the Flutter app via a minimal Android native wrapper.

## Goal

Provide a small, free-licensed native Android integration for PhotoEditor and expose a simple Dart API to open the native editor and receive the edited image path.

## What I added and modified

- Modified: `android/app/build.gradle.kts`
  - Ensured the native dependency is present: `implementation("com.burhanrashid52:photoeditor:3.1.0")`.
- Modified: `android/app/src/main/kotlin/com/nexthouse/instant/nexthouse_instant/MainActivity.kt`
  - Added a `MethodChannel` (`nexthouse/photo_editor`) with method `openEditor`.
  - `openEditor` starts `PhotoEditorActivity` for result and returns the edited image path or an error.
- Added: `android/app/src/main/kotlin/com/nexthouse/instant/nexthouse_instant/PhotoEditorActivity.kt`
  - Activity that hosts `ja.burhanrashid52.photoeditor.PhotoEditorView` and initializes `PhotoEditor`.
  - Provides `Save` and `Cancel` buttons. On save, calls `photoEditor.saveAsFile()` and returns the saved path via activity result.
- Added: `android/app/src/main/res/layout/activity_photo_editor.xml`
  - Layout for the native editor Activity with `PhotoEditorView` and simple controls.
- Modified: `android/app/src/main/AndroidManifest.xml`
  - Registered `.PhotoEditorActivity` so it can be launched from the Flutter `MethodChannel`.
- Added: `lib/photo_editor_native.dart`
  - Dart wrapper exposing `PhotoEditorNative.openEditor(String? imagePath)` that calls the method channel and returns the edited image path.

## How to use (Dart)

1. Import the wrapper:

```dart
import 'package:your_app/photo_editor_native.dart';
```

2. Call the editor (pass a file path or URI string):

```dart
final editedPath = await PhotoEditorNative.openEditor('/absolute/path/to/image.jpg');
if (editedPath != null) {
  // Use editedPath (it's saved to app cache by the native Activity)
}
```

The method returns the edited file path on success, throws or returns an error if cancelled or failed.

## Notes & Caveats

- The native integration uses the PhotoEditor library (MIT) and saves the edited image to the app's cache directory. If you need persistent storage, move the file from cache to your desired location in Dart or native code.
- No special storage permissions are required when saving to `cacheDir`. If you plan to save to external storage, you must request runtime permissions or use SAF.
- The native Activity is intentionally minimal (simple Save/Cancel). You can extend the UI, include more `PhotoEditor` options (shapes, sticker packs, fonts), or expose more granular controls via the `MethodChannel`.
- Error handling: `openEditor` returns an error result when the activity reports failure or cancellation. The Dart wrapper surfaces platform exceptions.

## Next recommended steps

- Integrate a call to `PhotoEditorNative.openEditor` in your photobooth flow (`PhotoboothFlowState.editPhoto()`), receiving and storing the edited image path.
- Move the edited image to persistent storage if you want to keep it between app restarts.
- Optionally customize `PhotoEditorActivity` to preconfigure brush/filters and to expose more features back to Flutter.

If you want, I can now wire the call into `PhotoboothFlowState.editPhoto()` and handle storing the returned edited file.
