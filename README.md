# architecture-knowledge-toolkit

Reusable architecture knowledge assets for software architecture work, aimed
first at individual architects setting up structured Docs-as-Code projects.
The toolkit is free and open source; the current product model is explicitly
non-commercial.

This repository combines Docs-as-Code, architecture documentation,
engine-agnostic semantic contracts, metadata-based traceability, reusable AI
skills, and deterministic generators. The contracts are useful to humans,
automation, and AI assistants alike: they make the way of working explicit
without making AI a required dependency.

AI may suggest architecture artifacts and relationships, but the repository owns
the truth. Reviewed metadata and source documents are the authoritative record.

## Principles

- Docs-as-Code first: architecture knowledge lives in version-controlled text.
- General project rules live in engine-agnostic semantic contracts.
- `AGENTS.md` and `SKILL.md` files adapt or narrow those contracts for AI
  workflows; they should not become the primary source of general project
  rules.
- AsciiDoc is the default format for architecture documentation and templates.
- Write once, publish everywhere: documentation content should be authored once
  and reused across target formats and document contexts.
- Reusable source fragments are first-class documentation assets when the same
  content belongs in more than one place.
- Every architecture artifact has a stable, explicit ID.
- Traceability is metadata-driven, not inferred from prose alone.
- AI-generated output is a suggestion until reviewed and committed.
- Generators must be deterministic, idempotent, and reproducible.
- Generated documentation is a derived artifact and is not committed as source
  content.
- Skills are engine-independent where possible.
- Engine-specific integration belongs under `adapters/`.

## Repository Layout

```text
src/docs/      New-project inception docs, canvases, vision, roadmap, and arc42.
metamodel/     Schemas for architecture artifacts and relations.
skills/        Reusable AI skill instructions and review workflows.
templates/     AsciiDoc templates for common architecture artifacts.
adapters/      Engine-specific integration layers.
```

## Contract Layers

The repository separates general project contracts from AI-specific adapters:

1. `general-semantic-contracts.md` is the engine-agnostic contract for project
   work.
2. `AGENTS.md` tells automated contributors how to apply that contract.
3. `skills/**/SKILL.md` adds task-specific rules, for example for ADRs, risks,
   quality scenarios, or traceability review.

Use the general contract as the maintained source for rules that also help
humans and deterministic tools. Put only runtime-specific AI details below
`adapters/`.

## Relationship Strategy

**Authoritative Outgoing Relations Only.**

To reduce duplication and maintenance overhead, this repository follows a strict
relationship directionality convention:

- **Source artifacts** contain only **outgoing** relations (what this artifact
  affects, introduces, addresses, etc.)
- **Incoming relations** are **derived automatically** during generation from the
  authoritative outgoing relations
- **Never** manually add reciprocal relations (e.g., if ADR-001 `introduces_risk`
  R-001, do NOT add R-001 `depends_on` ADR-001)

This strategy ensures:
- Single source of truth for each relationship
- Consistent traceability views
- Lower maintenance effort
- Reduced inconsistency risk

Generators automatically compute and display incoming relations in traceability
matrices and fragment views based on the outgoing relations stored in source
artifacts. All three generators (`TraceabilityMatrixGenerator`, `ArtifactIndexGenerator`,
`TraceabilityFragmentGenerator`) implement this derivation consistently.

## New Project Inception

Start new-project clarification in `src/docs/`.

- `src/docs/canvas/business-model-canvas.adoc`
- `src/docs/canvas/value-proposition-canvas.adoc`
- `src/docs/vision-mission.adoc`
- `src/docs/roadmap.adoc`
- `src/docs/questions-and-answers.adoc`

The current inception files are drafts. They use this repository as a hint, not
as proof. Review assumptions and answer the open questions before treating any
canvas, roadmap item, or product statement as accepted project truth.

The smallest useful adoption slice is the initial setup workflow: inception
canvases, vision and mission, roadmap, and open questions for an arc42
Docs-as-Code project. Artifact creation, validation, generation, and SDLC
automation are later slices.
The primary success evidence for this first slice is the completeness of the
initial artifact set; faster drafting and reduced review effort are secondary
outcomes.

