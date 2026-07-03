---
name: bootstrap-project
description: Bootstrap a new repository so its product clarification and architecture documentation follow the architecture-knowledge-toolkit structure instead of a generic arc42 document. Use when an agent is asked to create, initialize, migrate, or repair architecture documentation for a new project, especially when the user says the project should follow the architecture-knowledge-toolkit skills, contracts, docs-as-code conventions, arc42 structure, ADR/risk/quality scenario formats, traceability metadata, generator contracts, or generated include-fragment approach.
---

# Bootstrap Project

## Purpose

Create the initial project documentation structure expected by the
architecture-knowledge-toolkit. Do not stop at a single generic
`architecture.adoc` file or a Markdown ADR folder. The target shape is a
Docs-as-Code architecture knowledge base with product canvases, reusable
fragments, arc42 source files, explicit metadata, traceability, and reviewable
draft/proposed architecture artifacts.

Keep this skill focused on repository bootstrap responsibilities. Put
implementation-specific adapter behavior in adapter documentation, not in this
engine-independent skill.

## Bootstrap Contract

The bootstrap-project skill is responsible for:

- creating the initial documentation structure;
- creating required source artifacts;
- identifying missing documentation;
- identifying ADR candidates;
- identifying risks;
- identifying quality scenarios;
- identifying runtime scenarios;
- preparing generator input artifacts.

The bootstrap-project skill is not responsible for:

- implementing generators;
- maintaining generated files manually;
- vendor-specific AI integration.

## Generator Contract

Generator policy:

1. If the target repository already contains toolkit generators, use them.
2. If the target repository does not contain toolkit generators, bootstrap them
   from the architecture-knowledge-toolkit.
3. Never manually maintain generated include files when a generator exists.
4. Generated files are not primary editing surfaces.
5. Source artifacts are the authoritative source.
6. Generated artifacts must be reproducible from source artifacts.

Bootstrap generator support from the architecture-knowledge-toolkit when
required:

- copy generator scripts;
- copy templates;
- copy metamodel schemas;
- copy validation scripts;
- copy documentation build configuration.

If generators are unavailable:

- report missing generators;
- report affected generated artifacts;
- create source artifacts only;
- stop before inventing generated output.

## Toolkit Dependency

Treat the architecture-knowledge-toolkit as the authoritative source for:

- templates;
- generators;
- metamodel schemas;
- semantic contracts;
- validation rules;
- architecture documentation conventions.

When local project conventions conflict with toolkit conventions, apply this
order:

1. explicit user instructions;
2. project `AGENTS.md`;
3. relevant skill instructions;
4. toolkit semantic contracts.

Read `general-semantic-contracts.md` before creating or changing architecture
content when it is available from the toolkit or the target repository.

If the toolkit is not available on the local filesystem, use the remote
repository as the source of truth:

`https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit/tree/main`

Inspect the remote toolkit directory and copy the required contracts, skills,
templates, metamodel schemas, validation scripts, generator scripts, and example
patterns into the target repository before producing generated output.

## Example Prompt Workflow

Use the example prompts in `example/README.md` as the preferred starting point
for future project bootstraps:

- Greenfield prompt: use when the target repository has only a project idea and
  no architecture artifacts yet.
- Existing-artifacts prompt: use when the target repository already contains
  code, README files, diagrams, ADRs, or generic architecture documentation.

Both prompts expect the bootstrap to make validation immediately available in
the target repository. A complete bootstrap therefore includes, when required:

- `metamodel/artifact.schema.yaml`;
- `metamodel/relations.schema.yaml`;
- `scripts/validate-metamodel.rb`;
- `templates/adr.adoc`;
- `templates/quality-scenario.adoc`;
- `templates/risk.adoc`;
- documentation build or generator configuration available from the toolkit.

After source artifacts are created or migrated, validate the architecture source
set and regenerate derived fragments with the copied validator/generator.

## Core Workflow

1. Inspect the target repository before writing files.
2. Read the local project contract files if present: `AGENTS.md`,
   `general-semantic-contracts.md`, and relevant `skills/**/SKILL.md`.
3. Determine whether the task is greenfield or based on existing artifacts.
4. Identify whether documentation is absent, partial, or already present in a
   non-toolkit shape.
5. Create or migrate toward the toolkit structure in small, reviewable steps.
6. Mark AI-created or AI-modified architecture content as `draft` or
   `proposed`; set `reviewed: false` unless human acceptance is already
   recorded.
