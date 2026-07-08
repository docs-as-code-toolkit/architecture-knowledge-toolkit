# Demo Script

## Goal

Show the architecture-knowledge-toolkit as a working environment for
AI-assisted architecture work, not as a generic template repository.

## Primary Demo Path

1. Open the repository root and start from `README.md`.
2. Show the contract stack:
   - `general-semantic-contracts.md`
   - `AGENTS.md`
   - `skills/adr/SKILL.md`
3. Explain that the repository stays the source of truth. The chat is advisory
   until reviewed and committed.
4. Use this example question:
   - Should an application expose an open REST API for external systems?
5. Open the ADR skill and point out the expected structure:
   - context
   - decision drivers
   - options
   - Pugh matrix
   - decision
   - consequences and risks
6. Open an ADR template or existing ADR in `src/docs/arc42/09-architecture-decisions/`.
7. Show how metadata and relations make the artifact traceable.
8. Run or describe:
   - `ruby scripts/validate-metamodel.rb`
   - `ruby scripts/validate-metamodel.rb --generate`
   - `./build.sh build`
9. Show that generated documentation is derived output, not the editing surface.
10. Close the demo with the separation of concerns:
    - docToolchain publishes
    - docs-toolbox builds
    - architecture-knowledge-toolkit structures architecture work

## Fallback Path

If live execution is risky, avoid editing during the meetup. Show prepared
artifacts instead:

1. A skill file.
2. A semantic contract excerpt.
3. One existing ADR or a prepared ADR draft.
4. A validation command and expected kind of feedback.
5. A generated or rendered documentation view.

## Demo Risks

- Do not spend too much time explaining repository internals.
- Keep the example architecture question simple.
- Avoid presenting validation as a replacement for human review.
- Be explicit that the toolkit is a direction and working skeleton, not a
  finished architecture platform.
