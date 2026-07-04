Use this template for local agent installation, like 

- `~/.vibe/AGENTS.md` or
- `~/.codex/AGENTS.md`
- ...

# Personal Agent Instructions

For software projects, inspect the repository before changing files.

If the repository contains `AGENTS.md`, follow it.
If the repository contains `.github/copilot-instructions.md`, respect it for GitHub Copilot-related work.
If the repository references `architecture-knowledge-toolkit`, use that toolkit as the source of truth for architecture documentation conventions, skills, templates, metamodel schemas, validators, and generators.

Do not duplicate toolkit rules into this global file.
Project-local instructions override this file.

If no local architecture instructions exist and the user asks for structured architecture documentation, propose bootstrapping the project with:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit
