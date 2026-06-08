# NextHouseInstant - Agent Quickstart & Quirks

## 1. Custom State-Driven Navigation (No Router)
- **Do NOT use `Navigator`, `go_router`, or `setState` for page changes.**
- Screen transitions are managed strictly by mutating the `PhotoboothState` enum inside the `PhotoboothFlowState` ChangeNotifier (`lib/flow/photobooth_flow_state.dart`).
- The entire view is swapped by an `AnimatedSwitcher` in `PhotoboothFlowScreen`.

## 2. Timing & State Reset Quirks
- **Always call `_cancelTimers()`** in `PhotoboothFlowState` before initiating any state transitions. Outstanding timers will trigger out-of-order state resets (such as auto-resetting back to the Idle screen mid-interaction).

## 3. Duplicate App Colors Files (Potential Pitfall)
- `flutter/lib/theme/app_colors.dart` is a **read-only auto-generated** backup of Pranata variables.
- `lib/theme/app_colors.dart` (without the `flutter/` prefix) is the **actual colors file used by the app**. Do not edit the `flutter/` folder files.

## 4. Kiosk & Offline Constraints
- Locked to **landscape orientation** and **immersiveSticky fullscreen**.
- Dark theme only. Do not add a light theme.
- Must run **fully offline**. All assets must be bundled via `pubspec.yaml` (never use `Image.network`).

## 5. Verification & Build Commands
- Verify your work using standard Flutter/Gradle commands:
  - Format: `flutter format .`
  - Lint: `flutter analyze`
  - Tests: `flutter test`
  - Build Android APK via Gradle wrapper under `android/`:
    - Windows PowerShell: `.\gradlew.bat assembleDebug`
    - Unix Bash: `./gradlew assembleDebug`
