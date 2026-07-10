# Living documentation for the agent adapter generator.
# Bridged to: test/build-agent-adapters.test.mjs (node:test, classic runner, no
# native BDD). Each scenario maps to at least one automated test; here that is
# one test named after the scenario title, with Given/When/Then comment anchors
# inside the test body. Traceability is a reviewer-verifiable convention, not a
# build-enforced link.

Feature: Agent adapter generation
  As a toolkit maintainer
  I want agent adapters generated from the canonical skills
  So that every agent front-end routes to the same skill contracts

  Scenario: Build regenerates all four adapters
    Given a repository with canonical skills and no generated adapters
    When the adapter generator runs
    Then it writes the codex, vibe, github-copilot, and cursor adapters with the generated-file notice

  Scenario: Check reports adapters are current on a clean tree
    Given a repository whose adapters were just generated
    When the adapter generator runs in check mode
    Then it exits successfully and reports that the adapters are current

  Scenario: Check detects a stale adapter
    Given a repository whose generated adapter was edited by hand
    When the adapter generator runs in check mode
    Then it exits with a failure and names the stale adapter

  Scenario: Skills marked adapter_expose false are not listed
    Given a skill whose front matter sets adapter_expose to false and a normal skill
    When the adapter generator runs
    Then the generated adapters list the normal skill and omit the hidden skill
