# ADR Prompt

```text
Create or update an Architecture Decision Record for the following decision
problem:

<decision problem>

Analyze the relevant source code, architecture documentation, existing ADRs,
risks, quality scenarios, requirements, constraints, and affected components.
Compare realistic options, include a Pugh matrix, document consequences, and
propose impact and traceability metadata relations. Add `derived_from` metadata when the
ADR originates from a specific input question, prompt, repository document,
external source, or existing artifact; link to an anchor, URL, path, or artifact
ID when available. If provenance should appear in the ADR body, include the
generated metadata attribute fragment and render it with
`ifdef::derived_from_description[]`. Include generated Impact and Traceability
fragments instead of hand-authoring those matrices. Mark AI-created or
AI-modified content as proposed unless human acceptance is already recorded.

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.
```
