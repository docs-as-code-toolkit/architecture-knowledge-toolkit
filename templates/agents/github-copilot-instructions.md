Use this for `<project>/.github/copilot-instructions.md`

# Repository Instructions For GitHub Copilot

Follow the project `AGENTS.md`.

This project uses architecture-knowledge-toolkit for architecture documentation,
ADRs, quality scenarios, risks, traceability metadata, templates, validators,
and generated include fragments.

Use the toolkit repository as source of truth when local toolkit files are missing:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

For architecture-related changes:

- prefer small, reviewable changes
- preserve stable IDs
- keep AI-generated or AI-modified architecture content in `draft` or `proposed` state unless reviewed
- do not manually maintain generated fragments
- do not introduce Copilot-specific rules into engine-independent toolkit files