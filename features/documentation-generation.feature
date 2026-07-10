# Living documentation for the deterministic documentation generators.
# Bridged to: test/validate_metamodel_test.rb (classic Minitest). Each scenario
# title maps to a test method with the sanitized scenario title and Given/When/
# Then comment anchors.

Feature: Documentation generation
  As an architecture knowledge base maintainer
  I want derived indexes and fragments generated deterministically from source artifacts
  So that generated documentation is reproducible and reviewable

  Scenario: Traceability matrix output is deterministic
    Given a set of validated artifacts with outgoing relations
    When the traceability matrix is rendered twice
    Then both renderings are identical and list outgoing and incoming relations with xref links

  Scenario: Artifact index output is deterministic
    Given a set of validated artifacts including an ADR with provenance
    When the ADR artifact index is rendered twice
    Then both renderings are identical and include the ADR anchor, status, and derived-from question

  Scenario: Open questions index output is deterministic
    Given the arc42 source tree with open questions
    When the open questions index is rendered twice
    Then both renderings are identical and list only the open questions with their roles

  Scenario: Traceability fragment includes outgoing and incoming relations
    Given an ADR artifact with an outgoing relation
    When the traceability fragment is rendered
    Then it contains the matrix heading and the outgoing relation to the quality scenario

  Scenario: Impact fragment includes outgoing relation impacts
    Given an ADR artifact with an outgoing relation
    When the impact fragment is rendered
    Then it contains the impact matrix with the related quality scenario and relation type

  Scenario: Traceability fragment uses explicit anchor for numbered chapter file
    Given an ADR referenced by a numbered arc42 chapter document
    When the traceability fragment is rendered
    Then it links the chapter through its explicit anchor rather than the numbered file name

  Scenario: Metadata attribute fragment derives asciidoc attributes from metadata
    Given a validated ADR artifact with status and provenance metadata
    When the metadata attribute fragment is rendered
    Then it exposes the artifact id, status, and derived-from description as AsciiDoc attributes

  Scenario: Chapter include fragment output is deterministic and sorted by artifact id
    Given an arc42 chapter with two detail documents
    When the chapter include fragment is rendered twice
    Then both renderings are identical and include the detail documents sorted by artifact id

  Scenario: Chapter include fragment write skips generated artifacts
    Given an arc42 chapter with a source detail and a generated detail
    When the chapter include fragments are written
    Then only the source detail is included and the generated detail is skipped
