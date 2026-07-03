# GitHub Copilot Adapter

This directory contains GitHub Copilot-specific guidance for this repository.
Keep reusable review and architecture rules in `skills/` and
`general-semantic-contracts.md`; keep only Copilot integration details here.

GitHub Copilot should use:

- `../../.github/copilot-instructions.md` as the repository-level entry point.
- `../../.github/instructions/pr-review.instructions.md` for PR-review-specific
  repository instructions.
- `../../skills/pr-review/SKILL.md` as the engine-independent PR review
  workflow.

## PR Review Behavior

When asked to review a pull request, GitHub Copilot should:

1. Apply `skills/pr-review/SKILL.md`.
2. Read `AGENTS.md` and `general-semantic-contracts.md` before reviewing
   architecture content, skills, templates, schemas, or adapters.
3. Comment directly on the GitHub PR when the active Copilot surface supports
   PR review comments.
4. Prefer inline comments for changed-line findings and one summary comment for
   cross-file findings, verification notes, questions, and no-finding results.
5. If direct PR comments are unavailable, write the review to
   `.pr_comments/.pr<pr-number>_comments.md` on the PR branch.
6. Avoid creating the fallback file when direct PR comments were successfully
   posted, unless the user asks for an archival copy.

The fallback file is intentionally kept in `.pr_comments/` so review feedback is
separate from reviewed source content and can be removed or superseded during
normal PR iteration.