See [`example/`](example/) for a complete artificial bootstrap example of a
private budget application with backend, web UI, and mobile app. The example
includes copied toolkit templates, metamodel schemas, the validation/generation
script, three ADRs, quality goals, quality scenarios, risks, generated
traceability fragments, and two reusable prompts:

- a greenfield prompt for projects that only have an idea;
- an existing-artifacts prompt for adapting code, README files, diagrams, ADRs,
  or generic architecture documentation to the toolkit structure.

## Intended Workflow

1. Create or update an architecture artifact using an AsciiDoc template.
2. Add explicit metadata with a stable ID, lifecycle state, ownership, and tags.
3. Add traceability relations using the relation metamodel.
4. Optionally use an AI skill to suggest content, risks, scenarios, or links.
5. Review the suggestion as normal architecture work.
6. Commit reviewed source documents and metadata.
7. Run deterministic generators to produce derived documentation.

Reusable source fragments should be authored once and included where they are
needed with AsciiDoc `include::[]`. Examples include business value statements,
shared definitions, constraints, and other text that legitimately appears in
multiple document contexts. Fragment design must keep all target formats clean:
includes should not depend on local heading levels, generated file paths,
environment-specific attributes, or formatter-specific behavior unless those
choices are modeled as explicit inputs.

Generated output should be reproducible from committed inputs. Contributors can
create it locally, and CI/CD can publish it, but it should not be committed to
the repository as source content. If generated output differs without an input
change, that is a defect in the generator or environment.

## AI Skills

Use the skill contracts under `skills/` for focused architecture workflows:

- [`skills/bootstrap-project`](/skills/bootstrap-project/SKILL.md) for bootstrapping new project architecture documentation in the toolkit structure.
- [`skills/adr`](/skills/adr/SKILL.md) for Architecture Decision Records and impact analysis.
- [`skills/quality-scenario`](/skills/quality-scenario/SKILL.md) for measurable quality scenarios.
- [`skills/risk`](/skills/risk/SKILL.md) for architecture risks and mitigations.
- [`skills/traceability-review`](/skills/traceability-review/SKILL.md) for metadata relation reviews.
- [`skills/domain-modeling`](/skills/domain-modeling/SKILL.md) Actively build and sharpen a project's domain model — challenge terms against the glossary, stress-test with edge-case scenarios, and update CONTEXT.md and ADRs inline.
- [`skills/grilling/with-docs`](/skills/grilling/with-docs/SKILL.md) Grilling session that also builds your project's domain model, sharpening terminology and updating CONTEXT.md and ADRs inline
- [`skills/grilling/me`](/skills/grilling/me/SKILL.md) Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- [`skills/grilling/`](/skills/grilling/SKILL.md) Interview the user relentlessly about a plan or design until every branch of the decision tree is resolved. The reusable loop behind grill-me and grill-with-docs.

Shared writing guides live under `skills/references/`. AI-assisted artifacts,
decisions, assessments, and relationships remain proposed until reviewed.

## Current Status

This is the initial repository skeleton. It intentionally does not include a full
generator implementation yet. The first milestone is to stabilize the metamodel,
templates, dogfood arc42 documentation, and engine-independent skill contracts.
Version 1 focuses first on ADRs, quality scenarios, and risks, with
stakeholders, requirements, and components following next. The initial generated
navigation scope is artifact-type indexes; additional indexes by status, owner,
and tag remain a later evaluation topic.

The former `examples/sample-project` has been removed. The project now uses its
own arc42 documentation under `src/docs/arc42.adoc` and `src/docs/arc42/` as the
living example. The dogfood docs now include standalone proposed ADR, quality
scenario, and risk artifacts so the ADR-to-quality-to-risk traceability chain is
visible in the repository itself.

## Validation

The first deterministic validation step is available as a small Ruby CLI. It
scans architecture artifacts with YAML front matter and validates the metadata
and explicit relationships. Ruby is the current implementation language for the
validator and generator, but not a fixed long-term commitment for the toolkit.
Future runtime choices should also remain compatible with the wider
`docs-as-code-toolkit/docs-toolbox` delivery environment.

