<!-- GENERATED FILE: edit the canonical skills or scripts/build-agent-adapters.js, then regenerate. -->
# Vibe Adapter

This is a thin Vibe-specific wrapper for the example repository.
example keeps no local agent skills of its own; architecture and
software-development-lifecycle semantics are delegated to the
architecture-knowledge-toolkit.

When Vibe performs architecture-sensitive or AI-assisted work in this
repository:

1. Read repository-root `AGENTS.md`.
2. Read repository-root `general-semantic-contracts.md`.
3. Follow the toolkit lookup order in `AGENTS.md`, then read the relevant
   canonical `skills/**/SKILL.md` from the architecture-knowledge-toolkit.
4. Treat this adapter as routing guidance only.

## Toolkit Source Of Truth

Prefer a local toolkit checkout when present (see the lookup order in
`AGENTS.md`); otherwise use the public repository:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

## Adapter Boundary

Do not duplicate architecture, ADR, quality scenario, risk, traceability,
metadata, or arc42 rules here. Agent-specific files may only wrap, point to, or
invoke the canonical toolkit sources, local `skills/`, and repository-root
`general-semantic-contracts.md`.
