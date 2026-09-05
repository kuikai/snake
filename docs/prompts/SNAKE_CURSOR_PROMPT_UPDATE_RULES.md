# Paste this into Cursor

Update the project rules so you follow them on every chat. Do not change app code in this step.

Write or refresh these files in the Flutter repo root:

1. `.cursorrules`
2. `.cursor/rules/snake.mdc` if that folder exists, otherwise only `.cursorrules`

The rules must include all of this:

## Product
- App: Snake. Package com.yourname.snake
- Flutter + Material 3 + Riverpod + shared_preferences + purchases_flutter
- No Flame, no subscriptions, no ads, no cloud
- One $1.99 Pro purchase (snake_pro / entitlement pro) unlocks EVERYTHING
- Locks on modes/sizes are UI only. They all open the same paywall
- Restore Purchase always visible

## Files to obey
Read before UI or product changes:
- Snake_PRODUCT_SPEC.md
- Snake_UI_PERSONALITY.md
- Snake_CURSOR_CONTEXT.md
- Snake_MODELS.md
- Snake_IMPLEMENTATION_PLAN.md
- Snake_ACCEPTANCE_CRITERIA.md

## UI
- Pocket Arcade identity from Snake_UI_PERSONALITY.md
- No ColorScheme.fromSeed
- Fraunces for title/score, Figtree for UI
- Home uses assets/home_bg_light.jpg and home_bg_dark.jpg only on Home
- Never put that art behind the live game board
- Play button must not cover the snake/apple illustration

## Home picker
Two rows above Play, not at the top of the screen:

Mode: Classic | Wrap | No Walls | Obstacles
Size: Small | Medium | Large     Speed toggle

- One mode selected
- Chip labels never include the word Pro
- Locked chips: small lock only, same paywall
- Free stays Classic + Medium
- Overflow = horizontal scroll, no messy wrap

## Screen check
After any visual UI change:
1. I will have the emulator on the screen that matters
2. You run `bash tools/check_screen.sh`
3. You open `screenshots/latest.png`
4. You compare it to Snake_UI_PERSONALITY.md
5. If it still looks like default Material, fix that screen only and screenshot again

Do not ask me to attach a screenshot unless the script fails.
Do not guess what the emulator looks like.

When the rule files are written, show me the files you changed and stop.
