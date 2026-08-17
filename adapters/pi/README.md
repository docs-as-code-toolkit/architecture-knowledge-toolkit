# Pi Adapter

This directory is reserved for Pi-specific integration.

Keep this adapter thin. Reusable architecture knowledge, templates, schemas, and
skills should remain engine-independent whenever possible. Pi-specific files may
include invocation examples, local configuration, or wrappers that translate Pi
workflows into the repository conventions.

Pi implements the [Agent Skills standard](https://agentskills.io/specification)
natively. It discovers `SKILL.md` packages from `~/.agents/skills/`,
`~/.pi/agent/skills/`, project `.agents/skills/` / `.pi/skills/`, packages, or
the `skills` array in `settings.json`. At startup Pi injects each skill's name
and description into the system prompt and loads the full `SKILL.md` on demand
via `read`, and each skill is invocable as `/skill:<name>`.

## Two supported ways to wire the toolkit into Pi

### A. Routing adapter (default, like every other harness)

Point Pi at this directory's generated `AGENTS.md`. Pi reads repository-root
`AGENTS.md` and `general-semantic-contracts.md`, then selects and reads the
relevant canonical skill from the generated list. This mirrors the Codex, Vibe,
and GitHub Copilot adapters exactly and keeps Pi on the same routing contract.

### B. Pi-native auto-load (reference, don't copy)

Pi's native discovery can surface the canonical skills automatically, without
copying them, by registering the toolkit's `skills/` directory:

```json
// ~/.pi/settings.json (or project .pi/settings.json)
{
  "skills": ["/path/to/architecture-knowledge-toolkit/skills"]
}
```

Pi still references the canonical `SKILL.md` files in place, so content stays in
the toolkit and never drifts. This gives you automatic discovery and
`/skill:<name>` commands while keeping the toolkit as the single source of
truth.

## Auto-load caveats

- **Reference, don't copy.** Register the toolkit `skills/` directory path or a
  curated wrapper that points back to it. Do not copy `skills/**/SKILL.md`
  into the consuming project or into global Pi skill locations; copies drift.
- **Pi ignores `adapter_expose`.** Pi has no notion of the toolkit's
  `adapter_expose: false` marker, so registering the whole `skills/` directory
  surfaces helper skills too (currently `grilling`) that the generated routing
  adapter deliberately omits. Prefer a curated wrapper directory that selects
  only the intended skills.
- **Context/token footprint.** Auto-loading injects every skill's description
  into the Pi system prompt each session. Keep registered skill descriptions
  concise, or use a curated wrapper list, to avoid permanent system-prompt
  overhead (relevant to the toolkit's GreenIT-aware guidance).
- **Pin a stable version.** Favor a release tag or commit SHA for a long-lived
  Pi setup so the auto-loaded reference is reproducible, rather than pointing at
  the toolkit's moving `main` branch.
- **Contract order still governs.** Native auto-loading only changes discovery;
  the reading order (user instruction, relevant skill, `AGENTS.md`,
  `general-semantic-contracts.md`) and the "smallest relevant satellite skill"
  selection still apply.

## Adapter Boundary

Do not duplicate ADR, quality scenario, risk, traceability, metadata, or arc42
rules here. Agent-specific files may only wrap, point to, or invoke the
canonical sources.
