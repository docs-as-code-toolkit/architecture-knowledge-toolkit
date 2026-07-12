# Risk Prompt

```text
Identify, create, or update architecture risks for the following concern:

<risk concern>

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

Inspect existing risks, ADRs, quality scenarios, requirements, components,
controls, source code, deployment files, incidents, and operational evidence.
Avoid duplicating existing risks. Write each risk as cause, event, and impact;
assess likelihood, impact, priority, timeframe, and confidence; propose
mitigation or monitoring; and add traceability metadata where justified.
```
