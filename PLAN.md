# Plan: Idle + Processing wireframe realignment (PrototypeDesign)

> **Figma file**: `PrototypeDesign` (`fileKey: iHFUNecRDj8tJ5yBqHGPym`).
> **Scope**: Idle (Start Page) + Processing screen only. All other 18 nodes are explicitly deferred.
> **Conventions**: `AGENT.md` is authoritative for token layout, component patterns, and DoD.

## Decisions (locked)

- **Fonts**: Saira Stencil One for headers / big titles, Inter for everything else. (`pubspec.yaml:65-68` already bundles Saira Stencil One; Inter stays hardcoded per `app_theme.dart:17` — bundle only if a future visual review flags missing glyphs.)
- **`KioskButton`**: extend (do not add a new widget). Add two `final` params with defaults that preserve existing call-sites (AGENT.md §2.2).
- **Scope**: Idle + Processing only. All other screens deferred.
- **D2 — `TAKE A SELFIE` font size**: option A — `AppTextStyles.kioskCta` at 96px (matches Figma); wrap the text in `KioskButton` with `FittedBox(fit: BoxFit.scaleDown)` as a defensive safety net against overflow on the 694×171 CTA.

## 0. Figma context — frozen for this PR

| Figma node | Name | Maps to |
|---|---|---|
| `1:2` | Start Page | (root, white idle frame) |
| `28:234` | Frame 2 (864×521.86) | `lib/flow/screens/idle_screen.dart` |
| `28:235` | `NextHouse_Logo` (864×350.86) | bundled logo PNG, top of Idle |
| `28:236` | `NextHouse_Selfie_Button` (694×171, bg `#4D5358`, asymmetric r=80 on topRight/bottomLeft/bottomRight, Saira Stencil One Regular 96px white) | extended `KioskButton` |
| `33:23` | Camera Screen Processing (1280×800, black bg) | `lib/flow/screens/processing_screen.dart` |
| `33:24` | Camera (1212×808 @ `(29, 1)`, blur 3.5px) | bundled photo bg asset |
| `74:86` | `NextHouse_SpinningProcessing` instance @ `(334.56, 178.02)`, 600.88×auto, bg `#F26721`, r=60, gap 42 | new `ProcessingCard` widget |
| `74:83` | `NextHouse_SpinningProcessing` definition | source of `ProcessingCard` |
| `74:76` | "Processing" text (Inter Regular 96px white) | new `AppTextStyles.processingTitle` |
| `74:74` | `NextHouse_SpinningWheel` (262.56×259.67) | bundled spinner PNG, rotated via `RotationTransition` |
| `135:138` | `NextHouse_Record_Button` (Variant3) | **out of scope** — appears in the Processing frame at `(1289, 444)` but is empty in `Variant3`; only visible in Capture/Countdown. |

**Figma variables** (from `figma_get_variable_defs` on `1:2` and `33:23`): exactly one — `NextHouse_Black = #4d5358`. All other colors are hardcoded in the file: `#f26721` (already `AppColors.nextHouseOrange`), `#ffffff`, `#000000`. No new variables to register.

**Deferred** (kept on file for later PRs): Countdown `33:15, 53:85, 53:91, 53:98, 53:105, 53:112, 29:4, 131:144`; AskAnother `69:62`; Result `113:286, 112:195, 113:325, 57:209, 57:217`; Selection grid `74:91`; Delete confirm `117:589`; QR `48:152, 48:123`.

## 1. Extend `KioskButton` with two new `final` params

`lib/widgets/kiosk_button.dart`:

```dart
final BorderRadius? borderRadius;   // default null → AppRadius.button
final TextStyle?   textStyle;       // default null → AppTextStyles.buttonText
```

Wire them into the existing `BoxDecoration` and `Text`. No other changes to gesture handling, the scale-0.96 press animation, or sizing. Wrap the `Text` widget in `FittedBox(fit: BoxFit.scaleDown)` (the D2 safety net — only affects callers that pass a label that would overflow their fixed size).

## 2. Token additions (AGENT.md §1.2, §1.3)

**`lib/theme/app_colors.dart`** — append:
```dart
static const Color nextHouseBlack = Color(0xFF4D5358); // Figma: NextHouse_Black
```

