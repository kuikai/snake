# Paste this into Cursor (after copying tools/check_screen.sh into the Flutter repo)

You can see the running app. After any UI change:

1. Make sure the emulator is open and Snake is on the screen I care about.
2. Run: `bash tools/check_screen.sh`
3. Open `screenshots/latest.png`
4. Compare it to `Snake_UI_PERSONALITY.md`
5. If it still looks like default Material, fix that screen only and screenshot again.

Do not ask me to attach a screenshot unless the script fails.
