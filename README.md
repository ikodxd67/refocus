# Refocus

A calm pause between you and the scroll — and a small personal research
instrument built around it.

When you open a guarded app, Refocus holds a short pause: you name *why* you're
opening it, then meet a personal, loss-framed reframe alongside the real cost of
today's scrolling. How long that pause locks is decided by a model trained on
your own behaviour, on your own phone.

Cross-platform (iOS + Android) from one Flutter codebase. Based on the diploma
research "Investigation of Instant Gratification Loops…", of which this is the
productised successor to the native Android prototype.

## The loop

The app is not a blocker; it's a closed feedback loop, and each stage is a real
layer in the codebase:

| Stage | What happens | Where |
|---|---|---|
| **Measure** | Real per-app foreground minutes from the platform | `UsageStatsReader.kt`, `usage_stats_channel.dart` |
| **Store** | Append-only event log in SQLite — every pause is one row | `data/database.dart` |
| **Analyse** | Daily/hourly aggregates and the thesis's own correlation | `analytics/` |
| **Predict** | Logistic regression trained on-device, with held-out metrics | `ml/` |
| **Adapt** | Risk score sets the pause length (10–25s) | `data/insights_repository.dart` |
| **Explain** | Every score breaks down into weighted, named reasons | `screens/insights_screen.dart` |

Nothing is a stored counter: every number the app reports is derived from the
event log, so there is exactly one source of truth.

## What it does

- **Guard apps** you choose (TikTok, Reels, Shorts, …).
- On launch, show a **two-step pause**:
  1. *Intention* — "What for?" (bored / break / specific / habit).
  2. *Reframe* — a personal sentence built from your reason, your goal and how
     often you've opened it today, plus a **cost mirror**, gated behind a
     countdown the risk model sizes. "Take me home" is the easy path; "Open for
     5 min" is the deliberate one.
- **Daily focus check-in** (1–5, the same scale as the study's survey).
- **Insights**: your personal **Pearson correlation** between scroll minutes and
  focus — reported with *p* and *n*, and refusing to show a number when it would
  be meaningless — plus per-day and per-hour charts, which intention actually
  holds, and the model's own accuracy / ROC AUC against a majority-class
  baseline.
- **Frequency limit** so pauses never spam (once per N minutes per app).
- Local-only: SQLite plus a small settings blob. No account, no server.

## Design notes worth defending

- **No leakage in training.** Features for each event are computed strictly from
  events *before* it (`RiskModel.buildSamples`), and evaluation splits the log
  **chronologically**, never randomly — a random split would let the model learn
  from the user's future.
- **Honest statistics.** `pearson` returns `null` rather than a fake `0` when
  n < 3 or a sample has no variance; the two-tailed p-value comes from the exact
  t-distribution tail via the regularized incomplete beta function.
- **A linear model on purpose.** Logistic regression trains usefully on the few
  hundred events one person produces, runs instantly, needs no runtime — and
  every prediction decomposes into reasons the user can read.
- **Charts are hand-drawn** (`widgets/bar_chart.dart`) so the scale, the empty
  state and the palette are exactly the app's own.

## Project layout

```
lib/
  main.dart                     entry, providers, native trigger listener
  theme.dart                    light/dark palettes + fixed "night" pause palette
  data/
    database.dart               drift schema: events, check-ins, usage, weights
    insights_repository.dart    the seam between storage, analytics and the model
  analytics/
    stats.dart                  Pearson r, t-test p-value, incomplete beta
    models.dart                 plain domain objects (no drift, no Flutter)
    analytics_engine.dart       daily/hourly/reason aggregates, streaks
  ml/
    risk_model.dart             features + logistic regression + explanations
    model_evaluation.dart       chronological split, accuracy, ROC AUC
  models/                       guarded apps, pause reasons
  services/                     settings, reframes, platform channels
  screens/                      onboarding, home, apps, insights, settings, pause
  widgets/                      countdown ring, bar chart
android/app/src/main/kotlin/com/refocus/refocus/
  MainActivity.kt               interception + usage channels
  FocusAccessibilityService.kt  watches launches, sends home, shows the pause
  UsageStatsReader.kt           real foreground minutes
native_reference/ios/           Shortcuts-automation & Screen Time notes
test/                           analytics, ML and widget tests
```

## Running it

```bash
flutter pub get
flutter run                 # pick a device (Android phone recommended)
flutter test
flutter build apk --debug   # -> build/app/outputs/flutter-apk/app-debug.apk
```

Code generation (after changing the drift schema):

```bash
dart run build_runner build
```

The pause flow can be exercised without any native wiring via **"Try a pause
now"** on the Home screen.

> Note: the web target is only for previewing the UI on a PC. The database uses
> the native SQLite backend, so web needs the drift WASM setup before it will
> run — mobile is the target.

## Native interception

- **Android** — integrated. `FocusAccessibilityService` watches
  `TYPE_WINDOW_STATE_CHANGED`; when a guarded package opens it sends the user
  home, brings Refocus forward and emits the package so the pause appears.
  Enable it once in Settings → Accessibility, and grant Usage access for the
  measured minutes.
- **iOS** — follow `native_reference/ios/README_iOS.md`: ship the Shortcuts
  approach first (full custom pause screen), add Screen Time "strict mode"
  later.

## Status

- [x] Shared Flutter UI + two-step pause
- [x] SQLite event log (drift) with migrations
- [x] Analytics engine + personal Pearson correlation, unit-tested
- [x] On-device risk model with held-out evaluation, unit-tested
- [x] Adaptive pause length driven by predicted risk
- [x] Android interception + UsageStats telemetry; debug APK builds
- [ ] Test interception and telemetry on a real Android device
- [ ] Weekly AI report over the analytics
- [ ] iOS URL-scheme hook wired to `PauseScreen`
