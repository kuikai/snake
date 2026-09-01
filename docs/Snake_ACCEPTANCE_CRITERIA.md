# Snake – Acceptance Criteria (MVP)

**App name:** Snake  
**Package:** `com.yourname.snake`  
**Platform:** Android + iOS (+ Windows / Chrome for local testing)  
**Monetization:** Free unlimited classic play + $1.99 one-time Pro (RevenueCat)  
**Style:** Clean, minimal Material 3, offline-first  
**Target:** Realistic 1-week build with Cursor

---

## 1. Core Gameplay (Classic Mode)

### Board & Snake
- [ ] Fixed classic board size (e.g. 15×15 or 20×20 cells – choose one and keep consistent)
- [ ] Snake starts in the center (or near center), length 3, moving right
- [ ] Snake head is clearly distinguishable from body (different color / shape / highlight)
- [ ] Smooth, consistent tick rate (base speed feels good – not too slow, not frantic)
- [ ] Snake never leaves the board in classic mode (walls are solid)

### Controls
- [ ] Swipe gestures to change direction (up / down / left / right)
- [ ] Optional on-screen D-pad or arrow buttons (especially useful on tablets / accessibility)
- [ ] Cannot reverse into itself in one move (prevent instant self-collision)
- [ ] Direction change is queued properly (no lost inputs on rapid swipes)
- [ ] Pause / Resume button visible during play (or tap to pause)

### Food
- [ ] One food item on the board at a time
- [ ] Food spawns randomly on an empty cell (never on snake body)
- [ ] Eating food: snake grows by 1 segment, score increases by 1 (or 10 – decide and keep consistent)
- [ ] New food appears immediately after eating

### Collision & Game Over
- [ ] Collision with own body → Game Over
- [ ] Collision with solid wall → Game Over
- [ ] Clear “Game Over” state with final score
- [ ] Option to Restart immediately from Game Over screen

### Score
- [ ] Current score displayed during play (large, readable)
- [ ] High score for classic mode is tracked and shown
- [ ] High score updates only when beaten

---

## 2. Free vs Pro Feature Gates

### Free (always available)
- [ ] Unlimited play of **Classic mode** only
- [ ] One fixed board size
- [ ] Current high score for classic mode is saved and shown
- [ ] Basic Material 3 light/dark theme support
- [ ] Clear, non-intrusive upgrade prompts (banner or button on Game Over / Settings)
- [ ] No forced ads, no time limits, no energy system

### Pro ($1.99 one-time unlock)
- [ ] **Unlimited Undo / Second Chance**
  - On Game Over, Pro users get a “Continue” or “Undo last move” option (limited uses per game or unlimited – decide: recommend 1–3 continues per run for balance)
- [ ] **Multiple board sizes** (Small / Medium / Large)
- [ ] **Extra modes** (selectable before starting a game):
  - Walls Wrap (snake exits one side and enters the opposite)
  - No Walls (open play area)
  - Obstacles (a few fixed or random static blocks)
  - Increasing Speed (speed rises every X food items)
- [ ] **Snake skins** (at least 3–5 simple color / style variants)
- [ ] **Board themes** (at least 3–5 background / grid color schemes)
- [ ] **Full high-score history**
  - Personal bests stored **per mode** + **per board size**
  - Simple history list of recent runs (score, mode, date)
- [ ] Optional haptic feedback (on eat, on death, on direction change)
- [ ] Optional subtle sound effects (eat, game over, button taps)
- [ ] All Pro features gated cleanly in UI (locked items show lock icon + “Pro” badge)

### Purchase Flow
- [ ] Clear “Unlock Pro – $1.99” entry points (Game Over, Settings, mode select)
- [ ] Purchase succeeds → all Pro features unlock immediately (no restart required)
- [ ] **Restore Purchase** always available and working (Settings + any paywall)
- [ ] Graceful handling of purchase cancel / error / already owned

---

## 3. UI / UX Screens & Flows

### Home / Main Menu
- [ ] App name / logo
- [ ] Big **Play** button (starts Classic mode by default for Free users)
- [ ] Mode / Size selector (Pro only – Free sees locked state)
- [ ] High Score display (classic)
- [ ] Access to Settings and High Scores / History
- [ ] Clean empty / first-launch state if needed

### Game Screen
- [ ] Board fills available space cleanly (respect safe areas)
- [ ] Score + high score visible without clutter
- [ ] Pause control
- [ ] Consistent Material 3 styling (rounded cards, proper elevation, theme colors)
- [ ] Works in both portrait and landscape (or lock to portrait if simpler for MVP)

