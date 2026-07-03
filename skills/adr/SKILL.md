---
name: adr
description: Create proposed Architecture Decision Records and analyze their impact on related architecture artifacts. Use when Codex needs to draft or update ADRs, inspect existing architecture documentation and source code, compare options with a Pugh matrix, identify affected risks and quality scenarios, propose traceability metadata relations, update impacted artifacts only when justified, or produce an ADR impact report.
---

# ADR Skill

## Purpose

Help create Architecture Decision Records and analyze their impact on related
architecture artifacts. Treat every AI-created artifact, relation, and impact
claim as proposed until a human reviewer accepts it in the repository.

This skill is guidance and reusable content only. Do not implement AI execution,
do not implement a generator, and do not add automation as part of using this
skill.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
metadata, anchor, or Docs-as-Code rules here unless the ADR workflow needs a
stricter rule.

## Core Workflow

1. Inspect existing architecture documentation before writing.
2. Inspect relevant source code if available.
3. Identify existing ADRs, risks, quality scenarios, requirements, constraints,
   components, interfaces, and concepts that may relate to the decision.
4. Draft a proposed ADR with explicit assumptions, options, consequences,
   metadata, and a 3-point Pugh matrix.
5. Analyze impacts on existing risks and quality scenarios.
6. Create new risk or quality scenario artifacts only when no existing artifact
   covers the impact.
7. Propose explicit metadata relations.
8. Update affected artifacts with **outgoing** relations only when justified by evidence.
   Never create reciprocal incoming relations; they are derived automatically during generation.
9. Add stable AsciiDoc anchors to created documentation artifacts and use
   anchor-based `xref` links for visible references to documentation artifacts.
10. Prefer small, reviewable patches.
11. Run the repository validator after changes if one is available.

## Required Reading

Read these references as needed:

- `../../src/docs/arc42/04-solution-strategy/doc-003-metamodel.adoc` before writing or
  changing artifact metadata, artifact types, lifecycle states, or relation
  semantics.
- `../references/metadata-rules.md` before writing YAML front matter.
- `../references/relation-rules.md` before proposing or updating relations.
- `../references/adr-writing-guide.md` before drafting ADRs.
- `../references/risk-writing-guide.md` before creating or changing risks.
- `../references/quality-scenario-guide.md` before creating or changing quality
  scenarios.

Use these templates:

- `../../templates/adr.adoc` for ADR artifacts.
- `../../templates/risk.adoc` for new risk artifacts.
- `../../templates/quality-scenario.adoc` for new quality scenario artifacts.
- `../../templates/impact-report.adoc` for review reports when the user wants
  analysis without direct artifact changes.

## Inputs To Collect

- Decision topic and desired outcome.
- Forces, constraints, and candidate options.
- Existing architecture artifacts and their stable IDs.
- Relevant source code, configuration, API contracts, deployment files, tests, or
  operational evidence.
- Known risks, quality scenarios, requirements, or stakeholder concerns.
- Review scope: draft-only, update artifacts, or produce an impact report.

## Inspection Rules

- Prefer repository source files over conversational memory.
- Treat explicit metadata as more authoritative than inferred prose.
- Check existing artifact IDs before assigning new IDs.
- Read the closest architecture index, ADR register, risk list, quality tree, and
  affected arc42 chapter when present.
- Inspect code only to gather evidence or discover affected components; do not
  implement the decision unless the user separately asks for implementation.

## Output Rules

- Keep all AI-generated artifacts `status: proposed` or `status: draft`.
- Set `reviewed: false` for AI-generated or AI-modified content unless human
  review is already recorded in the repository.
- Preserve existing accepted statuses unless there is explicit repository
  evidence that they changed.
- Mark uncertain values as assumptions or open questions.
- Do not invent accepted relationships.
- Do not create new risk or quality scenario artifacts when a justified relation
  to an existing artifact is sufficient.
- Keep metadata relation targets as stable artifact IDs; render visible
  documentation references as anchor-based AsciiDoc `xref` links.
- Use explicit target anchors for visible links; do not derive xrefs from raw
  numbered chapter file names.
- Apply metadata, relation, anchor, and `xref` rules from
  `general-semantic-contracts.md`.
- Do not manually update chapter detail include lists. Chapter main documents
  use generated include fragments; run or request the generator after adding an
  artifact when the rendered chapter needs to include it.
- Keep changes narrow and easy to review.

## Impact Analysis Checklist

- Affected existing ADRs: superseded, constrained, conflicting, or dependent.
- Affected risks: introduced, mitigated, increased, reduced, or made obsolete.
- Affected quality scenarios: addressed, constrained, threatened, or verified.
- Affected components and interfaces: ownership, contracts, persistence,
  runtime behavior, deployment, observability, security, and error handling.
- Missing artifacts: only create when the impact cannot be represented by an
  existing artifact.
- Open decisions: list questions for human review.

## Validation

After edits, run the repository validator if available. Prefer existing commands
from the repository documentation or scripts. If no validator exists, report that
validation was not available and describe the manual checks performed.
