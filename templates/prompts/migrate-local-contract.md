# Migrate Local Contract Prompt

```text
Adapt my local project contract so it aligns with the corresponding generic
contract from the architecture-knowledge-toolkit.

Local contract:
<local contract path or name>

Use the toolkit migration guidance as the governing workflow. Treat the local
contract as migration input and project-specific evidence, not as the
authoritative process for this migration. Locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Compare the local contract with the generic toolkit contract that addresses the
same problem. If the local contract describes things that the generic contract
does not describe, try to merge them without losing project-specific intent.
Preserve local rules that deliberately narrow the generic workflow. If the
local and generic contracts conflict, or both variants are plausible, ask which
variant this project should prefer before changing behavior.

Keep the result small and reviewable. Report what was aligned, what stayed
project-specific, what remains uncertain, and which checks were run.
```
