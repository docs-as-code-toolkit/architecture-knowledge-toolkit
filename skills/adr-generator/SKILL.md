# ADR Generator Skill

## Purpose

Help draft Architecture Decision Records from explicit context. This skill may
suggest ADR content, but the result remains a proposal until reviewed.

## Inputs

- Decision topic.
- Problem or force being addressed.
- Candidate options.
- Known constraints.
- Relevant quality scenarios, risks, requirements, or prior ADR IDs.
- Desired decision status, usually `proposed`; use `Proposed (derived)` for derived ADRs until human acceptance is recorded.

## Output

Produce an AsciiDoc ADR based on `templates/adr.adoc` with:

- A stable proposed ID.
- Context and forces.
- Considered options.
- Decision.
- Consequences.
- Explicit metadata.
- Suggested traceability relations.
- Open questions for human review.

## Rules

- Do not invent authoritative relationships. Mark suggested relations as
  `proposed`.
- Preserve existing IDs and statuses.
- Do not mark derived ADRs as accepted unless human acceptance is already recorded in the repository.
- Prefer repository terms and artifact IDs over new vocabulary.
- If evidence is missing, state the assumption instead of hiding it.
- Keep the output engine-independent.

## Review Checklist

- The decision is stated clearly.
- Alternatives are represented fairly.
- Consequences include positive and negative effects.
- Relations reference stable IDs.
- Suggested content is reviewed before acceptance.

