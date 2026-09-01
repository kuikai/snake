# Optional online high-score board (Pro, opt-in).

Local scores remain the source of truth and work offline with no Firebase.

## Product

- Pro only, opt-in, default OFF
- Included in the existing $1.99 Pro unlock — no extra IAP
- No email / password / Google / Apple login
- Opt-in uses Firebase Anonymous auth in the background
- Toggle off stops submitting; Play is never blocked by login
- Public list: top 1000 per `mode + boardSize + increasingSpeed`
- Rank 1001+ never shown → copy: `not on the board`
- Paginate 50 rows; hard cap 1000
- Submit only when a personal best for that key is beaten
- Free tap on board / toggle → same Pro paywall

## UI copy

- Toggle: `share scores online`
- Helper: `public. top 1000.`
- First ON sheet: `post your bests to the live board` + nickname 3–12 + `Post` / `Not now`
- Board: mode/size filter, ranked list, mark own row `you`
- Empty: `no scores yet`
- Offline: `offline. local bests still count.`

## Data

Collection: `scores`  
Doc id: `{uid}_{mode}_{size}_{speed}`  
Fields: `uid`, `nickname`, `mode`, `size`, `increasingSpeed`, `score`, `updatedAt`  
Query: match key, `orderBy score desc`, limit 1000

## Setup

Do not init Firebase until opt-in is ON **and** Firebase is configured  
(`lib/firebase_options.dart` with `kFirebaseConfigured = true`, plus platform config files).
