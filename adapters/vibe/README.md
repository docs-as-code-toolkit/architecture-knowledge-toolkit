# Vibe Adapter

This directory is reserved for Vibe-specific integration.

Keep this adapter thin. Reusable architecture knowledge, templates, schemas, and
skills should remain engine-independent whenever possible. Vibe-specific files
may include invocation examples, local configuration, or wrappers that translate
Vibe workflows into the repository conventions.

Adapter responsibilities:

- Point Vibe at engine-independent skills in `skills/`.
- Preserve the policy that AI output is a suggestion until reviewed.
- Avoid embedding Vibe assumptions into shared templates or schemas.
- Keep generated output deterministic when invoking future generators.

