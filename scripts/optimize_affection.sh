#!/bin/sh
# One-time helper: convert the Affection album images into web-optimized
# WebP files under assets/affection/.
#
# Usage: ./scripts/optimize_affection.sh
#
# Requires: cwebp (from libwebp, e.g. `brew install webp`)
#
# Source images live outside the repo (iCloud). They are NOT committed;
# only the generated .webp files under assets/affection/ are.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="/Users/jckl/Library/Mobile Documents/com~apple~CloudDocs/aesth_Projects/pop/Affection-Album/affection"
OUT="$ROOT/assets/affection"

mkdir -p "$OUT"

# Longest edge in pixels. Album art is square; photos are resized to this
# max dimension which is plenty for a ~900px-wide page.
MAX=1600
QUALITY=80

for f in "$SRC"/*.png "$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.JPG "$SRC"/*.PNG; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    name="${base%.*}"
    # Replace spaces in filenames with dashes so the output paths are
    # easy to reference in Markdown (e.g. "1.the point" -> "1.the-point").
    name="$(printf '%s' "$name" | tr ' ' '-')"
    out="$OUT/${name}.webp"
    cwebp -q "$QUALITY" -resize "$MAX" 0 -mt "$f" -o "$out" >/dev/null
    echo "wrote $out"
done

echo "Done."
