# iOS interception — how the pause appears on iOS

iOS does **not** let an app draw over another app (no Android-style overlay).
Instead we *redirect* to Refocus and show the real Flutter pause screen — the
same approach the "one sec" app uses. Two options, simplest first.

## Option A — Shortcuts automation (MVP, full custom UI)

This is the basic path and gives our exact two-step pause screen.

**What the user sets up once per app (we guide them in onboarding):**
1. Open **Shortcuts → Automation → New → App**.
2. Choose the app to guard (e.g. TikTok), trigger **Is Opened**, and turn
   **Run Immediately** on (no confirmation banner on iOS 15+).
3. Action: **Open App → Refocus** (or "Open URL" `refocus://pause?app=tiktok`).

**What we implement in the app:**
- Register a URL scheme `refocus://` (Info.plist `CFBundleURLTypes`).
- On cold start / resume from that URL, read the `app` param and immediately
  call the Dart side to present `PauseScreen`. After "take me home", we just
  stay in Refocus (or the user swipes away); "Open for 5 min" re-opens the
  target app via its own URL scheme when it has one.

Trade-off: the user does a one-time setup, and a determined user can delete the
automation. Good enough for a graduation MVP and it keeps the UI identical to
Android.

### Minimal Dart hook (add to interception_channel or main)
```dart
// Using app_links / uni_links package to receive refocus://pause?app=...
// then: PauseScreen.show(context, appName: name, packageName: id);
```

## Option B — Screen Time API (stronger, limited UI) — later

`FamilyControls` + `DeviceActivity` + `ManagedSettings`:
- `AuthorizationCenter.shared.requestAuthorization(for: .individual)`.
- `FamilyActivityPicker` lets the user pick apps (returns opaque tokens — you
  never learn which app it is, by design).
- A `DeviceActivityMonitor` extension shields the chosen apps; the **shield**
  screen is a native `ShieldConfiguration` (title, subtitle, icon, two buttons,
  colors) — you **cannot** put a live 15-second countdown or arbitrary AI text
  on it. Its button can defer/unblock.

Use this later as a "strict mode": it's much harder to bypass, at the cost of
the rich pause UI. A common production setup runs both — Screen Time to enforce,
Shortcuts to deliver the nice screen.

## Summary
| | Setup friction | Custom UI | Hard to bypass |
|---|---|---|---|
| A · Shortcuts | one-time per app | full (our screen) | soft |
| B · Screen Time | pick apps once | shield only | strong |

Ship **A** for the MVP; keep **B** on the roadmap.
