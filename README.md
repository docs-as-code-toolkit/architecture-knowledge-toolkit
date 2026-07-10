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

## Relationship to docToolchain

This project is not intended to compete with
[docToolchain](https://github.com/docToolchain).

docToolchain is a mature Docs-as-Code toolchain for building, converting,
publishing, and integrating technical and software architecture documentation.
The architecture-knowledge-toolkit focuses on the layer above publishing:
semantic contracts, metadata conventions, artifact templates, traceability
relations, review workflows, deterministic generators, and AI-assistable
architecture work.

Both approaches can be combined. This toolkit can provide structured AsciiDoc
sources and metadata, while docToolchain or similar tools render and publish the
resulting documentation. The wider Docs-as-Code Toolkit also provides
`docs-toolbox` as a reproducible local and CI runtime for rendering.

In short: **we operate one layer above publishing.**

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
- Publishing toolchains are replaceable neighbors; reviewed source documents,
  metadata, and relations remain the authoritative architecture knowledge base.
- Skills are engine-independent where possible.
- Engine-specific integration belongs under `adapters/`.

## Repository Layout

```text
src/docs/      New-project inception docs, canvases, vision, roadmap, and arc42.
metamodel/     Schemas for architecture artifacts and relations.
skills/        Reusable AI skill instructions and review workflows.
templates/     AsciiDoc templates for common architecture artifacts.
adapters/      Engine-specific integration layers.
features/      Gherkin behaviour specifications (living documentation).
test/          Bridged unit, CLI, and generator tests.
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

- `src/docs/canvas/canvas-001-business-model.adoc`
- `src/docs/canvas/canvas-002-value-proposition.adoc`
- `src/docs/doc-002-vision-mission.adoc`
- `src/docs/doc-004-roadmap.adoc`
- `src/docs/doc-005-questions-and-answers.adoc`

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

Reusable prompt templates live in [`templates/prompts/`](templates/prompts/).
They include direct bootstrap prompts, one prompt per toolkit skill, contract
application prompts, and migration prompts for aligning local skills or
contracts with the generic toolkit guidance.

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
- [`skills/architecture-impact`](/skills/architecture-impact/SKILL.md) for keeping feature requests, refactorings, reviews, Epics, UserStories, and architecture documentation aligned.
- [`skills/adr`](/skills/adr/SKILL.md) for Architecture Decision Records and impact analysis.
- [`skills/quality-scenario`](/skills/quality-scenario/SKILL.md) for measurable quality scenarios.
- [`skills/risk`](/skills/risk/SKILL.md) for architecture risks and mitigations.
- [`skills/traceability-review`](/skills/traceability-review/SKILL.md) for metadata relation reviews.
- [`skills/pr-review`](/skills/pr-review/SKILL.md) for pull request reviews, including GitHub PR comments or `.pr_comments/.pr<pr-number>_comments.md` fallback files.
- [`skills/post-merge-sync`](/skills/post-merge-sync/SKILL.md) for returning a
  local checkout to the latest base branch after a pull request has been merged.
- [`skills/domain-modeling`](/skills/domain-modeling/SKILL.md) Actively build and sharpen a project's domain model — challenge terms against the glossary, stress-test with edge-case scenarios, and update CONTEXT.md and ADRs inline.
- [`skills/bdd-specification`](/skills/bdd-specification/SKILL.md) for enforcing living documentation through Behaviour-Driven Development — the strict default for any new or changed behaviour: a language-agnostic Gherkin feature spec mapped to at least one automated verification via a reviewer-verifiable scenario-to-test naming convention and Given/When/Then anchors, relaxed only with an explicit recorded waiver.
- [`skills/grilling/with-docs`](/skills/grilling/with-docs/SKILL.md) Grilling session that also builds your project's domain model, sharpening terminology and updating CONTEXT.md and ADRs inline
- [`skills/grilling/me`](/skills/grilling/me/SKILL.md) Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- [`skills/grilling/`](/skills/grilling/SKILL.md) Interview the user relentlessly about a plan or design until every branch of the decision tree is resolved. The reusable loop behind grill-me and grill-with-docs.

Shared writing guides live under `skills/references/`. AI-assisted artifacts,
decisions, assessments, and relationships remain proposed until reviewed.
GitHub Copilot-specific review entry points live in
`.github/copilot-instructions.md`, `.github/instructions/`, and
`adapters/github-copilot/`; those files point back to the engine-independent
skill contracts.

## Tests

The toolkit's executable features — the metamodel validator, the documentation
generators, and the agent adapter generator — are specified as Gherkin
behaviour in [`features/`](features/) and bridged into tests following the
[`bdd-specification`](/skills/bdd-specification/SKILL.md) skill. There is no
native BDD runner, and the bridge is a reviewer-verifiable convention rather than
a build-enforced link: each scenario maps to at least one classic test that is
traceable by the sanitized scenario title, with `Given` / `When` / `Then` comment
anchors. Here the mapping happens to be one-to-one.

Run all tests through the docs-toolbox image:

```sh
./build.sh test
```

Local equivalent (without docs-toolbox):

```sh
ruby -Itest test/validate_metamodel_test.rb       # validator + generator units
ruby -Itest test/validate_metamodel_cli_test.rb   # validator CLI behaviour
node --test test/build-agent-adapters.test.mjs    # adapter generator
```

The container-based render scripts (`build.sh` itself and
`scripts/render-presentation.sh`) are not covered yet; testing them requires a
container engine and is tracked as a follow-up.

## Current Status

This is the initial repository skeleton. It intentionally does not include a full
generator implementation yet. The first milestone is to stabilize the metamodel,
templates, dogfood arc42 documentation, and engine-independent skill contracts.
Version 1 focuses first on ADRs, quality scenarios, and risks, with
stakeholders, requirements, and components following next. The initial generated
navigation scope is artifact-type indexes; additional indexes by status, owner,
and tag remain a later evaluation topic.

The former `examples/sample-project` has been removed. The project now uses its
own arc42 documentation under `src/docs/doc-001-arc42.adoc` and `src/docs/arc42/` as the
living example. The dogfood docs now include standalone proposed ADR, quality
scenario, and risk artifacts so the ADR-to-quality-to-risk traceability chain is
visible in the repository itself.

## Running tasks

`build.sh` is the single entry point for every repository task. By default it
runs the task inside a pinned `docs-as-code-toolkit/docs-toolbox` container image,
so local runs and CI share the same reproducible toolchain (Ruby, Node.js,
Asciidoctor, PlantUML, Graphviz).

```sh
./build.sh <task>
```

Execution modes:

- **Container (default, reproducible).** Uses the pinned image (Docker or
  Podman). File ownership is mapped to the invoking user (`--user` on Docker,
  `--userns=keep-id` on rootless Podman), so generated files are not root-owned.
  The reproducibility guarantee holds only in this mode.
- **Local (opt-in, not reproducible).** `DOCS_TOOLBOX_LOCAL=1 ./build.sh <task>`
  runs against whatever Ruby/Node is installed on the host.

If no container engine is running and `DOCS_TOOLBOX_LOCAL=1` is not set, the task
aborts rather than silently using the host toolchain. Override the image (for
example to pin a digest) with `DOCS_TOOLBOX_IMAGE`.

| Task | What it does | Local equivalent |
|------|--------------|------------------|
| `validate` | Validate artifact metadata and relations | `ruby scripts/validate-metamodel.rb` |
| `generate` | Validate, then generate derived fragments/indexes | `ruby scripts/validate-metamodel.rb --generate` |
| `test` | Run all tests (Ruby units, Ruby CLI, JS adapter) | see [Tests](#tests) |
| `test-ruby` | Ruby validator/generator unit and CLI tests | `ruby -Itest test/validate_metamodel_test.rb` and `ruby -Itest test/validate_metamodel_cli_test.rb` |
| `test-js` | JS adapter generator tests | `node --test test/build-agent-adapters.test.mjs` |
| `adapters` | Regenerate agent adapters from skills | `node scripts/build-agent-adapters.js` |
| `check-adapters` | Fail if the generated adapters are stale | `node scripts/check-agent-adapters.js` |
| `build` | Generate fragments and render architecture HTML | see below |
| `presentation` | Render an AsciiDoc slide deck | `sh scripts/render-presentation.sh <slides.adoc> [out]` |
| `all` | `test` + `check-adapters` + `build` (`build` also validates) | — |
| `clean` | Remove `build/architecture` | `rm -rf build/architecture` |

Override the image with `DOCS_TOOLBOX_IMAGE`. The examples below show the
`./build.sh` task first and the local command you can run instead when you do
not want to use docs-toolbox.

## Validation

The first deterministic validation step is a small Ruby CLI. It scans
architecture artifacts with YAML front matter and validates the metadata and
explicit relationships. Ruby is the current implementation language for the
validator and generator, but not a fixed long-term commitment for the toolkit.

Run the default validation against this project's own arc42 documentation:

```sh
./build.sh validate
```

Local equivalent (without docs-toolbox):

```sh
ruby scripts/validate-metamodel.rb
```

Build the assembled architecture documentation with the same `docs-toolbox`
container image used in CI:

```sh
./build.sh build
```

The build output is written to `build/architecture/index.html`. The script uses
Docker or Podman when available and falls back to the local toolchain only when
no container engine is installed.

Validation and generation are intended to work both locally and in CI. GitHub
Actions and GitLab CI are the primary reproducible CI environments to support.
This repository validates pull requests and pushes to `main` with GitHub
Actions.

By default, the validator scans:

```text
src/docs/
```

You can validate another artifact file or directory with the local CLI (the
`--docs` flag is not exposed through `build.sh`):

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
./build.sh test-ruby
```

Local equivalent (without docs-toolbox):

```sh
ruby -Itest test/validate_metamodel_test.rb
ruby -Itest test/validate_metamodel_cli_test.rb
```

## Derived Documentation Generation

The documentation generator creates deterministic AsciiDoc fragments from
validated architecture artifact metadata. These fragments are includeable
derived output, not reviewed source content.

Do not use generated fragments or other derived output as architecture context
or evidence. Treat files below `generated/`, `build/`, `dist/`, `target/`, or
`out/`, rendered HTML/PDF, generated indexes, traceability views, and assembled
documentation as outputs to verify or regenerate from reviewed source inputs.

Generate the project arc42 derived documentation with:

```sh
./build.sh generate
```

Local equivalent (without docs-toolbox):

```sh
ruby scripts/validate-metamodel.rb --generate
```

The command validates the artifact metadata first. If validation fails, no
derived files are generated and the command exits with a non-zero status.

By default, generated files are written below `generated/` directories:

```text
src/docs/arc42/generated/traceability-matrix.adoc
src/docs/arc42/**/generated/*-includes.adoc
src/docs/arc42/**/generated/*-attributes.adoc
src/docs/arc42/**/generated/*-impact.adoc
src/docs/arc42/**/generated/*-traceability.adoc
src/docs/arc42/09-architecture-decisions/generated/open-questions.adoc
src/docs/arc42/09-architecture-decisions/generated/doc-09001-adr-index.adoc
src/docs/arc42/10-quality-requirements/generated/doc-10001-quality-scenarios.adoc
src/docs/arc42/11-risks-and-technical-debt/generated/doc-11001-risks.adoc
```

The generator also creates chapter include fragments. Chapter main files should
include these generated fragments instead of manually listing each detail
document. Generated chapter include fragments are sorted by artifact ID so new
artifacts appear deterministically after regeneration.

The chapter-level index fragments keep the existing table shape where possible.
Row content is derived from each artifact's metadata and structured source body:
IDs, titles, lifecycle status, provenance, summaries, and relations come from
YAML front matter; quality scenario and risk assessment fields come from their
existing definition tables. ADR index entries render optional `derived_from`
metadata as text, AsciiDoc anchors, external links, repository paths, or
artifact references where possible.

The generator also creates per-artifact metadata attribute fragments. Source
documents may include their local `generated/*-attributes.adoc` fragment before
using conditional AsciiDoc content such as:

```asciidoc
ifdef::derived_from_description[]
Derived from {derived_from_description}
endif::[]
```

Generated index fragments are included directly in their chapter context. Source
wrapper documents whose only purpose is to include generated indexes should not
be introduced; existing wrappers are migration targets.

Impact and traceability sections are generated per artifact from metadata
relations instead of being maintained manually in each source file. Source
artifacts include their local generated fragments below `=== Impact` and
`=== Traceability` sections, for example
`include::generated/adr-001-asciidoc-primary-source-impact.adoc[leveloffset=+2]`
and
`include::generated/adr-001-asciidoc-primary-source-traceability.adoc[leveloffset=+2]`.
Render or publish these files only in flows where the generator has run first.
Source files must not maintain manual impact or traceability matrices for ADR,
risk, or quality scenario artifacts; metadata relations are the source of truth.

You can choose another traceability matrix output path with the local CLI (the
`--output` flag is not exposed through `build.sh`):

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
