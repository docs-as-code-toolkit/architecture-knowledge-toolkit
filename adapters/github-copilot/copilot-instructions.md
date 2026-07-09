<!-- GENERATED FILE: edit skills/**/SKILL.md or scripts/build-agent-adapters.js, then regenerate. -->
# GitHub Copilot Adapter

This is a thin GitHub Copilot-specific wrapper for the
architecture-knowledge-toolkit. Keep architecture semantics in
repository-root `general-semantic-contracts.md` and canonical
`skills/**/SKILL.md` files.

When GitHub Copilot performs architecture-sensitive work:

1. Read repository-root `AGENTS.md`.
2. Read repository-root `general-semantic-contracts.md`.
3. Select and read the relevant canonical skill from the list below.
4. Treat this adapter as routing guidance only.

## Canonical Skills

Paths are relative to the architecture-knowledge-toolkit repository root.

- `adr`: `skills/adr/SKILL.md`
- `architecture-core`: `skills/architecture-core/SKILL.md`
- `architecture-impact`: `skills/architecture-impact/SKILL.md`
- `bootstrap-project`: `skills/bootstrap-project/SKILL.md`
- `commit-message`: `skills/commit-message/SKILL.md`
- `domain-modeling`: `skills/domain-modeling/SKILL.md`
- `implement-issue-workflow`: `skills/implement-issue-workflow/SKILL.md`
- `post-merge-sync`: `skills/post-merge-sync/SKILL.md`
- `pr-review`: `skills/pr-review/SKILL.md`
- `presentation`: `skills/presentation/SKILL.md`
- `quality-scenario`: `skills/quality-scenario/SKILL.md`
- `risk`: `skills/risk/SKILL.md`
- `slice-issues`: `skills/slice-issues/SKILL.md`
- `traceability-review`: `skills/traceability-review/SKILL.md`

## Adapter Boundary

Do not duplicate ADR, quality scenario, risk, traceability, metadata, or arc42
rules here. Agent-specific files may only wrap, point to, or invoke the
canonical sources.
