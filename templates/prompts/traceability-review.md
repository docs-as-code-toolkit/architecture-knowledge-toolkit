# Traceability Review Prompt

```text
Review architecture traceability for the following scope:

<documentation scope>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Inspect artifact metadata, relation metadata, AsciiDoc references, anchors, and
relevant source evidence. Identify missing, weak, stale, dangling, conflicting,
or unsupported relations. Validate relation endpoints, relation types,
ownership, status, rationale, and review state against the metamodel. Propose
small, reviewable relation updates without inventing unsupported traceability.
```
