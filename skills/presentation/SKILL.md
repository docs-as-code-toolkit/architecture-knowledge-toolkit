---
name: presentation
description: Create or update docs-as-code presentation material as AsciiDoc reveal.js decks rendered with docs-toolbox. Use when Codex needs to prepare talks, meetup or conference proposals, speaker notes, demo scripts, event-specific artifacts under talks/, or slide decks that must remain repository-native rather than PowerPoint or Google Slides files.
---

# Presentation Skill

## Purpose

Create presentation material as reviewed source artifacts in the repository.
AsciiDoc is the source of truth; reveal.js HTML is generated output. Do not
create `.pptx`, Google Slides, Keynote, or binary deck files unless the user
explicitly asks for an additional export.

Apply the repository contract hierarchy: user instruction, this skill,
`AGENTS.md`, then `general-semantic-contracts.md`. Keep this skill
engine-independent; put runtime-specific metadata under `adapters/**`.

## Core Workflow

1. Inspect the repository and read the relevant issue, proposal, documentation,
   or source artifacts before writing slides.
2. Define the communication job in one sentence: by the end, the audience should
   understand, believe, decide, discuss, or do what, and why.
3. Choose a narrative arc before drafting slides. Prefer story flow over a
   feature inventory.
4. Create or update a talk directory below `talks/<event-or-talk-slug>/`.
5. Keep the deck source in `slides.adoc`.
6. Add supporting source artifacts when useful, such as `proposal.md`,
   `demo-script.md`, `speaker-brief.md`, references, abstracts, or follow-up
   notes.
7. Add or update `talks/README.md` and the repository `README.md` when a new
   public talk entry should be discoverable.
8. Render the deck with docs-toolbox through the repository helper when
   available.
9. Treat generated reveal.js HTML below `build/` as derived output, not reviewed
   source content.

## Required Reading

- `../../general-semantic-contracts.md` and `../../AGENTS.md` before adding or
  changing toolkit presentation conventions.
- `references/asciidoc-revealjs.md` before creating or rendering an AsciiDoc
  reveal.js deck.

## Talk Directory Convention

Use:

```text
talks/
  README.md
  <talk-slug>/
    README.md
    slides.adoc
    proposal.md
    demo-script.md
    speaker-brief.md
```

Use lowercase hyphen-case slugs. Prefer the event name when material is
event-specific. Keep future variants in separate talk directories when the
audience, event, or framing changes materially.

## Slide Writing Rules

- Make each slide carry one claim.
- Use takeaway titles instead of topic labels when possible.
- Keep visible slide copy audience-facing; do not expose planning notes.
- Put presenter-only detail in `[NOTE.speaker]` blocks.
- Prefer short bullets, simple tables, and small code snippets.
- Avoid live-demo dependency for the story; provide a fallback demo path.
- Mark AI-created talk material as draft/proposal until reviewed.

## Rendering

Render a talk deck with:

```sh
scripts/render-presentation.sh talks/<talk-slug>/slides.adoc
```

Report whether rendering was run successfully. If docs-toolbox, Docker, Podman,
or `asciidoctor-revealjs` is unavailable, keep the AsciiDoc source valid and
state that render verification could not be completed.

## Output Rules

- Do not commit generated files under `build/`.
- Do not add binary slide deck artifacts by default.
- Keep source links explicit. When slides are based on an issue, proposal, or
  source document, mention it in the talk README or proposal artifact.
- Keep changes small enough to review.
