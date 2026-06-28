# Relation Rules

Use explicit metadata relations for traceability. Relations are claims and must
stay proposed until reviewed.

## Common Relation Semantics

- `addresses`: A decision or concept supports a requirement or quality scenario.
- `depends_on`: An artifact relies on another artifact being true.
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
- Do not add reciprocal relations automatically. Add them only if the repository
  convention or validator expects them.

## Impact Rules

- Link a proposed ADR to quality scenarios it addresses or constrains.
- Link a proposed ADR to risks it introduces or mitigates.
- Link new risks back to the ADR with `depends_on` when the risk exists because
  of that decision.
- Link new quality scenarios back to the ADR with `depends_on` only when the
  scenario assumes the decision.
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
