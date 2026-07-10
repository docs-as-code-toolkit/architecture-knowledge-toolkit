---
name: implement-issue-workflow
description: "Implement GitHub issue work using the repository workflow: start from the latest main branch, create an issue_<number> branch, make focused changes, verify, commit using the commit-message skill, push, and open a pull request. Use when Codex is asked to implement or fix a GitHub issue, continue issue work, prepare a PR for issue work, or address pull request review comments."
---

# Implement Issue Workflow

Use this workflow for issue implementation so changes are reviewable and never land directly on `main`.

If the issue is a feature request, Epic, UserStory, refactoring task, or
architecture-significant change, use `../architecture-impact/SKILL.md` before
and during implementation so the current architecture documentation,
implementation, ADRs, quality goals, risks, affected feature or refactoring
references, and issue markings stay aligned.

If the issue adds or changes observable behaviour — a feature, a behavioural
enhancement, or a behaviour-changing bug fix — use `../bdd-specification/SKILL.md`
no later than implementation time. This is the strict default: a language-agnostic
Gherkin `.feature` spec must exist and be bridged into the tests through the
scenario-to-test naming convention before the change is considered done. Write or
complete the spec first when analysis did not already produce it. Skip it only
with an explicit human waiver recorded in the issue or pull request.

If the issue is too broad for one focused pull request, or the user asks to
split, slice, decompose, or plan it before implementation, use
`../slice-issues/SKILL.md` first. Continue with this implementation workflow
only after the target issue or child issue is clear.

## Start Issue Work

1. Inspect the current branch and worktree before changing branches.
2. If unrelated user changes are present, preserve them and ask before moving or mixing them.
3. Fetch the latest `main` from the remote repository.
4. Switch to `main` and fast-forward it to the latest remote `main`.
5. Create a new branch named `issue_<number>` from that updated `main`.
6. Read the issue body and acceptance criteria from GitHub before implementing.

If useful work was already done on `main`, stash or otherwise preserve only that work, create the issue branch from updated `main`, and apply the work on the issue branch before continuing.

## Implement And Verify

1. Make small, reviewable changes that directly address the issue.
2. By default, for any behaviour-adding or behaviour-changing work, apply
   `../bdd-specification/SKILL.md`: keep the Gherkin `.feature` spec and its
   bridged tests in sync with the implementation. Every scenario has at least one
   identifiable automated verification, traceable by a stable id or the
   scenario-to-test naming convention; supporting unit tests need no separate
   scenario.
3. Keep commits meaningful and use `../commit-message/SKILL.md` for message text.
4. Run the relevant tests, linters, validators, generators, or manual checks before committing.
5. Do not use derived output as architecture evidence or context. This includes
   `generated/`, `build/`, `dist/`, `target/`, `out/`, rendered HTML/PDF,
   generated indexes, traceability views, and assembled documentation.
6. Do not commit generated derived output when the issue or repository contract says it must remain uncommitted.
7. Leave unrelated worktree changes untouched.
8. For feature or refactoring work, update or explicitly report the
   architecture impact using `../architecture-impact/SKILL.md`.

## Commit, Push, And PR

1. Stage only files that belong to the issue.
2. Commit using `../commit-message/SKILL.md`.
3. Push the `issue_<number>` branch to the remote repository.
4. Open a pull request against `main`.
5. Include the issue link, implementation summary, and verification results in the pull request body.

## Address PR Comments

1. Inspect review comments and decide which ones require code changes.
2. Group fixes into useful commits by intent.
3. Push the new commits to the existing PR branch.
4. Re-run and report relevant verification.

## PR Integration

Prefer a linear history when integrating pull requests. For a clean, mergeable
pull request with green checks, use rebase integration with remote branch
cleanup:

```sh
gh pr merge <number> --rebase --delete-branch
```

This preserves the PR's individual commits on the base branch. Do not squash
unless the user explicitly requests squash integration or repository policy
requires it. Use merge commits only when the user explicitly requests them or
repository policy requires merge commits.

Do not integrate or clean up branches automatically when there are warning
signs, such as failed or unknown checks, unresolved merge state, a diverged
local branch, unpushed local commits, uncertain PR state, or unclear branch
ownership. Report the situation and let the developer decide.

## After PR Integration

When the pull request is integrated onto `main`, use
`../post-merge-sync/SKILL.md` to return the checkout to the latest base branch,
confirm the integrated changes are present, and clean up local and remote PR
branches when it is safe to do so.
Use post-merge-sync to tidy local branches before starting the next issue.
