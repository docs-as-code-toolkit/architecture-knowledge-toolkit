# Bootstrap Existing Artifacts Prompt

```text
Use the architecture-knowledge-toolkit to adapt this repository's existing
project artifacts into the toolkit architecture documentation structure.

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

First inspect the existing repository artifacts, including README files,
existing architecture documents, ADRs, source code, build/deployment files,
tests, and diagrams. Treat them as evidence, not as automatically accepted
architecture truth.

Migrate or adapt the documentation to the toolkit structure:
- create or update project AI contracts such as AGENTS.md,
  .github/copilot-instructions.md, and general-semantic-contracts.md so that
  future architecture and SDLC work delegates missing method guidance to the
  architecture-knowledge-toolkit;
- reference the toolkit's skills, features, and contract text through the lookup
  order above instead of copying them; copy only executable tooling that must
  run here (metamodel schemas, templates, validators, generators, and the generic
  agent adapter generator from templates/scripts/build-agent-adapters.js and
  templates/scripts/check-agent-adapters.js -- not the toolkit's own
  generator, which is wired to the toolkit);
- generate thin agent adapters under adapters/ that route agents to the toolkit
  and general-semantic-contracts.md, keep .github/copilot-instructions.md as an
  entry point to adapters/github-copilot/copilot-instructions.md, and migrate any
  existing hand-written per-agent files into generated adapters;
- if the repository already has local skills or contracts, keep only the parts
  that extend the toolkit or explicitly override a specific rule, and drop
  silent duplicates of toolkit rules;
- preserve existing useful claims only when supported by repository evidence;
- convert generic architecture.adoc or Markdown ADRs into toolkit AsciiDoc
  source artifacts where appropriate;
- create or update product canvases, vision/mission, roadmap, and Q&A;
- create the assembled architecture entry point and all arc42 chapter source
  files;
- identify missing ADR candidates, risks, quality scenarios, and runtime
  scenarios;
- add metadata and outgoing relations according to the toolkit metamodel.

Keep AI-created or AI-modified content draft or proposed with reviewed: false.
Do not manually maintain generated include files. Run the validation script with
--generate when the source artifacts are ready, and report remaining migration
gaps, assumptions, and human decisions.
```