7. Preserve stable IDs and explicit anchors once assigned.
8. Record assumptions, unknowns, and human decisions in the Q&A document instead
   of inventing certainty.
9. Prepare source artifacts and generator inputs before generated outputs.
10. Prefer AsciiDoc source documents, PlantUML diagrams, and metadata relations.
11. Run toolkit generators, validators, or documentation builds when available.

## Target Structure

Use this structure as the default architecture documentation skeleton:

```text
src/docs/
|-- arc42.adoc
|-- vision-mission.adoc
|-- roadmap.adoc
|-- questions-and-answers.adoc
|-- canvas/
|   |-- business-model-canvas.adoc
|   |-- value-proposition-canvas.adoc
|   |-- architecture-inception-canvas.adoc
|   |-- architecture-communication-canvas.adoc
|   `-- techstack-canvas.adoc
|-- fragments/
|   |-- product/
|   `-- architecture/
`-- arc42/
    |-- 01-introduction-and-goals.adoc
    |-- 01-introduction-and-goals/
    |-- 02-architecture-constraints.adoc
    |-- 02-architecture-constraints/
    |-- 03-system-scope-and-context.adoc
    |-- 03-system-scope-and-context/
    |-- 04-solution-strategy.adoc
    |-- 04-solution-strategy/
    |-- 05-building-block-view.adoc
    |-- 05-building-block-view/
    |-- 06-runtime-view.adoc
    |-- 06-runtime-view/
    |-- 07-deployment-view.adoc
    |-- 07-deployment-view/
    |-- 08-crosscutting-concepts.adoc
    |-- 08-crosscutting-concepts/
    |-- 09-architecture-decisions.adoc
    |-- 09-architecture-decisions/
    |-- 10-quality-requirements.adoc
    |-- 10-quality-requirements/
    |-- 11-risks-and-technical-debt.adoc
    |-- 11-risks-and-technical-debt/
    |-- 12-glossary.adoc
    `-- 13-appendix.adoc
```

Chapter main pages keep stable YAML front matter, an explicit AsciiDoc anchor,
a concise summary, and generated include fragments where a toolkit generator is
available. Do not manually maintain long chapter detail include lists when the
generator exists.

## Bootstrap Steps

### 1. Clarify Product Inputs

Start with purpose before architecture. Create draft canvases in
`src/docs/canvas/` and use `src/docs/questions-and-answers.adoc` for open and
answered questions. Ask no more than three questions at a time. Keep questions
MECE and give every question a stable anchor.

Create these draft source files when missing:

- `src/docs/canvas/business-model-canvas.adoc`
- `src/docs/canvas/value-proposition-canvas.adoc`
- `src/docs/vision-mission.adoc`
- `src/docs/roadmap.adoc`
- `src/docs/canvas/architecture-inception-canvas.adoc`
- `src/docs/canvas/architecture-communication-canvas.adoc`
- `src/docs/canvas/techstack-canvas.adoc`
- `src/docs/questions-and-answers.adoc`

Include `src/docs/questions-and-answers.adoc` from
`src/docs/arc42/13-appendix.adoc` with `include::../questions-and-answers.adoc[leveloffset=+1]`.
The Q&A source remains the central discussion document and normally has no YAML
front matter; the appendix carries the standalone artifact metadata for the
assembled architecture documentation.

### 2. Create Reusable Source Fragments

Place repeated reviewed source content under `src/docs/fragments/`. Use
`include::[]` from standalone documents when the same business value,
definition, constraint, quality driver, scope statement, or system boundary
belongs in more than one place.

Do not put YAML front matter on directly included source fragments. Their
including standalone documents carry metadata.

### 3. Create arc42 As Toolkit Source Files

Create `src/docs/arc42.adoc` as the assembled architecture entry point and
`src/docs/arc42/` as the chapter source tree. Use the arc42 chapter order, but
make each chapter an addressable source artifact with:

- YAML front matter conforming to `metamodel/artifact.schema.yaml` when that
  schema exists in the repository.
- `type: Document` unless a more specific supported type applies.
- `status: draft` for AI-created chapter content.
- `reviewed: false` unless reviewed source evidence says otherwise.
- Stable `id`, `title`, `owner`, `summary`, `tags`, and outgoing `relations`.
- An explicit lowercase AsciiDoc anchor without numeric chapter prefixes, such
  as `[[architecture-decisions]]`, not `[[09-architecture-decisions]]`.
