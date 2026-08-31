# Living documentation for the wiring between canonical skills.
# Bridged to: test/skill-wiring.test.mjs (node:test, classic runner, no native
# BDD). Each scenario maps to one test named after the scenario title, with
# Given/When/Then comment anchors inside the test body. Traceability is a
# reviewer-verifiable convention, not a build-enforced link.
#
# Skills are prose contracts, so what an agent *does* with them cannot be
# verified here — that is the conformance and evaluation layer of #65. What can
# be verified is the wiring those contracts depend on: that a skill delegating
# to another one still points at a file that exists, and that a rule delegated
# away has not been copied back. Both fail loudly when someone edits one skill
# and forgets the other.

Feature: Skill wiring
  As a toolkit maintainer
  I want delegation between canonical skills to stay intact
  So that a skill that defers a rule still reaches the skill that owns it

  Scenario: Every skill-to-skill reference resolves
    Given the canonical skills under skills/
    When their relative references to other SKILL.md files are resolved
    Then every referenced file exists

  Scenario: The skills that own a gate moment reach the Convergence Check
    Given architecture-impact, implement-issue-workflow and pr-review
    When each is inspected for the canonical gate
    Then all three reference skills/convergence-check/SKILL.md

  Scenario: No caller defines any of the Convergence Check result states
    Given the four result states read from the Convergence Check itself
    When every other skill is searched for a definition of any of them
    Then none defines one
    # Naming a state is allowed and often clearer; defining it elsewhere is the
    # copy that drifts. All four are checked, not just one.

  Scenario: No caller carries the Convergence Check question structure
    Given the seven question titles read from the Convergence Check itself
    When every other skill is searched for those titles as headings
    Then none carries two or more of them
    # The section heading alone would not catch a copy made without it, so the
    # question titles themselves are what is checked.
