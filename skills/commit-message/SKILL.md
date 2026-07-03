---
name: commit-message
description: Write repository commit messages. Use when an agent creates commits, prepares commit text, reviews commit history, or updates workflow guidance that mentions commit messages.
---

# Commit Message Skill

## Purpose

Write clear, traceable commit messages for this repository without assuming a
specific AI engine or runtime.

## Format

For work done for an issue, start the summary with the issue number:

```text
issue_<issue number>: <imperative summary>
```

Example:

```text
issue_123: Add metadata validation
```

For work that does not refer to an issue, start directly with the imperative
summary:

```text
Add metadata validation
```

## Rules

1. Keep the first line short, with 50 characters or less.
2. Use the imperative mood, such as `Add feature` instead of `Added feature`.
3. Leave a blank line after the summary when adding a body.
4. Use the body only when more detail is needed.
5. Describe why the change was made, not only what changed.

## Issue References

Use the `issue_<issue number>:` prefix only when the commit belongs to a known
issue. Do not invent an issue number.
