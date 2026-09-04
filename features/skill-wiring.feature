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

  Scenario: The repository branch sweep is defined once and deferred to
    Given clock-in defines the repository-wide branch enumeration
    When every other skill is searched for that command
    Then none carries it and clock-out references skills/clock-in/SKILL.md
    # clock-out needs the same whole-repository view at the end of a session as
    # clock-in needs at the start. Copying the command into it is the drift this
    # feature exists to catch; the command is read from clock-in so that editing
    # it there moves the guard with it.

  Scenario: The branch enumeration reports divergence from the base branch
    Given the branch enumeration clock-in defines
    When it is inspected for what it produces
    Then it resolves the base branch and counts commits in both directions
    # The wiring scenario above keeps the command in one place. It does not keep
    # it useful: reduced to a list of ref names, it would still pass while the
    # divergence the skill promises quietly disappeared. This is the guard for
    # the promise rather than for the location.

  Scenario: No caller carries the Convergence Check question structure
    Given the seven question titles read from the Convergence Check itself
    When every other skill is searched for those titles as headings
    Then none carries two or more of them
    # The section heading alone would not catch a copy made without it, so the
    # question titles themselves are what is checked.
