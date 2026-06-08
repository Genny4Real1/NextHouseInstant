# CLAUDE.md — NextHouse Instant (Figma MCP Integration Rules)

> **Project**: `nexthouse_instant` — Flutter Android kiosk photobooth app for Next House Copenhagen.
> **Stack**: Flutter 3.11+ / Dart, Material 3, dark-only, landscape-locked, immersive (fullscreen).
> **Target device**: Android kiosk tablets. Offline-first. No backend (mock QR share only).
> **Primary goal of this file**: make Figma MCP integration deterministic. Every design-handoff artifact (color, type, spacing, radius, asset, screen frame) must map to a single, known, existing target in this repo.

---

## 0. Figma MCP Setup

- **MCP config**: `.opencode/mcp.json` declares the Figma MCP server. Do not edit the Figma-related entries without the user's confirmation.
- **Available tools (Figma MCP)**: `figma_whoami`, `figma_get_metadata`, `figma_get_design_context`, `figma_get_screenshot`, `figma_search_design_system`, `figma_use_figma`, `figma_upload_assets`, `figma_get_variable_defs`, `figma_get_libraries`, `figma_get_code_connect_*`, `figma_generate_diagram`, `figma_create_new_file`, `figma_generate_figma_design`.
- **Standard workflow for any Figma hand-off**:
  1. `figma_whoami` → resolve `planKey` if a new file must be created.
  2. `figma_get_screenshot` (use `maxDimension: 2048` for visual review) on the screen frame.
  3. `figma_get_design_context` on the same node for reference code (Flutter, not web — we ignore its React/Vue hints; the metadata + variable map is what matters).
  4. `figma_get_variable_defs` on the root frame → extract all design tokens (colors, type, spacing, radius, effects).
  5. `figma_search_design_system` *before* writing any new component, variable, or asset (re-use first).
  6. `figma_upload_assets` for raster/vector assets; then bundle via `pubspec.yaml` → `flutter pub get` → `Image.asset('assets/...')`.
  7. `figma_use_figma` only for downstream design-system edits (e.g. adding a Code Connect mapping).
- **Always prefer reuse**: search the Figma file's design-system library for an existing component/variable before proposing a new one. Mirror it 1:1 in this repo.

---

## 1. Design Tokens

### 1.1 Where they live (the single source of truth)

All design tokens are Dart `static const` fields on private-constructor classes under `lib/theme/`. **There is no JSON/YAML token file, no Style Dictionary, no build-time transformer.** Tokens are consumed by direct Dart import.

| File | Token type | Notes |
|---|---|---|
| `lib/theme/app_colors.dart` | Color (Color/0xAARRGGBB) | 8 named tokens; private constructor (`AppColors._()`) — non-instantiable |
| `lib/theme/app_text_styles.dart` | TextStyle | 5 named styles; `Inter` font baked in |
| `lib/theme/app_spacing.dart` | double | 9-step scale: `s4 … s96` |
| `lib/theme/app_radius.dart` | double + BorderRadius getters | 3 radii + ready-made `BorderRadius` getters |
| `lib/theme/app_durations.dart` | Duration + int | 6 tokens; mixes animation + flow-logic durations |
| `lib/theme/app_theme.dart` | ThemeData (aggregator) | Single `darkTheme` getter; do **not** add a light theme |

### 1.2 Color tokens — current values

`lib/theme/app_colors.dart:1-15`

```dart
class AppColors {
  AppColors._();

  static const Color background      = Color(0xFF0F172A); // Slate Obsidian
  static const Color surface         = Color(0xFF1E293B); // Charcoal Gray
  static const Color primary         = Color(0xFF38BDF8); // Muted Cyan
  static const Color textPrimary     = Color(0xFFF8FAFC); // Off-White
  static const Color textSecondary   = Color(0xFF64748B); // Slate Muted
  static const Color error           = Color(0xFFEF4444);
  static const Color success         = Color(0xFF10B981);
  static const Color nextHouseOrange = Color(0xFFF26721); // brand accent
}
```

