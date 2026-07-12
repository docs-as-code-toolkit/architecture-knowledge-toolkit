# Issue Type and Label Taxonomy

Shared guidance for how backlog issues (Epics, UserStories, slices, refactorings)
are typed and labelled so they are easy to find, filter, and classify — for
example when triaging them into a project board.

This is engine-independent guidance. It is referenced by
`skills/architecture-impact/SKILL.md` (which decides Epic vs UserStory) and
`skills/slice-issues/SKILL.md` (which creates the child slices). A consuming
project adopts the taxonomy that fits its tooling; the toolkit only fixes the
*dimensions* and the precedence, not a project's exact label names.

## Issue type

Every backlog issue has exactly one type. Set it with, in order of preference:

1. A **native issue type** when the platform supports it
   (`gh issue create --type <Type>`). GitHub issue types are currently an
   organization-level feature; personal repositories usually cannot use them.
2. Otherwise a **`type:` label** (see below).
3. Otherwise a **title prefix** as a last resort (`[EPIC]`, `[UserStory]`,
   `[REFACTORING]`), as described in `../architecture-impact/SKILL.md`.

Recommended type vocabulary:

| Type | Meaning |
|------|---------|
| `epic` | Coordination issue for work too large for one reviewable slice. |
| `user-story` | A reviewable slice of user or stakeholder value. |
| `task` | Technical work with no direct user-facing value (tooling, tests, docs, chores). |
| `refactoring` | Internal change that does not alter observable behaviour. |
| `bug` | Defect in existing behaviour. |

Epics and UserStories still begin their description with
`As a [Role], I want to [Action], so that [Benefit].` (see
`../architecture-impact/SKILL.md`). Tasks and refactorings use a short goal
statement plus acceptance criteria instead.

## Label dimensions

Apply labels along independent dimensions so a board can filter on each:

- **Type** — `type:epic`, `type:user-story`, `type:task`, `type:refactoring`,
  `type:bug` (mirror the native issue type as a label when the board cannot
  filter on the native type). Exactly one.
- **Area / domain** — `area:<name>` (for example `area:docs`, `area:testing`,
  `area:observability`). One or more; project-defined.
- **Grouping** — an optional project-defined grouping such as a roadmap phase or
  a component, expressed as a label (`phase-4`) or a GitHub milestone. Optional.

Keep **workflow status** (todo / in progress / done) in the project board, not
in labels; labels describe what an issue *is*, the board describes where it *is*.

Prefix labels by dimension (`type:`, `area:`) so they group and colour
consistently and are unambiguous when several are applied at once.

## Creating issues with type and labels

```sh
# Native type when available (org repos):
gh issue create --type UserStory --label "area:testing,phase-4" \
  --parent <epic> --title "<title>" --body-file <file>

# Label-based type when native types are unavailable (personal repos):
gh issue create --label "type:user-story,area:testing,phase-4" \
  --parent <epic> --title "<title>" --body-file <file>
```

Create the `type:` and `area:` labels once per repository (for example with
`gh label create`) so they exist before issues reference them.
