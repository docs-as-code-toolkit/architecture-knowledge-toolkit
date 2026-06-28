# Relation Rules

Use explicit metadata relations for traceability. Relations are claims and must
stay proposed until reviewed.

## Relationship Directionality Convention

**All relations in source artifacts are authoritative outgoing relations only.**

- Store only semantically active outgoing relationships in source artifact metadata.
- Incoming relationships are **derived** during generation, not manually maintained.
- This reduces duplication, maintenance effort, and inconsistency risk.

**Example:**
```yaml
# Authoritative (in ADR):
- type: introduces_risk
  target: R-001-example-risk
  status: proposed

# NOT in risk (reciprocal is derived, not stored):
# - type: depends_on
#   target: ADR-001-example-decision
```

The generator will automatically show that R-001 "is introduced by" ADR-001 in
-generated traceability views.

## Relationship Graph Structure

Architecture relationships should form a **DAG (directed acyclic graph)**. While cycles
are technically allowed by the generator (which uses iteration, not recursion) and won't
cause crashes, they are unusual and can indicate modeling issues. If cycles arise,
prefer using `affects` or explicitly documenting the cycle's breakpoints.

## Common Relation Semantics

- `addresses`: A decision or concept supports a requirement or quality scenario.
- `depends_on`: An artifact relies on another artifact being true (use for legitimate
hierarchical or dependency relationships, not as a reciprocal for other relation types).
- `constrains`: An artifact limits implementation or design choices.
- `refines`: An artifact makes another artifact more specific.
- `supersedes`: A newer artifact replaces an older artifact.
- `conflicts_with`: Two artifacts cannot both be fully satisfied as written.
- `mitigates`: A decision, concept, or action reduces a risk.
- `introduces_risk`: A decision or concept creates or increases a risk.
- `affects`: An artifact has relevant impact without a narrower relation.
- `verifies`: A test, scenario, or evidence checks an artifact.
- `documents`: A document describes an artifact.
- `relates_to`: Use only when no more specific relation is justified.

## Proposal Rules

- Prefer precise relation types over `relates_to`.
- Use existing artifact IDs as relation endpoints.
- Mark new or AI-suggested relations `status: proposed` and `reviewed: false`.
- Keep accepted relations unchanged unless the repository evidence justifies an
  update.
- **Never add reciprocal relations manually.** Incoming relations appear only in
  generated documentation, not in source metadata.

## Impact Rules

- Link a proposed ADR to quality scenarios it addresses or constrains.
- Link a proposed ADR to risks it introduces or mitigates.
- **Do NOT link artifacts back with `depends_on`** as a reciprocal for `introduces_risk`,
  `addresses`, or other directional relations. The risk or scenario's dependency on the
  decision is derived from the ADR's outgoing relation.
- Use `affects` when a relation is real but the direction or type needs review.

## Update Rules

- Update affected artifacts with new relations only when the source artifact's
  metadata owns outgoing relations and the impact is justified.
- If relation ownership is unclear, leave the affected artifact unchanged and
  include the proposed relation in the impact report.
- Preserve ordering conventions if the repository has them. Otherwise sort by
  relation type, target ID, then rationale.
- In YAML front matter, relation endpoints are artifact IDs. In visible
  documentation tables and prose, render those endpoints as anchor-based
  AsciiDoc `xref` links when the target document is available. Use the target
  document's explicit anchor rather than deriving the xref from a numbered
  chapter file name.
