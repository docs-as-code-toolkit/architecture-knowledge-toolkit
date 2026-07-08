# Proposal: Prompting skaliert schlecht

## Event

- Event: ai-assisted-coding meetup
- Host: envite
- Format: 10-20 minute talk with optional short demo
- Deck format: AsciiDoc source rendered to reveal.js with docs-toolbox
- Status: Draft proposal

## Title

Prompting skaliert schlecht: Architecture Knowledge as Code

## Abstract

AI-assisted coding is strong at producing code and text quickly. But architecture
work needs more than speed: it needs context, alternatives, quality goals,
risks, decisions, traceability, and reviewable artifacts.

This talk shows why architecture support for AI agents should not be built from
ever longer prompts. Instead, architecture knowledge should live in the
repository as structured Docs-as-Code assets. The
architecture-knowledge-toolkit turns that idea into a practical harness:
semantic contracts define expectations, skills guide repeatable work, templates
stabilize artifacts, validators create feedback, and generators keep published
views consistent.

The audience will see a concrete ADR-oriented workflow and how the toolkit fits
beside existing publishing tooling such as docToolchain and reproducible build
environments such as docs-toolbox.

## Takeaway

AI agents do not need unlimited freedom for architecture work. They need better
guardrails.

## Audience Benefit

Participants leave with a practical mental model for making AI-assisted
architecture work less accidental: keep knowledge in the repository, make the
rules explicit, and make generated output reproducible and reviewable.

## Demo Promise

The demo can be run live or narrated from prepared artifacts:

1. Show the repository structure.
2. Open `AGENTS.md` and a task-specific skill such as `skills/adr/SKILL.md`.
3. Show a semantic contract or template.
4. Walk through an ADR creation or review flow.
5. Run validation or explain the validation feedback loop.
6. Show how docs-toolbox/docToolchain remain publishing neighbors rather than
   being replaced by the toolkit.
