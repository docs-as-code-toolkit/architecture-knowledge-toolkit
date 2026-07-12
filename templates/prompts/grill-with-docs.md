# Grill With Docs Prompt

```text
Run a grilling session on this plan or design and update the relevant domain or
architecture documentation as decisions become clear:

<plan or design>

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

Ask one focused question at a time. Use repository evidence where available.
When terminology, domain boundaries, or decisions become clear, update the
glossary, ADRs, or related architecture artifacts according to the local
documentation contracts. Mark AI-created or AI-modified architecture content as
draft or proposed unless human acceptance is recorded.
```
