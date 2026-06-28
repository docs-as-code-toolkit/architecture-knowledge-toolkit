# architecture-knowledge-toolkit

Reusable architecture knowledge assets for software architecture work, aimed
first at individual architects setting up structured Docs-as-Code projects.
The toolkit is free and open source; the current product model is explicitly
non-commercial.

This repository combines Docs-as-Code, architecture documentation, metadata-based
traceability, reusable AI skills, and deterministic generators. AI may suggest
architecture artifacts and relationships, but the repository owns the truth.
Reviewed metadata and source documents are the authoritative record.

## Principles

- Docs-as-Code first: architecture knowledge lives in version-controlled text.
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
src/docs/      New-project inception docs, canvases, vision, and roadmap.
docs/concepts/ Legacy concept notes retained for later architecture docs.
metamodel/     Schemas for architecture artifacts and relations.
skills/        Reusable AI skill instructions and review workflows.
templates/     AsciiDoc templates for common architecture artifacts.
adapters/      Engine-specific integration layers.
examples/      Sample projects showing expected usage.
```

## New Project Inception

Start new-project clarification in `src/docs/`.

- `src/docs/canvas/business-model-canvas.adoc`
- `src/docs/canvas/value-proposition-canvas.adoc`
- `src/docs/vision-mission.adoc`
- `src/docs/roadmap.adoc`
- `src/docs/canvas/questions-and-answers.adoc`

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

Use `skills/adr` for Architecture Decision Records. The skill combines ADR
drafting with impact analysis for related risks, quality scenarios, components,
interfaces, and traceability metadata. AI-assisted decisions and relationships
remain proposed until reviewed.

## Current Status

This is the initial repository skeleton. It intentionally does not include a full
generator implementation yet. The first milestone is to stabilize the metamodel,
templates, example content, and engine-independent skill contracts. Version 1
focuses first on ADRs, quality scenarios, and risks, with stakeholders,
requirements, and components following next. The initial generated navigation
scope is artifact-type indexes; additional indexes by status, owner, and tag
remain a later evaluation topic.
## Validation

The first deterministic validation step is available as a small Ruby CLI. It
scans architecture artifacts with YAML front matter and validates the metadata
and explicit relationships. Ruby is the current implementation language for the
validator and generator, but not a fixed long-term commitment for the toolkit.
Future runtime choices should also remain compatible with the wider
`docs-as-code-toolkit/docs-toolbox` delivery environment.

Run the default validation against the sample project:

```sh
ruby scripts/validate-metamodel.rb
```

Validation and generation are intended to work both locally and in CI. GitHub
Actions and GitLab CI are the primary reproducible CI environments to support.

By default, the validator scans:

```text
examples/sample-project/docs
```

You can validate another artifact directory with:

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

## Traceability Matrix Generation

The first documentation generator creates a deterministic AsciiDoc traceability
matrix from validated architecture artifact metadata.

Generate the sample project matrix with:

```sh
ruby scripts/validate-metamodel.rb --generate
```

The command validates the artifact metadata first. If validation fails, no matrix
is generated and the command exits with a non-zero status.

By default, the generated file is written to:

```text
examples/sample-project/docs/generated/traceability-matrix.adoc
```

You can choose another output path with:

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
