# Migrate Local Skill Set Prompt

```text
Audit this repository's local skills and align them with the generic skills from
the architecture-knowledge-toolkit.

If you have a local skill for this task, use it. If not, search for the skill in
the local architecture-knowledge-toolkit. If no local
architecture-knowledge-toolkit is available, search for a suitable skill in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

For each local skill:
- identify the closest generic toolkit skill or contract;
- compare purpose, trigger conditions, workflow, safety rules, metadata rules,
  traceability expectations, and validation steps;
- keep project-specific instructions only when they narrow or extend the
  generic skill for this project;
- avoid copying the entire generic skill when a reference is enough;
- merge compatible guidance into the local skill;
- if the local and generic skill conflict or encode different valid variants,
  ask which variant the project should prefer before changing behavior.

Produce a short migration report listing changed skills, intentionally retained
project-specific rules, conflicts that need human decision, and validation
performed.
```
