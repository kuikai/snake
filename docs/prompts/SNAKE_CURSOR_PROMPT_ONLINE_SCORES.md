# Paste this into Cursor

Read `Snake_ONLINE_SCORES.md` and `Snake_UI_PERSONALITY.md` first.

Build the **optional online high-score board**. Do not rewrite gameplay, Home art, or the $1.99 purchase.

## Product rules (strict)

- Local scores stay the source of truth. They work offline with no Firebase.
- Online board is **Pro only** and **opt-in**. Default OFF.
- One Pro purchase already includes this. No extra IAP.
- No email, no password, no Google/Apple login in this version.
- Opt-in creates Firebase **Anonymous** auth in the background.
- Toggle off = stop submitting. Play is never blocked by login.
- Public list = **top 1000 only** per `mode + boardSize + increasingSpeed`.
- Rank 1001+ is never shown. If the player is outside the 1000, show `not on the board`.
- Load 50 rows at a time. Hard cap 1000.
- Submit only when a personal best for that key is beaten, not on every death.
- Free tap on the board / toggle → the same Pro paywall.

## UI

Pocket Arcade. Dry copy. No “Join the global community”.

Settings or History:
- Toggle label: `share scores online`
- Helper: `public. top 1000.`
- First ON → sheet:
  - `post your bests to the live board`
  - nickname 3–12 letters
  - `Post` / `Not now`
- Board screen: mode/size filter, ranked list, `you` on your row
- Empty: `no scores yet`
- Offline: `offline. local bests still count.`

## Data

Collection idea (adjust names if needed, keep the shape):

`scores/{uid}_{mode}_{size}_{speed}`

Fields: uid, nickname, mode, size, increasingSpeed, score, updatedAt

Query: where mode+size+speed match, orderBy score desc, limit 1000.

Add Firestore rules so:
- only authenticated users write
- a user can only write their own uid
- anyone authenticated can read the top list
- reject score writes from non-Pro in app code (client gate). Document that rules cannot see RevenueCat.

Persist locally: optIn flag, nickname, uid.

## Firebase wiring

Use FlutterFire: `firebase_core`, `firebase_auth`, `cloud_firestore`.

If `google-services.json` / `GoogleService-Info.plist` / `firebase_options.dart` are missing:
- still build the Dart service + UI + providers
- stub the backend behind an interface
- print a short TODO listing the exact files I must add
- do not crash the app at launch
- do not call Firebase until opt-in is on AND Firebase is configured

Never init Firebase for Free users just because they opened Home.

## Do not

- Force a login before Play
- Put the board on the Game screen
- Upload the full run history
- Show more than 1000 rows
- Invent friends, chat, or reports
- Change Classic gameplay

When done, list the files you added and how to turn the feature on in the Firebase console (Anonymous auth + Firestore).
