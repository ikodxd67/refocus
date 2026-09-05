# Refocus

A calm pause between you and the scroll. When you open a guarded app, Refocus
holds a short, honest pause — you name *why* you're opening it, then meet a
personal, loss-framed reframe with the real cost of today's scrolling — before
letting you through. Cross-platform (iOS + Android) from one Flutter codebase.

Based on the diploma research "Investigation of Instant Gratification Loops…";
this is the productised, cross-platform successor to the native Android
prototype. The random AI *fact* from the prototype is replaced with an
**intention check + personal reframe**, which is more effective and works
offline (see `docs`/report discussion).

## What it does

- **Guard apps** you choose (TikTok, Reels, Shorts, …).
- On launch, show a **two-step pause**:
  1. *Intention* — "What for?" (bored / break / specific / habit).
  2. *Reframe* — a personal sentence built from your reason + your goal + how
     often you've opened it today, plus a **cost mirror**, gated behind a
     15-second countdown. "Take me home" is the easy path; "Open for 5 min"
     is the deliberate one.
- **Frequency limit** so pauses never spam (once per N minutes per app).
- **Your goal**, shown in every pause, set once.
- **AI reframes via Gemini** when enabled + key present; **offline templates**
  otherwise — the screen always has something to say.
- Local-only: everything lives in `SharedPreferences`. No account, no server.

## Project layout

```
lib/
  main.dart                     app entry, theme wiring, native trigger listener
  theme.dart                    calm light/dark palettes + fixed "night" pause palette
  models/
    guarded_app.dart            an app the user can guard
    pause_reason.dart           the intention options
  services/
    settings_controller.dart    single source of truth (state + persistence + intervention rule)
    reframe_service.dart        Gemini call + offline templates
    interception_channel.dart   MethodChannel/EventChannel bridge to native (no-op off-device)
  screens/
    onboarding_screen.dart      permissions + optional goal
    root_nav.dart               Home · Apps · Settings bottom nav
    home_screen.dart            status, stats, "Try a pause now"
    apps_screen.dart            guarded-app list
    settings_screen.dart        frequency, goal, AI/key, appearance
    pause_screen.dart           ★ the two-step pause (the signature screen)
  widgets/
    countdown_ring.dart         the 15s ring
android/app/src/main/kotlin/com/refocus/refocus/
  MainActivity.kt               registers the interception channels
  FocusAccessibilityService.kt  watches launches, sends home, shows the pause
native_reference/
  ios/                          Shortcuts-automation & Screen Time notes
```

## Running it

```bash
flutter pub get
flutter run                 # pick a device (Android phone recommended)
flutter build apk --debug   # -> build/app/outputs/flutter-apk/app-debug.apk
```

The app also runs on web/desktop for previewing the UI: native interception is
a safe no-op off-device, and **"Try a pause now"** on the Home screen shows the
full pause flow.

## Native interception

- **Android** — integrated. `FocusAccessibilityService` watches
  `TYPE_WINDOW_STATE_CHANGED`, and when a guarded package opens it sends the
  user home, brings Refocus to the front, and emits the package over the event
  channel so the pause screen appears. Enable it once in Settings →
  Accessibility. (Runtime behaviour needs a real device/emulator; the debug APK
  builds and installs.)
- **iOS** — follow `native_reference/ios/README_iOS.md`: ship the Shortcuts
  approach first (full custom pause screen), add Screen Time "strict mode"
  later.

## Design

The UI mirrors the approved mockup: 3-tab bottom nav, calm teal + cool neutrals,
Manrope for UI and Fraunces for the reframe. Pause screen is intentionally dark
in both themes.

## Status

- [x] Shared Flutter UI (all screens) + core logic + offline/AI reframes
- [x] Android native interception wired (AccessibilityService + channels), debug APK builds
- [x] iOS approach documented (Shortcuts + Screen Time)
- [ ] Test interception on a real Android device
- [ ] iOS URL-scheme hook wired to `PauseScreen`
- [ ] Real per-app usage minutes via Android UsageStats
