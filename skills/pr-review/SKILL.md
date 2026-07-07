---
name: pr-review
description: Review GitHub pull requests and proposed branch changes for correctness, regressions, missing tests, documentation-contract violations, traceability gaps, and reviewability. Use when an AI assistant is asked to review a PR, review pull request changes, inspect a PR branch before merge, or produce PR review comments.
---

# PR Review Skill

## Purpose

Review pull request changes as an evidence-backed code and architecture review.
Prefer actionable findings over broad commentary. Treat AI review output as a
suggestion until a human reviewer accepts it.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
metadata, anchor, Docs-as-Code, arc42, or traceability rules here unless the PR
review workflow needs a stricter rule.

## Core Workflow

1. Identify the PR number, base branch, head branch, changed commits, and
   changed files.
2. Read the PR title, description, linked issue or ADR references, and review
   intent before judging the diff.
3. Inspect the diff and enough surrounding source to verify behavior, not only
   style.
4. Check changed architecture documents, skills, templates, schemas, adapters,
   and generated-output boundaries against the repository contracts.
5. For feature work, refactoring work, or architecture-significant review tasks, use
   `../architecture-impact/SKILL.md` to verify that current architecture
   documentation, implementation, ADRs, quality goals, risks, affected feature
   or refactoring references, Epic/UserStory links, and refactoring issue
   markings stay aligned.
6. Run relevant validators, tests, linters, render checks, or targeted commands
   when available and reasonable for the changed files.
7. Prioritize defects, behavioral regressions, broken contracts, missing
   verification, unsafe assumptions, stale links, and traceability problems.
8. Write findings first, ordered by severity. Keep summaries secondary.
9. Prefer precise file and line references for actionable findings.
10. Separate blocking findings from non-blocking suggestions and questions.
11. If no actionable findings are found, say so clearly and still report any
    residual risk or verification that could not be performed.

## Review Focus

Look especially for:

- Bugs, regressions, data loss, security issues, and user-visible breakage.
- Missing tests or validators for changed behavior.
- Documentation that treats generated or AI-suggested content as reviewed
  truth.
- Architecture artifact metadata that violates `metamodel/artifact.schema.yaml`.
- Relation metadata that violates `metamodel/relations.schema.yaml`.
- New or changed links that ignore explicit AsciiDoc anchors.
- Runtime-specific assumptions placed in engine-independent contracts or
  skills instead of `adapters/`.
- Generated derived output committed as source content.
- Changes that widen scope without explaining the human decision needed.

## Required Reading

Read these files when the PR touches the corresponding scope:

- `../../general-semantic-contracts.md` for architecture content, Docs-as-Code,
  metadata, traceability, quality, risks, SDLC workflow, and writing style.
- `../../AGENTS.md` for automated-contributor rules.
- `../architecture-impact/SKILL.md` before reviewing feature work, refactoring
  work, architecture-significant changes, Epic-linked PRs, UserStory-linked
  PRs, or refactoring PRs.
- `../traceability-review/SKILL.md` before reviewing relation metadata or
  traceability changes.
- `../adr/SKILL.md`, `../quality-scenario/SKILL.md`, or `../risk/SKILL.md`
  before reviewing those artifact types.
- `../../adapters/github-copilot/README.md` when GitHub Copilot performs the
  review.

## Output Channels

Prefer the most review-native output channel available:

1. Comment directly on the GitHub pull request when the reviewer has a tool or
   surface that can create PR review comments.
2. Use inline PR comments for findings tied to a changed line.
3. Use one PR summary comment for cross-file findings, verification notes,
   questions, and "no findings" results.
4. If direct PR comments are not possible, write the fallback review file on the
   PR branch at `.pr_comments/.pr<pr-number>_comments.md`.
5. If the PR number is unknown, identify the PR number before writing the
   fallback file. Do not invent a number.

Do not both post the full review to the PR and create the fallback file unless
the user explicitly asks for an archived copy.

## Fallback File Format

When writing `.pr_comments/.pr<pr-number>_comments.md`, use this structure:

```markdown
# PR <number> Review Comments

Review status: proposed
Base branch: <base>
Head branch: <head>
Reviewed commit: <sha-or-unknown>

## Findings

- [P1] <title>
  File: <path>:<line>
  Problem: <what can go wrong>
  Evidence: <why the changed code or docs cause it>
  Suggested change: <small actionable fix>

## Questions

- <human decision or missing context>

## Verification

- <command>: <result>
- Not run: <reason>
```

Use severity labels consistently:

- `P0`: blocks merge because it is dangerous, destructive, or security-critical.
- `P1`: should block merge because it causes incorrect behavior or breaks a
  repository contract.
- `P2`: should be fixed soon but does not necessarily block merge.
- `P3`: non-blocking improvement.

## Output Rules

- Lead with findings. Avoid congratulatory or generic prose.
- Keep each finding self-contained and actionable.
- Reference changed lines when possible; otherwise reference the smallest
  relevant file or section.
- Do not request changes for personal style preferences unless they hide a real
  risk.
- Do not mark AI-created or AI-modified architecture content as accepted unless
  the repository already records human acceptance.
- Preserve stable IDs and accepted relations unless evidence justifies a
  proposed change.
- State assumptions, unknowns, and verification gaps explicitly.
