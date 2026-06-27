# Agent Guidance

This repository may be used with AI coding agents, architecture assistants, and
documentation generators. The rules below apply to all automated contributors.

## Semantic Contracts
Unless otherwise specified or overridden here or any specific skill, the general semantic contracts from ./general-semantic-contracts.md apply.

## Source of Truth

The repository owns the architecture truth. Agent output is advisory until a human
reviewer accepts it by committing source files and metadata.

Agents must not treat generated prose, inferred relationships, or conversational
context as authoritative. Authoritative inputs are version-controlled files,
especially AsciiDoc documents and metadata files conforming to `metamodel/`.

## Editing Rules

- Prefer small, reviewable changes.
- Preserve stable IDs once assigned.
- Do not rename, merge, or delete architecture artifacts without an explicit
  migration note.
- Keep generated content separate from reviewed source content where practical.
- Do not add engine-specific assumptions to engine-independent skills.
- Put Codex-specific, Vibe-specific, or other runtime integration under
  `adapters/`.

## AI Output Policy

When creating architecture content, mark it as a suggestion unless the user asks
for a reviewed final artifact. Suggested output should identify assumptions,
unknowns, and required human decisions.

Even when the user asks for a reviewed final artifact, repository truth remains
version-controlled source accepted through human review. Agents may prepare a
review-ready artifact, but they must not mark architecture decisions, relations,
risks, or requirements as human-accepted unless that acceptance is already
recorded in the repository.

## Generator Expectations

Future generators in this project must be deterministic and idempotent:

- Same inputs produce the same outputs.
- Re-running a generator without input changes produces no meaningful diff.
- Output ordering is stable.
- Timestamps, random values, and environment-specific paths are avoided unless
  explicitly modeled as inputs.

