---
applyTo: "**/*"
---

# Pull Request Review Instructions

This file is a GitHub Copilot PR-review entry point only. Keep GitHub
Copilot-specific review integration under `adapters/github-copilot/` and keep
reusable PR-review semantics in `skills/pr-review/SKILL.md`.

When asked to review a pull request, apply repository-root
`adapters/github-copilot/README.md` and repository-root
`skills/pr-review/SKILL.md`.

Do not duplicate architecture or review semantics here. Add durable rules to
the canonical skill or adapter source instead.
