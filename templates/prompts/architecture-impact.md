# Architecture Impact Prompt

```text
Assess and update the architecture impact for the following feature request,
Epic, refactoring task, implementation issue, pull request, or review task:

<feature, issue, pull request, or review task>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Read the current architecture documentation and relevant implementation before
acting. Explicitly name affected ADRs, quality goals, quality scenarios, risks,
components, runtime scenarios, deployment views, and constraints. If conflicts
exist, propose a new or changed ADR. Record the feature or refactoring at every
affected place in the architecture documentation. Add PlantUML diagrams and
short descriptions for new components, runtime scenarios, or deployment changes.
Use tagged AsciiDoc includes instead of copying diagrams or descriptions that
also appear in the official architecture documentation. Ensure the feature has a
remote Epic issue; if the repository has no Epic issue type, prefix the Epic
description with [EPIC]. Ensure each refactoring task is marked with repository
metadata when available; otherwise prefix the issue title with [REFACTORING].
```
