# Domain Modeling Prompt

```text
Sharpen the domain model for the following product or architecture discussion:

<domain discussion>

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

Inspect existing glossary, ADRs, architecture documentation, and source code
where available. Challenge ambiguous terms, identify overloaded language,
propose precise domain terms, test them with concrete scenarios, and update the
glossary or ADRs only when the model is clear enough. Ask focused questions
when terms or boundaries remain uncertain.
```
