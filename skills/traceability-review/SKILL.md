# Traceability Review Skill

## Purpose

Review explicit architecture traceability metadata for gaps, inconsistencies,
and unsupported claims.

## Inputs

- Artifact metadata conforming to `metamodel/artifact.schema.yaml`.
- Relation metadata conforming to `metamodel/relations.schema.yaml`.
- Relevant AsciiDoc source documents.
- Review focus, such as ADR-to-risk coverage or quality-scenario coverage.

## Output

Produce a review report with:

- Missing or weak relations.
- Stale, dangling, or conflicting relations.
- Suggested relation additions marked as `proposed`.
- Questions for human reviewers.
- Validation notes against the metamodel.

## Rules

- Treat explicit metadata as authoritative over inferred prose.
- Do not silently create accepted relations.
- Identify dangling references by stable ID.
- Prefer deterministic ordering by source ID, relation type, then target ID.
- Keep findings actionable and evidence-backed.

## Review Checklist

- All relation endpoints exist.
- Relation types match the intended semantics.
- Accepted relations have evidence or rationale.
- AI-suggested additions are not marked as reviewed.

