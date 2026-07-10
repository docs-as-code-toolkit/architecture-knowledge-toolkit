---
name: architecture-impact
description: Analyze and document architecture impact for feature requests, Epic issues, UserStory issues, refactoring tasks, issue implementation, and review tasks. Use when Codex is asked to handle a feature request, decide whether feature work should become an Epic or UserStory, create or refine an Epic, mark a UserStory or refactoring issue, implement feature or refactoring work, review a pull request or review task, assess whether code changes affect architecture documentation, update affected arc42 sections, connect features or refactorings to ADRs, quality goals, quality scenarios, risks, components, runtime scenarios, deployment views, or create follow-up ADRs with diagrams.
---

# Architecture Impact

## Overview

Keep feature work, refactorings, reviews, and architecture knowledge
synchronized. A feature request or refactoring task is not complete until the
relevant implementation, issue tracking, and architecture documentation tell the
same story.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
arc42, metadata, anchor, Docs-as-Code, or traceability rules here.

This skill intentionally repeats a few backlog and issue-marking rules from
`general-semantic-contracts.md` because they are operationally important while
handling feature and review work. Keep the general contract as the long-term
source of truth when these rules evolve.

## Core Workflow

1. Identify the feature request, Epic issue, UserStory issue, refactoring task,
   implementation issue, pull request, or review task and read its title,
   description, acceptance criteria, comments, linked issues, and linked PRs.
2. Inspect the current architecture documentation before changing code or
   judging a review. Read the affected arc42 chapter files, ADR index, existing
   ADRs, quality goals, quality scenarios, risks, building blocks, runtime
   scenarios, deployment views, and relevant source files.
3. Classify each feature request before creating or updating backlog issues. If
   the request is broad enough to coordinate multiple user stories or slices,
   create or update an Epic. If it is small enough for one reviewable slice,
   create or update a UserStory. If the size is unclear and the decision affects
   issue structure, ask a short clarifying question before creating the issue.
4. Mark Epics and UserStories in the remote project backlog. Use the
   repository's Epic or UserStory issue type, label, or metadata when available;
   otherwise prefix the issue title with `[EPIC]` or `[UserStory]`.
5. Start every Epic and UserStory description with the pattern
   `As a [Role], I want to [Action], so that [Benefit].`
6. Assign each UserStory to a matching Epic when one exists. Prefer real
   sub-issues or parent-child issue relations when the repository supports them;
   otherwise link the UserStory from the Epic and the Epic from the UserStory.
7. Mark every requested refactoring in the remote project issue. Use the
   repository's refactoring issue type, label, or metadata when available; if no
   dedicated metadata exists, prefix the issue title with `[REFACTORING]`.
8. For any change that adds or changes observable behaviour, specify that
   behaviour with `../bdd-specification/SKILL.md`. This is the strict default and
   covers new features, behavioural enhancements, and behaviour-changing bug
   fixes. Capture the acceptance behaviour as a language-agnostic Gherkin
   `.feature` spec as early as request or analysis time. The specification and
   its scenario-to-test bridge are mandatory at the latest when the change is
   implemented. Relax this only with an explicit human waiver, recorded with its
   rationale in the issue, pull request, or Q&A document. Pure refactorings add
   no behaviour and need no new scenarios, but must keep the existing specs and
   their bridged tests passing.
9. Record the feature or refactoring at every affected place in the
   architecture documentation. Prefer a short `Affected Features` or
   `Affected Refactorings` section or table with stable issue links, status,
   and explicit `xref` links to related architecture artifacts.
10. Explicitly mention affected existing ADRs, quality goals, quality scenarios,
   risks, constraints, components, interfaces, runtime scenarios, and deployment
   elements in the issue, implementation notes, review output, or architecture
   changes.
11. If the feature or refactoring conflicts with an accepted or proposed ADR,
   quality goal, quality scenario, risk treatment, or constraint, stop treating
   the conflict as an implementation detail. Use `../adr/SKILL.md` to draft a
   new proposed ADR or update the affected decision trail.
12. Document new or changed components, runtime scenarios, and deployment
   changes with a matching PlantUML diagram plus a short textual description.
   Use C4-PlantUML for building-block diagrams.
13. Add diagrams to new ADRs when they help readers compare options. If the same
   diagram or description is also included in the official arc42 structure,
   author it once and include it with `include::...[tags=...]` instead of
   copying it.
14. Add or update quality scenarios and risks only when existing artifacts do
   not already cover the feature impact. Use `../quality-scenario/SKILL.md` and
   `../risk/SKILL.md` for those artifacts.
15. Run the relevant validators, generators, render checks, tests, or manual
    checks. Report any unavailable verification and remaining open human
    decisions.

## Required Reading

Read these files when the feature or review touches the corresponding scope:

- `../../general-semantic-contracts.md` for architecture documentation,
  Docs-as-Code, metadata, traceability, quality, risks, backlog management, and
  review rules.
