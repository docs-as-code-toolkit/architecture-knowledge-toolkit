# Agent Adapter

This file adapts the repository's engine-agnostic project contracts for AI
coding agents, architecture assistants, and documentation generators. It should
stay small. Do not duplicate general project rules here when they can live in
`general-semantic-contracts.md`.

## Contract Order

Apply instructions in this order:

1. User instruction.
2. Relevant `skills/**/SKILL.md`.
3. This `AGENTS.md` adapter.
4. `general-semantic-contracts.md`.

More specific instructions may narrow or override more general instructions.
They should not silently contradict them; call out unclear conflicts before
making architecture changes.

## Required Baseline

Read and apply `general-semantic-contracts.md` before creating or changing
architecture content. It defines the engine-agnostic project contract for
arc42, Docs-as-Code, metadata, traceability, quality, risks, SDLC work, and
writing style.

Use repository source files as the source of truth. Conversational context,
inferred relations, generated prose, and AI output are advisory until reviewed
and committed. Do not use derived output such as `generated/`, `build/`,
`dist/`, `target/`, `out/`, rendered HTML/PDF, generated indexes, traceability
views, or assembled documentation as evidence or source context for
architecture claims.

## Using This Toolkit From Other Projects

When this repository is used as a toolkit dependency from another software
project, automated agents should treat this repository as the canonical source
for architecture documentation conventions, templates, skills, metamodel
schemas, validators, generator behavior, and SDLC task workflows.

Target projects may contain their own `AGENTS.md`. In that case, apply the
target project's local instructions first, then use this toolkit to fill in
architecture-knowledge-toolkit-specific conventions.

If a target project references this toolkit but does not explicitly describe an
SDLC task locally, inspect the relevant toolkit contract or skill before acting.
Examples include issue slicing, issue implementation, commit messages, pull
request reviews, post-merge synchronization, ADRs, quality scenarios, risks,
traceability reviews, architecture documentation updates, and documentation
validation/generation.

If the architecture-knowledge-toolkit is not available on the local filesystem,
use the public repository as the fallback source of truth:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

Prefer a stable toolkit reference, such as a release tag or commit SHA, when a
target project records a long-lived dependency on the public repository.

Reference, don't copy. Do not copy this toolkit's `skills/**/SKILL.md`,
`features/`, or contract text into a consuming project; resolve them from the
toolkit through the lookup order above. Only executable tooling that must run in
the target project — metamodel schemas, templates, and validator/generator
scripts — is copied or vendored and kept in sync. A project's local skills and
contracts extend the toolkit or explicitly override a specific rule; they never
silently duplicate it. See "Consuming This Toolkit From a Project" in `README.md`.

Do not copy all toolkit rules into global agent installations. Global agent
instructions should only tell agents how to discover and apply this toolkit.

## Agent-Specific Rules

- Prefer small, reviewable changes.
- Preserve stable IDs once assigned.
- Mark AI-created or AI-modified architecture content as draft or proposed
  unless human acceptance is already recorded in the repository.
- Identify assumptions, unknowns, and required human decisions.
- Keep generated content separate from reviewed source content where practical.
- For generated or AI-updated links, prefer the explicit AsciiDoc anchor already
  present in the source file. Do not derive xrefs from artifact-id-prefixed file
  names such as `doc-09000-architecture-decisions.adoc`; the chapter anchor is
  `architecture-decisions`.
- Do not add engine-specific assumptions to engine-independent contracts or
  skills.
- Put Codex-specific, Vibe-specific, or other runtime integration under
  `adapters/`.
- Put OpenAI-specific skill UI metadata, such as `openai.yaml`, under
  `adapters/openai/<skill-name>/`; do not place it under
  `skills/<skill-name>/agents/`.
- Put GitHub Copilot-specific repository instructions in `.github/` only as an
  entry point that points back to `adapters/github-copilot/` and the
  engine-independent skills. For pull request reviews, use
  `skills/pr-review/SKILL.md`.
