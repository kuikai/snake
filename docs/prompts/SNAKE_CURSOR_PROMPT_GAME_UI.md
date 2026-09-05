# Paste this into Cursor (Game UI pass only)

Read `Snake_UI_PERSONALITY.md` first, especially **section 5 (Game)** and **section 11**.

Then fix the **Game screen only**. Do not touch the engine, scoring, collisions, modes, or other screens.

The current dark Game screen looks like a default Flutter template. Keep the bones: dark field, rounded board, grid, D-pad, pause icon. Change the face.

Do this:

1. Remove the AppBar. No back chevron. No centered title “Classic”.
2. Pause stays as a small icon in the top-right only. Leaving the run goes through pause, not a toolbar back button.
3. Score is the main element above the board:
   - Centered
   - Font: Fraunces 700
   - Size about 40
   - Color: ink (`#EDE6DA` in dark)
4. High score sits directly under it as `best 14` in Figtree, inkSoft (`#A39B8E`). Not “Best 14” on the right.
5. Snake head must be distinct from the body:
   - Body: `#5AA86A`
   - Head: `#C6E3B0`
   - Tiny eyes on the head, looking toward the current direction
6. Snake segments almost fill their cells. 2px gap max. Stop drawing small sparse pills.
7. Food is `#FF6A4A`, a circle almost as big as a cell. Optional tiny stem. It must be obvious in 200ms. No pale pink pin.
8. Board paper `#1C231C` on background `#141814`. Grid `#2C362C` at low opacity. No lime/hairline border around the board.
9. D-pad stays. Slightly lower contrast so the board wins, not the controls.
10. Use palette + theme from `Snake_UI_PERSONALITY.md`. Do not call `ColorScheme.fromSeed`.

Stop when the Game screen matches section 11. Show me the changed files and a short list of what you changed.