### Game Over Screen
- [ ] Final score prominently shown
- [ ] “New High Score!” celebration when beaten
- [ ] Restart button
- [ ] Back to Menu
- [ ] Pro users: Continue / Undo option (if available)
- [ ] Free users: soft upgrade prompt (“Unlock unlimited continues + more modes”)

### High Scores / History
- [ ] Classic high score always visible
- [ ] Pro: list of personal bests per mode + recent runs
- [ ] Free: only classic best + upgrade nudge

### Settings
- [ ] Theme: Light / Dark / System (persisted)
- [ ] Sound effects toggle (Pro only or always available – recommend always available, effects gated)
- [ ] Haptic feedback toggle
- [ ] Restore Purchase button (always visible)
- [ ] About / version info
- [ ] Debug-only “Unlock Pro / Reset Pro” for testing (hidden in release)

### Paywall / Upgrade Screen (simple)
- [ ] Clear list of Pro benefits
- [ ] Price $1.99
- [ ] Purchase button
- [ ] Restore Purchase link
- [ ] Close / Not now

---

## 4. Persistence (Offline-first)

- [ ] High score(s) saved via `shared_preferences`
- [ ] Selected theme, sound, haptic preferences persisted
- [ ] Last selected mode / board size remembered (Pro)
- [ ] Pro entitlement status respected (RevenueCat is source of truth; local cache for offline)
- [ ] All data survives app restart and device reboot
- [ ] No cloud, no account required

---

## 5. RevenueCat Integration

- [ ] `purchases_flutter` configured
- [ ] Product ID (e.g. `snake_pro`) and entitlement (`pro`) set up
- [ ] Purchase flow works on real device / sandbox
- [ ] Restore Purchase works from any entry point
- [ ] Entitlement is checked on app start and after purchase
- [ ] Offline: previously purchased Pro remains unlocked
- [ ] Clear loading / error states during purchase

---

## 6. Edge Cases & Polish (MVP expected)

- [ ] Rapid successive swipes do not break direction logic
- [ ] Food never spawns on the snake
- [ ] Snake growth is instantaneous and visually correct
- [ ] Game does not freeze or drop frames on mid-range devices
- [ ] Pause correctly freezes the tick and inputs
- [ ] App handles going to background → pause game
- [ ] Screen stays on while playing (keep awake)
- [ ] Back button / system gesture during game → pause or confirm exit (no accidental loss)
- [ ] First launch feels welcoming (short tip or just clean Play button)
- [ ] All locked Pro features show consistent lock UI + clear upgrade path
- [ ] No crashes on Game Over → Restart loop
- [ ] Score never goes negative or overflows visually

---

## 7. Architecture & Code Quality

- [ ] Clean folder structure: `core / models / providers / services / screens / widgets` (or equivalent game-friendly structure)
- [ ] Riverpod for state (game state, settings, pro status, high scores)
- [ ] Game loop is simple, testable, and does not block UI thread
- [ ] Material 3 theming used consistently
- [ ] No hardcoded magic numbers without constants
- [ ] Debug Pro unlock available in non-release builds

---

## 8. Explicitly Out of Scope (MVP)

- Online leaderboards or multiplayer
- Cloud sync / accounts
- Complex level editor or custom maps
- Advanced AI / pathfinding demos
- Particle effects, heavy animations, or 3D
- Ads of any kind
- Subscriptions or consumable IAPs
- Wear OS / watch support
- Multiple languages (English only for MVP)
- In-game tutorials beyond a simple first-run tip
- Daily challenges / achievements system
- Custom sound asset packs beyond simple system / bundled short SFX

---

## 9. Success Definition for MVP

The app is considered MVP-complete when:

1. A Free user can play unlimited Classic Snake, beat a high score, and the score persists.
2. All Pro features listed above are implemented and cleanly gated.
3. Purchase + Restore work end-to-end with RevenueCat.
4. The app feels polished, stable, and pleasant for a 1-week build.
5. No critical crashes or soft-locks in normal play.

---

**Notes for Cursor / implementation**  
- Prefer pure Flutter (CustomPainter or simple grid of widgets) over adding Flame unless it clearly saves time.  
- Keep the game loop simple (Timer or Ticker).  
- Reuse the exact monetization + settings patterns from DeepFocus / StackFit / ClearDay.  
- Ship the Classic experience first, then layer Pro modes and cosmetics.
