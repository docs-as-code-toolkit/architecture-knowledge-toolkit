Use this template for your `<project>/AGENTS.md`

# Project Agent Instructions

This project uses architecture-knowledge-toolkit for architecture work and
software-development-lifecycle tasks that are not described more specifically
in this repository.

Apply instructions in this order:

1. User instruction
2. This project `AGENTS.md`
3. Relevant toolkit skill, for example `skills/bootstrap-project/SKILL.md`,
   `skills/implement-issue-workflow/SKILL.md`, `skills/commit-message/SKILL.md`,
   `skills/pr-review/SKILL.md`, `skills/slice-issues/SKILL.md`,
   `skills/post-merge-sync/SKILL.md`,
   `skills/adr/SKILL.md`, `skills/quality-scenario/SKILL.md`, or
   `skills/risk/SKILL.md`
4. Toolkit `general-semantic-contracts.md`

Use the toolkit for:

- product clarification
- arc42 documentation
- ADRs
- quality scenarios
- risks and technical debt
- runtime scenarios
- traceability metadata
- templates
- validation
- generated include fragments
- issue slicing
- issue implementation workflow
- commit messages
- pull request reviews
- post-merge synchronization
- traceability reviews

If an SDLC task is requested and this repository does not describe the task
explicitly, look up the corresponding toolkit skill or contract before acting.
Do not invent a project-local workflow when the toolkit provides one.

Toolkit source of truth:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

If the architecture-knowledge-toolkit is not available on the local filesystem,
inspect the public repository above and use it as the fallback source for
missing contracts, skills, templates, schemas, validators, and generators.
Prefer a stable release tag or commit SHA for long-lived project references,
for example `docs-as-code-toolkit/architecture-knowledge-toolkit@v1.2.3`.

Before architecture or SDLC workflow work:

- inspect existing `src/docs/`, `metamodel/`, `templates/`, `scripts/`, and `skills/`
- verify that referenced toolkit skill paths exist before copying or linking
  them into project guidance
- inspect the toolkit skills before issue implementation, commit message,
  pull request review, issue slicing, post-merge synchronization, ADR,
  quality scenario, risk, or traceability-review work when local instructions
  are missing
- preserve stable artifact IDs
- use AsciiDoc as the default documentation format
- mark AI-created architecture content as `draft` or `proposed`
- set `reviewed: false` unless human acceptance is already recorded
- do not manually maintain generated fragments when a generator exists
- copy missing toolkit templates, schemas, validators, and generator scripts from the toolkit instead of inventing alternatives
