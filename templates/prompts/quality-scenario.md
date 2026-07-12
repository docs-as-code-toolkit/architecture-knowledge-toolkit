# Quality Scenario Prompt

```text
Create or update measurable quality scenarios for the following quality concern:

<quality concern>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise search upward from the project directory for a local
   architecture-knowledge-toolkit checkout: check ../architecture-knowledge-toolkit,
   then the same directory name in each parent directory up to the filesystem
   root.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Inspect existing quality objectives, quality scenarios, ADRs, risks,
requirements, architecture artifacts, source code, tests, deployment files, and
operational evidence where available. Draft proposed scenarios only when the
concern is not already covered. Use the six-part quality attribute scenario
format and include a measurable response measure. Mark uncertain targets as
assumptions.
```
