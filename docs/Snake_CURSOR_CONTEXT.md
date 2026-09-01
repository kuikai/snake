# Snake – Cursor Context & Rules

You are helping build **Snake**, a simple offline Flutter Snake game for Android + iOS.

Follow these rules strictly. Do not invent extra features.

Read first, in this order:
1. `Snake_PRODUCT_SPEC.md` — locked decisions
2. `Snake_ACCEPTANCE_CRITERIA.md` — testable checklist
3. `Snake_MODELS.md` — data shapes
4. `Snake_IMPLEMENTATION_PLAN.md` — build order

---

## 1. Project Overview

- Classic Snake, clean Material 3
- Free: unlimited Classic 20×20 + high score
- Pro $1.99 one-time: continues, sizes, modes, skins, themes, history
- Offline-first
- Package: `com.yourname.snake`
- RevenueCat product: `snake_pro`
- Entitlement: `pro`

---

## 2. Tech Stack (mandatory)

- Flutter + Material 3
- Riverpod
- shared_preferences
- purchases_flutter (RevenueCat)
- flutter_local_notifications is **not** required for this game
- Pure Flutter game loop — `Ticker` or periodic `Timer`
- CustomPainter (or a simple grid of widgets) for the board

**Never**
- Add Flame / Forge2D / extra game engines
- Add subscriptions, ads, analytics SDKs, or cloud
- Change the $1.99 one-time model

---

## 3. Folder Structure (mandatory)

```
lib/
├── core/          # constants, theme, router, game_config
├── models/
├── providers/     # Riverpod
├── services/      # storage, revenuecat, haptics, sound
├── game/          # engine, collision, spawn, tick (no UI)
├── screens/
└── widgets/
```

Keep gameplay logic in `lib/game/` + providers. Widgets only render and send input.

---

## 4. Coding Rules

- Use Riverpod. Prefer `ConsumerWidget` / `ConsumerStatefulWidget`.
- Business logic lives in providers / services / `lib/game`. Not in widgets.
- All magic numbers live in `lib/core/game_config.dart`.
- Models are JSON-serializable.
- Everything works offline.
- When in doubt, choose the simpler solution.
- Do not build Out of Scope items.
- Ship Classic first. Then gate Pro features. Then cosmetics + history.

### Game loop rules
- One tick moves the snake one cell.
- Queue at most **one** pending direction.
- Reject a turn that is a 180° reverse of the *current* movement direction.
- Food spawn must scan empty cells only.
- Pause cancels ticks and ignores direction changes except unpause.
- App lifecycle paused / inactive → pause the game.
- Keep the screen awake while a run is active.
- System back during a run → pause, do not instantly pop and lose the run.

### Pro gating rules
- Free users can only start Classic + Medium (20×20).
- Locked chips show a lock icon + “Pro” and open the paywall.
- After purchase, unlock immediately without restarting the app.
- Restore Purchase is visible in Settings **and** on the paywall.
- Debug Unlock Pro / Reset Pro exists only in `kDebugMode`.

### UI rules
- Material 3, clean, large tap targets, no clutter.
- Big readable score.
- Head of the snake is visually distinct.
- Lock portrait.
- Light / Dark / System theme from Settings.

---

## 5. Monetization Rules (strict)

- Free = unlimited Classic only
- Pro = $1.99 one-time via RevenueCat
- No subscriptions ever
- Always show Restore Purchase

Until RevenueCat keys exist, stub the purchase service and keep the debug unlock.

---

## 6. Do Not Do

- Do not add Flame
- Do not add online scores
- Do not add a tutorial slideshow
- Do not add particle systems
- Do not confirm every tap with a dialog
- Do not use GetX / Bloc / Provider (the package) — Riverpod only
- Do not put game state in `shared_preferences` every tick (save on game over / settings change only)
