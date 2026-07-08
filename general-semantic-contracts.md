## Contract Model <!-- omit from toc -->

This file is the engine-agnostic project contract. It describes how software
projects should be clarified, built, documented, validated, reviewed, and
evolved, whether the work is done by people, deterministic generators, or AI
assistants.

Agent adapters and skills build on this contract:

1. `general-semantic-contracts.md` defines the shared project rules.
2. `AGENTS.md` adapts those rules for automated contributors.
3. `skills/**/SKILL.md` narrows or extends the rules for one task.

When rules conflict, the more specific scope wins: user instruction,
`SKILL.md`, `AGENTS.md`, then this file. More specific files should reference
this contract instead of copying whole sections, so the project keeps one
maintained source for general rules.

These contracts are product assets. They are useful even without AI because
they make architecture, documentation, traceability, quality, and delivery
expectations explicit and reviewable.

## Table of Content <!-- omit from toc -->
- [New projects](#new-projects)
- [Using this toolkit as a dependency](#using-this-toolkit-as-a-dependency)
- [Specification](#specification)
- [Requirements Elicitation](#requirements-elicitation)
- [Architecture Documentation](#architecture-documentation)
  - [arc42](#arc42)
  - [Documenting Decisions](#documenting-decisions)
  - [Cross-Referencing: Static docs as architecture knowledge base](#cross-referencing-static-docs-as-architecture-knowledge-base)
- [Cross-cutting concepts](#cross-cutting-concepts)
- [Layer boundaries](#layer-boundaries)
- [Backlog Management](#backlog-management)
- [Vertical Slicing](#vertical-slicing)
- [Next, implement](#next-implement)
- [Refactoring](#refactoring)
- [Code quality](#code-quality)
- [Quality Assurance](#quality-assurance)
- [Docs-as-Code](#docs-as-code)
- [Socratic Code Theory Reconstruction](#socratic-code-theory-reconstruction)
- [Collaboration](#collaboration)
  - [Concise answer (TLDR)](#concise-answer-tldr)
  - [Simple explanation (ELI5)](#simple-explanation-eli5)
  - [Explaining and Teaching](#explaining-and-teaching)
- [Writing style](#writing-style)
- [TDD, Hamburg-style](#tdd-hamburg-style)
- [Strategic Architecture Analysis](#strategic-architecture-analysis)


## New projects

When we start a new project, we need to know the purpose of this project. Therefore we like to have a first version of the following canvases filled out:

- [Business Model Canvas (BMC)](https://www.strategyzer.com/library/the-business-model-canvas)
- [Value Proposition Canvas (VPC)](https://www.strategyzer.com/library/the-value-proposition-canvas)

Based on that a vision and mission statement can be created, which is then used to create a product roadmap.

Treat every canvas as a living document, which is updated as the project evolves. The canvases are not a replacement for a PRD, but they help to clarify the purpose of the project and to align the team on the goals.

Write every canvas as a single asciidoc file below src/docs/canvas/, with a unique anchor for each canvas. For example, the BMC is written in [`src/docs/canvas/canvas-001-business-model.adoc`](/src/docs/canvas/canvas-001-business-model.adoc) and has the anchor `business-model-canvas`, so that it can be referenced from other documents as `xref:business-model-canvas[]`.

Place the vision and mission statement in [`src/docs/doc-002-vision-mission.adoc`](/src/docs/doc-002-vision-mission.adoc) with the anchor `vision-mission`. Place the roadmap in `src/docs/doc-004-roadmap.adoc` with the anchor `roadmap`. The roadmap is a living document, which is updated as the project evolves.

Based on that information, we fill out further canvases, as the [Architecture Inception Canvas](https://canvas.arc42.org/architecture-inception-canvas) and the [https://canvas.arc42.org/architecture-communication-canvas](https://canvas.arc42.org/architecture-communication-canvas). Finally, we also like to have the [Techstack Canvas](https://techstackcanvas.io/) filled out, which is a living document that is updated as the project evolves.

Place every canvas in `src/docs/canvas/` with a unique anchor for each canvas, so that it can be referenced from other documents.

Use [`src/docs/doc-005-questions-and-answers.adoc`](/src/docs/doc-005-questions-and-answers.adoc) as the central discussion document for
open and answered questions that guide product clarification, canvas work, and
architecture documentation. Keep questions MECE (Mutually Exclusive, Collectively Exhaustive) and ask no more than 3 questions
at a time. Keep asking questions until you have fully understood the purpose of
the project. The Q&A document keeps the stable anchor
`canvas-questions-and-answers` for compatibility. Every question must have a
unique asciidoc anchor. Every source document that refers to a question must
link to the question with `xref:` and the explicit question anchor. For example,
the BMC question about the key partners is placed in the Q&A file with the
anchor `bmc-key-partners` and linked as `xref:bmc-key-partners[]`.
Include `src/docs/doc-005-questions-and-answers.adoc` from
`src/docs/arc42/doc-13000-appendix.adoc` so open and answered questions are part of the
assembled architecture documentation. Keep the Q&A document itself free of YAML
front matter unless the project explicitly promotes questions to first-class
architecture artifacts; otherwise the appendix carries the standalone artifact
metadata.

Apply the Docs-as-Code Toolkit philosophy `Write once. Publish everywhere.` in
two ways: publish the same source documentation to different target formats, and
author repeated documentation content once as a reusable AsciiDoc source
fragment. Include reusable fragments with `include::[]` where the same business
value, definition, constraint, or other content belongs in multiple places.
Keep reusable source fragments separate from generated fragments: source
fragments are reviewed source content, while generated fragments are derived
output and must not become the primary editing surface. Fragments must be safe
for supported target formats and should avoid fixed heading-level assumptions,
environment-specific paths, and formatter-specific behavior unless those
constraints are explicit inputs.

## Using this toolkit as a dependency

When a target project references the architecture-knowledge-toolkit, use the
target project's local instructions first. If an architecture or
software-development-lifecycle task is not explicitly described in that project,
consult the corresponding toolkit contract or skill before acting.

Lookup order for missing toolkit guidance is:

1. local project instructions and copied toolkit files;
2. organization-specific or pinned toolkit copy, when available;
3. public architecture-knowledge-toolkit repository as fallback.

This applies to product clarification, arc42 documentation, ADRs, quality
scenarios, risks, runtime scenarios, traceability metadata, issue slicing, issue
implementation, commit messages, pull request reviews, post-merge
synchronization, documentation validation, generation, and related maintenance
tasks.

Do not duplicate the full toolkit rule set into consuming projects or global
agent profiles. Local project instructions should point back to this toolkit as
the source of truth for missing conventions, skills, templates, metamodel
schemas, validators, and generators.

If the architecture-knowledge-toolkit is not available on the local filesystem,
use the public repository as the fallback source of truth:

https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit

Prefer a stable toolkit reference, such as a release tag or commit SHA, when a
project records a long-lived dependency. Example:
`docs-as-code-toolkit/architecture-knowledge-toolkit@v1.2.3`.

## Specification

When we refer to a ‘specification’ or ‘spec’, we mean:
- Persona use cases in the ‘Fully Dressed’ format as defined by Cockburn (primary actor, trigger, main success scenario, extensions, post-conditions) at the level of user goals, with business rules (BR-IDs)
- System use cases for each technical interface (API endpoint, CLI command, event, file format): input/validation, processing, output/status codes, error responses
- Activity diagrams for all workflows (not just the happy path)
- Acceptance criteria in Gherkin format (Given/When/Then)
- Individual requirements in EARS syntax, where applicable (When/While/If/Shall)
- Supplementary specifications as required: entity model, state machines, interface contracts, validation rules

## Requirements Elicitation

Clarify requirements using the Socratic method:
- Ask no more than 3 questions at a time; challenge assumptions
- Use MECE to ensure that the questions cover all areas without overlapping
- Keep asking questions until you have fully understood the requirements

Define the scope before documenting it:
- Impact mapping links outcomes to business objectives and stakeholders – this enables you to develop what drives an objective forward, rather than just what has been requested.
- User Story Mapping organises stories along the user journey and highlights a coherent initial snapshot.

Document the outcome as a PRD (Problem, Objectives, Personas, Success Criteria, Scope).

## Architecture Documentation

The following sections describe the architecture documentation.

### arc42

The architecture documentation follows arc42. Use the templates from https://github.com/arc42/arc42-template/raw/master/dist/arc42-template-DE-withhelp-asciidoc.zip and place them in `src/docs/`, rather than reproducing the chapter structure here – the help text for each chapter serves as its structural specification, which the process fills in and subsequently replaces.
For each chapter, create a subfolder with the chapter’s name, within a file is created for each aspect, following the template for that chapter.
Chapter main pages keep stable metadata, an explicit anchor, and a concise
chapter summary. Navigation should use native AsciiDoc `:toc:` behavior rather
than hand-written tables of links. Chapter main pages should include one
generated chapter include fragment instead of manually listing every detail
document. The generated fragment is derived output, sorted by artifact ID, and
is regenerated whenever source artifacts change. Do not manually maintain
chapter detail include lists in reviewed source files.
Generated index fragments, such as ADR, quality scenario, and risk indexes,
should be included directly where they belong. Do not create reviewed source
wrapper documents whose only purpose is to include generated index output.
Every standalone arc42 source document, including chapter pages and detail
pages, uses YAML front matter that conforms to `metamodel/artifact.schema.yaml`.
Use `type: Document` unless a more specific supported artifact type applies.
The filename of every standalone source artifact or standalone AsciiDoc
document with an `:id:` attribute must match its stable artifact ID: lowercase
the `id`, replace non-alphanumeric separators with `-`, trim leading and
trailing dashes, and add `.adoc`. For example,
`DOC-09000-architecture-decisions` is stored as
`doc-09000-architecture-decisions.adoc`, and
`ADR-001-asciidoc-primary-source` is stored as
`adr-001-asciidoc-primary-source.adoc`. Do not add a second title or chapter
number to the filename.
DOC artifact IDs inside arc42 use decimal classification without dot
separators. The first two digits are the structural directory or arc42 chapter
number, and the last three digits are the local sequence inside that class.
Chapter overview documents use local sequence `000`, for example
`DOC-01000-introduction-and-goals`. Detail documents inside a numbered chapter
directory start at `001`, for example
`DOC-01001-quality-goals` in `src/docs/arc42/01-introduction-and-goals/` and
`DOC-02001-documentation-constraints` in
`src/docs/arc42/02-architecture-constraints/`. Artifact types with their own
classification, such as ADRs, quality scenarios, and risks, keep their own ID
schemes and are ordered by their chapter location.
Traceability between arc42 source documents is captured in `relations` using
stable artifact IDs and relation types from `metamodel/relations.schema.yaml`.
Render AsciiDoc sources with YAML front matter using the Asciidoctor
`skip-front-matter` attribute so metadata does not appear in published output.
Reusable source fragments that are included directly into other AsciiDoc files
do not receive YAML front matter; otherwise their metadata would render as
content. Their including standalone documents carry the metamodel metadata.
AsciiDoc anchors must start with a lowercase letter and contain only lowercase
letters, digits, and hyphens. Digits are used only when they are part of a
stable artifact identifier, such as `adr-001`, not for chapter ordering. Use
explicit anchors from source files as the source of truth for generated links.
When deriving anchors from file names, remove numeric ordering prefixes such as
`09-` before normalizing spaces and punctuation, and never use an anchor with
spaces inside `[[...]]` or `[#...]`.
Every visible reference to a document that is included in the assembled arc42
documentation uses an explicit `xref` to that document's anchor. Canvas files
remain source inputs for arc42 drafts and are referenced by repository path
unless they become part of the assembled arc42 documentation set.
Each chapter on context, building blocks and runtime contains at least one diagram.
Diagrams are created in PlantUML, not in Mermaid; for building blocks, C4 is used via the standard C4-PlantUML library integrated into PlantUML – in the form `!include <C4/...>` (pointy brackets), never via the remote URL `https://` and never via supplied file copies. No generic boxes.

### Documenting Decisions

Decisions are ADRs (Nygard) with a 3-point Pugh matrix (-1/0/+1). ADR titles
name the decision topic or underlying question, not the selected option; the
actual decision statement appears in the `Decision` section directly after the
status block. If the rationale is derived but not yet confirmed by a human
reviewer, the ADR status is `Proposed (derived)`, and Pugh cells requiring
assessment by the team are marked with `?` rather than making an assumption.
Every Pugh matrix includes a `Sum` row. For each option column, add the numeric
cells manually; if any cell in that option column is `?`, the sum for that
option is also `?` until the open assessment is resolved. Only human-reviewed
decisions may become `Accepted` or `Accepted (derived)`. The ‘consequences’ of
each ADR identify the risks associated with the decision, referencing the risk
IDs from Chapter 11 (R-NNN); a decision that creates a risk not yet listed in
Chapter 11 either adds it there or notes the consequence as explicitly
accepted, without tracking the risk. Conversely, concepts from Chapter 8 refer
back to the ADR that adopted them.

### Cross-Referencing: Static docs as architecture knowledge base

Cross-sectional traceability – arc42 templates do not enforce this, so the contract does:
- Each quality objective from Chapter 1.2 is assigned to a named approach in Chapter 4.
- The external systems in Chapter 3 (Context) and the Level 1 building block view in Chapter 5 form the same set – each representing a system boundary in both.
- Every building block from Chapter 5 appears in at least one runtime scenario from Chapter 6; Chapter 6 contains at least one failure/recovery scenario, not just the ‘happy path’.
- Chapter 9 contains an internal ADR index (ADR | Title | Status), even though the ADRs are listed in a separate register.
- Each building block from Chapter 5 specifies the responsibility, the interface and the storage location.
- Every building block affected by one of the other chapters contains a link to the relevant document under the heading of the corresponding chapter, with the heading ‘Affected by …’
  Chapter 1.2 lists only the 3–5 most important quality objectives – those that determine architectural decisions. Chapter 10 may elaborate on further quality characteristics beyond these top-level objectives; this is correct, arc42, and not an error. The quality tree in Chapter 10 identifies each attribute either as a concretisation of a top-level objective from Chapter 1.2 or as a derived quality requirement, and every quality scenario in Chapter 10 refers back to the objective from Chapter 1.2 that it concretises (or is marked as ‘derived’).
  Each scenario in Chapter 10 is written in the six-part format for quality attribute scenarios (source, stimulus, artefact, environment, response, response measure); the response measure contains a specific value, so that the requirement is testable and does not consist solely of an adjective. Draft scenarios may mark uncertain values as assumptions, but final arc42 documentation must not treat assumed or invented target values as answered evidence.

Chapter 11 divides risks and technical debt into two subsections. Each risk is assigned a qualitative probability, a qualitative impact, a derived qualitative priority and a mitigation/action, which refers to an existing mitigation in Chapter 8 or, where applicable, to a quality scenario; the risks are ordered by priority. Each item of technical debt refers to the specific building block from Chapter 5 to which it relates.

## Cross-cutting concepts

arc42 leaves Chapter 8 open. We require five fundamental cross-cutting concepts in the following order:

- 8.1 Threat model – STRIDE; threats are assigned IDs (T-001…).
- 8.2 Security – each mitigation measure refers to the T-IDs it resolves.
- 8.3 Testing – test pyramid; tests can be traced back to use cases and business rules.
- 8.4 Observability – logs, metrics, traces, audit trails.
- 8.5 Error handling – retry, circuit breaker, fallback, recovery.

Only add further concepts from Chapter 8.x (persistence, i18n, accessibility, configuration, performance) if the system is actually affected by that aspect.

## Layer boundaries

At each layer boundary:
- Expose only clearly defined DTOs and contracts – never domain entities
- Use explicit mapping at every interface
- Apply anti-corruption layers when integrating external systems
- The direction of dependency points inwards (DIP)

## Backlog Management

Create EPICs and user stories as GitHub issues based on the specification.
- Use an EPIC for larger feature requests that coordinate multiple user stories
  or implementation slices. Use a user story for feature requests that are small
  enough for one focused, reviewable slice. If the scope is unclear and the
  issue type affects backlog structure, ask before creating the issue.
- Start every EPIC and user story description with
  `As a [Role], I want to [Action], so that [Benefit].`
- When creating or editing GitHub issues or pull requests with multi-line
  Markdown bodies, use `--body-file` so GitHub receives real line breaks and
  code fences. Examples: `gh issue create --body-file <file>`,
  `gh issue edit <issue> --body-file <file>`,
  `gh pr create --body-file <file>`, and
  `gh pr edit <pr> --body-file <file>`. Do not pass escaped newline sequences
  through `--body`.
- Mark EPICs and user stories with the repository's issue type, label, or
  metadata if available. If no metadata exists, prefix the issue title with
  `[EPIC]` or `[UserStory]`.
- Assign each user story to a matching EPIC when one exists. Prefer real
  sub-issues or parent-child issue relations when the repository supports them.
- User stories follow the INVEST criteria (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- Prioritise using MoSCoW (Must/Should/Could/Won’t)
- Highlight dependencies between issues
- Maintain the backlog regularly as the project evolves

## Vertical Slicing

Create the first increment as a ‘walking skeleton’: a deployable end-to-end slice that connects all architectural layers and does almost nothing else.

Extend the system in the form of thin vertical slices – each slice traverses all layers and delivers a small portion of the user value. Slices are ‘tracer bullets’: they are retained and refined, never discarded.

If a technical unknown blocks a slice, first carry out a spike solution – a time-limited, disposable experiment that eliminates the risk. The spike code is discarded; only the insights gained from it are incorporated into the slice.

## Next, implement

For each ticket:
- Create a feature branch for the EPIC
- Select the next ticket from the backlog (taking dependencies into account)
- Analyse the ticket and document the analysis as a comment on the ticket
- Implement using TDD (following the London or Chicago school, as appropriate)
- Each test refers to its use-case ID for traceability
- Make a commit using `skills/commit-message/SKILL.md`.
- Check whether specifications or architecture documents need updating
- When the EPIC is complete, create a pull request

## Refactoring

The aims of refactoring are to address specific ‘code smells’, not a vague urge to ‘tidy up’.

Create or update a remote issue for every requested refactoring task. Mark it
with the repository's refactoring issue type, label, or metadata if available;
otherwise prefix the issue title with `[REFACTORING]`.

For any refactoring task that cannot be completed in a single step, use the Mikado method: try the change, note down what no longer works as a result, revert the change and address the prerequisites first – never leave the build in a failed state whilst you are working on it.

Refactoring commits must only change the structure. Behavioural changes are made in separate commits, and the test suite must pass with every commit.

## Code quality

Our code adheres to:
- the [SOLID](https://en.wikipedia.org/wiki/SOLID) principles
- DRY (Don't Repeat Yourself), KISS (Keep It Simple, Stupid)
- Ubiquitous Language from Domain-Driven Design (the same terms in the code as in the specification -  use the business language)

## Quality Assurance

Quality assurance is carried out at three levels:
- Code review using the Fagan inspection (structured, systematic, with defined phases)
- Security review based on the OWASP Top 10
- Architecture review using ATAM (scenario-based trade-off analysis with regard to quality objectives)

For AI-assisted reviews, use a different AI model or a new session to avoid blind spots.

## Docs-as-Code

Documentation follows the ‘Docs-as-Code’ approach as outlined by Ralf D. Müller:
- AsciiDoc as the format, PlantUML for inline diagrams, and rendering through
  docToolchain, docs-toolbox-based pipelines, or similar publishing tools
- Version-controlled, peer-reviewed and automatically generated
- Plain English according to Strunk & White (or ‘Good German’ according to Wolf Schneider)
- Every reference to a documentation artifact must be addressable by an
  AsciiDoc `xref` link. Therefore include a unique anchor on every generated
  chapter page, and use the explicit source anchor in the xref link. When an
  anchor must be derived from a file name, remove numeric ordering prefixes,
  replace all non-alphanumeric characters with a dash (`-`), and lowercase all
  letters. Anchors must start with a lowercase letter and must not contain
  spaces or punctuation other than hyphens; digits are reserved for stable
  artifact identifiers, not chapter ordering. For example, the artifact
  `DOC-09000-architecture-decisions` is stored as
  `src/docs/arc42/doc-09000-architecture-decisions.adoc`; it has the anchor
  `architecture-decisions`, and the xref link is
  `xref:architecture-decisions[]`.

## Socratic Code Theory Reconstruction

Reconstruction of a programme’s ‘theory’ (Naur 1985) from the source code through recursive refinement of questions.

- Start with 5 core questions: Q1 Problem/User, Q2 Specification, Q3 Architecture, Q4 Quality Objectives, Q5 Risks.

- The second level of the tree is FIXED; it cannot be freely chosen. Each pass outputs exactly these nodes in this order, even if the only leaf of a node is [OPEN] or [ANSWERED: not applicable]:
- Q1.1–Q1.6: Product identity, primary users, channels, reason for development, key performance indicators, segment priority
    - Q2.1–Q2.6: Stakeholders, use case catalogue, system specifications per interface, data/entity model, acceptance criteria, cross-cutting business rules
    - Q3.1–Q3.12: the twelve arc42 chapters in the order specified by arc42
- Q4.1–Q4.8: the eight characteristics according to ISO/IEC 25010; and Q4.9: Which characteristic takes priority
- Q5.1–Q5.5: technical debt, security risks, operational risks, dependency/supply chain risks, scalability/performance risks

- Below the defined second level, decomposition is adaptive and code-oriented; a node is only a leaf node if it can be resolved using specific evidence from ‘file:line’ (a directory is too coarse – decompose further) or is unambiguously marked as [OPEN]. The depth reflects the code density: A small, limited context results in a shallow tree, whilst a large one results in a deep tree, limited to four levels below a specified node. The depth varies between runs – this is to be expected.

- Q-IDs are stable: Q3.7 is always the ‘Deployment View’ in every run, so that trees from different runs can be compared node by node.

- Each leaf node is either [ANSWERED] (with evidence in file:line) or [OPEN] (with category, questioner’s role and an explanation of why it cannot be answered based on the code).

- Quality is not solely a matter of team knowledge. Derive quality scenarios for the Q4 branch and arc42 Chapter 10 from measurable code behaviour – specific thresholds, timeouts, budgets, the threat catalogue and the test concept from Q3.8 – as [ANSWERED] with File:Line; never invent target values.
  Only the ranking of the quality objectives (Q4.9) is [OPEN]. arc42 Chapter 10 contains the derivable scenarios; never include just an [OPEN] reference. Chapter 1.2 lists only the 3–5 most important quality objectives;

Chapter 10 covers all eight characteristics – mark every entry in Chapter 10 as a specification of a top-level objective from Chapter 1.2 or as derived.

- Open questions form the handover document: Always create one section per role (Product Owner, Architect, Developer, Subject Matter Expert, Operations), even if a section is empty (“No open questions for this role”).

- Two-phase workflow: In Phase 1, the tree is constructed; the team answers the open questions; in Phase 2, the documentation is compiled from the tree filled with answers.

## Collaboration

The following section describes the basic concepts of collaboration.

### Concise answer (TLDR)

Answers begin with the conclusion (BLUF). Stick to the key points. No filler words, no introduction. Use short sentences, the active voice and no unnecessary words (Strunk & White).

### Simple explanation (ELI5)

Explain complex concepts using simple language and everyday analogies. If you find it difficult to write the explanation, this indicates gaps in your understanding – address these areas first (Feynman Technique).

### Explaining and Teaching

If you’re asked to explain or teach something (including ‘Why does X…?’), act like a teacher engaged in a dialogue, rather than a lecturer giving a talk – your aim is for the learner to be able to apply what they’ve learnt afterwards, not simply for you to have conveyed the information.

First, let the learner repeat what they already understand (Socratic method), so that you can fill in the gaps in their knowledge rather than covering the entire topic; adjust the level of detail as required (ELI5 / ELI-internal). Keep a short, ongoing checklist of the points the learner needs to understand – the problem and why it exists, the solution with its design decisions and edge cases, as well as the significance of the whole – a ‘Definition of Done’ for understanding, which is worked through point by point; if the explanation is lengthy or spans several sessions, save this checklist as a file so that it is retained even if context is lost and can be continued.

Take one small step per round: fill the knowledge gap with questions, not answers; ask follow-up questions or explain the next smaller part in a few sentences and then check their understanding – then pause and wait. Never cram several steps into a single round. Start with the ‘why’ – why something is important – before delving into the mechanisms (4MAT), and keep probing for the ‘why’ behind the ‘why’ – the logic behind the design, not just its function (Naur); also address the ‘what’ and the ‘how’.

Check what has been learnt by asking questions, never with ‘Does that make sense?’ – use open-ended or multiple-choice questions; when using multiple-choice questions, vary which option is correct, and only reveal the answer once the learner has made a choice. The most effective way to check understanding is to get learners to explain what they have learnt in their own words (the Feynman technique) or to apply it to a new scenario; use a concrete example (an example, code, a flowchart) if it helps. Respond to the actual answer: if the learner has understood, move on; if not, give a brief, targeted hint and ask again. ‘Understood’ means that the learner can apply what they have learnt to a new scenario, not that they can recite it from memory (Bloom’s ‘Application’, not ‘Recall’) – do not move on or end the exercise until the learner has demonstrated this.

Do not announce the method you are using or go through it step by step – let your actions guide you, not your words. Adapt to the question: a short, factual question receives a one-line answer, and the learner can say at any time, ‘Just tell me.’ If you are unsure about the topic, learn it before you teach.

## Writing style

The writing style is based on ‘Gutes Deutsch’ by Wolf Schneider (or ‘Plain English’ by Strunk & White).

Additionally:
- Technical terms remain in English (LLM, prompt, token, spec, etc.)
- Address the reader directly; use the first person sparingly but deliberately
- Use analogies to human thinking to explain technical concepts
- One idea per paragraph (5–8 sentences are fine)
- Section headings are statements, not topic introductions
- The first sentence states what the paragraph is about
- Show code and prompts; don’t simply claim that things work
- Conclusions make a clear statement – never end with “it remains to be seen”

## TDD, Hamburg-style

Ralf Westphal’s design-oriented TDD approach – bridge the gap between requirements and logic before writing code, then test at service boundaries with minimal mocking. Apply this when the problem is too complex for pure ‘Red-Green-Refactor’ in microsteps.

- **ACD cycle (Analyse → Design → Code)** precedes the test loop: first model the solution to bridge the gap between requirements and logic; only then do you code.
- **‘Right from the start’ philosophy** – implement it correctly the first time round, so that refactoring is a correction rather than a routine clean-up.
- **Service-level testing** – testing behind the public API, regardless of the API technology.
- **Minimal mocking** – closer to *TDD, Chicago School* than to *London School*.
- **IOSP (Integration Operation Segregation Principle)** – A function is either composition (integration) or logic (operation), never both; structural support for simple unit tests.
- **In-depth work rather than small steps** — accept that some problems cannot be broken down into tiny ‘green’ increments; remain in the ‘red’ state for longer if the design requires it.

Consists of: *TDD, London School*, *TDD, Chicago School*, *Red-Green-Refactor*, *IOSP*.
Sources: https://ralfw.de/hamburg-style-tdd/, https://ralfw.de/tdd-how-it-can-be-done-right/

## Strategic Architecture Analysis

Strategic architecture analysis combines four perspectives, each dedicated to a different question. Use this approach when evaluating ‘Build vs. Buy’, assessing the architecture’s suitability for changing requirements, or conducting a strategic technology radar review.

Map out the value chain using Wardley Mapping to identify how the individual components are evolving – what is standard, what is emerging, and where the strategic differentiation actually lies.

Classify each challenge using the Cynefin framework – ‘clear’, ‘complicated’, ‘complex’ or ‘chaotic’ – so that the response is tailored to the specific context, rather than imposing a single, uniform approach on every problem.

If a decision involves a broad range of possible solutions, present the dimensions and their options in a ‘Morphological Box’ and combine them deliberately, rather than sticking rigidly to the first draft that springs to mind.

Evaluate the shortlisted architectures against the quality objectives using ATAM, identifying the critical points, the trade-offs and the risks associated with each option.

If the root cause of a problem remains unclear, use the ‘Five Whys’ to get to the bottom of it before committing to a course of action.
