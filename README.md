# jackkilgore.github.io

Personal website, built with **Markdown → pandoc → static HTML** and served by GitHub Pages.

## How the site works

The source of truth is **Markdown** in [`content/`](content/). A build script runs
**pandoc** to convert each Markdown file into a standalone HTML page at the repo
root, wrapping it in a shared HTML template. You commit the generated HTML —
GitHub Pages serves the repo root directly.

```
content/cv.md  ──┐
                 ├── pandoc ──>  cv.html   (committed, served by GitHub Pages)
templates/page.html ──┘
```

## Layout

```
content/          Markdown sources (one .md per page)
templates/        pandoc HTML template (page shell: <head>, nav, footer)
css/style.css     all styling
assets/           images / media
build.sh          converts content/*.md -> *.html at the repo root
*.html            generated output (commit these)
```

## Workflow: updating the site

1. **Edit the Markdown** for the page you want to change, e.g. `content/cv.md`.
2. **Build**:

   ```sh
   ./build.sh
   ```

   This regenerates `cv.html` (and any other page with a `.md` source) at the
   repo root.

3. **Preview** the generated HTML in a browser.
4. **Commit** both the Markdown source _and_ the regenerated HTML.

> Requires [pandoc](https://pandoc.org/) (`brew install pandoc`).

## The header / navigation system

The nav bar lives in **one place**: `templates/page.html`. Each page's build
sets a variable that activates the matching link. In `build.sh`, each page
name maps to a variable:

```sh
case "$name" in
    cv)    active="cv=true" ;;
    index) active="home=true" ;;
esac
```

and the template renders that link as active:

```html
<a class="$if(cv)$active$endif$" href="cv.html">CV</a>
```

So to change the nav, edit the template **once** and rebuild — every page
updates. To add a page to the nav, add a `case` entry and a matching
`$if(...)$` conditional.

### Adding a new page

1. Create `content/yourpage.md`.
2. If you want a nav link to be highlighted as active, add a case to the
   `case` statement in `build.sh` (e.g. `yourpage) active="yourpage=true" ;;`)
   and a matching `$if(yourpage)$` conditional in `templates/page.html`.
3. Run `./build.sh` — it picks up every `content/*.md` automatically.

## Markdown conventions

Pandoc's extended Markdown is used. A few patterns specific to this site:

- **Sections** are fenced divs with a page-scoped class, e.g. `::: {.cv}`.
  Fenced divs must be separated from content by blank lines.
- **Entry rows** (a title with a right-aligned date) are **definition lists**:

  ```markdown
  Lunacy Audio
  : 2023 - 2026
  ```

  Pandoc renders these as `<dl><dt>…</dt><dd>…</dd></dl>`.

- **Italic subtitles** are written as `*…*`, rendered as `<em>`.
- **Bullet lists** are standard Markdown `- item` lists.

## CSS architecture

`css/style.css` is organized into layers, from most general to most specific:

1. **`:root`** — CSS custom properties. `--base-font-size` is the master knob;
   changing it rescales all text proportionally across the site.
2. **Global element rules** — `body`, `h2`, `p`, `ul`, `li`, `.topnav`,
   `#content`, `.flex-container`. Shared typography and layout that every page
   uses.
3. **Page-scoped rules** — prefixed with a page class (e.g. `.cv`). These apply
   only inside that page's sections and don't leak into other pages.

### The inheritance pattern

Global rules define the shared defaults; page-scoped rules **inherit** them and
override only what's specific to that page. For example, lists are styled
globally, and the CV adds whitespace below them:

```css
ul { margin: 0; ... }          /* global default */
.cv ul { margin-bottom: 1.5em; }  /* CV-specific: only adds the bottom margin */
```

To add a new page type, give it its own class namespace (e.g. `.works`) and
scope its page-specific rules under that prefix, reusing the global rules for
everything shared.
