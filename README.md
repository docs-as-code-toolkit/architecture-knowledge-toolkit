# architecture-knowledge-toolkit

Reusable architecture knowledge assets for software architecture work.

This repository combines Docs-as-Code, architecture documentation, metadata-based
traceability, reusable AI skills, and deterministic generators. AI may suggest
architecture artifacts and relationships, but the repository owns the truth.
Reviewed metadata and source documents are the authoritative record.

## Principles

- Docs-as-Code first: architecture knowledge lives in version-controlled text.
- AsciiDoc is the default format for architecture documentation and templates.
- Every architecture artifact has a stable, explicit ID.
- Traceability is metadata-driven, not inferred from prose alone.
- AI-generated output is a suggestion until reviewed and committed.
- Generators must be deterministic, idempotent, and reproducible.
- Skills are engine-independent where possible.
- Engine-specific integration belongs under `adapters/`.

## Repository Layout

```text
docs/          Human-authored architecture documentation.
metamodel/     Schemas for architecture artifacts and relations.
skills/        Reusable AI skill instructions and review workflows.
templates/     AsciiDoc templates for common architecture artifacts.
adapters/      Engine-specific integration layers.
examples/      Sample projects showing expected usage.
```

## Intended Workflow

1. Create or update an architecture artifact using an AsciiDoc template.
2. Add explicit metadata with a stable ID, lifecycle state, ownership, and tags.
3. Add traceability relations using the relation metamodel.
4. Optionally use an AI skill to suggest content, risks, scenarios, or links.
5. Review the suggestion as normal architecture work.
6. Commit reviewed source documents and metadata.
7. Run deterministic generators to produce derived documentation.

Generated output should be reproducible from committed inputs. If generated output
differs without an input change, that is a defect in the generator or environment.

## Current Status

This is the initial repository skeleton. It intentionally does not include a full
generator implementation yet. The first milestone is to stabilize the metamodel,
templates, example content, and engine-independent skill contracts.
## Validation

The first deterministic validation step is available as a small Ruby CLI. It
scans architecture artifacts with YAML front matter and validates the metadata
and explicit relationships.

Run the default validation against the sample project:

```sh
ruby scripts/validate-metamodel.rb
```

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

