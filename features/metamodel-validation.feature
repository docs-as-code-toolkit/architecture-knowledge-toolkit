# Living documentation for the metamodel validator.
# Bridged to: test/validate_metamodel_test.rb (classic Minitest, no native BDD
# runner). Each scenario maps to at least one automated test; here that happens
# to be one test method named after the sanitized scenario title, with Given/
# When/Then comment anchors inside it. Traceability is a reviewer-verifiable
# convention, not a build-enforced link.

Feature: Metamodel validation
  As an architecture knowledge base maintainer
  I want architecture artifacts checked against the metamodel
  So that metadata, identifiers, and relations stay trustworthy

  Scenario: Valid fixture passes
    Given a directory of well-formed architecture artifacts
    When the validator runs
    Then it reports no errors

  Scenario: Invalid fixture reports errors
    Given an artifact missing a required title, using an unknown relation key, and pointing at a missing target
    When the validator runs
    Then it reports the missing title, the unknown relation key, and the unknown target

  Scenario: Duplicate artifact id reports an error
    Given two artifacts that declare the same artifact id
    When the validator runs
    Then it reports the duplicate artifact id

  Scenario: Filename warning when artifact id does not match filename
    Given an artifact whose filename does not match its normalized id
    When the validator runs
    Then it warns that the filename should match the artifact id

  Scenario: Filename warning for asciidoc attribute id
    Given an artifact that declares its id through an AsciiDoc attribute instead of YAML front matter
    When the validator runs
    Then it reports no errors and warns that the filename should match the attribute id

  Scenario: Decimal classification warning for arc42 detail document
    Given a DOC artifact in an arc42 chapter directory whose id uses the wrong chapter prefix
    When the validator runs
    Then it warns that the id should start with the chapter prefix and a local sequence greater than 000

  Scenario: Relations field must be a list
    Given an artifact whose relations field is a mapping instead of a list
    When the validator runs
    Then it reports that the relations field must be a list

  Scenario: Relation entry must be a mapping
    Given an artifact whose relations list contains a bare string entry
    When the validator runs
    Then it reports that the relation must be a mapping

  Scenario: Relation missing required keys reports errors
    Given a relation without type, target, and status
    When the validator runs
    Then it reports each missing required relation key

  Scenario: Unknown relation type reports an error
    Given a relation whose type is not defined in the relation schema
    When the validator runs
    Then it reports the unknown relation type

  Scenario: Front matter without closing marker reports an error
    Given an artifact whose YAML front matter has no closing marker
    When the validator runs
    Then it reports the missing closing front matter marker

  Scenario: Front matter that is not a mapping reports an error
    Given an artifact whose front matter is a YAML sequence instead of a mapping
    When the validator runs
    Then it reports that the front matter must be a mapping

  Scenario: Invalid yaml front matter reports an error
    Given an artifact with syntactically invalid YAML front matter
    When the validator runs
    Then it reports the invalid YAML front matter

  Scenario: Missing docs target reports an error
    Given a docs target path that does not exist
    When the validator runs
    Then it reports that the docs target does not exist

  Scenario: Generated artifacts are skipped during scan
    Given a chapter with one source artifact and one artifact under a generated directory
    When the validator scans the docs tree
    Then only the source artifact is scanned

  Scenario: Bidirectional relation is detected
    Given two artifacts that each declare a relation pointing at the other
    When the validator runs
    Then it warns that a bidirectional relation was detected

  Scenario: Report states validation passed for valid artifacts
    Given a directory of well-formed architecture artifacts
    When the validator prints its report
    Then the report ends with a validation passed line

  Scenario: Report states validation failed for invalid artifacts
    Given a directory containing an invalid artifact
    When the validator prints its report
    Then the report ends with a validation failed line
