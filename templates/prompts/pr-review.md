# PR Review Prompt

```text
Review the following pull request:

<pull request number or URL>

If you have a local skill for this task, use it. If not, search for the skill in
the local architecture-knowledge-toolkit. If no local
architecture-knowledge-toolkit is available, search for a suitable skill in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

Inspect the PR title, body, linked issues, changed files, and enough surrounding
code or documentation to verify behavior. Prioritize correctness, regressions,
missing tests, documentation-contract violations, traceability gaps, unsafe
assumptions, and reviewability. Put actionable findings first with precise file
and line references. If there are no actionable findings, say so and report
remaining risks or test gaps.
```
