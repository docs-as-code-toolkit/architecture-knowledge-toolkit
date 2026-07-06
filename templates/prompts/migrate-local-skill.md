# Migrate Local Skill Prompt

```text
Adapt my local skill so it aligns with the corresponding generic skill from the
architecture-knowledge-toolkit.

Local skill:
<local skill path or name>

If you have a local skill for this task, use it. If not, search for the skill in
the local architecture-knowledge-toolkit. If no local
architecture-knowledge-toolkit is available, search for a suitable skill in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

Compare the local skill with the generic toolkit skill that addresses the same
problem. If the local skill describes things that the generic skill does not
describe, try to merge the two without losing project-specific intent. Preserve
local rules that deliberately narrow the generic workflow. If the local and
generic skill conflict, or both variants are plausible, ask which variant this
project should prefer before changing behavior.

Keep the result small and reviewable. Report what was aligned, what stayed
project-specific, what remains uncertain, and which checks were run.
```
