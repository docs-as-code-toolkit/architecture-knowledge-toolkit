# Private Budget Example

This example shows how to bootstrap architecture documentation for a small
private budget application with a backend, web UI, and mobile app. It is an
artificial project, but the documentation follows the
architecture-knowledge-toolkit conventions: arc42 source documents, AsciiDoc,
YAML metadata, explicit anchors, ADRs, quality scenarios, risks, templates,
metamodel schemas, validation, and reproducible generated fragments.

## What Is Included

- `src/docs/doc-001-private-budget-arc42.adoc` as the assembled architecture entry point.
- `src/docs/arc42/` with all arc42 chapters represented as source artifacts.
- Three ADRs in `src/docs/arc42/09-architecture-decisions/`.
- Three quality scenarios in `src/docs/arc42/10-quality-requirements/`.
- Initial risks and technical debt in `src/docs/arc42/11-risks-and-technical-debt/`.
- Product clarification artifacts under `src/docs/canvas/`,
  `src/docs/doc-002-vision-mission.adoc`, `src/docs/doc-004-roadmap.adoc`, and
  `src/docs/doc-005-questions-and-answers.adoc`.
- `AGENTS.md` as the example project's local agent contract, delegating missing
  architecture and SDLC guidance to the toolkit.
- `.github/copilot-instructions.md` as a thin GitHub Copilot entry point.
- Thin, generated agent adapters under `adapters/` (Codex, Vibe, GitHub Copilot,
  Cursor) that route agents to the toolkit.
- Copied toolkit templates under `templates/`.
- Copied metamodel schemas under `metamodel/`.
- Copied validation/generator script and the agent adapter generator under
  `scripts/`.

Generated files live below `generated/` directories and are not primary editing
surfaces. The `adapters/` files are likewise generated. Edit source artifacts or
the generators and regenerate.

## Reference, Don't Copy

This example follows **reference, don't copy**. It does not copy the toolkit's
`skills/**/SKILL.md`, `features/`, or contract text; it references them through
the lookup order in `AGENTS.md`. Only executable tooling that must run here —
metamodel schemas, templates, and validator/generator scripts — is copied and
kept in sync with the toolkit. The example has no local skills of its own; a
real project adds local skills only to *extend* the toolkit or to *explicitly
override* a specific rule.

## Agent Adapters

The per-agent files under `adapters/` are generated from
`scripts/build-agent-adapters.js`:

```sh
node scripts/build-agent-adapters.js       # regenerate the adapters
node scripts/check-agent-adapters.js       # fail if they are stale
```

Because this example has no local skills, the adapters route agents to the
toolkit. A project with local skills generates the same adapters from its
`skills/**/SKILL.md`. Keep `.github/copilot-instructions.md` as an entry point
that points to `adapters/github-copilot/copilot-instructions.md`.

## Validate And Generate

From this example directory, run:

```sh
ruby scripts/validate-metamodel.rb \
  --docs src/docs \
  --relations-schema metamodel/relations.schema.yaml \
  --generate
```

The command validates source metadata and relations, then regenerates
traceability fragments, ADR index, quality scenario index, risk index, open
question index, and the traceability matrix.

## Prompt 1: Greenfield Project

The reusable version of this prompt lives in
`../templates/prompts/bootstrap-greenfield.md`.

Use this prompt when only the project idea exists and the target repository does
not yet contain architecture documentation:

```text
Use the architecture-knowledge-toolkit to bootstrap architecture documentation
for a new project.

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

Project idea:
Create a private budget application with a backend, web UI, and mobile app.
Users can record income and expenses, assign categories, define monthly budgets,
see remaining budget per category, and review simple spending trends.

Create the initial architecture documentation in the toolkit structure:
- create or update project AI contracts such as AGENTS.md,
  .github/copilot-instructions.md, and general-semantic-contracts.md so that
  future architecture and SDLC work delegates missing method guidance to the
  architecture-knowledge-toolkit;
- reference the toolkit's skills, features, and contract text through the lookup
  order above instead of copying them; copy only executable tooling that must
  run here (metamodel schemas, templates, validators, generators, and the agent
  adapter generator scripts/build-agent-adapters.js and
  scripts/check-agent-adapters.js);
- generate thin agent adapters under adapters/ that route agents to the toolkit
  and general-semantic-contracts.md, and keep .github/copilot-instructions.md as
  an entry point to adapters/github-copilot/copilot-instructions.md;
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

## Prompt 2: Existing Project Artifacts

The reusable version of this prompt lives in
`../templates/prompts/bootstrap-existing-artifacts.md`.

Use this prompt when a repository already contains code, README files,
diagrams, ADRs, or a generic architecture document:

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
  run here (metamodel schemas, templates, validators, generators, and the agent
  adapter generator scripts/build-agent-adapters.js and
  scripts/check-agent-adapters.js);
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