- `../../AGENTS.md` for automated-contributor rules.
- `../bdd-specification/SKILL.md` by default for any new or changed observable
  behaviour, to specify it as Gherkin and bridge it into tests.
- `../adr/SKILL.md` before creating or changing ADRs, or when a feature
  conflicts with an existing decision.
- `../quality-scenario/SKILL.md` before creating or changing quality scenarios.
- `../risk/SKILL.md` before creating or changing risks.
- `../traceability-review/SKILL.md` before changing relation metadata or
  reviewing traceability.
- `../slice-issues/SKILL.md` when the Epic or UserStory needs child issues or
  reviewable implementation slices.
- `../implement-issue-workflow/SKILL.md` when continuing from feature analysis
  into implementation.
- `../pr-review/SKILL.md` when the task is a pull request or review task.

## Backlog Issue Rules

- Treat an Epic as the coordination artifact for a feature that is too large for
  one reviewable slice or naturally contains multiple UserStories.
- Treat a UserStory as a reviewable slice of user value that can fit into one
  focused implementation flow.
- Prefer real Epic and UserStory issue types, labels, or metadata if the remote
  repository supports them.
- If no Epic metadata is available, prefix the Epic issue title with `[EPIC]`.
- If no UserStory metadata is available, prefix the UserStory issue title with
  `[UserStory]`.
- Start every Epic and UserStory description with
  `As a [Role], I want to [Action], so that [Benefit].`
- Assign a UserStory to an existing matching Epic when one exists. Prefer a real
  GitHub sub-issue or parent-child relation; use linked issue references only
  when sub-issues are unavailable.
- Keep child issues small and independently reviewable. Create sub-issues as
  real sub-issues for Epics and UserStories when the repository allows it.
- Do not create duplicate Epics or UserStories. Search open and recently closed
  issues before creating a new one.

## Refactoring Issue Rules

- Treat refactoring as intentional structural work, not incidental cleanup.
- Prefer a real refactoring issue type, label, or metadata field if the remote
  repository supports it.
- If no refactoring metadata is available, prefix the issue title with
  `[REFACTORING]`.
- Keep refactoring issues separate from behavioral feature changes unless a
  human explicitly accepts a combined scope.
- Link affected components, ADRs, risks, quality scenarios, tests, and follow-up
  issues from the refactoring issue.

## Documentation Rules

- Use reviewed repository source files as the source of truth; conversational
  context and generated prose are advisory until reviewed and committed.
- Do not load derived output as evidence or architecture context. This includes
  `generated/`, `build/`, `dist/`, `target/`, `out/`, rendered HTML/PDF,
  generated indexes, traceability views, and assembled documentation.
- Preserve stable IDs and accepted statuses. Mark AI-created or AI-modified
  architecture content as draft or proposed unless human acceptance is already
  recorded.
- Add feature or refactoring references where the work affects the
  documentation, not only in a central index. A component affected by a feature
  or refactoring should name that issue near the component description or in an
  `Affected Features` or `Affected Refactorings` section.
- Use explicit AsciiDoc anchors and `xref` links for visible references.
- Do not manually maintain generated include lists. Regenerate derived include
  fragments when the repository provides a generator.
- Keep reusable source content in one reviewed source location and include it
  elsewhere. Use tagged includes for shared descriptions and diagrams:

  ```asciidoc
  // tag::feature-auth-runtime[]
  [plantuml,feature-auth-runtime,svg]
  ----
  @startuml
  ' diagram body
  @enduml
  ----
  // end::feature-auth-runtime[]
  ```

  ```asciidoc
  include::../06-runtime-view/doc-06004-authentication.adoc[tags=feature-auth-runtime]
  ```

## Review Checklist

- Does the feature, refactoring, or PR change an architecture-significant
  behavior, boundary, dependency, interface, deployment concern, quality
  attribute, risk, or operational workflow?
- Is each Epic, UserStory, or refactoring issue marked with the repository's
  native metadata, or with `[EPIC]`, `[UserStory]`, or `[REFACTORING]` in the
  issue title when no metadata exists?
- Does every Epic and UserStory begin with
  `As a [Role], I want to [Action], so that [Benefit].`?
- Is each UserStory assigned to a matching Epic when one exists?
- Does every behaviour-adding or behaviour-changing change have a Gherkin
  `.feature` specification bridged to tests per `../bdd-specification/SKILL.md`,
  or an explicitly recorded human waiver?
- Are affected ADRs and quality goals explicitly named?
- Is there a conflict that requires a new or changed ADR?
- Are all affected architecture locations updated with feature references?
- Are new components, runtime scenarios, and deployment changes documented with
  PlantUML diagrams and short text?
- Are shared diagrams and descriptions included by tag instead of copied?
- Do the Epic and UserStory links cover implementation, documentation, ADRs,
  risks, quality scenarios, PRs, and real sub-issues where supported?
- Are validators, generators, tests, and render checks run or explicitly noted
  as not run?
