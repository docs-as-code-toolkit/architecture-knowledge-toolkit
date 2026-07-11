Use this for `<project>/.github/copilot-instructions.md`

# Repository Instructions For GitHub Copilot

Follow the project `AGENTS.md`.

If this project generates agent adapters (see `adapters/` and
`scripts/build-agent-adapters.js`), keep this file as an entry point only:
follow `adapters/github-copilot/copilot-instructions.md`, then the contract
hierarchy in `AGENTS.md` and `general-semantic-contracts.md`, and do not
duplicate architecture or SDLC rules here. Otherwise this file delegates
directly to the toolkit as described below.

This project uses architecture-knowledge-toolkit for architecture documentation,
ADRs, quality scenarios, risks, traceability metadata, templates, validators,
generated include fragments, and SDLC task workflows that are not described
more specifically in this repository.

Use the toolkit repository as source of truth when local toolkit files are missing:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

If the architecture-knowledge-toolkit is not available on the local filesystem,
inspect the public repository above and use it as the fallback source for
missing contracts, skills, templates, schemas, validators, and generators.
Prefer a stable release tag or commit SHA for long-lived project references.

For architecture-related or SDLC workflow changes:

- prefer small, reviewable changes
- preserve stable IDs
- use reviewed source files as architecture context; do not use derived output
  such as `generated/`, `build/`, `dist/`, `target/`, `out/`, rendered
  HTML/PDF, generated indexes, traceability views, or assembled documentation
  as evidence
- keep AI-generated or AI-modified architecture content in `draft` or `proposed` state unless reviewed
- do not manually maintain generated fragments
- consult the relevant toolkit skill before issue slicing, issue
  implementation, commit message, pull request review, post-merge
  synchronization, ADR, quality scenario, risk, or traceability-review work
  when local instructions are missing
- do not introduce Copilot-specific rules into engine-independent toolkit files
