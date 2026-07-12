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

Preferred lookup order for the toolkit:

1. `$ARCHITECTURE_KNOWLEDGE_TOOLKIT` if it is set.
2. Otherwise the nearest local `architecture-knowledge-toolkit` checkout found by
   searching upward from this project directory:
   `../architecture-knowledge-toolkit`, then the same directory name in each
   parent directory up to the filesystem root. Do not assume the toolkit is a
   direct sibling; this project may live outside the toolkit's parent folder.
3. Otherwise a project-local recorded toolkit reference such as a submodule,
   vendored copy, or pinned path.
4. Otherwise the public repository above, preferably at a stable release tag or
   commit SHA, for example
   `docs-as-code-toolkit/architecture-knowledge-toolkit@v1.2.3`.

Use the public repository as the fallback source for missing contracts, skills,
templates, schemas, validators, and generators only after the local lookup
fails.

Before architecture or SDLC workflow work:

- inspect existing `src/docs/`, `metamodel/`, `templates/`, `scripts/`, and `skills/`
- use reviewed source files as architecture context; do not use derived output
  such as `generated/`, `build/`, `dist/`, `target/`, `out/`, rendered
  HTML/PDF, generated indexes, traceability views, or assembled documentation
  as evidence
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

## Reference, Don't Copy

Treat the architecture-knowledge-toolkit as the single source of truth for
architecture skills, contracts, and features. Do not copy toolkit
`skills/**/SKILL.md`, `features/`, or contract text into this repository;
resolve them from the toolkit through the lookup order above. Only executable
tooling that must run here — metamodel schemas under `metamodel/`, templates
under `templates/`, and validator/generator scripts under `scripts/` — is copied
or vendored and kept in sync with the toolkit.

Any local `skills/**/SKILL.md` or task contract covers project-specific work
only. Local skills and contracts extend the toolkit — their bodies read the
toolkit baseline first, then add the project-specific steps — or explicitly
override a specific toolkit rule; they never silently duplicate toolkit rules.

## Agent Adapters

Keep runtime-specific integration under `adapters/<agent>/` and generate the
thin routing wrappers instead of hand-writing them:

- Copy the generic generator from the toolkit's
  `templates/scripts/build-agent-adapters.js` and
  `templates/scripts/check-agent-adapters.js` into this project's `scripts/`. Do
  not copy the toolkit's own `scripts/build-agent-adapters.js`; it is wired to the
  toolkit itself.
- The generator derives the project name (from `AGENT_ADAPTER_PROJECT`, an
  optional `adapters/agent-adapters.config.json` `project` field, or the
  repository directory name) and names the Cursor rule
  `adapters/cursor/rules/<project>.mdc`.
- Run `node scripts/build-agent-adapters.js` to generate
  `adapters/codex/AGENTS.md`, `adapters/vibe/AGENTS.md`,
  `adapters/github-copilot/copilot-instructions.md`, and the Cursor rule that
  route agents to this file, `general-semantic-contracts.md`, and the relevant
  skills.
- The generator auto-detects routing: with local `skills/**/SKILL.md` it lists
  them and delegates the rest to the toolkit; with none it routes to the toolkit.
- Keep `.github/copilot-instructions.md` as an entry point only that points to
  `adapters/github-copilot/copilot-instructions.md`.
- Put OpenAI skill UI metadata under `adapters/openai/<skill-name>/openai.yaml`.
- Run `node scripts/check-agent-adapters.js` in CI to fail on stale adapters.
