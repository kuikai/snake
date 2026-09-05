# Paste this into Cursor

Rare critters: exactly five kinds. Keep spawn rules. Do not rewrite Home or paywall.

## Spawn (unchanged)

- After an apple, 15% chance
- Not before 3 apples this run
- After a critter is eaten or expires, 3 more apples before the next roll
- One at a time
- Spawn 2–5 tiles from the head
- Lives 5 ticks
- Eat: +5 score, grow +1
- Free + Pro, every mode

## Kinds — only these five

`mouse` `lizard` `frog` `beetle` `bird`

Remove rat / snail / rabbit if they exist.
Update `CritterKind` to that list. Pick one at random.

## Draw

CustomPainter only. Must read in one cell:

- mouse — grey-brown, ears, tail
- lizard — olive, not the snake color, tiny legs
- frog — round bright green, side eye
- beetle — dark oval, shell line
- bird — small body + beak, not apple-red

Do not use photo sprites.
Do not change tick rate or collisions.
