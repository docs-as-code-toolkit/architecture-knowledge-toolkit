# Risk Assessment Skill

## Purpose

Help identify and structure architecture risks. This skill supports review and
prioritization; it does not decide risk acceptance.

## Inputs

- Architecture context.
- Decisions, components, interfaces, constraints, or quality scenarios.
- Known incidents, assumptions, or uncertainties.
- Existing risk IDs where available.

## Output

Produce risk entries based on `../../templates/risk.adoc` when invoked from
this skill directory, or `templates/risk.adoc` from the repository root, with:

- Stable proposed IDs.
- Clear cause, event, and impact.
- Qualitative likelihood and impact assessments.
- Mitigation options.
- Owner and review status.
- Suggested relations to affected artifacts.

## Rules

- Separate risks from issues and decisions.
- Call out uncertainty explicitly.
- Avoid false precision in likelihood, impact, or priority; use qualitative ratings.
- Mark AI-suggested risks as `proposed` until reviewed.
- Prefer actionable mitigations.
- Use YAML front matter conforming to `metamodel/artifact.schema.yaml` and
  relation types from `metamodel/relations.schema.yaml` for standalone risk
  artifacts.
- Use AsciiDoc anchors that start with a lowercase letter and contain only
  lowercase letters, digits, and hyphens.
- Use explicit `xref` links for visible references to documents included in the
  same assembled documentation set.

## Review Checklist

- The risk statement is specific.
- Impact is tied to architecture outcomes.
- Mitigations are realistic and owned.
- Relations use stable artifact IDs.
