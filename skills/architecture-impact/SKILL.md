---
name: architecture-impact
description: Analyze and document architecture impact for feature requests, Epic issues, refactoring tasks, issue implementation, and review tasks. Use when Codex is asked to handle a feature request, create or refine an Epic, mark a refactoring issue, implement feature or refactoring work, review a pull request or review task, assess whether code changes affect architecture documentation, update affected arc42 sections, connect features or refactorings to ADRs, quality goals, quality scenarios, risks, components, runtime scenarios, deployment views, or create follow-up ADRs with diagrams.
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

## Core Workflow

1. Identify the feature request, Epic issue, refactoring task, implementation
   issue, pull request, or review task and read its title, description,
   acceptance criteria, comments, linked issues, and linked PRs.
2. Inspect the current architecture documentation before changing code or
   judging a review. Read the affected arc42 chapter files, ADR index, existing
   ADRs, quality goals, quality scenarios, risks, building blocks, runtime
   scenarios, deployment views, and relevant source files.
3. Create or update the remote project Epic for every feature request. Mark it
   with the repository's Epic issue type when available; if no Epic type exists,
   prefix the issue description with `[EPIC]`.
4. Mark every requested refactoring in the remote project issue. Use the
   repository's refactoring issue type, label, or metadata when available; if no
   dedicated metadata exists, prefix the issue title with `[REFACTORING]`.
5. Record the feature or refactoring at every affected place in the
   architecture documentation. Prefer a short `Affected Features` or
   `Affected Refactorings` section or table with stable issue links, status,
   and explicit `xref` links to related architecture artifacts.
6. Explicitly mention affected existing ADRs, quality goals, quality scenarios,
   risks, constraints, components, interfaces, runtime scenarios, and deployment
   elements in the issue, implementation notes, review output, or architecture
   changes.
7. If the feature or refactoring conflicts with an accepted or proposed ADR,
   quality goal, quality scenario, risk treatment, or constraint, stop treating
   the conflict as an implementation detail. Use `../adr/SKILL.md` to draft a
   new proposed ADR or update the affected decision trail.
8. Document new or changed components, runtime scenarios, and deployment
   changes with a matching PlantUML diagram plus a short textual description.
   Use C4-PlantUML for building-block diagrams.
9. Add diagrams to new ADRs when they help readers compare options. If the same
   diagram or description is also included in the official arc42 structure,
   author it once and include it with `include::...[tags=...]` instead of
   copying it.
10. Add or update quality scenarios and risks only when existing artifacts do
   not already cover the feature impact. Use `../quality-scenario/SKILL.md` and
   `../risk/SKILL.md` for those artifacts.
11. Run the relevant validators, generators, render checks, tests, or manual
    checks. Report any unavailable verification and remaining open human
    decisions.

## Required Reading

Read these files when the feature or review touches the corresponding scope:

- `../../general-semantic-contracts.md` for architecture documentation,
  Docs-as-Code, metadata, traceability, quality, risks, backlog management, and
  review rules.
- `../../AGENTS.md` for automated-contributor rules.
- `../adr/SKILL.md` before creating or changing ADRs, or when a feature
  conflicts with an existing decision.
- `../quality-scenario/SKILL.md` before creating or changing quality scenarios.
- `../risk/SKILL.md` before creating or changing risks.
- `../traceability-review/SKILL.md` before changing relation metadata or
  reviewing traceability.
- `../slice-issues/SKILL.md` when the Epic needs child issues or reviewable
  implementation slices.
- `../implement-issue-workflow/SKILL.md` when continuing from feature analysis
  into implementation.
- `../pr-review/SKILL.md` when the task is a pull request or review task.

## Feature Issue Rules

- Treat the Epic as the coordination artifact for the feature.
- Prefer a real Epic issue type if the remote repository supports it.
- If no Epic type is available through the repository UI, CLI, or API, prefix
  the Epic issue description with `[EPIC]`.
- Link child issues, PRs, ADRs, affected quality scenarios, risks, and relevant
  architecture documents from the Epic.
- Keep child issues small and independently reviewable; use sub-issues when
  available.
- Do not create duplicate Epics. Search open and recently closed issues before
  creating a new one.

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

- Use repository source files as the source of truth; conversational context and
  generated prose are advisory until reviewed and committed.
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
- Is the Epic or refactoring issue marked with the repository's native metadata,
  or with `[EPIC]` in the Epic description / `[REFACTORING]` in the refactoring
  issue title when no metadata exists?
- Are affected ADRs and quality goals explicitly named?
- Is there a conflict that requires a new or changed ADR?
- Are all affected architecture locations updated with feature references?
- Are new components, runtime scenarios, and deployment changes documented with
  PlantUML diagrams and short text?
- Are shared diagrams and descriptions included by tag instead of copied?
- Does the Epic link the implementation, documentation, ADRs, risks, quality
  scenarios, and PRs?
- Are validators, generators, tests, and render checks run or explicitly noted
  as not run?
