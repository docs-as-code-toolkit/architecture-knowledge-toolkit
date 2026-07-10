# BDD Specification Prompt

```text
Specify and test the following new or changed behaviour using Behaviour-Driven
Development as living documentation. Applying BDD is the strict default for any
behaviour-adding or behaviour-changing work; skip it only with an explicit,
recorded waiver:

<feature or behaviour-change description>

Use project-local contracts and skills first. If they do not cover this task,
locate toolkit guidance in this order:
1. If ARCHITECTURE_KNOWLEDGE_TOOLKIT is set, use that path.
2. Otherwise check ../architecture-knowledge-toolkit.
3. Otherwise check any project-local recorded toolkit reference, such as a
   submodule, vendored copy, or pinned path.
4. Otherwise use
   https://github.com/docs-as-code-toolkit/architecture-knowledge-toolkit,
   preferably at a pinned release tag or commit SHA.

Follow the bdd-specification skill:
1. Analyze the tech stack and decide between a native BDD framework and a classic
   unit-test framework; prefer what the repository already uses.
2. Write a language-agnostic Gherkin .feature file with declarative,
   business-focused scenarios.
3. Bridge each scenario into a test: the test name is a sanitized translation of
   the scenario title, and Given/When/Then appear as visual anchors (comments)
   that separate Arrange, Act, and Assert.

Run the relevant BDD or unit-test runner and report the result, or report that
verification was not possible. Keep the .feature file and the tests in sync.
```