**Rules**
- New Figma color variables must be added here as a `static const Color` with a semantic name (e.g. `nextHouseBlack = Color(0xFF4D5358)` — currently only an inline literal in `idle_screen.dart:52`).
- Use the Figma variable path as the comment (`// Slate Obsidian`, `// Muted Cyan`).
- Never inline a `Color(0xFF…)` literal in a screen file; route it through `AppColors.*`. The 3 known inlines are pending refactors (`qr_code_placeholder.dart:12`, `camera_placeholder.dart:27-28`, `idle_screen.dart:52`) — when touched, lift them into `app_colors.dart`.

### 1.3 Typography tokens — current values

`lib/theme/app_text_styles.dart:1-42`

```dart
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle countdownDisplay = TextStyle(
    fontFamily: 'Inter', fontSize: 120.0, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle header1 = TextStyle(
    fontFamily: 'Inter', fontSize: 36.0, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle header2 = TextStyle(
    fontFamily: 'Inter', fontSize: 24.0, fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter', fontSize: 20.0, fontWeight: FontWeight.w500,
    color: AppColors.background,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter', fontSize: 16.0, fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
```

**Rules**
- The Figma type ramp **must** map to one of these 5 styles, or a new one added here (do not inline a `TextStyle` in a screen).
- Font family is hardcoded to `Inter` in **both** `app_theme.dart:17` (`fontFamily: 'Inter'` on the `ThemeData`) **and** every `TextStyle` here. The font is **not yet bundled in `pubspec.yaml`** (see §4).
- Weight convention used across the codebase: `w100`…`w900` spelled out (e.g. `FontWeight.w500`, `FontWeight.w800`). Match this when extending.

### 1.4 Spacing & radius tokens

`lib/theme/app_spacing.dart` (multiples of 4): `s4, s8, s12, s16, s24, s32, s48, s64, s96`.
`lib/theme/app_radius.dart`: `button = 16`, `card = 24`, `container = 20`. Exposes `buttonBorder`, `cardBorder`, `containerBorder` `BorderRadius` getters.

**Rules**
- All `SizedBox(height/width: …)`, `EdgeInsets.*`, `padding`, `gap` values in screens must come from `AppSpacing.*`.
- Pinned/absolute sizes (kiosk frame sizes, fixed 4:3 camera viewfinder, 600×140 CTA, 540×380 dialog) are *intentionally* hardcoded because they correspond to the Figma frame — do not refactor them into `AppSpacing` unless the spec changes.
- Border radius must use `AppRadius.*` getters; raw `BorderRadius.circular(…)` is only acceptable for one-off kiosk geometry (e.g. pill-shaped 70-radius CTA in `idle_screen.dart:53-57`).

### 1.5 Duration / motion tokens

`lib/theme/app_durations.dart`: `pageTransition (300ms)`, `buttonPress (100ms)`, `flashFade (150ms)` + flow values `countdownStart (5s)`, `captureFeedback (2s)`, `processing (2500ms)`, `resultAutoReset (1 min)`.

**Rules**
- Animation durations only — never use `Duration(milliseconds: …)` literals in screen code; import `AppDurations`.
- The flow values (`countdownStart`, etc.) are referenced by the state machine (`photobooth_flow_state.dart:20`) — do not move them.

### 1.6 Token transformation systems

**None.** No Style Dictionary, no build-time codegen, no JSON. If Figma exports variables as JSON, convert by hand into the 5 Dart files above.

---

## 2. Component Library

### 2.1 Where they live

`lib/widgets/`. Four components today, all stateless or locally-stateful, all hand-rolled (no Material wrappers that conflict with the dark kiosk look):

