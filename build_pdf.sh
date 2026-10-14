#!/bin/sh
# Render a page to a print-ready PDF.
#
# Pipeline: Markdown -> pandoc -> HTML (templates/print.html) -> headless
# Chrome -> PDF. Reuses css/style.css so the PDF matches the website, plus
# css/print.css for page layout. The template adds a name/contact header.
#
# Output goes to prints/ (gitignored) as jackkilgore-<page>-<YYYYMM>.pdf.
#
# Usage: ./build_pdf.sh [page] [output]
#   page    name of a content/*.md source, without extension (default: cv)
#   output  output PDF path (default: prints/jackkilgore-<page>-<YYYYMM>.pdf)
#
# Examples:
#   ./build_pdf.sh                  # content/cv.md -> prints/jackkilgore-cv-<YYYYMM>.pdf
#   ./build_pdf.sh cv-engineering   # content/cv-engineering.md -> prints/jackkilgore-cv-engineering-<YYYYMM>.pdf
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

PAGE="${1:-cv}"
STAMP="$(date +%Y%m)"
OUT="${2:-prints/jackkilgore-$PAGE-$STAMP.pdf}"
SRC="content/$PAGE.md"
TMP=".print-$PAGE.html"
LOG=".print-$PAGE.log"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [ ! -f "$SRC" ]; then
    echo "No such source: $SRC" >&2
    exit 1
fi

if [ ! -x "$CHROME" ]; then
    echo "Google Chrome not found at: $CHROME" >&2
    exit 1
fi

mkdir -p "$(dirname "$OUT")"

echo "Rendering $OUT <- $SRC"
pandoc "$SRC" \
    --standalone \
    --template templates/print.html \
    --lua-filter filters/links.lua \
    --lua-filter filters/entries.lua \
    -V "pagetitle=jackilgore" \
    -o "$TMP"

# --virtual-time-budget gives the webfont time to load before printing.
# Chrome on macOS writes harmless display-link noise to stderr; capture it,
# drop the known noise, and surface anything else (or everything on failure).
if ! "$CHROME" \
    --headless \
    --disable-gpu \
    --no-pdf-header-footer \
    --virtual-time-budget=5000 \
    --print-to-pdf="$ROOT/$OUT" \
    "file://$ROOT/$TMP" 2>"$LOG"; then
    cat "$LOG" >&2
    rm -f "$TMP" "$LOG"
    exit 1
fi

grep -vE 'CVDisplayLinkCreateWithCGDisplay|task_policy_set|Trying to load the allocator' "$LOG" >&2 || true

rm -f "$TMP" "$LOG"
echo "Done."
