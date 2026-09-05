# Paste this into Cursor

The app is more or less finished. Do a **code review only**. Do not start rewriting screens.

Read first:
- Snake_PRODUCT_SPEC.md
- Snake_ACCEPTANCE_CRITERIA.md
- Snake_UI_PERSONALITY.md
- Snake_MODELS.md
- Snake_ONLINE_SCORES.md
- .cursorrules

Then inspect `lib/` (and pubspec, Android/iOS config). Do not invent features that are missing unless they are spec bugs.

## How to report

Group findings as:

- **P0 — ship blocker** (crash, data loss, Free user gets Pro, purchase broken)
- **P1 — should fix before Play** (wrong gate, score not persisting, Game Over wrong, debug unlock in release)
- **P2 — polish** (copy, spacing, personality drift)
- **OK** — what already matches the spec

For each issue: file + short why + smallest fix. No drive-by refactors.

If you can run `flutter analyze`, do that and include real errors.

## Check these

### Gameplay
- Classic is 20×20, start length 3, facing right
- Score +1 per food
- Tick 180ms; Increasing Speed −15ms every 5 food, floor 80ms
- One queued direction; 180° reverse ignored
- Food never on snake or obstacles
- Classic walls kill; Wrap wraps; No Walls no wall death; self-hit always kills
- Obstacles: 6/8/12 by size, start corridor clear
- Pause on background; keep screen awake while running
- Back during a run pauses, does not discard the run
- Pro continues: 3 per run, restore state from before the death move

### Free vs Pro
- One product `snake_pro`, entitlement `pro`. One purchase unlocks all Pro
- Free = Classic + Medium only, unlimited play, local classic best
- Locked chips: name only + lock. No “Pro” suffix. Same paywall
- Purchase unlocks immediately, no restart
- Restore Purchase visible in Settings and paywall
- Debug Unlock/Reset Pro only in `kDebugMode`
- No subscriptions, no ads

### Persistence
- High scores and settings survive kill
- Pro bests keyed by mode + size + speed
- Do not write shared_preferences every tick

### UI
- Pocket Arcade: no ColorScheme.fromSeed, Fraunces score/title, Figtree UI
- Home art only on Home; Play does not cover snake/apple
- Game: no AppBar, centered score, distinct head, loud fruit
- Game Over is a full screen (`oof.` / `nice run.` / `new best.` + Again / Menu), not a Material dialog
- Copy stays dry

### Online scores (if the code exists)
- Pro + opt-in only, default off
- No email login
- Top 1000 cap, pages of 50
- No Firebase init for Free / opted-out users
- App still runs if Firebase config is missing

### Release hygiene
- No secrets in git
- Package / app name / icons look intentional
- Portrait lock
- analyze is clean enough to ship
- Dead debug UI, print spam, hardcoded test Pro flags

## Stop condition

Write the review. Then stop.

Do not apply fixes until I say which severity to fix.
