# Bootstrap Existing Artifacts Prompt

```text
Use the architecture-knowledge-toolkit to adapt this repository's existing
project artifacts into the toolkit architecture documentation structure.

If you have a local skill for this task, use it. If not, search for the skill in
the local architecture-knowledge-toolkit. If no local
architecture-knowledge-toolkit is available, search for a suitable skill in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

First inspect the existing repository artifacts, including README files,
existing architecture documents, ADRs, source code, build/deployment files,
tests, and diagrams. Treat them as evidence, not as automatically accepted
architecture truth.

Migrate or adapt the documentation to the toolkit structure:
- preserve existing useful claims only when supported by repository evidence;
- convert generic architecture.adoc or Markdown ADRs into toolkit AsciiDoc
  source artifacts where appropriate;
- create or update product canvases, vision/mission, roadmap, and Q&A;
- create the assembled architecture entry point and all arc42 chapter source
  files;
- identify missing ADR candidates, risks, quality scenarios, and runtime
  scenarios;
- add metadata and outgoing relations according to the toolkit metamodel.

Keep AI-created or AI-modified content draft or proposed with reviewed: false.
Do not manually maintain generated include files. Run the validation script with
--generate when the source artifacts are ready, and report remaining migration
gaps, assumptions, and human decisions.
```
