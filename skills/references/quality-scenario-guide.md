# Quality Scenario Guide

Create a new quality scenario only when a decision introduces a measurable
quality concern that existing scenarios do not cover.

## Six-Part Scenario

Every quality scenario should include:

- Source of stimulus.
- Stimulus.
- Environment.
- Artifact.
- Response.
- Response measure.

## Response Measures

- Prefer measurable thresholds.
- Mark uncertain thresholds as assumptions.
- Do not turn aspirations into accepted requirements without review.
- If no threshold can be justified, write an open question instead of inventing
  a target.

## Relation Guidance

- Use `addresses` from an ADR to a quality scenario when the decision supports
  the scenario.
- Use `constrains` when the quality scenario limits the decision space.
- Use `depends_on` from a quality scenario to an ADR only when the scenario
  assumes that decision.
- Use `affects` from a risk to a quality scenario when the risk can threaten the
  scenario.

## Generated Matrices

- Keep impact and traceability relations in YAML front matter.
- Do not hand-author impact or traceability matrices in quality scenario source
  files.
- Add `=== Impact` and `=== Traceability` sections that include the generated
  `generated/<artifact-anchor>-impact.adoc` and
  `generated/<artifact-anchor>-traceability.adoc` fragments with
  `leveloffset=+2`; the generated fragments start with `== Matrix`.
