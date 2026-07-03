# Private Budget Example

This example shows how to bootstrap architecture documentation for a small
private budget application with a backend, web UI, and mobile app. It is an
artificial project, but the documentation follows the
architecture-knowledge-toolkit conventions: arc42 source documents, AsciiDoc,
YAML metadata, explicit anchors, ADRs, quality scenarios, risks, templates,
metamodel schemas, validation, and reproducible generated fragments.

## What Is Included

- `src/docs/arc42.adoc` as the assembled architecture entry point.
- `src/docs/arc42/` with all arc42 chapters represented as source artifacts.
- Three ADRs in `src/docs/arc42/09-architecture-decisions/`.
- Three quality scenarios in `src/docs/arc42/10-quality-requirements/`.
- Initial risks and technical debt in `src/docs/arc42/11-risks-and-technical-debt/`.
- Product clarification artifacts under `src/docs/canvas/`,
  `src/docs/vision-mission.adoc`, `src/docs/roadmap.adoc`, and
  `src/docs/questions-and-answers.adoc`.
- Copied toolkit templates under `templates/`.
- Copied metamodel schemas under `metamodel/`.
- Copied validation and generator script under `scripts/`.

Generated files live below `generated/` directories and are not primary editing
surfaces. Edit source artifacts and regenerate.

## Validate And Generate

From this example directory, run:

```sh
ruby scripts/validate-metamodel.rb \
  --docs src/docs/arc42.adoc \
  --docs src/docs/arc42 \
  --relations-schema metamodel/relations.schema.yaml \
  --generate
```

The command validates source metadata and relations, then regenerates
traceability fragments, ADR index, quality scenario index, risk index, open
question index, and the traceability matrix.

## Prompt 1: Greenfield Project

Use this prompt when only the project idea exists and the target repository does
not yet contain architecture documentation:

```text
Use the architecture-knowledge-toolkit to bootstrap architecture documentation
for a new project.

Toolkit source:
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit/tree/main

Use the bootstrap-project skill from the toolkit. If the toolkit is not
available locally, inspect the remote GitHub directory and copy the required
templates, metamodel schemas, validation script, and generator support into this
repository.

Project idea:
Create a private budget application with a backend, web UI, and mobile app.
Users can record income and expenses, assign categories, define monthly budgets,
see remaining budget per category, and review simple spending trends.

Create the initial architecture documentation in the toolkit structure:
- product canvases, vision/mission, roadmap, and Q&A;
- src/docs/arc42.adoc and all arc42 chapter source files;
- at least three proposed ADRs with Pugh matrices;
- quality goals and measurable quality scenarios;
- initial risks and runtime scenarios;
- metadata and outgoing relations according to the toolkit metamodel.

Keep all AI-created content draft or proposed with reviewed: false. Do not
invent generated output manually. Run the validation script with --generate when
the source artifacts are ready, and report any assumptions or open questions.
```

## Prompt 2: Existing Project Artifacts

Use this prompt when a repository already contains code, README files,
diagrams, ADRs, or a generic architecture document:

```text
Use the architecture-knowledge-toolkit to adapt this repository's existing
project artifacts into the toolkit architecture documentation structure.

Toolkit source:
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit/tree/main

Use the bootstrap-project skill from the toolkit. If the toolkit is not
available locally, inspect the remote GitHub directory and copy the required
templates, metamodel schemas, validation script, and generator support into this
repository.

First inspect the existing repository artifacts, including README files,
existing architecture documents, ADRs, source code, build/deployment files,
tests, and diagrams. Treat them as evidence, not as automatically accepted
architecture truth.

Migrate or adapt the documentation to the toolkit structure:
- preserve existing useful claims only when supported by repository evidence;
- convert generic architecture.adoc or Markdown ADRs into toolkit AsciiDoc
  source artifacts where appropriate;
- create or update product canvases, vision/mission, roadmap, and Q&A;
- create src/docs/arc42.adoc and all arc42 chapter source files;
- identify missing ADR candidates, risks, quality scenarios, and runtime
  scenarios;
- add metadata and outgoing relations according to the toolkit metamodel.

Keep AI-created or AI-modified content draft or proposed with reviewed: false.
Do not manually maintain generated include files. Run the validation script with
--generate when the source artifacts are ready, and report remaining migration
gaps, assumptions, and human decisions.
```
