# PR Review Prompt

```text
Review the following pull request:

<pull request number or URL>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Inspect the PR title, body, linked issues, changed files, and enough surrounding
code or documentation to verify behavior. Prioritize correctness, regressions,
missing tests, documentation-contract violations, traceability gaps, unsafe
assumptions, and reviewability. Put actionable findings first with precise file
and line references. If there are no actionable findings, say so and report
remaining risks or test gaps.

For feature work, refactoring work, or architecture-significant review tasks,
use the local architecture-impact skill. Verify that current architecture
documentation, implementation, ADRs, quality goals, risks, affected feature or
refactoring references, Epic links, and refactoring issue markings stay aligned.
```
