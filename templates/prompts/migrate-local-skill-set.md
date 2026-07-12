# Migrate Local Skill Set Prompt

```text
Audit this repository's local skills and align them with the generic skills from
the architecture-knowledge-toolkit.

Use the toolkit migration guidance as the governing workflow. Treat local
skills as migration inputs and project-specific evidence, not as the
authoritative process for this migration. Locate toolkit guidance in this order:
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
