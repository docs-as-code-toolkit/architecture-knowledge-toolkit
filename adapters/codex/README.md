# Codex Adapter

This directory is reserved for Codex-specific integration.

Keep this adapter thin. Reusable architecture knowledge, templates, schemas, and
skills should remain engine-independent whenever possible. Codex-specific files
may include invocation examples, local configuration, or wrappers that translate
Codex workflows into the repository conventions.

Adapter responsibilities:

- Point Codex at engine-independent skills in `skills/`.
- Preserve the policy that AI output is a suggestion until reviewed.
- Avoid embedding Codex assumptions into shared templates or schemas.
- Keep generated output deterministic when invoking future generators.

