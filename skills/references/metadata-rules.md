# Metadata Rules

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

## Evidence Rules

- Metadata relations should include `rationale`.
- Add `evidence` when the repository relation schema supports it and a concrete
  file or section supports the claim.
- Do not use source code comments, generated prose, or chat history as the only
  authority for accepted metadata.

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
  `src/docs/arc42/09-architecture-decisions.adoc` is referenced as
  `xref:architecture-decisions[]`, not `xref:09-architecture-decisions[]`.
- Keep metadata relation targets as stable artifact IDs.
- Use anchor-based `xref` links in visible prose and tables when referencing a
  documentation artifact.
