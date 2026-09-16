# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Git Rules (Mandatory)

- **Never run `git commit` or `git push` without first asking and receiving explicit permission for that specific action.** Approval to commit once does not carry over to later commits. Leave changes uncommitted in the working tree and ask.
- **Never run `git push`.** Claude must never be the author or initiator of a push.
- Commits, when Julian approves one, are authored by Julian Reif (the configured git user). Do not set Claude as the commit author.

## Project Overview

This is Julian Reif's personal academic website built with Jekyll using the [Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes) theme as a remote theme. The site is hosted on GitHub Pages at julianreif.com.

## Build and Deploy Commands

Build locally:
```bash
bundle exec jekyll build
```

Serve locally with live reload:
```bash
bundle exec jekyll serve
```

Note: Changes to `_config.yml` require restarting the server. Ruby/Bundler may not be installed on every machine; if not, validate JSON with Python and rely on the GitHub Pages build.

**Deploy process:**
Push to the `master` branch. GitHub Pages builds and publishes the site automatically (no manual build/copy step). `CLAUDE.md` and `README.md` are excluded from the built site via the `exclude` list in `_config.yml`.

**Important:** The `_data/*.json` files must be valid strict JSON — no trailing commas.

## Architecture

### Data-Driven Content
Research publications and software listings are managed via JSON data files in `_data/`:
- `publications.json` - Published papers
- `publications-working.json` - Working papers
- `publications-chapters.json` - Book chapters
- `publications-other.json` - Other publications
- `publications-wip.json` - Works in progress (title, coauthors)
- `publications-grants.json` - External grants
- `software.json` - Software package descriptions

The `_pages/research.md` template iterates over these JSON files to render the research page dynamically.

### Theme Customizations
Custom overrides to the Minimal Mistakes theme:
- `/assets/css/main.scss` - Removes hyperlink underlines, larger avatar, no sidebar fade
- `/_includes/head.html` - Copy of the theme's head with Font Awesome pinned to a fixed version (the theme loads `@latest`). Re-sync with the theme when upgrading.
- `/_includes/head/custom.html` - Favicon, syntax highlighting (VS Code Light+), Google Analytics
- `/_includes/footer.html` - RSS feed link removed

### SEO settings (in `_config.yml`)
- `url`, `og_image`, `social` (schema.org Person + `sameAs` profile links), `atom_feed.hide`, and site-verification placeholders.
- Each page in `_pages/` has its own `description` front matter used for meta/Open Graph descriptions.

### Key Configuration
- Theme skin: `contrast`
- Remote theme: `mmistakes/minimal-mistakes`
- Navigation defined in `_data/navigation.yml`

## Conventions

- Use absolute paths (`/research/...`, `/assets/...`) for internal links and images, not `../`.
- Use `https://` for external links.
- In Liquid templates, test for missing/empty values with `{% if x and x != "" %}`, never `!= blank`. The `blank` literal only works when ActiveSupport happens to be loaded (it was, via the since-removed jemoji plugin) and otherwise evaluates as always-true.
- In `_pages/guide.md`, content headings start at `##` (the page title is the `h1`). Sidebar anchors in `_data/navigation.yml` are derived from heading text, so renaming a heading requires updating the nav.

## Content Updates

To add a new publication, add an entry to the appropriate JSON file in `_data/`. Each entry supports fields: `title`, `coauthors`, `publication`, `award`, `media`, `policy`, `other`, `abstract`.

Research PDFs are stored in `/research/` and CV in `/cv/`.
