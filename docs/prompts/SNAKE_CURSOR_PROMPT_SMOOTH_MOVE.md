# Paste this into Cursor

Add a Settings toggle for snake motion. Do not change gameplay rules.

## Behavior

Default stays the current old-style snap: the snake jumps one cell per tick. That is correct.

New setting:
- Label: `smooth move`
- Default: OFF
- Available to Free and Pro
- Persisted in settings (`smoothMove: bool`)

When ON:
- During each tick, draw the snake lerping from the previous grid cell to the next
- Head, body, and tail all follow the same interpolation
- Wrap mode must lerp through the edge correctly (do not draw a segment across the whole board)
- Collision, speed, score, food spawn, continues — unchanged
- Pause freezes the visual mid-lerp

When OFF:
- Exact current snap rendering

## Do not

- Make smooth the default
- Add a second game speed
- Add particles or stretchy cartoon goo
- Gate this behind Pro
- Rewrite Home or Game Over

When done, list the files you changed. If the emulator is running, screenshot Game with the toggle on and off.
