# Bootstrap Greenfield Prompt

```text
Use the architecture-knowledge-toolkit to bootstrap architecture documentation
for a new project.

If you have a local skill for this task, use it. If not, search for the skill in
the local architecture-knowledge-toolkit. If no local
architecture-knowledge-toolkit is available, search for a suitable skill in
https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit.

Project idea:
<project idea>

Create the initial architecture documentation in the toolkit structure:
- product canvases, vision/mission, roadmap, and Q&A;
- an assembled architecture entry point and all arc42 chapter source files;
- proposed ADRs with Pugh matrices where decisions are already visible;
- quality goals and measurable quality scenarios;
- initial risks and runtime scenarios;
- metadata and outgoing relations according to the toolkit metamodel.

Keep all AI-created content draft or proposed with reviewed: false. Do not
invent generated output manually. Run the validation script with --generate when
the source artifacts are ready, and report assumptions, open questions, and
required human decisions.
```
