# Implement Issue Workflow Prompt

```text
Implement the following GitHub issue in a focused, reviewable pull request:

<issue number or URL>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Start from the latest base branch, create the appropriate issue branch, read the
issue body and acceptance criteria, implement the smallest focused change, run
the relevant checks, commit using the local commit-message convention, push the
branch, and open a pull request. Preserve unrelated local changes and do not
stage files outside the issue scope.
```