| Widget | File | Purpose | Token dependencies |
|---|---|---|---|
| `KioskButton` | `lib/widgets/kiosk_button.dart` | Primary CTA with press scale animation (0.96) | `AppColors`, `AppRadius.button`, `AppSpacing.s48`, `AppDurations.buttonPress`, `AppTextStyles.buttonText` |
| `KioskContainer` | `lib/widgets/kiosk_container.dart` | Rounded surface card around a child (camera viewfinder, etc.) | `AppColors.surface` (default bg), `AppRadius.container` |
| `CameraPlaceholder` | `lib/widgets/camera_placeholder.dart` | Camera fallback + reticle + face silhouette | `AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.primary`, `AppSpacing.s16`; uses `CustomPaint` (`CameraReticlePainter`) |
| `QrCodePlaceholder` | `lib/widgets/qr_code_placeholder.dart` | Stylised placeholder QR (deterministic 25×25 grid) | No token deps (intentional: max contrast); uses `CustomPaint` (`QrCodePainter`) |

**Architecture**: bare StatelessWidget/StatefulWidget with `super.key`, `const` constructors, named required parameters. No props enums, no variants.

### 2.2 Documentation / storybook

**None.** No Storybook, no widget gallery, no Markdown docs.
- Tests: only `test/widget_test.dart` (still the default Flutter counter test — does not exercise `MyApp`; refactor or delete when touching).
- The closest thing to "documentation" is the comment header on each widget file describing the intent.

**Rules**
- When adding a new widget: add a top-of-file `///` Dartdoc comment, place it under `lib/widgets/`, follow the existing `super.key` + `const` constructor + named-required-args pattern.
- When a widget gains a visual variant, add a second `final` bool/enum field with a `= …` default — do not break existing call-sites.
- Add at least one smoke test in `test/` that pumps the widget in a `MaterialApp` wrapped in `AppTheme.darkTheme`.

### 2.3 Component architecture for new Figma components

For any Figma component discovered via `figma_search_design_system`:
1. Match the Figma component name to a Dart class name (`PascalCase`, no spaces).
2. Wrap the variant axes (size, state, color) as `final` constructor params with sensible defaults.
3. Always wrap with `GestureDetector`/`InkWell` for tap, never `ElevatedButton` unless the Figma spec is explicitly Material.
4. Internally compose `BoxDecoration` + `Text` from `AppColors`/`AppRadius`/`AppSpacing`/`AppTextStyles`. No raw hex, no raw px, no raw `Duration` literals.
5. Place the new file under `lib/widgets/`. If the component is screen-specific (used by exactly one screen), keep it in `lib/flow/screens/` as a private class — but prefer extracting it when reused.

---

## 3. Frameworks & Libraries

| Concern | Choice | Version (per `pubspec.yaml`) |
|---|---|---|
| App framework | **Flutter** (Dart SDK `^3.11.1`) | bundled with Flutter |
| UI design system | **Material 3** (`useMaterial3: true`, `Brightness.dark`) — used sparingly | bundled |
| Icons | **Material Icons** (`uses-material-design: true` in `pubspec.yaml`) + ad-hoc Material rounded variants | bundled |
| Camera | `camera` | `^0.12.0+1` |
| QR | `qr_flutter` (`QrImageView`) | `^4.1.0` |
| iOS-style icons | `cupertino_icons` | `^1.0.8` |
| State | **Hand-rolled `ChangeNotifier` + `AnimatedBuilder`** (no Riverpod/Bloc/Provider) | stdlib |
| Routing | **Custom state machine** (`PhotoboothState` enum + `AnimatedSwitcher`) — no `go_router`, no `Navigator` | stdlib |
| Lint | `flutter_lints` | `^6.0.0` |

**Build / bundler**: standard Flutter toolchain (`flutter build apk`, `flutter run -d <android-id>`). Gradle on Android, CocoaPods on iOS, CMake/MSVC on Windows (all platform folders scaffolded; only Android is exercised).

**Targets** (`lib/main.dart:11-17`):
- Landscape-locked (`landscapeLeft`, `landscapeRight`).
- `SystemUiMode.immersiveSticky` — no system bars; pure kiosk experience.

