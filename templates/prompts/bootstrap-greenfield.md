# Bootstrap Greenfield Prompt

```text
Use the architecture-knowledge-toolkit to bootstrap architecture documentation
for a new project.

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Project idea:
<project idea>

Create the initial architecture documentation in the toolkit structure:
- create or update project AI contracts such as AGENTS.md,
  .github/copilot-instructions.md, and general-semantic-contracts.md so that
  future architecture and SDLC work delegates missing method guidance to the
  architecture-knowledge-toolkit;
- product canvases, vision/mission, roadmap, and Q&A;
- an assembled architecture entry point and all arc42 chapter source files;
- proposed ADRs with Pugh matrices where decisions are already visible;
- quality goals and measurable quality scenarios;
- initial risks and runtime scenarios;
- metadata and outgoing relations according to the toolkit metamodel.

Keep all AI-created content draft or proposed with reviewed: false. Do not
invent generated output manually. Run the validation script with --generate when
the source artifacts are ready, and report assumptions, open questions, and
required human decisions.
```
