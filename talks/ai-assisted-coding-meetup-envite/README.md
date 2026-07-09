# ai-assisted-coding meetup by envite

Proposal material for the `ai-assisted-coding meetup` hosted by `envite`.

## Talk

**Working title:** Prompting skaliert schlecht: Architecture Knowledge as Code

**Core message:** AI-assisted coding is powerful, but architecture work becomes
reproducible, reviewable, and team-capable only when the working method is
explicit: repository truth, semantic contracts, skills, templates, validation,
and deterministic generation.

**Audience:** Developers, architects, technical leads, and AI-assisted coding
practitioners who already see the productivity upside of coding agents and now
need a stronger way to handle architecture knowledge.

**Suggested length:** 10-15 minutes plus 5 minutes Q&A.

**Language:** The talk will be delivered in German. Talk-facing artifacts such
as the deck, proposal, speaker brief, demo script, and reusable fragments are
therefore written in German, while established technical terms such as
Docs-as-Code, Skills, ADR, and docs-toolbox remain unchanged where useful.

## Artifacts

- [AsciiDoc reveal.js slide deck](slides.adoc)
- [Proposal abstract](proposal.adoc)
- [Demo script](demo-script.adoc)
- [Speaker brief](speaker-brief.adoc)
- [Reusable AsciiDoc fragments](fragments/)

Render the deck with docs-toolbox:

```sh
scripts/render-presentation.sh talks/ai-assisted-coding-meetup-envite/slides.adoc
```

The generated reveal.js deck is written to
`build/talks/ai-assisted-coding-meetup-envite/index.html`.

Serve the generated deck through docs-toolbox when using Reveal.js browser
features such as speaker notes:

```sh
DOCS_TOOLBOX_IMAGE="${DOCS_TOOLBOX_IMAGE:-ghcr.io/docs-as-code-toolkit/docs-toolbox:latest}"

docker run --rm \
  -p 8000:8000 \
  -v "$(pwd)":/app \
  -w /app \
  "$DOCS_TOOLBOX_IMAGE" \
  docs-toolbox-serve build/talks/ai-assisted-coding-meetup-envite 8000
```

Then open `http://localhost:8000/index.html`.

## Source

The first proposal is based on
[GitHub issue #53](https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit/issues/53)
and should be treated as draft talk material until the event framing and demo
path are reviewed.
