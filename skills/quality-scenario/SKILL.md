---
name: quality-scenario
description: Create proposed quality scenarios and analyze their traceability to quality objectives, ADRs, risks, requirements, architecture artifacts, and code evidence. Use when Codex needs to draft or update measurable quality scenarios, inspect existing arc42 Chapter 10 quality requirements, derive scenarios from source evidence without inventing targets, propose metadata relations, or produce a quality scenario impact report.
---

# Quality Scenario Skill

## Purpose

Help create measurable quality scenarios for architecture work and analyze their
traceability to related architecture artifacts. Treat every AI-created artifact,
relation, threshold, and impact claim as proposed until a human reviewer accepts
it in the repository.

This skill is guidance and reusable content only. Do not implement AI execution,
do not implement a generator, and do not add automation as part of using this
skill.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
metadata, anchor, Docs-as-Code, arc42, or traceability rules here unless the
quality scenario workflow needs a stricter rule.

## Core Workflow

1. Inspect existing architecture documentation before writing.
2. Inspect relevant source code, configuration, tests, API contracts,
   deployment files, and operational evidence when available.
3. Identify existing quality objectives, quality scenarios, ADRs, risks,
   requirements, constraints, components, interfaces, and concepts that may
   relate to the scenario.
4. Check whether an existing quality scenario already covers the concern.
5. Draft a proposed quality scenario only when the concern is not covered by an
   existing artifact.
6. Use the six-part quality attribute scenario format: source, stimulus,
   artifact, environment, response, and response measure.
7. Prefer measurable response criteria with concrete evidence. If no threshold
   can be justified, write an open question instead of inventing a target.
8. Propose explicit metadata relations to quality objectives, ADRs, risks,
   requirements, affected architecture documents, and verification evidence.
9. Update affected artifacts with **outgoing** relations only when justified by evidence.
   Never create reciprocal incoming relations; they are derived automatically during generation.
10. Add stable AsciiDoc anchors to created documentation artifacts and use
    anchor-based `xref` links for visible references to documentation artifacts.
11. Prefer small, reviewable patches.
12. Run the repository validator after changes if one is available.

## Required Reading

Read these references as needed:

- `../../src/docs/arc42/04-solution-strategy/doc-04001-metamodel.adoc` before writing or
  changing artifact metadata, artifact types, lifecycle states, or relation
  semantics.
- `../references/metadata-rules.md` before writing YAML front matter.
- `../references/relation-rules.md` before proposing or updating relations.
- `../references/quality-scenario-guide.md` before creating or changing
  quality scenarios.
- `../references/adr-writing-guide.md` before linking scenarios to ADRs.
- `../references/risk-writing-guide.md` before linking scenarios to risks
  or creating risk follow-ups.

Use these templates:

- `../../templates/quality-scenario.adoc` for new quality scenario artifacts.
- `../../templates/impact-report.adoc` for review reports when the user wants
  analysis without direct artifact changes.

## Inputs To Collect

- Quality attribute, such as performance, availability, modifiability, security,
  usability, interoperability, operability, or an ISO/IEC 25010 characteristic.
- Stakeholder, user group, or accountable owner.
- System context and affected system element.
- Stimulus, environment, response, and response measure if known.
- Relevant quality objective from arc42 Chapter 1.2, or a clear note that the
  scenario is derived.
- Related artifact IDs for ADRs, risks, requirements, components, interfaces,
  tests, operational evidence, or existing quality scenarios.
- Review scope: draft-only, update artifacts, or produce an impact report.

## Inspection Rules

- Prefer reviewed repository source files over conversational memory.
- Do not load derived output as evidence or architecture context. This includes
  `generated/`, `build/`, `dist/`, `target/`, `out/`, rendered HTML/PDF,
  generated indexes, traceability views, and assembled documentation.
- Treat explicit metadata as more authoritative than inferred prose.
- Check existing artifact IDs before assigning new IDs.
- Read the closest architecture index, quality tree, quality scenario list,
  ADR register, risk list, and affected arc42 chapter when present.
- Inspect code only to gather evidence, discover measurable behavior, or
  identify affected components; do not implement architecture changes unless
  the user separately asks for implementation.
- Derive thresholds from existing requirements, tests, configuration, service
  levels, operational data, or human-provided decisions. Do not invent target
  values.

## Output Rules

- Keep all AI-generated artifacts `status: proposed` or `status: draft`.
- Set `reviewed: false` for AI-generated or AI-modified content unless human
  review is already recorded in the repository.
- Preserve existing accepted statuses unless there is explicit repository
  evidence that they changed.
- Mark uncertain values as assumptions in drafts.
- Do not treat assumed or invented target values as answered evidence in final
  arc42 documentation.
- Do not turn aspirations into accepted requirements without review.
- Keep generated scenarios concise and testable.
- Do not create new quality scenario artifacts when a justified relation to an
  existing artifact is sufficient.
- Keep metadata relation targets as stable artifact IDs; render visible
  documentation references as anchor-based AsciiDoc `xref` links.
- Keep quality scenario impact and traceability data exclusively in YAML front
  matter relations. Do not add a manual impact matrix, manual traceability
  matrix, or reciprocal incoming relations to the quality scenario body.
- Make impact and traceability visible through `=== Impact` and
  `=== Traceability` sections that include the generated local
  `generated/<artifact-anchor>-impact.adoc` and
  `generated/<artifact-anchor>-traceability.adoc` fragments with
  `leveloffset=+2`. The generator owns the visible tables, and each fragment
  starts with `== Matrix` because the source document owns the semantic section
  heading.
- Use explicit target anchors for visible links; do not derive xrefs from raw
  numbered chapter file names.
- Apply metadata, relation, anchor, and `xref` rules from
  `general-semantic-contracts.md`.
- Do not manually update chapter detail include lists. Chapter main documents
  use generated include fragments; run or request the generator after adding an
  artifact when the rendered chapter needs to include it.
- Keep changes narrow and easy to review.

## Scenario Checklist

- The scenario uses the six-part format: source, stimulus, artifact,
  environment, response, and response measure.
- The response measure is specific and evaluable.
- The environment is explicit, such as normal load, failure, maintenance,
  attack, peak usage, degraded dependency, or another reviewable context.
- The stakeholder value or architectural concern is clear.
- The scenario is linked to a top-level quality objective from Chapter 1.2 or
  marked as derived.
- The accountable owner is recorded.
- Assumptions and open questions are explicit.

## Traceability Checklist

- Related quality objective: concretizes a Chapter 1.2 objective or is marked as
  derived.
- Related ADRs: addressed, constrained, threatened, verified, or depended on.
- Related risks: risks that can threaten the scenario or mitigations that
  support it.
- Related requirements, use cases, business rules, tests, and operational
  evidence.
- Affected components and interfaces: ownership, contracts, persistence,
  runtime behavior, deployment, observability, security, and error handling.
- Missing artifacts: only create when the concern cannot be represented by an
  existing artifact.
- Open decisions: list questions for human review.

## Validation

After edits, run the repository validator if available. Prefer existing commands
from the repository documentation or scripts. If no validator exists, report
that validation was not available and describe the manual checks performed.
