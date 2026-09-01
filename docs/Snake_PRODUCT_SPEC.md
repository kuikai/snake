# Snake – Product Spec (MVP)

**Package name:** `com.yourname.snake`  
**Platform:** Android + iOS (Flutter; Windows / Chrome for local testing)  
**Monetization:** Free unlimited Classic + $1.99 one-time Pro (RevenueCat)  
**Style:** Clean, minimal Material 3, offline-first  
**Engine:** Pure Flutter (CustomPainter + Ticker). Do **not** add Flame.

---

## 1. Core Concept

A classic Snake game with a modern Material 3 look.

- Free users play unlimited **Classic** mode on one board size and keep a high score.
- Pro ($1.99 one-time) unlocks extra modes, board sizes, continues, skins, themes, and full history.

This is a game I would actually play. Keep it simple, fast, and fair.

---

## 2. Locked Decisions (do not reopen)

| Topic | Decision |
|---|---|
| Classic / Free board | **20×20** cells |
| Pro board sizes | Small **12×12**, Medium **20×20**, Large **28×28** |
| Starting snake | Length **3**, center of board, moving **right** |
| Score | **+1** per food |
| Tick rate (Classic) | **180 ms** per step |
| Increasing Speed mode | Start 180 ms, −15 ms every **5** food, floor **80 ms** |
| Continues (Pro) | **3** continues per run. Restores state from *before* the death move. Same length, same food. |
| Portrait | **Lock portrait** for MVP |
| Controls | Swipe + on-screen D-pad |
| Reverse | Illegal. Ignore a 180° turn. Queue **one** pending direction. |
| Food | One at a time, never on snake or obstacles |
| Obstacles mode | **6** static blocks on Small, **8** on Medium, **12** on Large. Never block the start corridor. |
| Wrap mode | Exit one edge → enter opposite. Self-collision still kills. |
| No Walls mode | No wall death. Self-collision still kills. Board edge is visual only. |
| Skins (Pro) | Classic Green, Ember, Ocean, Mono, Neon |
| Themes (Pro) | Classic, Midnight, Sand, High Contrast, Forest |
| Sounds | Short bundled / system SFX. Toggle in Settings. |
| Haptics | Light on turn, medium on eat, heavy on death. Toggle in Settings. |
| Language | English only |
| Product ID | `snake_pro` |
| Entitlement | `pro` |

---

## 3. Modes

| Mode | Free | Behavior |
|---|---|---|
| Classic | Yes | Solid walls. Constant speed. |
| Walls Wrap | Pro | Wrap around edges. |
| No Walls | Pro | Open edges, no wall death. |
| Obstacles | Pro | Static blocks are deadly. |
| Increasing Speed | Pro | Speed ramps every 5 food. |

Modes can be combined with a board size. Increasing Speed can be combined with Classic / Wrap / No Walls / Obstacles.

For MVP keep the mode picker simple:

- One primary mode (Classic / Wrap / No Walls / Obstacles)
- Optional “Increasing Speed” toggle (Pro)
- Board size chips (Pro)

---

## 4. Free vs Pro

**Free**
- Unlimited Classic on 20×20
- Current Classic high score
- Light / Dark / System theme
- Soft upgrade prompts only (Game Over + Settings + locked chips)

**Pro ($1.99 one-time)**
- 3 continues per run
- All board sizes
- All extra modes + Increasing Speed
- Skins + board themes
- Personal bests per mode + size
- Recent run history
- Haptics + SFX (toggles still respected)

No ads. No energy. No subscriptions.

---

## 5. Screens

1. Home
2. Game
3. Pause overlay
4. Game Over
5. High Scores / History
6. Settings
7. Paywall (simple)

---

## 6. Persistence

`shared_preferences` only.

Save:
- Classic high score
- Pro personal bests keyed by `mode + boardSize + speedFlag`
- Recent runs (last 30)
- Theme / sound / haptic
- Last selected mode, size, skin, board theme
- Cached Pro flag (RevenueCat is source of truth)

---

## 7. Out of Scope

Cloud, accounts, leaderboards, multiplayer, ads, subscriptions, Flame, level editor, particles/3D, Wear OS, i18n, daily challenges, achievements.