**`lib/theme/app_text_styles.dart`** — append:
```dart
static const TextStyle processingTitle = TextStyle(
  fontFamily: 'Inter', fontSize: 96.0, fontWeight: FontWeight.w400,
  color: Colors.white,
);
static const TextStyle kioskCta = TextStyle(
  fontFamily: 'Saira Stencil One', fontSize: 96.0, fontWeight: FontWeight.normal,
  color: Colors.white,
);
```

**`lib/theme/app_durations.dart`** — append:
```dart
static const Duration processingRotation = Duration(seconds: 2);
```
Justification: matches the existing pattern (named motion tokens); a 2nd use-site on the Share-screen spinner is expected later.

**`lib/theme/app_radius.dart`** — no additions. The 80px corner is intentional, one-off kiosk geometry (AGENT.md §1.4).

## 3. Bundle assets (AGENT.md §4.3–§4.4)

| Source node | Target path | Figma download |
|---|---|---|
| `28:235` | `assets/images/nexthouse_logo.png` (+ `2.0x/`, `3.0x/`) | already in repo, re-export to refresh |
| `74:74` | `assets/images/processing_spinner.png` (+ `2.0x/`, `3.0x/`) | `https://www.figma.com/api/mcp/asset/8bc92e82-4b60-4eb3-a5d3-4b11b47bdb7f` |
| `33:24` | `assets/images/processing_bg_sample.png` (placeholder; runtime uses the captured photo) | `https://www.figma.com/api/mcp/asset/7a814ce7-f214-4163-ba36-01a4650c9945` |

`pubspec.yaml` — update the `assets:` block to also list the resolution variants:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/2.0x/
    - assets/images/3.0x/
```
(Font section unchanged — Saira Stencil One already bundled at `pubspec.yaml:65-68`.)

## 4. Refactor `IdleScreen` — `lib/flow/screens/idle_screen.dart`

| Current (line) | New |
|---|---|
| `Scaffold(backgroundColor: Colors.white)` (15) | keep — matches Figma white bg (per-screen override of the global dark theme) |
| `Image.asset('assets/images/nexthouse_logo.png', height: 250.0, ...)` (23-41) | unchanged; the Figma logo is 864×350.86, our 250px height is intentional responsive |
| `GestureDetector` + raw `Container` CTA (45-69) | replace with `KioskButton(width: 694, height: 171, backgroundColor: AppColors.nextHouseBlack, borderRadius: const BorderRadius.only(topRight: Radius.circular(80), bottomLeft: Radius.circular(80), bottomRight: Radius.circular(80)), textStyle: AppTextStyles.kioskCta, label: 'TAKE A SELFIE', onPressed: onStart)` |
| Inline `Color(0xFF4D5358)` (52) | `AppColors.nextHouseBlack` |
| Inline `TextStyle(fontFamily: 'Saira Stencil One', fontSize: 84, ...)` (61-67) | `AppTextStyles.kioskCta` (96px) |

## 5. Refactor `ProcessingScreen` — `lib/flow/screens/processing_screen.dart`

The current layout uses `Center` + `Positioned.fill` for the photo bg; Figma uses absolute positioning. Rebuild as a `Stack` matching the Figma coords:

```dart
Stack(children: [
  Container(color: Colors.black),                                                          // 1. background
  Positioned(left: 29, top: 1, width: 1212, height: 808, child:                            // 2. blurred photo
    ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5), child:
      hasCapturedImage ? Image.file(File(path), fit: BoxFit.cover, errorBuilder: ...)
                       : Image.asset('assets/images/processing_bg_sample.png', fit: BoxFit.cover, errorBuilder: ...))),
  Positioned(left: 334.56, top: 178.02, child: ProcessingCard(rotation: _rotationController)), // 3. orange card
]);
```

New widget `lib/widgets/processing_card.dart`:

```dart
/// Orange processing card (Figma node 74:83 / 74:86).
class ProcessingCard extends StatelessWidget {
  final Animation<double> rotation;
  const ProcessingCard({super.key, required this.rotation});

