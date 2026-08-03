#!/bin/sh
# Build static HTML pages from Markdown sources in content/ using pandoc.
# Usage: ./build.sh     (requires pandoc)
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

TEMPLATE="templates/page.html"
FILTER="filters/links.lua"

build_page() {
    md="$1"
    name="$(basename "$md" .md)"
    out="${name}.html"

    # Which nav link is active for this page.
    active=""
    case "$name" in
        cv)      active="cv=true" ;;
        index)   active="home=true" ;;
        contact) active="contact=true" ;;
        affection) active="works=true" ;;
        new)     active="works=true" ;;
        emission_control_2) active="works=true" ;;
        live)    active="works=true" ;;
    esac

    echo "Building $out <- $md"
    if [ -n "$active" ]; then
        pandoc "$md" \
            --standalone \
            --template "$TEMPLATE" \
            --lua-filter "$FILTER" \
            -V "pagetitle=jackilgore" \
            -V "$active" \
            -o "$out"
    else
        pandoc "$md" \
            --standalone \
            --template "$TEMPLATE" \
            --lua-filter "$FILTER" \
            -V "pagetitle=jackilgore" \
            -o "$out"
    fi
}

for md in content/*.md content/*/*.md; do
    [ -e "$md" ] || continue
    build_page "$md"
done

echo "Done."
