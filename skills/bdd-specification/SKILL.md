---
name: bdd-specification
description: "Enforce Living Documentation through Behaviour-Driven Development by writing a language-agnostic Gherkin feature specification for any new or changed observable behaviour and mapping each scenario to at least one automated verification, even when the target language has no native BDD framework. This is the strict default for features, behavioural enhancements, and behaviour-changing bug fixes; relax it only with an explicit recorded human waiver. Use when Codex is asked to specify feature or behaviour, write or update .feature files, add BDD or acceptance tests, keep behaviour specs and tests in sync, bridge Gherkin scenarios to classic tests, or apply a scenario-to-test naming convention with Given/When/Then structure."
---

# BDD Specification

Act as a software architect who enforces Living Documentation through
Behaviour-Driven Development (BDD). For every feature, write a language-agnostic
Gherkin specification that describes business behaviour, and map each scenario to
at least one automated verification — regardless of whether the target language
supports a BDD framework natively.

A Gherkin scenario and a unit test sit at different abstraction levels: a
scenario describes observable business or system behaviour, while unit tests
verify its technical decomposition. Do not force a one-to-one scenario-to-unit-test
mapping. One scenario may need several supporting unit tests (boundaries, error
paths, persistence, events), and many legitimate unit tests do not justify a
separate business-readable scenario. Keep the feature files as Living
Documentation, not as technical test catalogues written in Gherkin.

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
  documentation as a source or literal block. This keeps a single source of
  truth: the runner executes it and the docs render it.
- **Choose the arc42 location by architectural relevance, not by default.** Not
  every scenario is an architecture-relevant runtime scenario. Use Chapter 6
  (Runtime View) when the scenario explains runtime collaboration between
  building blocks, Chapter 10 for quality-related behaviour, and
  requirement-oriented sections or references for functional acceptance
  behaviour. A scenario that carries no architectural significance may stay in
  `features/` and need not be surfaced into arc42 at all. Avoid turning
  Chapter 6 into a collection of validation and acceptance details.
- Do not move `.feature` files under `src/docs/` and point the runner at the docs
  tree; that couples runner configuration to the documentation layout and is more
  fragile than including the spec into the docs.
- When no convention exists yet, propose one and keep it consistent.

### Step 3: Technical Implementation & Naming Convention (the Bridge)

When implementing in test code, keep reviewer-verifiable traceability between the
documentation and the code. This bridge is a review convention, not build-time
enforcement: no CI check proves the link, so a reviewer must be able to confirm
it from stable identifiers or naming.

1. **Every scenario has at least one identifiable automated verification.**
   Prefer a one-to-one mapping to an acceptance, component, or use-case test
   where practical. A scenario may instead map to a test class, a nested test
   group, or several supporting tests. Supporting unit tests that exist only to
   verify technical decomposition do not require their own Gherkin scenario.

2. **Naming convention for the scenario-mapped test.** Name the acceptance,
   component, or group test that stands for the scenario as a direct, sanitized
   translation of the Gherkin scenario title (for example snake_case or CamelCase
   per the language's convention), so a reviewer can trace it by name.

   - `Scenario: Passwort ist zu kurz` ➡️ `def test_passwort_ist_zu_kurz` (Python)
     or `it "passwort_ist_zu_kurz"` (Ruby/RSpec).

   Names are readable but poor identifiers: improving the wording of a scenario
   should not silently break traceability. When stronger traceability is wanted,
   prefer a stable scenario identifier over the title, for example a
   `@scenario-id(PAYMENT-003)` tag on the scenario and a matching marker on the
   test (`@Scenario("PAYMENT-003")`, a comment, or the test name). This repository
   does not add a machine check for the link yet.

   See `../references/bdd-writing-guide.md` for slug normalization rules
   (umlauts, punctuation, whitespace).

3. **Structure in code.** Inside the scenario-mapped test, mark the `Given`,
   `When`, and `Then` phases as clear visual anchors (comments). They separate
   the logic cleanly into Arrange, Act, and Assert.

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

- Keep the `.feature` file and the tests in sync: every scenario has at least one
  identifiable automated verification, and the scenario-mapped test is traceable
  by a stable identifier or the sanitized scenario title. Removing or renaming a
  scenario is a documentation change that a reviewer must reconcile with the tests.
- Keep scenarios declarative and business-focused; push mechanical detail down
  into supporting unit tests, step definitions, or test helpers.
- Do not weaken assertions to make a test pass; a red test is valid feedback.
- Mark AI-created specifications and tests as proposed until reviewed, following
  the repository's status conventions where they apply.

## Verification

After adding or changing specifications and tests, run the relevant BDD or
unit-test runner (for example `pytest`, `cucumber`, `dotnet test`, `rake test`)
and report the result. If no runner is available, report that verification was
not possible and describe the manual checks performed. Prefer existing commands
from the repository documentation or scripts.