**Rules**
- Do **not** add new third-party packages without an explicit user instruction. This codebase deliberately stays stdlib + Material + `camera` + `qr_flutter`.
- Do not introduce Riverpod/Bloc/Provider. Mirror the existing `ChangeNotifier` pattern (`PhotoboothFlowState` is the canonical example).
- Do not add `go_router` or `Navigator` for screen transitions; the `AnimatedSwitcher` in `photobooth_flow_screen.dart:43` is the only navigation mechanism.

---

## 4. Asset Management

### 4.1 Current state — broken / placeholder

Two screens still load assets from a **local Figma Make dev server** over the network:

- `lib/flow/screens/idle_screen.dart:23-41` → `http://localhost:3845/assets/e9108d7c9f046f4af4488df44bec74f286ab1109.png` (Next House logo, 250 px high)
- `lib/flow/screens/processing_screen.dart:114-131` → `http://localhost:3845/assets/d8785036d17612960f0b02a9176166b7c5010ebc.png` (spinner PNG, 220×220)

Both include an `errorBuilder` that falls back to a hand-drawn `Text`/`CircularProgressIndicator`. **Both must be migrated to bundled assets** per `PLAN.md` steps 2–3.

### 4.2 Source assets (design source-of-truth)

- `DesignPlanning/BrandGuideLines/Logos/` — 4 logo PNGs:
  - `image0.PNG`
  - `Next_House_logo (1).png`
  - `Next_House_logo-negativ (1).png` *(the one used at runtime — the one referenced by the Figma Make URL above)*
  - `nh logo white.png`
- `DesignPlanning/BrandGuideLines/StockPhotos/` — 4 stock JPGs (`pexels-*`).
- `DesignPlanning/BrandGuideLines/Design_Guide_Next _ Steel_House-compressed.pdf` — the printed brand guide.

### 4.3 Bundling pipeline (target state)

Per `PLAN.md` step 2, the required structure is:

```
assets/
  images/
    idle_logo.png            # exported from Figma, 1x/2x for Android
    processing_image.png     # exported spinner asset
    component icons (svg/png)
  fonts/
    Inter-Regular.ttf
    Inter-Bold.ttf
    Inter-ExtraBold.ttf
    Inter-*.ttf              # weights used in app_text_styles.dart
```

And `pubspec.yaml` must include:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
        - asset: assets/fonts/Inter-ExtraBold.ttf
          weight: 800
        - asset: assets/fonts/Inter-Black.ttf
          weight: 900
