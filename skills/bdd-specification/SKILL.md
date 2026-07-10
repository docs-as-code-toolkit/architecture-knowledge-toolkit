---
name: bdd-specification
description: "Enforce Living Documentation through Behaviour-Driven Development by writing a language-agnostic Gherkin feature specification for any new or changed observable behaviour and mapping each scenario into the technical unit tests, even when the target language has no native BDD framework. This is the strict default for features, behavioural enhancements, and behaviour-changing bug fixes; relax it only with an explicit recorded human waiver. Use when Codex is asked to specify feature or behaviour, write or update .feature files, add BDD or acceptance tests, keep behaviour specs and tests in sync, bridge Gherkin scenarios to classic unit tests, or apply a scenario-to-test naming convention with Given/When/Then structure."
---

# BDD Specification

Act as a software architect who enforces Living Documentation through
Behaviour-Driven Development (BDD). For every feature, write a language-agnostic
Gherkin specification that describes business behaviour, and map that
specification into the technical unit tests — regardless of whether the target
language supports a BDD framework natively.

This skill is guidance and reusable content only. Do not implement a runner or
add automation as part of using this skill. Treat AI-created specifications and
tests as proposed until a human reviewer accepts them.

Apply the repository contract hierarchy: this skill narrows `AGENTS.md`, and
`AGENTS.md` adapts `general-semantic-contracts.md`. Do not duplicate general
metadata, anchor, testing, or Docs-as-Code rules here unless the BDD workflow
needs a stricter rule.

This skill is the strict default for any change that adds or changes observable
behaviour — new features, behavioural enhancements, and behaviour-changing bug
fixes. `../architecture-impact/SKILL.md` invokes it when the behaviour change is
requested, and `../implement-issue-workflow/SKILL.md` invokes it at the latest
when the change is implemented. Specify the behaviour as Gherkin as early as
request or analysis time; the specification and its test bridge must exist by the
time the change is implemented. Use those skills for backlog, branching,
verification, and PR mechanics, and use this skill for the specification and its
test bridge.

The only way out is an explicit, recorded human waiver. Do not skip the
specification on your own judgement: relax it only when a human explicitly asks
for a lighter treatment, and record that decision and its rationale where the
project keeps such decisions (for example the issue, the pull request, or the
Q&A document). Pure refactorings do not add behaviour, so they need no new
scenarios, but they must keep the existing `.feature` specs and their bridged
tests passing.

## Required Reading

- `../references/bdd-writing-guide.md` before writing `.feature` files, choosing
  scenario names, or translating scenarios into test names.

## Core Workflow

Follow three steps: decide the framework, write the feature documentation, then
build the bridge into code.

### Step 1: Technology & Framework Decision

Analyze the project's tech stack and decide whether to use a native BDD framework
or a classic unit-test framework.

- **Native BDD available** (for example Python/`pytest-bdd` or `behave`,
  JS/TS/Cucumber, Java/Cucumber-JVM): use the native runner so `.feature` files
  execute directly against step definitions.
- **No native BDD, or a classic unit-test framework is preferred** (for example
  Ruby/Minitest, C#/xUnit, Go/`testing`): use the classic framework and apply
  the bridge rules in Step 3 to keep the specification coupled to the tests.

Prefer the framework the repository already uses. Do not introduce a new BDD
dependency when a classic framework is established; use the bridge instead.
Record the decision and its rationale where the project keeps such notes (for
example an ADR via `../adr/SKILL.md` when the choice is architecture-significant).

### Step 2: Documentation Duty (the Feature File)

Create a `.feature` file in Gherkin style for every feature. This file is the
long-lived, living project documentation, not a throwaway test artifact.

- Write scenarios declaratively, focused on business behaviour, not on UI
  mechanics or implementation detail.
- One feature per file; a clear `Feature:` intent line and focused `Scenario:`
  blocks with `Given` / `When` / `Then` steps.

#### Where to store feature files

A `.feature` file has a dual nature: it is an executable specification that the
test runner must discover, and it is long-lived documentation. Resolve the
tension by authoring it once and surfacing it into the docs, never by copying it.

- **Authoritative location: code-side, where the runner discovers it.** Use the
  project convention (for example `features/`, `tests/features/`, or the
  language's own convention such as `spec/features/`). An executable spec that
  the runner never runs rots and stops being trustworthy documentation, so
  runner discovery wins for the source-of-truth location.
- **Surface it as documentation with an AsciiDoc `include::`, do not copy it.**
  Gherkin is plain text, so include the `.feature` file into the architecture
  documentation as a source or literal block. Its natural arc42 home is
  Chapter 6 (Runtime View) for behavioural scenarios; reference it from
  Chapter 1 requirements or Chapter 10 quality when the behaviour is
  requirement- or quality-relevant. This keeps a single source of truth: the
  runner executes it and the docs render it.
- Do not move `.feature` files under `src/docs/` and point the runner at the docs
  tree; that couples runner configuration to the documentation layout and is more
  fragile than including the spec into the docs.
- When no convention exists yet, propose one and keep it consistent.

### Step 3: Technical Implementation & Naming Convention (the Bridge)

When implementing in test code, keep a strict coupling between the documentation
and the code.

1. **Strict naming convention.** The name of the test method, block, or function
   MUST be a direct, sanitized translation of the Gherkin scenario title (for
   example snake_case or CamelCase per the language's convention).

   - `Scenario: Passwort ist zu kurz` ➡️ `def test_passwort_ist_zu_kurz` (Python)
     or `it "passwort_ist_zu_kurz"` (Ruby/RSpec).

   See `../references/bdd-writing-guide.md` for slug normalization rules
   (umlauts, punctuation, whitespace).

2. **Structure in code.** Inside each test, mark the `Given`, `When`, and `Then`
   phases as clear visual anchors (comments). They separate the logic cleanly
   into Arrange, Act, and Assert.

   ```python
   def test_passwort_ist_zu_kurz():
       # Given: a registration form with the minimum length policy
       form = RegistrationForm(min_password_length=8)

       # When: the user submits a password that is too short
       result = form.submit(password="short")

       # Then: registration is rejected with a length error
       assert result.rejected
       assert result.error == "password_too_short"
   ```

With a native BDD runner, the scenario title and Given/When/Then steps live in
the `.feature` file and its step definitions instead of comments; keep the step
text as the canonical behaviour statement.

## Output Rules

- Keep the `.feature` file and the tests in sync: every scenario has exactly one
  corresponding test, and the test name matches the sanitized scenario title.
- Keep scenarios declarative and business-focused; push mechanical detail down
  into step definitions or test helpers.
- Do not weaken assertions to make a test pass; a red test is valid feedback.
- Mark AI-created specifications and tests as proposed until reviewed, following
  the repository's status conventions where they apply.

## Verification

After adding or changing specifications and tests, run the relevant BDD or
unit-test runner (for example `pytest`, `cucumber`, `dotnet test`, `rake test`)
and report the result. If no runner is available, report that verification was
not possible and describe the manual checks performed. Prefer existing commands
from the repository documentation or scripts.
