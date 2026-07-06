Use this template for local agent installation, like 

- `~/.vibe/AGENTS.md` or
- `~/.codex/AGENTS.md`
- ...

# Personal Agent Instructions

For software projects, inspect the repository before changing files.

If the repository contains `AGENTS.md`, follow it.
If the repository contains `.github/copilot-instructions.md`, respect it for GitHub Copilot-related work.
If the repository references `architecture-knowledge-toolkit`, use that toolkit
as the source of truth for architecture documentation conventions,
software-development-lifecycle task guidance, skills, templates, metamodel
schemas, validators, and generators.

For any SDLC task that is not explicitly described in the local repository,
look up the corresponding architecture-knowledge-toolkit skill or contract
before acting. This includes issue slicing, issue implementation, commit
messages, pull request reviews, ADRs, quality scenarios, risks, traceability
reviews, and architecture documentation updates.

If the architecture-knowledge-toolkit is not available on the local filesystem,
use the public repository as the fallback source of truth:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

Prefer a stable toolkit reference, such as a release tag or commit SHA, when a
project records a long-lived dependency on the public repository.

Do not duplicate toolkit rules into this global file.
Project-local instructions override this file.

If no local architecture instructions exist and the user asks for structured architecture documentation, propose bootstrapping the project with:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit
