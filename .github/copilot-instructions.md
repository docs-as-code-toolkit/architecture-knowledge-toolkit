# Repository Instructions For GitHub Copilot

Follow the contract hierarchy in `AGENTS.md`.

Before changing or reviewing architecture content, skills, templates, schemas,
or adapters, read and apply `general-semantic-contracts.md`.

Use repository source files as the source of truth. Treat conversational
context, inferred relations, generated prose, and AI output as advisory until a
human reviewer accepts them in the repository.

Keep engine-independent rules in `general-semantic-contracts.md` or `skills/`.
Put GitHub Copilot-specific integration guidance under
`adapters/github-copilot/`.

For pull request reviews, apply `skills/pr-review/SKILL.md` and the adapter
rules in `adapters/github-copilot/README.md`. Prefer direct GitHub PR comments.
If direct PR comments are not available, write
`.pr_comments/.pr<pr-number>_comments.md` on the PR branch.

When this repository is copied or referenced from a target project, keep
project-specific Copilot instructions in the target project's `.github/`
directory and point them back to this toolkit instead of duplicating the full contract text.
