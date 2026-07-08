---
name: architecture-core
description: Apply the architecture-knowledge-toolkit baseline for architecture documentation, traceability, metadata, quality scenarios, risks, ADRs, and adapter boundaries. Use before architecture-sensitive work or when creating derived agent adapters from canonical skills.
---

# Architecture Core Skill

## Purpose

Keep architecture-knowledge-toolkit semantics engine-independent. This skill is
the canonical entry point for architecture-sensitive agent work and for thin
agent adapter generation.

Apply the repository contract hierarchy: user instruction, relevant
`skills/**/SKILL.md`, `AGENTS.md`, then `general-semantic-contracts.md`.
Architecture semantics belong in `skills/**/SKILL.md` and
`general-semantic-contracts.md`; agent-specific files under `adapters/**` only
wrap, route, or point to those sources.

## Core Workflow

1. Read `../../general-semantic-contracts.md` and `../../AGENTS.md` before
   changing architecture content, skills, adapters, templates, schemas, or
   generators.
2. Select the smallest relevant satellite skill for the task, such as
   `../adr/SKILL.md`, `../quality-scenario/SKILL.md`, `../risk/SKILL.md`,
   `../slice-issues/SKILL.md`, or `../traceability-review/SKILL.md`.
3. Use repository source files as the source of truth.
4. Keep AI-created or AI-modified architecture content draft or proposed unless
   human acceptance is already recorded.
5. Preserve stable IDs, explicit anchors, metadata relations, and generated
   output boundaries.
6. Keep agent-specific integration in `adapters/**`.
7. Run the repository validator and any adapter drift checks after edits when
   available.

## Adapter Boundary

Generated or hand-written agent adapters may:

- point to canonical skills and general contracts;
- describe how a specific agent loads or invokes those sources;
- include minimal, engine-specific routing or file-location details;
- declare that architecture semantics are governed elsewhere.

Agent adapters must not:

- duplicate ADR, quality scenario, risk, traceability, metadata, or arc42 rules;
- introduce engine-specific assumptions into canonical skills or contracts;
- replace reviewed source content with generated adapter content;
- silently diverge from canonical skills.

## GreenIT-aware agent work

When the user explicitly asks for GreenIT, token footprint, agent efficiency, or
repeated context loading, agents may use selected external Honey skills from
`Green-PT/honey-for-devs`:

- `honey-eco` for token/CO2/session-footprint reporting
- `honey-memory` for stable project memory
- `honey-compress` for frequently loaded prose context files

These skills are operational helpers only. They must not override
architecture-knowledge-toolkit semantics, ADR structure, quality scenario
requirements, risk documentation, or traceability rules.

Do not apply external compression to ADR rationale, quality scenarios, risk
descriptions, stakeholder requirements, code, configuration, schemas, generated
data, security directives, migration directives, authentication directives,
money-related directives, or delete-related directives.

## Validation

Run the metamodel validator after architecture edits when available. Run
`node scripts/check-agent-adapters.js` after changing canonical skills or
generated adapter files.
