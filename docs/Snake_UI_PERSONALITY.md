# Snake – UI Personality Sheet

Cursor must follow this file for all UI.  
Do not fall back to generic Material 3 cards, ListTiles, FABs, and seed-color themes.

**Identity name:** Pocket Arcade  
**Feeling:** a small physical game you keep in a drawer — warm, chunky, quiet. Not a dashboard. Not neon cyber.

---

## 1. What this app should *not* look like

- Settings-screen-as-home (lists of tiles)
- Cards stacked in a column with 16px padding
- Purple/teal Material seed theme
- Inter / Roboto / Outfit everywhere
- “Unlock your full potential” paywall copy
- Glass, gradients on every button, glow, particles
- Pixel-font retro cliché (no Press Start 2P)

If a screen looks like every other Flutter template, rewrite it.

---

## 2. Color (locked hex)

Put these in `lib/core/palette.dart`. Do not invent extra brand colors.

### Light
| Token | Hex | Use |
|---|---|---|
| cream | `#F3EDE2` | App background |
| paper | `#E7DCCB` | Board background |
| grid | `#D4C6B0` | Grid lines |
| ink | `#1C1915` | Titles, score |
| inkSoft | `#5C554C` | Secondary text |
| snake | `#2B6B3A` | Body |
| snakeHead | `#1E4D28` | Head (darker, always distinct) |
| belly | `#7CB389` | Subtle inner highlight on body |
| fruit | `#E24B2E` | Food — the only loud color |
| fruitStem | `#3A6B32` | Tiny stem on food |
| play | `#1C1915` | Primary button fill |
| playText | `#F3EDE2` | Primary button text |

### Dark
| Token | Hex | Use |
|---|---|---|
| cream | `#141814` | App background |
| paper | `#1C231C` | Board background |
| grid | `#2C362C` | Grid lines |
| ink | `#EDE6DA` | Titles, score |
| inkSoft | `#A39B8E` | Secondary text |
| snake | `#5AA86A` | Body |
| snakeHead | `#C6E3B0` | Head (lighter than body in dark) |
| belly | `#3E7A4A` | Inner highlight |
| fruit | `#FF6A4A` | Food |
| fruitStem | `#8FCB84` | Stem |
| play | `#EDE6DA` | Primary button fill |
| playText | `#141814` | Primary button text |

Pro skins / board themes may remap snake + paper + grid only.  
**Fruit stays fruit-colored.** Never make food the same color as the snake.

---

## 3. Type

Use `google_fonts`.

| Role | Font | Weight | Notes |
|---|---|---|---|
| Title / wordmark | **Fraunces** | 600–700 | Soft serif. This is the handwriting. |
| Score | **Fraunces** | 700 | Big. Tabular figures if available. |
| Buttons / labels | **Figtree** | 600 | |
| Body | **Figtree** | 400–500 | |

Sizes (logical px):
- Wordmark on Home: 48–56
- In-game score: 36–44
- Play button: 18–20
- Everything else stays smaller than the score

No all-caps paragraphs. The wordmark may be “Snake” not “SNAKE”.

---

## 4. Shape

- Board outer corner: **20**
- Board sits on the cream background with a **soft shadow**, not inside a Material Card
- Cells: square, **2 px gap**, cell corner **3**
- Snake segments: rounded squares that almost fill the cell (corner 5)
- Head: same size as body, but darker + tiny eye dots
- Food: circle, slightly smaller than a cell, optional 2px stem
- Primary Play button: **stadium** (999 radius), full width, tall (56–64)
- Secondary buttons: radius **14**, outline or text — not another filled black pill
- D-pad buttons: circular, 56–64, low emphasis
- No FAB
- No default ListTile chevrons on Home

---

## 5. Layout rules

### Home
- Wordmark top-left or top-center, not inside an AppBar with a back arrow
- High score as a small caption under the wordmark: `best 42`
- Giant Play button near the bottom
- Mode / size as small chips above Play (not a settings list)
- Settings and History as two quiet text/icon buttons
- Lots of empty cream. Let it breathe.

### Game
- No AppBar. No back chevron in a toolbar. No centered “Classic” title bar.
- Score is top-center, Fraunces 700, the biggest thing above the board
- Best sits under the score as `best 14`, Figtree, inkSoft
- Pause is a small top-right icon only
- Back / leave lives behind pause, not as a toolbar action
- Board centered, max width, side margins 16
- D-pad below the board, same as now (this part is fine)
- Mode name can be a tiny caption under `best`, not a title

### Game Over
- Not a dialog on a grey scrim
- Full screen cream
- Score huge
- One line of voice (see copy)
- Restart = primary pill
- Menu = text button
- Continue (Pro) = secondary outline button
- Upgrade nudge for Free = one quiet line + text button, not a modal wall

