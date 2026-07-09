---
name: risk
description: Create proposed architecture risk artifacts and analyze their traceability to ADRs, quality scenarios, requirements, components, controls, and evidence. Use when Codex needs to identify, draft, update, prioritize, or review architecture risks, separate risks from issues and decisions, propose mitigations, or produce a risk impact report without deciding acceptance.
---

# Risk Skill

## Purpose

Help identify, structure, and update architecture risks for review and
prioritization. Treat every AI-created risk, relation, assessment, mitigation,
and impact claim as proposed until a human reviewer accepts it in the
repository.

This skill is guidance and reusable content only. Do not implement AI execution,
do not implement a generator, and do not add automation as part of using this
skill.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
metadata, anchor, Docs-as-Code, arc42, or traceability rules here unless the risk
workflow needs a stricter rule.

## Core Workflow

1. Inspect existing architecture documentation before writing.
2. Inspect relevant source code, configuration, deployment files, incidents,
   tests, ADRs, quality scenarios, and operational evidence when available.
3. Identify existing risks, ADRs, quality scenarios, requirements, constraints,
   components, interfaces, controls, and concepts that may relate to the risk.
4. Check whether an existing risk already covers the concern.
5. Draft a proposed risk only when the concern is not covered by an existing
   artifact.
6. Write the risk statement as cause, event, and impact.
7. Assess likelihood, impact, priority, timeframe, and confidence qualitatively.
8. Propose actionable mitigations, monitoring, or review actions with an owner
   where evidence supports them.
9. Propose explicit metadata relations to decisions, quality scenarios,
   requirements, affected architecture documents, mitigations, and evidence.
10. Update affected artifacts with **outgoing** relations only when justified by evidence.
    Never create reciprocal incoming relations; they are derived automatically during generation.
11. Add stable AsciiDoc anchors to created documentation artifacts and use
    anchor-based `xref` links for visible references to documentation artifacts.
12. Prefer small, reviewable patches.
13. Run the repository validator after changes if one is available.

## Required Reading

Read these references as needed:

- `../../src/docs/arc42/04-solution-strategy/doc-04001-metamodel.adoc` before writing or
  changing artifact metadata, artifact types, lifecycle states, or relation
  semantics.
- `../references/metadata-rules.md` before writing YAML front matter.
- `../references/relation-rules.md` before proposing or updating relations.
- `../references/risk-writing-guide.md` before creating or changing risks.
- `../references/adr-writing-guide.md` before linking risks to ADRs.
- `../references/quality-scenario-guide.md` before linking risks to quality
  scenarios.

Use these templates:

- `../../templates/risk.adoc` for new risk artifacts.
- `../../templates/impact-report.adoc` for review reports when the user wants
  analysis without direct artifact changes.

## Inputs To Collect

- Architecture context, affected outcome, and risk owner.
- Decision, component, interface, constraint, quality scenario, control, or
  requirement that creates or exposes the risk.
- Known incidents, assumptions, dependencies, threat findings, operational
  constraints, or uncertainties.
- Existing risk IDs and related artifact IDs where available.
- Evidence for likelihood, impact, confidence, mitigation, or monitoring.
- Review scope: draft-only, update artifacts, or produce an impact report.

## Inspection Rules

- Prefer reviewed repository source files over conversational memory.
- Do not load derived output as evidence or architecture context. This includes
  `generated/`, `build/`, `dist/`, `target/`, `out/`, rendered HTML/PDF,
  generated indexes, traceability views, and assembled documentation.
- Treat explicit metadata as more authoritative than inferred prose.
- Check existing risk IDs before assigning new IDs.
- Read the closest architecture index, risk list, ADR register, quality
  scenario list, threat model, concept chapter, and affected arc42 chapter when
  present.
- Inspect code only to gather evidence, discover affected components, or verify
  controls; do not implement mitigations unless the user separately asks for
  implementation.
- Separate risks from issues, decisions, constraints, defects, and open
  questions.

## Output Rules

- Keep all AI-generated artifacts `status: proposed` or `status: draft`.
- Set `reviewed: false` for AI-generated or AI-modified content unless human
  review is already recorded in the repository.
- Preserve existing accepted statuses unless there is explicit repository
  evidence that they changed.
- Do not mark a risk accepted unless human acceptance is already recorded.
- Avoid false precision in likelihood, impact, priority, or confidence.
- Mark uncertainty explicitly instead of pretending evidence is complete.
- Prefer actionable mitigations with owners.
- Do not create new risk artifacts when a justified relation to an existing
  artifact is sufficient.
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

## Risk Checklist

- The risk statement uses cause, event, and impact.
- The impact is tied to architecture outcomes, quality scenarios, delivery,
  operations, security, compliance, or stakeholder value.
- Likelihood, impact, priority, timeframe, and confidence are qualitative and
  reviewable.
- Mitigations, monitoring, or review actions are realistic and owned.
- Assumptions and open questions are explicit.
- Risk acceptance remains a human decision.

## Traceability Checklist

- Related ADRs: introduces, mitigates, depends on, constrains, or affects.
- Related quality scenarios: threatened, constrained, verified, or mitigated.
- Related concepts, controls, tests, operational evidence, requirements, use
  cases, and business rules.
- Affected components and interfaces: ownership, contracts, persistence,
  runtime behavior, deployment, observability, security, and error handling.
- Missing artifacts: only create when the concern cannot be represented by an
  existing artifact.
- Open decisions: list questions for human review.

## Validation

After edits, run the repository validator if available. Prefer existing commands
from the repository documentation or scripts. If no validator exists, report
that validation was not available and describe the manual checks performed.
