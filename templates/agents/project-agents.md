Use this template for your `<project>/AGENTS.md`

# Project Agent Instructions

This project uses architecture-knowledge-toolkit for architecture work.

Apply instructions in this order:

1. User instruction
2. This project `AGENTS.md`
3. Relevant toolkit skill, for example `skills/bootstrap-project/SKILL.md`, `skills/adr/SKILL.md`, `skills/quality-scenario/SKILL.md`, or `skills/risk/SKILL.md`
4. Toolkit `general-semantic-contracts.md`

Use the toolkit for:

- product clarification
- arc42 documentation
- ADRs
- quality scenarios
- risks and technical debt
- runtime scenarios
- traceability metadata
- templates
- validation
- generated include fragments

Toolkit source of truth:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

Before creating or changing architecture content:

- inspect existing `src/docs/`, `metamodel/`, `templates/`, `scripts/`, and `skills/`
- preserve stable artifact IDs
- use AsciiDoc as the default documentation format
- mark AI-created architecture content as `draft` or `proposed`
- set `reviewed: false` unless human acceptance is already recorded
- do not manually maintain generated fragments when a generator exists
- copy missing toolkit templates, schemas, validators, and generator scripts from the toolkit instead of inventing alternatives
