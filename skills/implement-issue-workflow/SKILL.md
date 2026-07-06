---
name: implement-issue-workflow
description: "Implement GitHub issue work using the repository workflow: start from the latest main branch, create an issue_<number> branch, make focused changes, verify, commit using the commit-message skill, push, and open a pull request. Use when Codex is asked to implement or fix a GitHub issue, continue issue work, prepare a PR for issue work, or address pull request review comments."
---

# Implement Issue Workflow

Use this workflow for issue implementation so changes are reviewable and never land directly on `main`.

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
2. Keep commits meaningful and use `../commit-message/SKILL.md` for message text.
3. Run the relevant tests, linters, validators, generators, or manual checks before committing.
4. Do not commit generated derived output when the issue or repository contract says it must remain uncommitted.
5. Leave unrelated worktree changes untouched.

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

## After PR Integration

When the pull request is rebased or merged onto `main`, use
`../post-merge-sync/SKILL.md` to return the checkout to the latest base branch,
confirm the merged changes are present, and clean up the local PR branch when it
is safe to do so.
