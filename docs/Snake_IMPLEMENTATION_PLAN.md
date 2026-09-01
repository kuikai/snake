# Snake – Implementation Plan

Build in this order. Do not skip ahead to skins, history, or RevenueCat until Classic play works.

Each step is done when you can tap through it on a device / emulator without crashes.

---

## Step 0 — Project

- Flutter app, package `com.yourname.snake`
- Material 3
- Portrait only
- Dependencies: `flutter_riverpod`, `shared_preferences`, `purchases_flutter`
- Folder structure from `Snake_CURSOR_CONTEXT.md`
- Copy these briefing files into the repo root or `/docs` so they stay visible

---

## Step 1 — Foundation (no game yet)

- `game_config.dart` constants
- Models + `models.dart` barrel
- Theme (light / dark / system)
- Router or simple `MaterialApp` routes
- `StorageService` (shared_preferences) with settings + classic high score
- Riverpod providers: settings, storage, proStatus (default false + debug unlock)

Done when: app opens to a blank Home with theme working.

---

## Step 2 — Classic engine (headless)

- `lib/game/engine.dart` (or similar)
- new run, queue direction, tick, grow, collide, spawn food
- Unit-test style checks in comments or a tiny debug screen if needed:
  - cannot reverse
  - food never on body
  - wall + self collision end the run
  - eat increases length and score by 1

Done when: engine can play a full Classic run in memory.

---

## Step 3 — Game screen (Classic only)

- CustomPainter board
- Distinct head
- Swipe + D-pad
- Score + high score
- Pause / Resume
- Keep screen awake
- Lifecycle → pause
- Back button → pause

Done when: you can play Classic, die, and see the board freeze.

---

## Step 4 — Home + Game Over

- Home: title, big Play, classic high score, Settings, High Scores
- Game Over: score, New High Score banner, Restart, Menu
- Persist classic high score only on game over if beaten

Done when: Free loop works end-to-end (Play → die → restart → high score survives app kill).

---

## Step 5 — Settings

- Theme Light / Dark / System
- Sound toggle
- Haptic toggle
- Restore Purchase (stub OK)
- About + version
- Debug Unlock / Reset Pro (`kDebugMode` only)

---

## Step 6 — Pro gates (still stubbed purchase)

- Mode chips + size chips + Increasing Speed toggle
- Free tap on locked chip → paywall
- Paywall lists Pro benefits, $1.99, Purchase stub, Restore, Not now
- When `isPro == true` (debug unlock):
  - Wrap / No Walls / Obstacles / Increasing Speed work
  - Board sizes work
  - 3 continues on Game Over
- Skins + board themes selectable for Pro

Done when: debug-unlocked Pro can play every mode.

---

## Step 7 — History

- Save run on game over
- Personal best per `mode + size + speedFlag`
- History screen: classic best always; full list if Pro
- Free history screen shows classic best + upgrade nudge

---

## Step 8 — Juice

- SFX on eat / death / button (respect toggle)
- Haptics on turn / eat / death (respect toggle)
- Keep juice cheap. No particles.

---

## Step 9 — RevenueCat last

- Wire `purchases_flutter`
- Product `snake_pro`, entitlement `pro`
- Real purchase + restore
- Cache entitlement for offline
- Remove reliance on debug unlock for the release build

---

## Definition of done

Matches `Snake_ACCEPTANCE_CRITERIA.md` section 9:

1. Free user plays unlimited Classic, high score persists
2. Pro features exist and are gated
3. Purchase + Restore work (or are clearly stubbed with a TODO if keys are missing)
4. No critical crashes in the Play → Die → Restart loop
