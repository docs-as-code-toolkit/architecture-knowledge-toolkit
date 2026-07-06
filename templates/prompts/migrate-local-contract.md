# Migrate Local Contract Prompt

```text
Adapt my local project contract so it aligns with the corresponding generic
contract from the architecture-knowledge-toolkit.

Local contract:
<local contract path or name>

If you have local project contracts for this task, use them first. If not,
search for the relevant contract in the local architecture-knowledge-toolkit. If
no local architecture-knowledge-toolkit is available, search for a suitable
contract in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

Compare the local contract with the generic toolkit contract that addresses the
same problem. If the local contract describes things that the generic contract
does not describe, try to merge them without losing project-specific intent.
Preserve local rules that deliberately narrow the generic workflow. If the
local and generic contracts conflict, or both variants are plausible, ask which
variant this project should prefer before changing behavior.

Keep the result small and reviewable. Report what was aligned, what stayed
project-specific, what remains uncertain, and which checks were run.
```