```

### 4.4 MCP-driven asset ingestion workflow

1. `figma_upload_assets` to push the Figma-exported PNG/SVG into the Figma file (if re-syncing).
2. Export the file from Figma desktop (1× + 2× for Android; prefer SVG for icons).
3. Drop the files into `assets/images/` (and `assets/fonts/` for `Inter`).
4. Update `pubspec.yaml` `assets:` and `fonts:` blocks as above.
5. Replace `Image.network('http://localhost:3845/...')` with `Image.asset('assets/images/...')` and **keep** the `errorBuilder` as a defensive fallback.
6. Run `flutter pub get` then `flutter analyze` — both must pass clean.

### 4.5 Asset optimization

- **No CDN, no network images at runtime.** This is a kiosk — it must work offline.
- For Android: provide 1×/2×/3× variants under `assets/images/2.0x/`, `assets/images/3.0x/` (Flutter resolution-aware).
- Prefer SVG for icons (rasterise at build time or use `flutter_svg` — not currently in `pubspec.yaml`, add only with user approval).
- Images are referenced as **literal `String` paths** in `Image.asset(...)` — no asset index, no codegen, no enum.

---

## 5. Icon System

### 5.1 Sources

- **Material Icons** (the `Icons.*` class). `pubspec.yaml:60` enables `uses-material-design: true`. Used everywhere; examples already in code: `Icons.chevron_left_rounded`, `Icons.ios_share_rounded`, `Icons.delete_outline_rounded`, `Icons.print_rounded`, `Icons.edit_rounded`, `Icons.close_rounded`, `Icons.check_rounded`, `Icons.arrow_forward_rounded`.
- **Custom-painted icons** (e.g. face silhouette + reticle in `camera_placeholder.dart:35-78`). Used when no Material equivalent exists.
- **Branding logo** — see §4.2 (currently a remote Figma Make URL in `idle_screen.dart:24`).

### 5.2 No SVG / icon-font library

There is no `flutter_svg`, no `font_awesome`, no custom `.ttf` icon font. The project is **100% Material Icons + custom `CustomPainter`**.

### 5.3 Naming & usage conventions

- Always use the `_rounded` Material variant to match the soft, modern kiosk look (e.g. `Icons.close_rounded`, not `Icons.close`).
- Icon size in toolbars: `32.0`. Icon size in IconButton chrome: `24.0` (close) or `40.0` (chevron arrows in `result_screen.dart:249,271`).
- Icon color: `Colors.white` for toolbar/overlay; `AppColors.primary` for highlight, `AppColors.error` for destructive (`result_screen.dart:219,225`).
- When a new Figma icon is needed:
  1. Check Material Icons first — if there's a 1:1 match, use it.
  2. Else export from Figma as **SVG**, prefer converting to a `CustomPainter` (matches the existing `CameraReticlePainter` / `QrCodePainter` pattern) over adding a new dependency.
  3. Document the Material icon name in the widget's Dartdoc.

---

## 6. Styling Approach

### 6.1 Methodology

This is **Flutter**, not CSS — there are no `*.module.css`/Styled Components. The styling contract is:

- **Theme aggregation**: `lib/theme/app_theme.dart:1-21` builds a single `ThemeData` from the 5 token files. `MaterialApp(theme: AppTheme.darkTheme, …)` is the only consumer (`main.dart:30`).
- **Widget-local styling**: every screen/widget composes its own `BoxDecoration`, `TextStyle`, `EdgeInsets`, `BorderRadius` by importing the token classes. **No global stylesheet, no theme extensions** (e.g. no `Theme.of(context).extension<…>()`), no styled-components equivalent.
- **Inline `const TextStyle(...)` literals** appear in screen files (e.g. `result_screen.dart:96-101`, `processing_screen.dart:99-106`, `idle_screen.dart:61-67`). These are **known debt** — when a Figma update changes their values, route them through `AppTextStyles.*` instead of editing the literal.

### 6.2 Global styles

- `MaterialApp.theme = AppTheme.darkTheme` is the only global. It sets:
  - `brightness: Brightness.dark`
  - `scaffoldBackgroundColor: AppColors.background`
  - `colorScheme: ColorScheme.dark(surface: AppColors.surface, primary: AppColors.primary, onPrimary: AppColors.background, onSurface: AppColors.textPrimary)`
  - `fontFamily: 'Inter'`
  - `useMaterial3: true`
- No light theme exists. Do not add one (kiosk is dark-only).
- No `Theme.of(context).textTheme.*` is used — text styles are applied directly from `AppTextStyles.*`.

### 6.3 Responsive design

- **One breakpoint model**: the app is locked to **landscape tablet** (`SystemChrome.setPreferredOrientations` in `main.dart:11-14`). It does **not** need to handle portrait, phones, or split-screen.
- The camera viewfinder is fixed at `AspectRatio(aspectRatio: 4 / 3)` (`countdown_screen.dart:44`, `capture_screen.dart:67`, `result_screen.dart:136`).
- Hardcoded kiosk sizes (e.g. `width: 620.0, height: 140.0` for the CTA) are intentional and match the Figma frame. Do **not** "fix" them with `MediaQuery`/`LayoutBuilder` — the design is absolute, not fluid.
- `PageView` in `result_screen.dart` uses `viewportFraction: 0.65` and a per-page scale animation (0.85 → 1.0) for the gallery peek effect. This is the only responsive-style behaviour in the app.

### 6.4 Effects / shadows

Defined inline per-widget, not tokenised:

- Dialog/processing card shadow: `BoxShadow(color: Colors.black.withAlpha(76), blurRadius: 30.0, offset: const Offset(0.0, 15.0))` — appears in `processing_screen.dart:88-91` and `ask_another_screen.dart:67-71`. **Candidate for promotion** to an `AppShadows` file if/when a 3rd use-site appears.
- Card shadow: `BoxShadow(color: Colors.black.withAlpha(127), blurRadius: 15.0, spreadRadius: 1.0, offset: const Offset(0.0, 6.0))` (`result_screen.dart:142-148`).
- Selection glow: `AppColors.primary.withAlpha(50), blurRadius: 15.0` (`photo_selection_share_screen.dart:91-95`).

When the Figma spec changes, update the literal where it appears. There is no `AppShadows` class yet.

---

## 7. Project Structure

```
NextHouseInstant/
├── android/  ios/  linux/  macos/  windows/  web/      # platform shells (Android is the real target)
├── lib/
│   ├── main.dart                                       # entry: locks orientation, immersive mode, mounts MyApp
│   ├── flow/
│   │   ├── photobooth_flow_screen.dart                 # AnimatedSwitcher + per-state screen dispatch
│   │   ├── photobooth_flow_state.dart                  # ChangeNotifier + PhotoboothState enum + camera + timers
│   │   └── screens/
│   │       ├── idle_screen.dart                        # NEXT HOUSE logo + TAKE A SELFIE CTA
│   │       ├── countdown_screen.dart                   # live camera + giant 120px number
│   │       ├── capture_screen.dart                     # flash overlay + captured photo
│   │       ├── processing_screen.dart                  # blurred photo + orange Processing card + spinner
│   │       ├── ask_another_screen.dart                 # orange dialog "Take another picture?" (Yes/No)
│   │       ├── result_screen.dart                      # PageView gallery, Done button, toolbar (Edit/Share/Delete/Print)
│   │       ├── photo_selection_share_screen.dart       # horizontal select-to-share carousel
│   │       └── photo_gallery_screen_share_2.dart       # QR code card + 30s countdown (uses qr_flutter)
│   ├── theme/
│   │   ├── app_theme.dart                              # ThemeData aggregator
│   │   ├── app_colors.dart                             # 8 Color tokens
│   │   ├── app_text_styles.dart                        # 5 TextStyle tokens
│   │   ├── app_spacing.dart                            # 9 spacing tokens
│   │   ├── app_radius.dart                             # 3 radii + BorderRadius getters
│   │   └── app_durations.dart                          # 3 animation + 4 flow durations
│   └── widgets/
│       ├── kiosk_button.dart                           # animated CTA (scale 0.96 on press)
│       ├── kiosk_container.dart                        # rounded surface wrapper
│       ├── camera_placeholder.dart                      # gradient + face silhouette + reticle (CustomPainter)
│       └── qr_code_placeholder.dart                    # stylised 25×25 QR (CustomPainter) — supersedable by qr_flutter
├── test/
│   └── widget_test.dart                                # default Flutter counter test (replace or delete)
├── DesignPlanning/
│   ├── Brainstorming.jam
│   └── BrandGuideLines/
│       ├── Design_Guide_Next _ Steel_House-compressed.pdf
│       ├── Logos/        (4 PNGs — runtime source-of-truth for the logo)
│       └── StockPhotos/  (4 JPGs)
├── analysis_options.yaml                               # flutter_lints baseline
├── pubspec.yaml                                        # deps + assets + fonts
├── pubspec.lock
└── PLAN.md                                             # current design-alignment plan; treat as authoritative for in-flight work
```

### 7.1 Feature organisation pattern

- One feature = one folder under `lib/`. The only feature so far is `flow/`.
- Inside a feature: `flow.dart` (the screen host), `flow_state.dart` (the state machine), and `screens/` (one file per state, named exactly after the state — `idle_screen.dart`, `processing_screen.dart`, …).
- Reusable primitives → `lib/widgets/`. Reusable tokens → `lib/theme/`. There is no `lib/utils/`, no `lib/models/`, no `lib/services/`.

### 7.2 State machine convention (the only pattern in the app)

`lib/flow/photobooth_flow_state.dart:7-16`:

```dart
enum PhotoboothState {
  idle, countdown, captureFeedback, processing,
  askAnother, result, shareSelection, shareQr,
}
```

The flow is driven by a `ChangeNotifier` (`PhotoboothFlowState`) that:
- mutates `_state`,
- calls `notifyListeners()`,
- schedules `Timer` callbacks that mutate `_state` again.

The host screen (`photobooth_flow_screen.dart:39-52`) wraps the body in `AnimatedBuilder(animation: _flowState, …)` + `AnimatedSwitcher(duration: AppDurations.pageTransition, …)` and dispatches on `state` via a `switch` returning one screen widget per case (`_buildScreen`).

**Rules**
- Adding a new screen state: extend the enum, add a `case` in `_buildScreen`, add the transition in `PhotoboothFlowState`. Keep all transitions in the state class — never call `setState` from inside a screen.
- `Timer` instances must be tracked in private fields (`_countdownTimer`, `_autoResetTimer`, `_shareTimer`) and cancelled in `_cancelTimers()` (see `photobooth_flow_state.dart:323-327`).
- Auto-reset on the result/share screens is mandatory (1 minute of inactivity → `resetToHome`).

### 7.3 i18n / l10n

**None yet.** All user-facing strings are English literals (e.g. `'TAKE A SELFIE'`, `'Get ready...'`, `'Smile for the camera'`, `'Photo captured'`, `'Processing'`, `'Do you want to take another picture?'`). Source comments are Italian. When adding a string, follow the existing English-pascal-case-with-spaces convention. The brand speaks English to guests.

**Do not** introduce `intl` / ARB files without an explicit user instruction.

---

## 8. Figma → Flutter Mapping Cheat Sheet

Use this when translating any Figma frame the user hands off:

| Figma concept | Flutter target |
|---|---|
| Figma Color Variable | New `static const Color` in `lib/theme/app_colors.dart` |
| Figma Text Style | New `static const TextStyle` in `lib/theme/app_text_styles.dart` |
| Figma Spacing token | New `static const double` in `lib/theme/app_spacing.dart` |
| Figma Corner radius | New `static const double` (+ optional `BorderRadius` getter) in `lib/theme/app_radius.dart` |
| Figma Effect (shadow) | Inline `BoxShadow` literal (or create `lib/theme/app_shadows.dart` if used 3+ times) |
| Figma Component | New `StatelessWidget`/`StatefulWidget` in `lib/widgets/` (or `lib/flow/screens/` if one-off) |
| Figma Frame (screen) | New `*_screen.dart` in `lib/flow/screens/` + new `PhotoboothState` enum value + dispatch case |
| Figma Image (raster) | Export → `assets/images/…` → `pubspec.yaml` `assets:` → `Image.asset('assets/images/…')` |
| Figma Image (vector icon, no Material match) | `CustomPainter` in `lib/widgets/` |
| Figma Image (logo) | `Image.asset` with `errorBuilder` fallback; never `Image.network` |
| Figma Variable mode "Dark/Light" | We only ship dark — map the dark-mode values; ignore the light variant |
| Figma Component set / variants | One `StatelessWidget` with `final` constructor params + defaults |
| Figma Auto-layout vertical/horizontal | `Column`/`Row` (or `ListView` for long lists) with `mainAxisAlignment` / `crossAxisAlignment` |
| Figma Stack / absolute | `Stack` + `Positioned` |
| Figma Frame with fixed size | `SizedBox(width: …, height: …)` or hardcoded `width`/`height` on the child widget |
| Figma 4:3 / 16:9 frame | `AspectRatio(aspectRatio: 4 / 3)` (used for camera viewfinder) |
| Figma Mask / blur | `ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))` (used in `processing_screen.dart:48-49` and `ask_another_screen.dart:28-29`) |
| Figma Page transition | `AnimatedSwitcher(duration: AppDurations.pageTransition, switchInCurve: Curves.easeInOut, …)` (the one in `photobooth_flow_screen.dart:43`) |
| Figma Press state (scale 0.96) | `KioskButton` (already implements `_isPressed` + `AnimatedScale` at `kiosk_button.dart:31-39`) |
| Figma Selection / hover | Inline `AnimatedContainer` with `border`/`boxShadow` toggle (see `photo_selection_share_screen.dart:76-102`) |

---

## 9. Definition of Done — Figma Hand-off Integration

Before claiming a Figma hand-off is integrated, verify all of the following:

1. **Lint clean**: `flutter analyze` returns 0 issues. (`analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`; do not weaken it.)
2. **Format clean**: `flutter format` produces no diff.
3. **No new network assets**: `grep -r "http://" lib/` returns no `Image.network` calls referencing `localhost:3845`. All Figma imagery is in `assets/images/`.
4. **No raw tokens in screens**: `grep -rE "Color\(0x[0-9A-Fa-f]+\)|EdgeInsets\.(all|symmetric|only)\(\s*[0-9]+(\.[0-9]+)?\s*\)" lib/flow/screens/` should not find new literals introduced by this change. Existing known literals are listed in §1.2 and §6.1.
5. **No raw `Duration(...)` in screens**: durations only via `AppDurations.*`.
6. **Tests pass**: `flutter test`. If a new widget was added, at least one smoke test in `test/` exercises it inside `AppTheme.darkTheme`.
7. **Manual visual check**: open the affected screen on an Android tablet emulator in landscape, side-by-side with the Figma screenshot, confirm typography, spacing, radius, and colour.
8. **Offline**: kill the network on the device and re-run the flow end-to-end (Idle → Countdown → Capture → Processing → Result → Share). No asset should fail.
9. **`PLAN.md` updated**: if the change fulfils a step in `PLAN.md`, mark the relevant step complete in the file or in the commit message.

---

## 10. Anti-patterns (do **not**)

- ❌ Don't introduce Tailwind, CSS-in-JS, or any web-style framework — this is Flutter.
- ❌ Don't introduce a new state-management library; mirror `ChangeNotifier` + `AnimatedBuilder`.
- ❌ Don't add a light theme or a theme switcher.
- ❌ Don't inline `Color(0xFF…)`, `Duration(milliseconds: …)`, or `BorderRadius.circular(…)` in screen files — route through the token classes.
- ❌ Don't add asset paths, font weights, or new env values to `pubspec.yaml` without a matching `app_*.dart` token file edit.
- ❌ Don't use `Image.network` for any Figma-sourced asset. Bundle it.
- ❌ Don't add `Navigator`, `go_router`, named routes, or deep links — there is no navigation in the app beyond the `AnimatedSwitcher` in `photobooth_flow_screen.dart`.
- ❌ Don't add `intl`/ARB until the user requests i18n.
- ❌ Don't use `Theme.of(context).textTheme.*` — consume `AppTextStyles.*` directly.
- ❌ Don't call `setState` from inside a screen to change `PhotoboothState`; route through the state class.

---

## 11. Quick links

- App entry: `lib/main.dart`
- Theme aggregator: `lib/theme/app_theme.dart`
- State machine: `lib/flow/photobooth_flow_state.dart`
- Flow dispatcher: `lib/flow/photobooth_flow_screen.dart`
- All screens: `lib/flow/screens/*.dart`
- Reusable widgets: `lib/widgets/*.dart`
- Plan / in-flight tasks: `PLAN.md`
- Brand source assets: `DesignPlanning/BrandGuideLines/`

## Automated Verification Commands

| Check | Command |
|---|---|
| Unit tests | `./gradlew test` |
| Instrumented tests | `./gradlew connectedAndroidTest` |
| Lint | `./gradlew lint` |
| Build | `./gradlew assembleDebug` |

Always run these after changes and fix any failures before considering a task done.