  @override
  Widget build(BuildContext context) => Container(
    width: 600.88,                                                                          // Figma value (intentional, AGENT.md §1.4)
    padding: const EdgeInsets.symmetric(vertical: 42, horizontal: AppSpacing.s48),
    decoration: BoxDecoration(
      color: AppColors.nextHouseOrange,
      borderRadius: BorderRadius.circular(60.0),
      boxShadow: const [BoxShadow(color: Color(0x4C000000), blurRadius: 30.0, offset: Offset(0.0, 15.0))],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Processing', style: AppTextStyles.processingTitle),
      const SizedBox(height: 42.0),                                                          // Figma gap-42
      RotationTransition(turns: rotation, child:
        Image.asset('assets/images/processing_spinner.png', width: 262.56, height: 259.67, fit: BoxFit.contain, errorBuilder: ...)),
    ]),
  );
}
```

`ProcessingScreen` keeps the `AnimationController(duration: AppDurations.processingRotation, vsync: this)..repeat()` in its `State` and passes `_rotationController` into `ProcessingCard`.

| Current (line) | New |
|---|---|
| `Image.network('http://localhost:3845/...')` (114-131) | `Image.asset('assets/images/processing_spinner.png', width: 262.56, height: 259.67, fit: BoxFit.contain, errorBuilder: ...)` — bundled |
| `BoxDecoration(color: AppColors.nextHouseOrange, ...)` (83-93) | unchanged |
| `BorderRadius.circular(60.0)` (85) | unchanged (intentional, AGENT.md §1.4) |
| `width: 600.0, height: 440.0` orange card (77) | `width: 600.88` (Figma); let height auto-fit |
| Inline `TextStyle('Inter', 72, w800, ...)` (99-106) | `AppTextStyles.processingTitle` (Inter 96, w400 per Figma) |
| `Duration(seconds: 2)` (29) | `AppDurations.processingRotation` |
| `ImageFiltered(blur sigma 10.0)` (49) | `ImageFiltered(blur sigmaX: 3.5, sigmaY: 3.5)` (Figma value) |
| `Positioned.fill` photo (47-65) | `Positioned(left: 29, top: 1, width: 1212, height: 808)` (Figma value) |
| `Center` orange card (75-135) | `Positioned(left: 334.56, top: 178.02)` (Figma value) |

## 6. Definition of Done (gate from `AGENT.md` §9)

1. `flutter analyze` → 0 issues.
2. `flutter format` → no diff.
3. `grep -r "http://" lib/` → no `localhost:3845` references.
4. `grep -rE "Color\(0x[0-9A-Fa-f]+\)|EdgeInsets\.(all|symmetric|only)\(\s*[0-9]+(\.[0-9]+)?\s*\)" lib/flow/screens/` → no new literals.
5. `grep -rE "Duration\(milliseconds:" lib/flow/screens/` → no new raw `Duration` literals.
6. `flutter test` → passes; add at least one smoke test per screen in `test/widget_test.dart` pumping `IdleScreen` and `ProcessingScreen` (with a fake `capturedImagePath`) inside `AppTheme.darkTheme`.
7. Visual: open on Android landscape tablet, compare Idle (white bg, logo, 694×171 dark CTA) and Processing (black bg, blurred photo 1212×808, orange card 600.88×auto at `(334.56, 178.02)`, Inter 96px "Processing", spinning wheel) against Figma screenshots.
8. Offline: airplane mode, idle → tap → flow into processing (countdown is out of scope, so direct via a debug entry point) → processing renders from bundled assets.
9. `PLAN.md` updated (this file).

## 7. Rollout

- Branch: `feat/wireframe-idle-processing-realignment`.
- Commits (one per logical change, all independently revertable):
  1. `chore(theme): add nextHouseBlack + processingTitle + kioskCta + processingRotation tokens`
  2. `feat(kiosk-button): add borderRadius and textStyle params (defaults preserve existing callers)`
  3. `chore(assets): bundle processing_spinner (74:74) and processing_bg_sample (33:24); update pubspec.yaml`
  4. `feat(widget): extract ProcessingCard (74:83)`
  5. `refactor(processing): swap Image.network for Image.asset, reposition to Figma (334.56, 178.02), use tokens`
  6. `refactor(idle): route through KioskButton + tokens, match Figma (28:236)`
  7. `test(idle,processing): add smoke tests in test/widget_test.dart`
- PR description lists the Figma node IDs touched: `28:234, 28:235, 28:236, 33:23, 33:24, 74:86, 74:83, 74:76, 74:74`.

## 8. Explicitly out of scope (deferred to follow-up PRs)

- Countdown, Capture, AskAnother, Result, ShareSelection, ShareQr screens.
- Camera permission UI, error states, kiosk admin flow.
- `intl` / ARB files.
- Bundling `Inter` as a font (stays hardcoded; revisit only if a visual review flags missing glyphs).
- Promoting the 80px corner radius into a token — it's a one-off (AGENT.md §1.4).
- Promoting the dialog/photo shadows into `app_shadows.dart` (still only 2 use-sites).

---

# Plan v3: Capture + Countdown + Result/Gallery + Onboarding (DONE)

> **Figma file**: `PrototypeDesign` (`fileKey: iHFUNecRDj8tJ5yBqHGPym`).
> **Scope**: complete the wireframe realignment across the full photobooth flow
> (Idle → Processing → Countdown → Capture → Result → Share) and add lightweight
> onboarding hints for the first-time use of the camera, gallery, and QR screens.
> Builds on the v2 Idle + Processing baseline.

## Decisions (locked)

- **D1**: Saira Stencil One = headers/big titles; Inter = everything else. Unchanged.
- **D2**: 96px + `FittedBox(scaleDown)` safety net. Unchanged.
- **D3 (countdown phase model)**: single `CountdownScreen` widget, phases driven by state flags. Verbatim from Figma:
  - t = 0.0–0.8s intro: "Say..." Inter 96px white (suspense, Figma 131-144)
  - t = 0.8s + countdownValue 5→1:
    - 5 + "I love hostels!" text
    - 4 + "I love hostels!" text
    - 3 number only
    - 2 number only
    - 1 number only
  - t = 0 (after countdown): flashActive=true for 150ms
  - then → `captureEnd` state, ~250ms hold
  - then → `processing`
- **D4 (end state)**: new `PhotoboothState.captureEnd` between countdown and processing. 250ms hold.
- **D5 (share flow)**: state machine adds `shareConfirm` and `shareUploading`. Transitions: `shareSelection.Done` → if all selected → `shareUploading`, else `shareConfirm`. `shareConfirm.Yes` → `shareUploading`. `shareConfirm.No` → `shareSelection`. `shareUploading` 2s hold → `shareQr`. `shareQr` 60s auto-reset (no visible countdown) → `resetToHome`.
- **D6 (toolbar wiring)**: only `onShare` wired. `editPhoto()` and `printPhoto()` are `debugPrint` stubs.
- **D7 (idle record button)**: not a separate state; decorative inside `CountdownScreen`.
- **D8 (QR timeout)**: change from 30s to 60s. Drop visible countdown ring. Add a thin progress bar at bottom of QR card (option C from Q2). New `AppDurations.shareQrAutoReset = 60s`.
- **D9 (ask another)**: include in this PR — token swap only, no visual change.
- **D10 (share selection title)**: keep a small English title above the grid: "Select your photos to share" (Inter 32px white bold).
- **D11 (onboarding)**: every time the user reaches the screen, no persistence. Single `OnboardingOverlay` widget. Tap anywhere + 5s auto-dismiss. White rounded card r=24 with shadow, Inter 24px w500 dark text, small X in top-right.

## Figma context — frozen for v3

| Figma node | Name | Maps to |
|---|---|---|
| `29:4` | `CameraScreen` (no text) | first frame of `CountdownScreen` (decorative record button at (1141, 327.5)) |
| `131:144` | `CameraScreenStartTimer` — "Say..." Inter 96px white | countdown intro phase (~800ms) |
| `33:15` | `CameraScreenTimer` — "I love hostels!" Inter 96px white | countdown prep text (t=5) |
| `53:85` | Timer 5 — "5" + text | countdown t=5 |
| `53:91` | Timer 4 | countdown t=4 |
| `53:98` | Timer 3 — no text | countdown t=3 |
| `53:105` | Timer 2 — no text | countdown t=2 |
| `53:112` | Timer 1 — no text | countdown t=1 |
| `57:209` | Flash — white frame | `_showFlash` overlay |
| `57:217` | End — blur 2px on camera, no UI | new `CaptureEndScreen` |
| `69:62` | AskAnother orange dialog | `AskAnotherScreen` (token swap only) |
| `112:195` | `End Photo 1` | `ResultScreen` (carousel page 1) |
| `113:286` | `End Photo 2` | `ResultScreen` (carousel page 2) |
| `113:325` | `End Photo 3` | `ResultScreen` (carousel page 3) |
| `135:139` | `NextHouse_Record_Button` Variant4 (filled) | `RecordButton` widget |
| `74:91` | `PhotoSelectionSharePage` — 4×3 grid | `PhotoSelectionShareScreen` (rebuild) |
| `117:589` | `OverlayAreyousure` — 691×620 orange card | new `ShareConfirmScreen` |
| `48:123` | Share Processing — 2 photos + spinner | new `ShareUploadingScreen` |
| `48:152` | Share 2 (QR) — blurred camera + white card + Scan me! + Tap to go back | `PhotoGalleryScreenShare2` (rewrite) |

**No new Figma variables.** All colors = existing tokens.

## Token additions (v3)

`app_text_styles.dart` — appended 9 new styles:
- `countdownTitle` (Inter 96px w400 white + shadow)
- `countdownNumber` (Inter 96px w400 white + shadow)
- `areYouSureTitle` (Inter 64px w400 white, h=1.15)
- `askAnotherTitle` (Inter 36px w700 white, h=1.2)
- `areYouSureChoice` (Inter 40px w500 orange)
- `askAnotherChoice` (Inter 28px w700 orange)
- `scanMe` (Inter 48px w400 black)
- `tapToGoBack` (Inter 32px w400 white70)
- `donePill` (Inter 40px w500 white)
- `galleryToolbarLabel` (Inter 14px w500 white)
- `onboardingMessage` (Inter 24px w500 black87)

`app_durations.dart` — appended 4 new durations:
- `countdownFlash` (150ms)
- `captureEndHold` (250ms)
- `shareUploading` (2s)
- `shareQrAutoReset` (60s, replaces hardcoded 30s)

`app_colors.dart`, `app_spacing.dart`, `app_radius.dart` — no additions.

## Bundled assets (v3)

No new files. The existing `assets/images/processing_bg_sample.png` (Figma 33:24)
is reused for the share processing strip and the QR blurred background.

## New widget files (v3)

```
lib/widgets/record_button.dart          // 154x155 CustomPainter filled circle
lib/widgets/gallery_button.dart         // 50x66 icon+label, 4 action variants
lib/widgets/gallery_chevron.dart        // 100x100 white circle + chevron
lib/widgets/thumbnail_checkmark.dart    // 89x141 white pill with check
lib/widgets/are_you_sure_card.dart      // 691x620 orange card r=40
lib/widgets/qr_share_card.dart          // 570.24x648.24 white card r=60 + QR + progress bar
lib/widgets/share_photo_strip.dart      // 2 photos side-by-side
lib/widgets/onboarding_overlay.dart     // White rounded card, tap+5s dismiss
```

## State machine (v3)

```dart
enum PhotoboothState {
  idle,
  countdown,
  captureEnd,        // NEW
  captureFeedback,   // SEMANTIC CHANGE: now flash overlay only
  processing,
  askAnother,
  result,
  shareSelection,
  shareConfirm,      // NEW
  shareUploading,    // NEW
  shareQr,
}
```

New methods: `_triggerFlashAndCapture`, `_startCaptureEnd`, `confirmShareSelection`,
`proceedShareUpload`, `cancelShareConfirm`, `editPhoto`/`printPhoto` stubs,
`shareQrProgress` getter (drives the thin QrShareCard progress bar).

## Per-screen change list (v3)

- `countdown_screen.dart` — full rewrite: full-bleed camera + decorative record button + phased "Say..."/"I love hostels!"/number overlays per Figma 29-4, 131-144, 33-15, 53-85..112, 57-209. Onboarding overlay at top.
- `capture_screen.dart` — simplified to flash-only overlay (150ms white fade).
- `capture_end_screen.dart` — NEW: blurred photo, no UI, 250ms hold.
- `processing_screen.dart` — v2 already implemented, no changes.
- `ask_another_screen.dart` — token swap only (`askAnotherTitle`/`askAnotherChoice`).
- `result_screen.dart` — full rewrite: full-bleed carousel + `GalleryChevron` L/R + 4-button `GalleryButton` toolbar at the bottom. Onboarding overlay at top.
- `photo_selection_share_screen.dart` — rebuilt as 4×3 grid (Figma 74:91) with Done pill in last cell. Small English title above. Wired to `confirmShareSelection`.
- `share_confirm_screen.dart` — NEW: `AreYouSureCard` overlay.
- `share_uploading_screen.dart` — NEW: `SharePhotoStrip` + centered `ProcessingCard` spinner.
- `photo_gallery_screen_share_2.dart` — rebuilt: blurred bg + `QrShareCard` with `Scan me!` + thin 60s progress bar + `Tap to go back` caption.

## Definition of Done (v3)

1. `flutter analyze` → 0 issues.
2. `flutter format` → no diff.
3. `grep -r "http://" lib/` → 0 references.
4. `grep -rE "Color\(0x[0-9A-Fa-f]+\)|EdgeInsets\.(all|symmetric|only)\(\s*[0-9]+(\.[0-9]+)?\s*\)" lib/flow/screens/` → no new literals.
5. `grep -rE "Duration\(milliseconds:" lib/flow/screens/` → no new raw `Duration` literals.
6. `flutter test` → 14/14 passes. Smoke tests cover: Idle, Processing, Countdown (intro + 3), CaptureScreen, CaptureEndScreen, AskAnother, Result, ShareSelection, ShareConfirm, ShareUploading, ShareQr, OnboardingOverlay (tap + auto-dismiss), GalleryButton.
7. Visual: side-by-side with Figma screenshots on Android landscape tablet.
8. Offline: kill network → full flow works from bundled assets.
9. `PLAN.md` updated (this section).

## Rollout (v3, atomic commits, all independently revertable)

1. `chore(theme): add countdownTitle/Number, areYouSure/Title/Choice, askAnotherTitle/Choice, scanMe, tapToGoBack, donePill, galleryToolbarLabel, onboardingMessage, countdownFlash, captureEndHold, shareUploading, shareQrAutoReset tokens`
2. (skipped — no new assets needed; share samples reuse `processing_bg_sample.png`)
3. `feat(widgets): extract RecordButton, GalleryButton, GalleryChevron, ThumbnailCheckmark, AreYouSureCard, QrShareCard, SharePhotoStrip`
4. `feat(widget): add OnboardingOverlay (tap-to-dismiss + 5s auto-dismiss, white card with X)`
5. `feat(state): add captureEnd, shareConfirm, shareUploading states; extend countdown driver; bump shareQr auto-reset 30s→60s`
6. `refactor(countdown): full-bleed camera + intro "Say..." + record button + phase text/number overlays; add captureEnd, shareConfirm, shareUploading dispatch stubs`
7. `refactor(capture-flash): strip CaptureScreen to flash-only overlay`
8. (combined with commit 6) `feat(screen): CaptureEndScreen (57-217) + dispatch`
9. `refactor(ask-another): swap inline TextStyles for askAnotherTitle/Choice tokens (69-62)`
10. `refactor(result): rebuild as full-bleed carousel + GalleryChevron + 4-button GalleryButton toolbar + OnboardingOverlay`
11. `refactor(share-selection): rebuild as 4×3 grid + Done pill + small English title; wire to confirmShareSelection`
12. `feat(screen): ShareConfirmScreen (117-589) + AreYouSureCard + dispatch`
13. `feat(screen): ShareUploadingScreen (48-123) + SharePhotoStrip + dispatch`
14. `refactor(share-qr): rebuild with QrShareCard + Scan me! + Tap to go back + thin 60s progress bar`
15. `test(*): add smoke tests for all 10 screens + OnboardingOverlay + GalleryButton`
16. `docs(plan): append v3 (this section) to PLAN.md`

PR description lists the Figma node IDs touched: `29:4, 131:144, 33:15, 53:85, 53:91, 53:98, 53:105, 53:112, 57:209, 57:217, 69:62, 112:195, 113:286, 113:325, 135:139, 74:91, 117:589, 48:123, 48:152`.

## Explicitly out of scope (still deferred after v3)

- `Edit` and `Print` functionality in result toolbar (stubs only).
- Camera permission UI, error states.
- `intl` / ARB.
- Bundling `Inter` as a font.
- `AppShadows` extraction (still 2 use-sites).
- Per-locale onboarding copy variants.
- `figma_get_design_context` integration for Code Connect.
