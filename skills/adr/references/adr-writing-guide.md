# ADR Writing Guide

Write ADRs as review-ready proposals, not as accepted decisions.

## Content

- State the problem and forces before the decision.
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

## Consequences

- Positive consequences describe what the decision enables.
- Negative consequences describe costs, risks, coupling, and operational burden.
- Neutral or follow-up consequences describe work that must be decided later.
- Reference risk IDs when a consequence is tracked as a risk.

## Review Notes

End with review notes that state what must be confirmed before acceptance. Keep
review notes concrete: owners, thresholds, operational evidence, team decisions,
or unresolved trade-offs.
