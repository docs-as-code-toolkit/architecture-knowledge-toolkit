# OpenCode Adapter

OpenCode-specific integration for the architecture-knowledge-toolkit. Keep
architecture semantics engine-independent in `skills/` and
`general-semantic-contracts.md`.

OpenCode natively implements the Agent Skills standard (native `skill` tool,
`SKILL.md` discovery, `permission.skill` gating). Unlike Pi, it has no config
array to point at an external skills dir, so we reference the toolkit via a
symlink farm (see `install-skills.sh`).

## Native skill loading

Run `./install-skills.sh` so OpenCode's skill tool discovers the toolkit's
exposed skills:

```bash
./install-skills.sh           # ~/.config/opencode/skills
./install-skills.sh --agents  # ~/.agents/skills (shared: pi/Claude/OpenCode)
```

The script skips helper skills (`adapter_expose: false`) and non-skill dirs.
All toolkit skill names already match their directory names (required by
OpenCode), so no renames are needed. Re-run the installer after a toolkit
update, and pin a stable toolkit tag for a reproducible setup.

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
