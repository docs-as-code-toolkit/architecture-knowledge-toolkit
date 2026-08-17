# Pi Adapter

Pi-specific integration for the architecture-knowledge-toolkit. Keep
architecture semantics engine-independent in `skills/` and
`general-semantic-contracts.md`.

Pi implements the [Agent Skills standard](https://agentskills.io/specification)
natively: it injects each skill's name/description into the system prompt and
loads the full `SKILL.md` on demand, invocable as `/skill:<name>`.

## Wire the toolkit into Pi

**A. Routing adapter (default).** Point Pi at this directory's generated
`AGENTS.md`; it routes to the canonical skills via the same contract as the
other harnesses.

**B. Native skill loading.** Two ways, both referencing (not copying) the
canonical skills and enabling auto-discovery + `/skill:<name>`:

1. **Via `settings.json`** — register the toolkit's `skills/` directory in
   `~/.pi/settings.json` (or project `.pi/settings.json`):

   ```json
   {
     "skills": ["/path/to/architecture-knowledge-toolkit/skills"]
   }
   ```

2. **Via the shared installer** — since Pi reads `.agents/skills`, run the
   installer (defaults to the project's `.agents/skills`; see
   `../shared/README.md`):

   ```bash
   ../shared/install-skills.sh
   ```

Caveats:

- Pi ignores `adapter_expose`, so either approach surfaces helper skills too
  (currently `grilling`); prefer a curated wrapper.
- Pin a stable toolkit tag rather than `main` for a reproducible setup.
- The contract reading order (relevant skill, `AGENTS.md`,
  `general-semantic-contracts.md`) still applies.

## Adapter Boundary

Do not duplicate ADR, quality scenario, risk, traceability, metadata, or arc42
rules here. Agent-specific files may only wrap, point to, or invoke the
canonical sources.
