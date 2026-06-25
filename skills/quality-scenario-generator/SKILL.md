# Quality Scenario Generator Skill

## Purpose

Help draft measurable quality scenarios for architecture work. Scenarios should
be concrete enough to review, prioritize, and trace to decisions or risks.

## Inputs

- Quality attribute, such as performance, availability, modifiability, security,
  usability, interoperability, or operability.
- Stakeholder or user group.
- System context.
- Stimulus, environment, response, and response measure if known.
- Related artifact IDs.

## Output

Produce an AsciiDoc quality scenario based on
`templates/quality-scenario.adoc` with:

- A stable proposed ID.
- Quality attribute.
- Source of stimulus.
- Stimulus.
- Environment.
- Artifact or system element.
- Response.
- Response measure.
- Suggested traceability relations.

## Rules

- Prefer measurable response criteria over vague goals.
- Mark uncertain values as assumptions.
- Do not turn aspirations into accepted requirements without review.
- Keep generated scenarios concise and testable.

## Review Checklist

- The response measure can be evaluated.
- The environment is explicit.
- The scenario has an accountable owner.
- Relations to ADRs, risks, and requirements are explicit.

