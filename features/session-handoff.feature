# Living documentation for the private journal binding used by the clock-in and
# clock-out skills.
# Bridged to: test/journal-config.test.mjs (node:test, classic runner, no native
# BDD). Each scenario maps to at least one automated test named after the
# scenario title, with Given/When/Then comment anchors inside the test body.
# Traceability is a reviewer-verifiable convention, not a build-enforced link.
#
# The skills themselves are prose contracts and are not executable. What is
# specified here is the one mechanical part they depend on: where a private
# journal is bound, and how that binding is resolved.

Feature: Private journal binding
  As someone who keeps a private journal alongside project work
  I want its location recorded once per user and never inside a repository
  So that clock-in and clock-out reach both layers on any machine

  Scenario: An unrecorded binding asks to be set up
    Given a user with no recorded private journal binding
    When the binding is resolved
    Then it reports that no answer has been recorded yet

  Scenario: Binding a journal discovers its clock skills
    Given a journal checkout containing daily-clock-in and daily-clock-out skills
    When the journal is bound to that directory
    Then the resolved binding names the directory and both discovered skills

  Scenario: Declining a private journal is a stored answer
    Given a user who keeps no private journal
    When that answer is recorded
    Then the binding resolves as disabled instead of asking again

  Scenario: The environment overrides the stored binding
    Given a stored binding to one journal checkout
    When the environment names a different journal checkout
    Then the resolved binding names the checkout from the environment

  Scenario: The environment can switch the private layer off
    Given a stored binding to a journal checkout
    When the environment sets the journal to off
    Then the binding resolves as disabled and the stored binding is untouched

  Scenario: A directory without clock skills is refused
    Given a directory that contains no clock-in skill
    When the journal is bound to that directory
    Then binding fails and names what is missing

  Scenario: Forgetting the binding returns to the setup question
    Given a stored binding to a journal checkout
    When the binding is forgotten
    Then it reports that no answer has been recorded yet

  Scenario: A bound journal that is not on this machine is reported, not fatal
    Given a stored binding whose journal checkout is absent
    When the binding is resolved
    Then it still reports the binding and warns that the checkout is unreachable

  Scenario: The skill installer records the binding in one step
    Given a journal checkout and an empty skill discovery root
    When the installer runs with the private journal option
    Then the skills are linked and the binding resolves to that checkout

  Scenario: The binding is stored outside every repository
    Given a user configuration home
    When the binding location is requested
    Then it is inside that configuration home and not inside the toolkit
