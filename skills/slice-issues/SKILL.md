---
name: slice-issues
description: Slice GitHub parent issues into reviewable real sub-issues. Use when Codex is asked to split, slice, decompose, refine, or plan a GitHub issue into child issues, sub-issues, implementation slices, or reviewable follow-up issues before implementation work begins.
---

# Slice Issues

## Overview

Use this workflow to decompose a GitHub issue into reviewable implementation
slices before code changes begin. Prefer real GitHub sub-issues over textual
task lists so the backlog remains traceable and each slice can have its own
acceptance criteria, branch, PR, and verification.

This skill is GitHub-specific but engine-independent. Keep runtime-specific
integration details in `adapters/`.

## Required Reading

- `../references/issue-labels.md` before creating child issues, to set each
  slice's issue type and labels so the backlog and any project board can filter
  them.

## Workflow

1. Identify the parent issue number or URL.
2. Read the parent issue body and comments before slicing.
3. Check existing open issues to avoid duplicate slices.
4. Decide whether the work should be split into sub-issues or kept in one PR
   with clearly separated commits.
5. For each sliced task, create a child issue with GitHub's sub-issue support,
   setting its type and labels per `../references/issue-labels.md`. Use exactly
   one type representation — a native issue type **or** a `type:` label, never
   both:

   ```sh
   # Org repos with native issue types:
   gh issue create --parent <parent> --title "<title>" --body-file <file> \
     --type <Type> --label "<area>,<grouping>"

   # Personal repos (native issue types unavailable) — carry the type as a label:
   gh issue create --parent <parent> --title "<title>" --body-file <file> \
     --label "<type-label>,<area>,<grouping>"
   ```

   A slice is normally a `user-story` (a reviewable slice of value) or a `task`
   (technical work with no direct user value). Use `--body-file` instead of
   `--body` when the body is multi-line or contains Markdown that would be
   awkward to quote safely.
6. Comment on the parent issue with the created child issue links and the
   recommended implementation order.
7. Report the created child issues and any fallback used.

## Slicing Rules

- Make each child issue independently reviewable and small enough for one
  focused PR.
- Give each child issue a clear goal, scope, and acceptance criteria.
- Give each child issue an explicit type and labels per
  `../references/issue-labels.md` — exactly one type representation (a native
  issue type or a `type:` label) plus `area:` and any project grouping such as a
  roadmap phase — so it can be triaged onto a project board
  without re-reading the body. Do not encode workflow status in labels; that
  belongs to the board.
- Preserve the parent issue as the coordination point.
- Prefer dependency order over arbitrary numbering.
- Keep implementation work out of the slicing step unless the user explicitly
  asks to continue into implementation.
- If a slice is only documentation, validation, generator behavior, or example
  refresh work, make that boundary explicit in the title and acceptance
  criteria.

## Fallback

Use body links or Markdown task lists only when GitHub sub-issue creation is
unavailable or rejected by the CLI/API.

When fallback is used:

- Include the exact command that failed.
- Include the exact error returned by the CLI/API.
- Add the fallback links or task list to the parent issue.
- State in the final report that real sub-issues could not be created.

## Relationship To Issue Implementation

After slicing is complete, use `../implement-issue-workflow/SKILL.md` for each
child issue that needs implementation, branch, commit, push, and pull request
work.
