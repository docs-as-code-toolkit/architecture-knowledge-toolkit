# OpenCode Adapter

OpenCode-specific integration for the architecture-knowledge-toolkit. Keep
architecture semantics engine-independent in `skills/` and
`general-semantic-contracts.md`.

OpenCode natively implements the Agent Skills standard (native `skill` tool,
`SKILL.md` discovery, `permission.skill` gating). Unlike Pi, it has no config
array to point at an external skills dir, so we reference the toolkit via a
symlink farm.

## Native skill loading

OpenCode reads `SKILL.md` from `.agents/skills` (and `.claude/skills`). Install
the toolkit's skills there with the shared installer:

```bash
../shared/install-skills.sh        # default: ~/.agents/skills (OpenCode, pi)
../shared/install-skills.sh claude # ~/.claude/skills (also read by OpenCode)
```

See `../shared/README.md` for usage, targets, and caveats.

## Permissions example

Gate skills in `opencode.json`; e.g. allow read-only review skills, ask before
build/generator ones:

```json
{
  "permission": {
    "skill": {
      "pr-review": "allow",
      "traceability-review": "allow",
      "build-*": "ask"
    }
  }
}
```

## Adapter Boundary

Do not duplicate ADR, quality scenario, risk, traceability, metadata, or arc42
rules here. Agent-specific files may only wrap, point to, or invoke the
canonical sources.
