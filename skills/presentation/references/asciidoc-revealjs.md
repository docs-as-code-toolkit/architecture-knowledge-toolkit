# AsciiDoc reveal.js Reference

Use this reference when creating or editing slide decks for rendering with
Asciidoctor reveal.js.

## Source Shape

Use one `.adoc` file per deck as the reviewed source. Use generated HTML under
`build/` as derived output.

Minimal deck:

```asciidoc
= Talk Title
:author: Speaker Name
:revdate: 2026-07-08
:revealjs_theme: white
:revealjs_slideNumber: true
:source-highlighter: highlight.js

== First slide title

One clear claim.

[NOTE.speaker]
--
Presenter notes that are not visible on the slide.
--
```

## Slide Structure

- Use level-2 headings (`==`) for horizontal slides.
- Use level-3 headings (`===`) only when vertical reveal.js stacks are useful.
- Keep visible slide copy short and audience-facing.
- Put talk-track detail in `[NOTE.speaker]` blocks.
- Prefer AsciiDoc lists, tables, source blocks, and includes over embedded HTML.
- Use PlantUML for architecture diagrams when the talk needs diagrams, matching
  the repository's architecture documentation convention.

## Render Command

Prefer the repository helper:

```sh
scripts/render-presentation.sh talks/<talk-slug>/slides.adoc
```

The helper writes derived reveal.js HTML to:

```text
build/talks/<talk-slug>/index.html
```

If calling Asciidoctor directly inside docs-toolbox, use:

```sh
asciidoctor-revealjs \
  -r asciidoctor-diagram \
  -r asciidoctor-diagram/plantuml \
  --failure-level=ERROR \
  -a icons=font \
  -a source-highlighter=highlight.js \
  -D build/talks/<talk-slug> \
  -o index.html \
  talks/<talk-slug>/slides.adoc
```
