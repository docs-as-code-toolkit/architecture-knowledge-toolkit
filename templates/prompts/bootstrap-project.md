# Bootstrap Project Prompt

```text
Bootstrap this repository so product clarification and architecture
documentation follow the architecture-knowledge-toolkit structure rather than a
generic architecture document.

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Inspect the repository first. Create or repair the initial Docs-as-Code
architecture knowledge base with product canvases, reusable fragments, arc42
source files, explicit metadata, traceability, templates, schemas, validators,
and generator support where needed. Create or update project AI contracts such
as AGENTS.md, .github/copilot-instructions.md, and
general-semantic-contracts.md so that future architecture and SDLC work
delegates missing method guidance to the architecture-knowledge-toolkit.

Preserve local project instructions, mark AI-created content as draft or
proposed, do not invent generated output manually, and report assumptions,
unknowns, and required human decisions.
```
