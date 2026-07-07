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

If this is feature work, refactoring work, or an architecture-significant
change, use the local architecture-impact skill before and during
implementation. Read the current architecture documentation and relevant
implementation, name affected ADRs, quality goals, risks, components, runtime
scenarios, and deployment views, and update or explicitly report the required
architecture documentation changes. Classify feature work as Epic or UserStory,
assign UserStories to matching Epics when available, and mark backlog issues
with repository metadata when available; otherwise prefix issue titles with
[EPIC], [UserStory], or [REFACTORING].
```