Run the default validation against this project's own arc42 documentation:

```sh
ruby scripts/validate-metamodel.rb
```

Validation and generation are intended to work both locally and in CI. GitHub
Actions and GitLab CI are the primary reproducible CI environments to support.

By default, the validator scans:

```text
src/docs/arc42.adoc
src/docs/arc42/
```

You can validate another artifact file or directory with:

```sh
ruby scripts/validate-metamodel.rb --docs path/to/docs
```

The validator checks that:

- every `.adoc` file has YAML front matter between `---` markers;
- required metadata fields exist: `id`, `type`, `title`, `status`, `created`;
- artifact IDs are unique;
- relation keys are known according to `metamodel/relations.schema.yaml`;
- relation types are supported by the metamodel;
- relation targets reference existing artifact IDs in the scanned document set.

It prints a validation report and exits with a non-zero status if validation
fails. It does not generate documentation and does not call any AI service.

Run the validator tests with:

```sh
ruby -Itest test/validate_metamodel_test.rb
```

## Derived Documentation Generation

The documentation generator creates deterministic AsciiDoc fragments from
validated architecture artifact metadata. These fragments are includeable
derived output, not reviewed source content.

Generate the project arc42 derived documentation with:

```sh
ruby scripts/validate-metamodel.rb --generate
```

The command validates the artifact metadata first. If validation fails, no
derived files are generated and the command exits with a non-zero status.

By default, generated files are written below `generated/` directories:

```text
src/docs/arc42/generated/traceability-matrix.adoc
src/docs/arc42/**/generated/*-includes.adoc
src/docs/arc42/09-architecture-decisions/generated/open-questions.adoc
src/docs/arc42/09-architecture-decisions/generated/adr-index.adoc
src/docs/arc42/09-architecture-decisions/generated/*-traceability.adoc
src/docs/arc42/10-quality-requirements/generated/quality-scenarios.adoc
src/docs/arc42/10-quality-requirements/generated/*-traceability.adoc
src/docs/arc42/11-risks-and-technical-debt/generated/risks.adoc
src/docs/arc42/11-risks-and-technical-debt/generated/*-traceability.adoc
```

The generator also creates chapter include fragments. Chapter main files should
include these generated fragments instead of manually listing each detail
document. Generated chapter include fragments are sorted by artifact ID so new
artifacts appear deterministically after regeneration.

The chapter-level index fragments keep the existing table shape where possible.
Row content is derived from each artifact's metadata and structured source body:
IDs, titles, lifecycle status, summaries, and relations come from YAML front
matter; quality scenario and risk assessment fields come from their existing
definition tables.

Generated index fragments are included directly in their chapter context. Source
wrapper documents whose only purpose is to include generated indexes should not
be introduced; existing wrappers are migration targets.

Traceability sections are generated per artifact from metadata relations instead
of being maintained manually in each source file. Source artifacts include their
local generated fragment, for example
`include::generated/adr-001-asciidoc-primary-source-traceability.adoc[]`.
Render or publish these files only in flows where the generator has run first.
Source files may still contain temporary manual traceability sections while a
project migrates, but metadata is the source of truth.

You can choose another traceability matrix output path with:

```sh
ruby scripts/validate-metamodel.rb --generate --output path/to/traceability-matrix.adoc
```

The generator is deterministic and idempotent: running it multiple times with the
same inputs produces identical output. Generated files under a `generated/`
directory are ignored by the artifact scanner so derived documentation is not
treated as source architecture knowledge. Generated documentation should also be
publishable through an automated CI/CD pipeline to a location accessible to the
team and stakeholders. Based on reviewed workshop input, GitHub Pages is the
first supported automated publishing target for version 1. The first supported
GitHub Pages delivery path should be plain Asciidoctor-generated static HTML;
other static-site flows remain later extension points. Version 1 should provide
one maintained default CSS theme for generated documentation; additional
selectable themes remain a future option. Reviewed workshop input also confirms
that generator regression coverage should use golden files across all supported
generated artifact views, including per-artifact relationship views and
artifact-type indexes.
