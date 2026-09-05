# Paste this into Cursor (Home background only)

Home art is ready. Wire it. Do not put it on the Game board.

Assets (copy into the Flutter project if they are not there yet):
- `assets/home_bg_light.jpg`
- `assets/home_bg_dark.jpg`

Register both in `pubspec.yaml` under `flutter: assets:`.

Home screen:
- Stack the matching background behind the UI (`Theme.of(context).brightness`)
- `BoxFit.cover`
- `IgnorePointer` on the image
- Wordmark + `best 12` stay in the empty upper third
- Play button stays in the middle empty field, **above** the snake and apple
- Do not cover the apple or the snake with the Play pill
- Settings / History stay quiet

Do not use these images on Game, Pause, or Settings.
Do not change the engine.
Stop when Home uses the art in both light and dark.