- Generator input metadata that is sufficient to regenerate chapter include
  fragments, indexes, and traceability views.

### 4. Use Toolkit Artifact Formats

Use the repository templates when present:

- `templates/adr.adoc` for ADRs in `src/docs/arc42/09-architecture-decisions/`.
- `templates/quality-scenario.adoc` for quality scenarios in
  `src/docs/arc42/10-quality-requirements/`.
- `templates/risk.adoc` for risks in
  `src/docs/arc42/11-risks-and-technical-debt/`.

When those templates are missing, still preserve the same semantics:

- ADRs use Nygard style, a 3-point Pugh matrix, assumptions, open questions,
  consequences, and proposed metadata relations.
- Quality scenarios use the six-part format: source, stimulus, artifact,
  environment, response, and response measure.
- Risks use cause, event, impact, qualitative likelihood, qualitative impact,
  priority, confidence, mitigation/action, and owner.

### 5. Preserve Traceability

Capture traceability in YAML `relations`, using stable artifact IDs and relation
types from `metamodel/relations.schema.yaml` when available. Add only outgoing
relations. Incoming relations are derived by generators.

Visible documentation links use explicit AsciiDoc `xref:` links to target
anchors. Do not derive links from raw numbered chapter file names.

### 6. Prepare Generator Inputs

Before generating output, ensure source artifacts contain enough structured
input for deterministic generation:

- stable artifact IDs;
- explicit AsciiDoc anchors;
- valid YAML metadata;
- outgoing relations;
- artifact type and status;
- review state;
- source paths and evidence where required.

If generator scripts, schemas, templates, validation scripts, or build
configuration are missing, copy them from the architecture-knowledge-toolkit
when the user requested a full bootstrap. If the toolkit source is unavailable,
report the missing dependency and stop before creating generated artifacts.

### 7. Add Required Architecture Concepts

Ensure the initial arc42 skeleton leaves room for the toolkit-required content:

- Chapter 1.2 has only the 3-5 quality objectives that drive decisions.
- Chapter 3 context and Chapter 5 level-1 building blocks describe the same
  system boundary from different views.
- Chapters 3, 5, and 6 contain at least one PlantUML diagram when they receive
  real content.
- Building block diagrams use C4-PlantUML via `!include <C4/...>`.
- Chapter 6 includes at least one failure or recovery scenario.
- Chapter 8 starts with threat model, security, testing, observability, and
  error handling, in that order.
- Chapter 9 contains the ADR index where ADRs belong.
- Chapter 10 contains a quality tree and measurable quality scenarios.
- Chapter 11 separates risks from technical debt.

## Migration Rules

If the target repository already contains a generic architecture document, such
as `src/docs/architecture.adoc`, or Markdown ADRs under `src/docs/adr/`, do not
delete or overwrite them without instruction. Instead:

1. Treat the existing files as source evidence.
2. Propose a migration path to the toolkit structure.
3. Create new AsciiDoc toolkit files as draft/proposed artifacts.
4. Preserve existing claims only when supported by repository evidence.
5. Convert accepted-looking AI output to `proposed` unless human acceptance is
   recorded.
6. Link migrated artifacts by stable IDs and explicit anchors.

The failure mode to avoid is: "the repo follows arc42" but lacks the toolkit's
source layout, metadata, traceability, generated-fragment discipline, and
artifact templates.

## Validation Checklist

- No single monolithic `src/docs/architecture.adoc` is the only architecture
  source.
- Product canvases, Q&A, vision/mission, and roadmap exist or are explicitly
  listed as open bootstrap tasks.
- arc42 chapter pages and detail pages use AsciiDoc, stable anchors, and YAML
  metadata where applicable.
- ADRs, quality scenarios, and risks live under the corresponding arc42 chapter
  directories, not in a separate Markdown-only structure.
- `src/docs/arc42/13-appendix.adoc` includes
  `src/docs/questions-and-answers.adoc`.
- AI-created content is `draft` or `proposed` and `reviewed: false`.
- Visible links use explicit `xref:` anchors.
- Metadata relations use stable IDs and only outgoing relations.
- Generated fragments are not treated as primary editing surfaces.
- PlantUML is used for diagrams; C4-PlantUML is used for building block views.
- A validator or docs build was run when available, or the absence of validation
  is reported.
