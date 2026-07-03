---
applyTo: "**/*"
---

# Pull Request Review Instructions

When asked to review a pull request, use `skills/pr-review/SKILL.md`.

For this repository, review findings should focus on correctness, regressions,
missing verification, architecture-contract violations, generated-output
boundaries, traceability gaps, stale links, and runtime-specific assumptions
placed outside `adapters/`.

Prefer direct GitHub PR review comments. Use inline comments for changed-line
findings and one summary comment for cross-file findings or verification notes.
If direct PR comments are unavailable, write
`.pr_comments/.pr<pr-number>_comments.md` on the PR branch, following the
fallback format in `skills/pr-review/SKILL.md`.
