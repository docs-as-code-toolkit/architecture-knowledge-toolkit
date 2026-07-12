# Grilling Prompt

```text
Stress-test the following plan or design:

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

Interview me relentlessly but one question at a time. Walk the design tree,
resolve dependencies between decisions, and use repository evidence instead of
asking when the answer can be discovered locally. For each question, provide
your recommended answer.
```
