# Metadata Rules

Treat `src/docs/arc42/04-solution-strategy/doc-04001-metamodel.adoc` as the maintained
source for artifact metadata semantics. Use this file as task-level guidance,
not as a competing schema or contract.

Use YAML front matter for every source artifact created by this skill.

## Required Fields

- `id`: Stable artifact ID. Preserve existing IDs.
- `type`: One of the repository-supported artifact types.
- `title`: Short human-readable title.
- `status`: Lifecycle state.
- `owner`: Accountable role or person.
- `created`: Date in `YYYY-MM-DD`.

## Recommended Fields

- `updated`: Date in `YYYY-MM-DD` when modifying an existing artifact.
- `reviewed`: `false` for AI-generated or AI-modified content until human review
  is recorded.
- `summary`: One sentence for indexes and generated views.
- `derived_from`: Optional provenance for artifacts derived from an input
  question, prompt, external document, repository path, URL, conversation note,
  or another artifact.
- `tags`: Stable lowercase tags.
- `relations`: Explicit outgoing relations.
- `metadata_version`: Use when the repository already uses it.

## Status Rules

- Use `proposed` for AI-created ADRs, risks, quality scenarios, and relations.
- Use `draft` for incomplete notes or impact reports that are not source
  architecture truth.
- Keep `accepted`, `reviewed`, `rejected`, `superseded`, and `deprecated` only
  when the repository already records that lifecycle state.
- Do not mark AI output as reviewed.

## ID Rules

- Follow the repository's existing ID pattern.
- Prefer the next stable number in the existing sequence.
- Do not reuse IDs.
- Do not rename IDs as part of impact analysis.
- If the next ID is unclear, use a clearly proposed ID and add an open question.
- Name every standalone architecture source artifact, and every standalone
  AsciiDoc document with an `:id:` attribute, after its normalized artifact ID:
  lowercase the `id`, replace non-alphanumeric separators with `-`, trim
  leading and trailing dashes, and add `.adoc`.
- For DOC artifacts inside arc42, use decimal classification without dot
  separators: two digits for the structural directory or arc42 chapter and
  three digits for the local sequence. Chapter overview documents use local
  sequence `000`; detail documents inside a numbered chapter directory start at
  `001`. For example, `DOC-01001-quality-goals` becomes
  `doc-01001-quality-goals.adoc` in chapter `01`.
- Do not duplicate the title, chapter number, or type prefix beyond what is
  already part of the artifact ID.
- Do not force artifact types with their own classification, such as ADRs,
  quality scenarios, or risks, into the DOC decimal-classification scheme.

## Evidence Rules

- Metadata relations should include `rationale`.
- Add `evidence` when the repository relation schema supports it and a concrete
  file or section supports the claim.
- Use `derived_from` when an artifact was created because of a specific prompt,
  answered question, external source, repository document, or originating
  artifact. Prefer a structured entry with `description` and, when available,
  `anchor`, `uri`, `path`, or `target`.
- Use generated metadata attribute fragments when source prose needs access to
  metadata values as AsciiDoc attributes. For provenance text, include the
  artifact's local `generated/*-attributes.adoc` fragment before checking
  `ifdef::derived_from_description[]`.
- Do not use `relations` only to capture provenance. Relations express
  architecture traceability between artifacts; `derived_from` explains origin.
- Do not use source code comments, generated prose, derived output, or chat
  history as the only authority for accepted metadata.
- Derived output includes `generated/`, `build/`, `dist/`, `target/`, `out/`,
  rendered HTML/PDF, generated indexes, traceability views, and assembled
  documentation. Use it only to verify rendering, generation, packaging, or
  drift against source inputs.

## Documentation Anchor Rules

- Add an AsciiDoc anchor immediately after YAML front matter in every generated
  or AI-assisted documentation artifact.
- Use the explicit AsciiDoc anchor already present in a target source file when
  generating or updating `xref` links.
- If an anchor must be derived from a file name, remove numeric ordering
  prefixes such as `09-`, replace every non-alphanumeric character with `-`,
  lowercase all letters, and trim leading or trailing dashes.
- Keep digits only when they are part of a stable artifact identifier, such as
  `adr-001`, not when they only express chapter ordering.
- Do not derive visible xrefs from raw numbered chapter file names. For example,
  `src/docs/arc42/doc-09000-architecture-decisions.adoc` is referenced as
  `xref:architecture-decisions[]`, not `xref:09-architecture-decisions[]`.
- Keep metadata relation targets as stable artifact IDs.
- Use anchor-based `xref` links in visible prose and tables when referencing a
  documentation artifact.
- Do not add a new artifact to a hand-written chapter include list. Chapter
  assembly is generated from artifact metadata and sorted by artifact ID.
