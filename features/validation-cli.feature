# Living documentation for the validator command-line interface.
# Bridged to: test/validate_metamodel_cli_test.rb (classic Minitest driving the
# script as a subprocess). Each scenario maps to at least one automated test;
# here that is one test method named after the sanitized scenario title, with
# Given/When/Then comment anchors. Traceability is a reviewer-verifiable
# convention, not a build-enforced link.

Feature: Validation command-line interface
  As a contributor or CI job
  I want to run the metamodel validator from the command line
  So that broken architecture metadata fails the build

  Scenario: CLI exits zero and reports success for valid docs
    Given the valid fixtures directory
    When the validator script runs against it
    Then the process exits with status zero and the report says validation passed

  Scenario: CLI exits nonzero and reports failure for invalid docs
    Given the invalid fixtures directory
    When the validator script runs against it
    Then the process exits with a nonzero status and the report says validation failed

  Scenario: CLI generate writes the traceability matrix
    Given a temporary copy of the valid fixtures
    When the validator script runs with generate and an output path
    Then the process exits with status zero and writes the traceability matrix file

  Scenario: CLI reports a missing docs target
    Given a docs target path that does not exist
    When the validator script runs against it
    Then the process exits with a nonzero status and the report names the missing docs target
