# ADR Writing Guide

Write ADRs as review-ready proposals, not as accepted decisions.

## Content

- Use the ADR title for the decision topic or underlying question, not for the
  selected option.
- Place the `== Decision` section directly after the status block.
- State the problem and forces clearly in the context. The `Decision` section
  still appears directly after status as the short answer for reviewers.
- Add `derived_from` metadata when the ADR originated from a specific input
  question, prompt, external document, repository path, or other source. Link to
  an existing question anchor or URL when available; otherwise record a concise
  textual origin note.
- When provenance should be visible in the ADR body, include the generated
  metadata attribute fragment before the `ifdef::derived_from_description[]`
  block and render `{derived_from_description}`.
- Represent options fairly.
- Include positive, negative, and neutral consequences.
- Call out assumptions and open questions.
- Use repository vocabulary and stable IDs.
- Keep the decision narrow enough to review.

## Decision Status

- Use `status: proposed` for AI-created ADRs.
- Write `== Status` as `Proposed.`.
- Use accepted wording only when human acceptance is already recorded.
- Say "We propose to..." instead of "We will..." for proposed ADRs.

## Options

Include at least two realistic alternatives unless the decision is explicitly a
constraint. Include a 3-point Pugh matrix when there are multiple options. Use
`+1` for better support, `0` for neutral support, and `-1` for weaker support.
Use `?` instead of guessing when the team must assess a criterion.
Add a `Sum` row to every Pugh matrix. Sum each option column manually. If any
cell in an option column is `?`, write `?` as that option's sum until the team
resolves the open assessment.
Mark Pugh matrix tables with the `.pugh-matrix` role. Emphasize the `Sum` row
with strong table cells, for example `s| Sum s| ? s| 0 s| ?`, so the source
stays portable and renderers can add theme-specific styling later.

## Consequences

- Positive consequences describe what the decision enables.
- Negative consequences describe costs, risks, coupling, and operational burden.
- Neutral or follow-up consequences describe work that must be decided later.
- Reference risk IDs when a consequence is tracked as a risk.

## Generated Matrices

- Keep impact and traceability relations in YAML front matter.
- Do not hand-author impact or traceability matrices in ADR source files.
- Add `=== Impact` and `=== Traceability` sections that include the generated
  `generated/<artifact-anchor>-impact.adoc` and
  `generated/<artifact-anchor>-traceability.adoc` fragments with
  `leveloffset=+2`; the generated fragments start with `== Matrix`.

## Review Notes

End with review notes that state what must be confirmed before acceptance. Keep
review notes concrete: owners, thresholds, operational evidence, team decisions,
or unresolved trade-offs.
