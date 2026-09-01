#!/usr/bin/env bash
# Grab the current Flutter device/emulator screen so Cursor can inspect it.
# Usage:
#   ./tools/check_screen.sh
#   ./tools/check_screen.sh home
#   ./tools/check_screen.sh game_over

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/screenshots"
LABEL="${1:-latest}"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$OUT_DIR/${LABEL}_${STAMP}.png"
LATEST="$OUT_DIR/latest.png"

mkdir -p "$OUT_DIR"

have() { command -v "$1" >/dev/null 2>&1; }

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

if have flutter; then
  DEVICE_LINE="$(flutter devices --machine 2>/dev/null | head -c 1 || true)"
  flutter screenshot -o "$OUT" >/tmp/snake_screenshot_log.txt 2>&1 || true
  if [[ ! -s "$OUT" ]]; then
    if have adb && adb devices | grep -q $'\tdevice$'; then
      adb exec-out screencap -p > "$OUT"
    else
      cat /tmp/snake_screenshot_log.txt >&2 || true
      fail "No screenshot taken. Start the emulator (or device), run the app, then retry."
    fi
  fi
elif have adb; then
  adb devices | grep -q $'\tdevice$' || fail "adb sees no device. Start the emulator first."
  adb exec-out screencap -p > "$OUT"
else
  fail "Need flutter or adb on PATH."
fi

# Drop a stable name Cursor can always open.
cp "$OUT" "$LATEST"

BYTES="$(wc -c < "$OUT" | tr -d ' ')"
echo "Saved $OUT"
echo "Also $LATEST ($BYTES bytes)"
echo
echo "Cursor: open screenshots/latest.png and compare to Snake_UI_PERSONALITY.md"
