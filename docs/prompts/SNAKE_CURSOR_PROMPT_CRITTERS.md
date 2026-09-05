# Paste this into Cursor

Add Nokia-style rare critters. Do not rewrite Home, paywall, or Settings beyond what the engine needs.

Read Snake_PRODUCT_SPEC.md and Snake_MODELS.md first.

## What to add

Regular food stays the apple (+1, always on the board).

Sometimes a **mouse, rat, or lizard** appears. Extra score. Short life.

Rules:
- After the player eats an apple, **15%** chance to spawn one critter
- Not before **3** apples eaten this run
- After a critter is eaten or expires, eat **3** more apples before the next spawn can roll
- Only one critter at a time
- Pick kind at random: mouse / rat / lizard
- Spawn 2–5 Manhattan tiles from the **head**
- Not on snake, apple, or obstacles
- If no legal cell exists, skip the spawn
- Lives **5 ticks**, then vanishes. No penalty
- Eating it: score **+5**, grow +1
- Apple still respawns as usual when eaten. Critter does not replace the apple
- Free + Pro, every mode
- Pause freezes the remaining life ticks

## Draw

Keep CustomPainter. No image files required.

- Mouse / rat: grey-brown, ears, tail — not red
- Lizard: olive different from snake body + tiny legs
- Must be readable as “not the apple” in 200ms
- Optional: tiny ticks showing life left (5 → 0)

## Do not

- Change tick rate or collision rules
- Make critters Pro-only
- Add a new mode
- Award +5 and also skip the grow
- Let the critter sit forever

When done, list files changed. If the emulator is up, play until a critter appears and screenshot it.