### Settings / History / Paywall
- These may look more “app-like”
- Still use Fraunces for the screen title
- Still use the cream/ink palette
- Paywall is a short list of facts, not feature marketing

---

## 6. Motion (one signature, keep it cheap)

- Snake **lerps** toward the next cell during the tick so it doesn’t teleport
- Food **pops** scale 0.85 → 1.08 → 1.0 on spawn / eat (150ms)
- Score **ticks** up, no counting-machine animation
- Game Over fades in 200ms
- No particles, no shake-on-everything, no bounce on every tap

---

## 7. Copy tone

Dry, short, a little human. Never corporate. Never cute-overload.

| Moment | Say this | Do not say |
|---|---|---|
| Home subtitle | `eat. don't hit yourself.` | Welcome to Snake! |
| High score | `best 42` | High Score: 42 pts |
| Pause | `paused` | Game Paused |
| Game over, normal | `oof.` | Game Over! Better luck next time! |
| Game over, decent | `nice run.` | Congratulations |
| New best | `new best.` | NEW HIGH SCORE!!! |
| Continue used | `still here. 2 left.` | Continue purchased successfully |
| Free upgrade line | `want another shot?` | Unlock premium features |
| Paywall title | `Pro` | Go Pro and Supercharge Your Gameplay |
| Paywall price | `$1.99 once` | Billed once. Cancel anytime. |
| Empty history | `no runs yet.` | You haven't completed any games. |
| Restore | `Restore purchase` | Restore Purchases (Manage Subscription) |

Buttons: `Play`, `Again`, `Menu`, `Continue`, `Unlock · $1.99`

---

## 8. Sound / haptic personality

- Eat: short tick, light haptic
- Death: lower thud, heavier haptic
- Turn: haptic only if enabled, no sound
- No looping music in MVP

---

## 9. Implementation notes for Cursor

- ThemeData is allowed, but **override** colors from `palette.dart`. Do not call `ColorScheme.fromSeed`.
- `useMaterial3: true` is fine for ripples and text fields. Visual identity still comes from palette + type + shape.
- Put text styles in `lib/core/app_theme.dart`.
- Wordmark widget: `lib/widgets/snake_wordmark.dart`
- Board painter must draw grid, snake, head eyes, fruit. Do not use a GridView of colored Containers if a painter is cleaner.
- If you add a default AppBar, you already drifted. Check Home again.

---

## 10. Personality check (before calling a screen done)

- [ ] Can I tell this is Snake from a blurry screenshot?
- [ ] Is the score the loudest number on the game screen?
- [ ] Is fruit the only saturated accent?
- [ ] Is there a serif wordmark somewhere?
- [ ] Would this Home still make sense if I ripped out every ListTile?
- [ ] Is any sentence longer than it needs to be?

---

## 11. Dark Game screen — fix pass (from current screenshot)

The current dark Game screen is too close to a Flutter template. Keep the layout bones (board + D-pad). Change the face.

### Keep
- Dark green-black field
- Rounded board
- Four-button D-pad
- Pause icon in the corner
- Grid (but make it quieter)

### Change
1. **Kill the AppBar.** Remove the top row `←  Classic  ⏸`. Pause stays as a lone icon. Leaving the run goes through pause.
2. **Score owns the top.** `0` is Fraunces, ~40px, centered. `best 14` is small underneath. Current top-left 0 / top-right Best 14 looks like a stats header.
3. **Head must read as a head.** Same mint squares in a row is a caterpillar, not a snake. Head = lighter (`#C6E3B0` in dark), tiny eyes looking toward movement. Body stays `#5AA86A`.
4. **Fruit must pop.** Current food is a pale pink pin. Make it `#FF6A4A`, circle almost cell-sized, optional stem. You should spot it in 200ms.
5. **Segments should fill the cell.** Current snake looks like sparse pills with too much board around each piece. Almost fill the cell, 2px gap max.
6. **Board vs background.** Paper `#1C231C` on cream `#141814`. Grid `#2C362C` at low opacity. No lime hairline border.
7. **D-pad is fine.** Keep circles. Icons can stay. Slightly lower contrast so the board wins, not the controls.
8. **Type.** If score/best are still default sans, swap them. This is the fastest “not AI” fix on this screen.

### Paste to Cursor
> Game screen still looks like default Material. Follow Snake_UI_PERSONALITY.md section 11. Remove the AppBar. Center a Fraunces score. Distinct head with eyes. Fruit is #FF6A4A and cell-sized. Snake segments fill their cells. No lime border. Do not change the engine.
