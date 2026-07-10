# Risk Writing Guide

Create new risk artifacts only when the decision creates or changes a risk that
is not already covered by an existing risk.

## Risk Statement

Use cause, event, and impact:

`Because <cause>, <event> may occur, leading to <impact>.`

## Assessment

- Use qualitative likelihood and impact.
- Add qualitative priority when the repository uses priority.
- Avoid false precision.
- State confidence when the evidence is incomplete.

## Mitigation

- Prefer actionable mitigations with owners.
- Link mitigations to concepts, ADRs, quality scenarios, tests, or operational
  controls when those artifacts exist.
- Do not mark a risk accepted unless human acceptance is already recorded.

## Relation Guidance

- Use `depends_on` from the risk to the ADR when the risk exists because of the
  decision.
- Use `affects` from the risk to a quality scenario when the risk threatens the
  scenario.
- Use `mitigates` from an ADR or concept to a risk when it reduces the risk.

## Generated Matrices

- Keep impact and traceability relations in YAML front matter.
- Do not hand-author impact or traceability matrices in risk source files.
- Add `=== Impact` and `=== Traceability` sections that include the generated
  `generated/<artifact-anchor>-impact.adoc` and
  `generated/<artifact-anchor>-traceability.adoc` fragments with
  `leveloffset=+2`; the generated fragments start with `== Matrix`.
