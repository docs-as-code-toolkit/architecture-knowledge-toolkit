---
name: traceability-review
description: Review explicit architecture traceability metadata for gaps, inconsistencies, unsupported claims, stale links, dangling references, and metamodel violations. Use when Codex needs to inspect artifact relations, validate ADR-to-risk or quality-scenario coverage, propose relation updates, or produce an evidence-backed traceability review report.
---

# Traceability Review Skill

## Purpose

Review explicit architecture traceability metadata for gaps, inconsistencies,
and unsupported claims. Treat every AI-suggested relation, finding, and impact
claim as proposed until a human reviewer accepts it in the repository.

This skill is guidance and reusable content only. Do not implement AI execution,
do not implement a generator, and do not add automation as part of using this
skill.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
metadata, anchor, Docs-as-Code, arc42, or traceability rules here unless the
traceability review workflow needs a stricter rule.

## Core Workflow

1. Inspect the requested documentation scope before writing findings.
2. Read artifact metadata and relation metadata from repository source files.
3. Inspect the relevant AsciiDoc prose only to verify relation rationale,
   visible references, anchors, and evidence.
4. Inspect relevant source code, tests, configuration, or operational evidence
   only when relation claims depend on those artifacts.
5. Validate relation endpoints, relation types, ownership, status, rationale,
   and review state against the metamodel.
6. Compare explicit metadata relations with visible AsciiDoc `xref` links when
   both are expected.
7. Identify missing, weak, stale, dangling, conflicting, or unsupported
   relations.
8. Propose relation additions or changes as `proposed`; do not silently create
   accepted relations.
9. Update affected artifacts with **outgoing** relations only when the user
   requested edits. Never create reciprocal incoming relations; they are derived
   automatically during generation.
10. Prefer deterministic ordering by source ID, relation type, target ID, then
    rationale.
11. Prefer small, reviewable patches.
12. Run the repository validator after changes if one is available.

## Required Reading

Read these references as needed:

- `../../src/docs/arc42/04-solution-strategy/doc-04001-metamodel.adoc` before reviewing
  artifact metadata, artifact types, lifecycle states, or relation semantics.
- `../references/metadata-rules.md` before reviewing YAML front matter.
- `../references/relation-rules.md` before proposing or updating relations.
- `../references/adr-writing-guide.md` before reviewing ADR relations.
- `../references/risk-writing-guide.md` before reviewing risk relations.
- `../references/quality-scenario-guide.md` before reviewing quality scenario
  relations.

Use these templates:

- `../../templates/impact-report.adoc` for review reports when the user wants
  analysis without direct artifact changes.

## Inputs

- Artifact metadata conforming to `metamodel/artifact.schema.yaml`.
- Relation metadata conforming to `metamodel/relations.schema.yaml`.
- Relevant AsciiDoc source documents.
- Review focus, such as ADR-to-risk coverage or quality-scenario coverage.
- Optional evidence sources, such as code, tests, configuration, deployment
  files, issue references, or operational data.
- Review scope: report-only, update proposed relations, or validate a changed
  artifact set.

## Output

Produce a review report with:

- Missing or weak relations.
- Stale, dangling, or conflicting relations.
- Suggested relation additions marked as `proposed`.
- Questions for human reviewers.
- Validation notes against the metamodel.

## Inspection Rules

- Prefer repository source files over conversational memory.
- Treat explicit metadata as authoritative over inferred prose.
- Treat visible `xref` links as documentation references, not as substitutes for
  metadata relations when traceability is required.
- Check the artifact and relation schemas before declaring a relation invalid.
- Check existing artifact IDs before suggesting new IDs.
- Never add reciprocal relations. Incoming relations are derived from outgoing
  relations during generation.
- Preserve accepted or reviewed relations unless repository evidence justifies a
  proposed update.

## Output Rules

- Do not silently create accepted relations.
- Identify dangling references by stable ID.
- Mark AI-suggested additions as `status: proposed` and `reviewed: false`.
- Prefer precise relation types over `relates_to`.
- Prefer deterministic ordering by source ID, relation type, target ID, then
  rationale.
- Keep findings actionable and evidence-backed.
- Check metadata, relation, anchor, and `xref` rules from
  `general-semantic-contracts.md`.

## Review Checklist

- All relation endpoints exist.
- Relation types match the intended semantics.
- Accepted relations have evidence or rationale.
- AI-suggested additions are not marked as reviewed.
- Visible references to documentation artifacts use valid anchor-based
  AsciiDoc `xref` links where required.
- Visible references use the explicit target anchors from source files, not
  raw numbered chapter file names.
- Open questions identify the human decision needed to resolve each uncertain
  relation.

## Validation

After edits, run the repository validator if available. Prefer existing commands
from the repository documentation or scripts. If no validator exists, report
that validation was not available and describe the manual checks performed.
