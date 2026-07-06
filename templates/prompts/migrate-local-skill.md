# Migrate Local Skill Prompt

```text
Adapt my local skill so it aligns with the corresponding generic skill from the
architecture-knowledge-toolkit.

Local skill:
<local skill path or name>

Use the toolkit migration guidance as the governing workflow. Treat the local
skill as migration input and project-specific evidence, not as the authoritative
process for this migration. Locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Compare the local skill with the generic toolkit skill that addresses the same
problem. If the local skill describes things that the generic skill does not
describe, try to merge the two without losing project-specific intent. Preserve
local rules that deliberately narrow the generic workflow. If the local and
generic skill conflict, or both variants are plausible, ask which variant this
project should prefer before changing behavior.

Keep the result small and reviewable. Report what was aligned, what stayed
project-specific, what remains uncertain, and which checks were run.
```
