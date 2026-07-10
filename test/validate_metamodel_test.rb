# frozen_string_literal: true

# Behaviour specification bridge for the metamodel validator and the
# deterministic documentation generators.
#
# Living documentation: features/metamodel-validation.feature and
# features/documentation-generation.feature. There is no native BDD runner for
# Ruby here, so each Gherkin scenario is bridged to a classic Minitest method:
# the method name is the sanitized scenario title, and the Given/When/Then
# phases appear as comment anchors that separate Arrange, Act, and Assert.

require 'minitest/autorun'
require 'pathname'
require 'stringio'
require_relative '../scripts/validate-metamodel'

class ValidateMetamodelTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join('..').expand_path
  SCHEMA = ROOT.join('metamodel/relations.schema.yaml')

  # Feature: Metamodel validation

  def test_valid_fixture_passes
    # Given: a directory of well-formed architecture artifacts
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )

    # When: the validator runs
    artifacts = validator.validate

    # Then: it reports no errors
    assert_equal 2, artifacts.length
    assert_empty validator.errors
  end

  def test_invalid_fixture_reports_errors
    # Given: an artifact missing a required title, using an unknown relation key,
    # and pointing at a missing target
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/invalid'),
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports the missing title, the unknown relation key, and the unknown target
    assert_includes validator.errors.join("\n"), "missing required metadata field 'title'"
    assert_includes validator.errors.join("\n"), 'unknown relation key(s): confidence'
    assert_includes validator.errors.join("\n"), "references unknown artifact id 'QS-999-missing'"
  end

  def test_duplicate_artifact_id_reports_an_error
    # Given: two artifacts that declare the same artifact id
    temp_dir = ROOT.join('tmp/test-duplicate-id')
    write_artifact(temp_dir.join('doc-100-first.adoc'), 'DOC-100-duplicate', 'First')
    write_artifact(temp_dir.join('doc-100-second.adoc'), 'DOC-100-duplicate', 'Second')

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports the duplicate artifact id
    assert_includes validator.errors.join("\n"), "duplicate artifact id 'DOC-100-duplicate'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_filename_warning_when_artifact_id_does_not_match_filename
    # Given: an artifact whose filename does not match its normalized id
    temp_dir = ROOT.join('tmp/test-filename-id')
    FileUtils.mkdir_p(temp_dir)
    artifact_path = temp_dir.join('wrong-name.adoc')
    artifact_path.write(<<~ADOC)
      ---
      id: DOC-999-right-name
      type: Document
      title: Right Name
      status: draft
      owner: test
      created: 2026-07-03
      ---
      [[right-name]]
      = Right Name
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it warns that the filename should match the artifact id
    assert_includes validator.warnings.join("\n"), "wrong-name.adoc filename should be 'doc-999-right-name.adoc'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_filename_warning_for_asciidoc_attribute_id
    # Given: an artifact that declares its id through an AsciiDoc attribute
    # instead of YAML front matter
    temp_dir = ROOT.join('tmp/test-attribute-filename-id')
    FileUtils.mkdir_p(temp_dir)
    artifact_path = temp_dir.join('legacy-name.adoc')
    artifact_path.write(<<~ADOC)
      [[attribute-id-document]]
      = Attribute ID Document
      :id: DOC-998-attribute-id-document

      This document uses an AsciiDoc id attribute instead of YAML front matter.
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports no errors and warns that the filename should match the attribute id
    assert_empty validator.errors
    assert_includes validator.warnings.join("\n"), "legacy-name.adoc filename should be 'doc-998-attribute-id-document.adoc'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_decimal_classification_warning_for_arc42_detail_document
    # Given: a DOC artifact in an arc42 chapter directory whose id uses the
    # wrong chapter prefix
    temp_dir = ROOT.join('tmp/test-decimal-classification')
    docs_dir = temp_dir.join('src/docs')
    chapter_dir = docs_dir.join('arc42/02-architecture-constraints')
    FileUtils.mkdir_p(chapter_dir)
    artifact_path = chapter_dir.join('doc-99001-wrong-class.adoc')
    artifact_path.write(<<~ADOC)
      ---
      id: DOC-99001-wrong-class
      type: Document
      title: Wrong Class
      status: draft
      owner: test
      created: 2026-07-03
      ---
      [[wrong-class]]
      = Wrong Class
    ADOC

    validator = MetamodelValidator.new(
      root: temp_dir,
      docs_dir: docs_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it warns that the id should start with the chapter prefix and a
    # local sequence greater than 000
    assert_includes validator.warnings.join("\n"), "artifact id should start with 'DOC-02' plus a three-digit local sequence greater than 000"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_relations_field_must_be_a_list
    # Given: an artifact whose relations field is a mapping instead of a list
    temp_dir = ROOT.join('tmp/test-relations-not-list')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('adr-200-bad-relations.adoc').write(<<~ADOC)
      ---
      id: ADR-200-bad-relations
      type: ADR
      title: Bad Relations
      status: draft
      created: 2026-07-03
      relations:
        type: relates_to
        target: ADR-200-bad-relations
        status: proposed
      ---
      = Bad Relations
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports that the relations field must be a list
    assert_includes validator.errors.join("\n"), "metadata field 'relations' must be a list"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_relation_entry_must_be_a_mapping
    # Given: an artifact whose relations list contains a bare string entry
    temp_dir = ROOT.join('tmp/test-relation-not-mapping')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('adr-201-string-relation.adoc').write(<<~ADOC)
      ---
      id: ADR-201-string-relation
      type: ADR
      title: String Relation
      status: draft
      created: 2026-07-03
      relations:
        - just a string
      ---
      = String Relation
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports that the relation must be a mapping
    assert_includes validator.errors.join("\n"), 'relation #1 must be a mapping'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_relation_missing_required_keys_reports_errors
    # Given: a relation without type, target, and status
    temp_dir = ROOT.join('tmp/test-relation-missing-keys')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('adr-202-empty-relation.adoc').write(<<~ADOC)
      ---
      id: ADR-202-empty-relation
      type: ADR
      title: Empty Relation
      status: draft
      created: 2026-07-03
      relations:
        - {}
      ---
      = Empty Relation
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports each missing required relation key
    errors = validator.errors.join("\n")
    assert_includes errors, "relation #1 missing required relation key 'type'"
    assert_includes errors, "relation #1 missing required relation key 'target'"
    assert_includes errors, "relation #1 missing required relation key 'status'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_unknown_relation_type_reports_an_error
    # Given: a relation whose type is not defined in the relation schema
    temp_dir = ROOT.join('tmp/test-unknown-relation-type')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('adr-203-unknown-type.adoc').write(<<~ADOC)
      ---
      id: ADR-203-unknown-type
      type: ADR
      title: Unknown Type
      status: draft
      created: 2026-07-03
      relations:
        - type: teleports_to
          target: ADR-203-unknown-type
          status: proposed
      ---
      = Unknown Type
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports the unknown relation type
    assert_includes validator.errors.join("\n"), "uses unknown relation type 'teleports_to'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_front_matter_without_closing_marker_reports_an_error
    # Given: an artifact whose YAML front matter has no closing marker
    temp_dir = ROOT.join('tmp/test-front-matter-open')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('doc-300-open.adoc').write("---\nid: DOC-300-open\ntype: Document\n")

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports the missing closing front matter marker
    assert_includes validator.errors.join("\n"), 'has no closing YAML front matter marker'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_front_matter_that_is_not_a_mapping_reports_an_error
    # Given: an artifact whose front matter is a YAML sequence instead of a mapping
    temp_dir = ROOT.join('tmp/test-front-matter-sequence')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('doc-301-sequence.adoc').write(<<~ADOC)
      ---
      - one
      - two
      ---
      = Sequence Front Matter
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports that the front matter must be a mapping
    assert_includes validator.errors.join("\n"), 'YAML front matter must be a mapping'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_invalid_yaml_front_matter_reports_an_error
    # Given: an artifact with syntactically invalid YAML front matter
    temp_dir = ROOT.join('tmp/test-invalid-yaml')
    FileUtils.mkdir_p(temp_dir)
    temp_dir.join('doc-302-invalid.adoc').write(<<~ADOC)
      ---
      id: [unclosed
      ---
      = Invalid YAML
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports the invalid YAML front matter
    assert_includes validator.errors.join("\n"), 'has invalid YAML front matter'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_missing_docs_target_reports_an_error
    # Given: a docs target path that does not exist
    missing = ROOT.join('tmp/test-does-not-exist')
    FileUtils.rm_rf(missing)

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: missing,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it reports that the docs target does not exist
    assert_includes validator.errors.join("\n"), 'docs target does not exist'
  end

  def test_generated_artifacts_are_skipped_during_scan
    # Given: a chapter with one source artifact and one artifact under a
    # generated directory
    temp_dir = ROOT.join('tmp/test-scan-skips-generated')
    docs_dir = temp_dir.join('src/docs')
    generated_dir = docs_dir.join('generated')
    write_artifact(docs_dir.join('doc-400-source.adoc'), 'DOC-400-source', 'Source Document')
    write_artifact(generated_dir.join('doc-401-generated.adoc'), 'DOC-401-generated', 'Generated Document')

    validator = MetamodelValidator.new(
      root: temp_dir,
      docs_dir: docs_dir,
      relations_schema: SCHEMA
    )

    # When: the validator scans the docs tree
    artifacts = validator.validate

    # Then: only the source artifact is scanned
    scanned_ids = artifacts.map(&:document_id)
    assert_equal ['DOC-400-source'], scanned_ids
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_bidirectional_relation_is_detected
    # Given: two artifacts that each declare a relation pointing at the other
    temp_dir = ROOT.join('tmp/test-bidirectional')
    FileUtils.mkdir_p(temp_dir)

    temp_dir.join('ADR-999-test.adoc').write(<<~ADOC)
      ---
      id: ADR-999-test
      type: ADR
      title: Test ADR
      status: proposed
      owner: test
      created: 2026-06-28
      relations:
        - type: addresses
          target: QS-999-test
          status: proposed
      ---
      = Test ADR
    ADOC

    temp_dir.join('QS-999-test.adoc').write(<<~ADOC)
      ---
      id: QS-999-test
      type: QualityScenario
      title: Test QS
      status: proposed
      owner: test
      created: 2026-06-28
      relations:
        - type: depends_on
          target: ADR-999-test
          status: proposed
      ---
      = Test QS
    ADOC

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    # When: the validator runs
    validator.validate

    # Then: it warns that a bidirectional relation was detected
    warnings_text = validator.warnings.is_a?(Array) ? validator.warnings.join("\n") : ''
    assert_includes warnings_text, 'Bidirectional relation detected: ADR-999-test -> QS-999-test'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_report_states_validation_passed_for_valid_artifacts
    # Given: a directory of well-formed architecture artifacts
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    buffer = StringIO.new

    # When: the validator prints its report
    validator.print_report(artifacts, io: buffer)

    # Then: the report ends with a validation passed line
    assert_includes buffer.string, 'Validation passed.'
  end

  def test_report_states_validation_failed_for_invalid_artifacts
    # Given: a directory containing an invalid artifact
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/invalid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    buffer = StringIO.new

    # When: the validator prints its report
    validator.print_report(artifacts, io: buffer)

    # Then: the report ends with a validation failed line
    assert_includes buffer.string, 'Validation failed.'
  end

  # Feature: Documentation generation

  def test_traceability_matrix_output_is_deterministic
    # Given: a set of validated artifacts with outgoing relations
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    generator = TraceabilityMatrixGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      output_path: ROOT.join('tmp/test-traceability-matrix.adoc')
    )

    # When: the traceability matrix is rendered twice
    first = generator.render(artifacts)
    second = generator.render(artifacts)

    # Then: both renderings are identical and list outgoing and incoming
    # relations with xref links
    assert_equal first, second
    assert_includes first, '| Artifact ID | Type | Title | Status | Outgoing relations | Incoming relations'
    assert_includes first, 'xref:../test/fixtures/valid/ADR-001-valid.adoc#adr-001-valid[ADR-001-valid]'
    assert_includes first, 'relates_to -> xref:../test/fixtures/valid/QS-001-valid.adoc#qs-001-valid[QS-001-valid]'
    assert_includes first, 'xref:../test/fixtures/valid/ADR-001-valid.adoc#adr-001-valid[ADR-001-valid] -> relates_to'
  end

  def test_artifact_index_output_is_deterministic
    # Given: a set of validated artifacts including an ADR with provenance
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    generator = ArtifactIndexGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid')
    )
    definition = ArtifactIndexGenerator::INDEX_DEFINITIONS.fetch('ADR')
    output_path = ROOT.join('tmp/test-doc-09001-adr-index.adoc')

    # When: the ADR artifact index is rendered twice
    first = generator.render(artifacts, definition, output_path)
    second = generator.render(artifacts, definition, output_path)

    # Then: both renderings are identical and include the ADR anchor, status,
    # and derived-from question
    assert_equal first, second
    assert_includes first, '[[adr-index]]'
    assert_includes first, '| ADR | Title | Status | Derived from | Notes'
    assert_includes first, 'xref:adr-001-valid[ADR-001]'
    assert_includes first, '| accepted'
    assert_includes first, '| xref:q-arch-001[Should the valid fixture demonstrate ADR provenance?]'
  end

  def test_open_questions_index_output_is_deterministic
    # Given: the arc42 source tree with open questions
    generator = OpenQuestionsIndexGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('src/docs/arc42')
    )
    output_path = ROOT.join('tmp/test-open-questions.adoc')

    # When: the open questions index is rendered twice
    first = generator.render(output_path)
    second = generator.render(output_path)

    # Then: both renderings are identical and list only the open questions with
    # their roles
    assert_equal first, second
    assert_includes first, '[[open-questions]]'
    assert_includes first, '== Open Questions'
    assert_includes first, '| Question | Role | Topic'
    assert_includes first, 'xref:q-arch-007[Q-ARCH-007]'
    assert_includes first, '| Architect'
    assert_includes first, '| Source fragment location'
    assert_includes first, 'xref:q-arch-008[Q-ARCH-008]'
    assert_includes first, 'xref:q-dev-005[Q-DEV-005]'
    assert_includes first, 'xref:q-ops-007[Q-OPS-007]'
    refute_includes first, 'xref:q-arch-006[Q-ARCH-006]'
  end

  def test_traceability_fragment_includes_outgoing_and_incoming_relations
    # Given: an ADR artifact with an outgoing relation
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    artifacts_by_id = artifacts.each_with_object({}) { |artifact, index| index[artifact.metadata['id']] = artifact }
    generator = TraceabilityFragmentGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid')
    )
    output_path = ROOT.join('tmp/test-adr-traceability.adoc')
    incoming = []

    # When: the traceability fragment is rendered
    content = generator.render(artifacts_by_id.fetch('ADR-001-valid'), artifacts_by_id, incoming, output_path)

    # Then: it contains the matrix heading and the outgoing relation to the
    # quality scenario
    assert_includes content, '[[generated-traceability-adr-001-valid]]'
    assert_includes content, '== Matrix'
    assert_includes content, '| outgoing'
    assert_includes content, '| relates_to'
    assert_includes content, 'xref:qs-001-valid[QS-001-valid]'
  end

  def test_impact_fragment_includes_outgoing_relation_impacts
    # Given: an ADR artifact with an outgoing relation
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    artifacts_by_id = artifacts.each_with_object({}) { |artifact, index| index[artifact.metadata['id']] = artifact }
    generator = ImpactFragmentGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid')
    )
    output_path = ROOT.join('tmp/test-adr-impact.adoc')

    # When: the impact fragment is rendered
    content = generator.render(artifacts_by_id.fetch('ADR-001-valid'), artifacts_by_id, output_path)

    # Then: it contains the impact matrix with the related quality scenario and
    # relation type
    assert_includes content, '[[generated-impact-adr-001-valid]]'
    assert_includes content, '== Matrix'
    assert_includes content, '| Artifact | Impact | Rationale'
    assert_includes content, 'xref:qs-001-valid[QS-001-valid]'
    assert_includes content, '| relates_to'
  end

  def test_traceability_fragment_uses_explicit_anchor_for_numbered_chapter_file
    # Given: an ADR referenced by a numbered arc42 chapter document
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: [
        ROOT.join('src/docs/doc-001-arc42.adoc'),
        ROOT.join('src/docs/arc42')
      ],
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    assert_empty validator.errors

    artifacts_by_id = artifacts.each_with_object({}) { |artifact, index| index[artifact.metadata['id']] = artifact }
    incoming = [
      {
        'source' => 'DOC-09000-architecture-decisions',
        'type' => 'documents',
        'target' => 'ADR-001-asciidoc-primary-source',
        'status' => 'proposed'
      }
    ]
    generator = TraceabilityFragmentGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('src/docs/arc42')
    )
    output_path = ROOT.join('tmp/test-adr-real-traceability.adoc')

    # When: the traceability fragment is rendered
    content = generator.render(
      artifacts_by_id.fetch('ADR-001-asciidoc-primary-source'),
      artifacts_by_id,
      incoming,
      output_path
    )

    # Then: it links the chapter through its explicit anchor rather than the
    # numbered file name
    assert_includes content, 'xref:architecture-decisions[DOC-09000-architecture-decisions]'
    refute_includes content, 'xref:09-architecture-decisions'
  end

  def test_metadata_attribute_fragment_derives_asciidoc_attributes_from_metadata
    # Given: a validated ADR artifact with status and provenance metadata
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    artifact = artifacts.find { |candidate| candidate.metadata['id'] == 'ADR-001-valid' }
    generator = MetadataAttributeFragmentGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid')
    )

    # When: the metadata attribute fragment is rendered
    first = generator.render(artifact)
    second = generator.render(artifact)

    # Then: it exposes the artifact id, status, and derived-from description as
    # AsciiDoc attributes
    assert_equal first, second
    assert_includes first, '// Generated from architecture artifact metadata for ADR-001-valid. Do not edit manually.'
    assert_includes first, ':artifact_id: ADR-001-valid'
    assert_includes first, ':artifact_status: accepted'
    assert_includes first, ':derived_from_description: Should the valid fixture demonstrate ADR provenance?'
  end

  def test_chapter_include_fragment_output_is_deterministic_and_sorted_by_artifact_id
    # Given: an arc42 chapter with two detail documents
    temp_dir = ROOT.join('tmp/test-chapter-includes')
    docs_dir = temp_dir.join('src/docs')
    arc42_dir = docs_dir.join('arc42')
    chapter_dir = arc42_dir.join('01-introduction-and-goals')
    FileUtils.mkdir_p(chapter_dir)

    write_artifact(arc42_dir.join('doc-01000-introduction-and-goals.adoc'), 'DOC-01000-introduction-and-goals', 'Introduction And Goals')
    write_artifact(chapter_dir.join('doc-01002-requirements-overview.adoc'), 'DOC-01002-requirements-overview', 'Requirements Overview')
    write_artifact(chapter_dir.join('doc-01001-quality-goals.adoc'), 'DOC-01001-quality-goals', 'Quality Goals')

    validator = MetamodelValidator.new(
      root: temp_dir,
      docs_dir: docs_dir,
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    generator = ChapterIncludeFragmentGenerator.new(root: temp_dir, docs_dir: docs_dir)
    chapter = artifacts.find { |artifact| artifact.metadata['id'] == 'DOC-01000-introduction-and-goals' }
    details = artifacts.reject { |artifact| artifact == chapter }
    output_path = arc42_dir.join('generated/doc-01000-introduction-and-goals-includes.adoc')

    # When: the chapter include fragment is rendered twice
    first = generator.render(chapter, details, output_path)
    second = generator.render(chapter, details, output_path)

    # Then: both renderings are identical and include the detail documents
    # sorted by artifact id
    assert_equal first, second
    assert_includes first, '// Generated from arc42 chapter metadata for DOC-01000-introduction-and-goals. Do not edit manually.'
    assert_includes first, "\n\ninclude::../01-introduction-and-goals/doc-01001-quality-goals.adoc[]\n\n"
    assert_operator first.index('include::../01-introduction-and-goals/doc-01001-quality-goals.adoc[]'), :<,
                    first.index('include::../01-introduction-and-goals/doc-01002-requirements-overview.adoc[]')
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_chapter_include_fragment_write_skips_generated_artifacts
    # Given: an arc42 chapter with a source detail and a generated detail
    temp_dir = ROOT.join('tmp/test-chapter-includes-ignore-generated')
    docs_dir = temp_dir.join('src/docs')
    arc42_dir = docs_dir.join('arc42')
    chapter_dir = arc42_dir.join('01-introduction-and-goals')
    generated_dir = arc42_dir.join('01-introduction-and-goals/generated')
    FileUtils.mkdir_p([chapter_dir, generated_dir])

    write_artifact(arc42_dir.join('doc-01000-introduction-and-goals.adoc'), 'DOC-01000-introduction-and-goals', 'Introduction And Goals')
    write_artifact(chapter_dir.join('doc-01001-quality-goals.adoc'), 'DOC-01001-quality-goals', 'Quality Goals')
    write_artifact(generated_dir.join('doc-01002-generated-detail.adoc'), 'DOC-01002-generated-detail', 'Generated Detail')

    validator = MetamodelValidator.new(
      root: temp_dir,
      docs_dir: docs_dir,
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    generator = ChapterIncludeFragmentGenerator.new(root: temp_dir, docs_dir: docs_dir)

    # When: the chapter include fragments are written
    output_paths = generator.write(artifacts)
    content = output_paths.first.read

    # Then: only the source detail is included and the generated detail is skipped
    assert_equal 2, artifacts.length
    assert_equal [arc42_dir.join('generated/doc-01000-introduction-and-goals-includes.adoc')], output_paths
    assert_includes content, 'include::../01-introduction-and-goals/doc-01001-quality-goals.adoc[]'
    refute_includes content, 'generated-detail'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  private

  def write_artifact(path, id, title, status: 'draft', owner: 'test', created: '2026-07-03')
    FileUtils.mkdir_p(path.dirname)
    path.write(<<~ADOC)
      ---
      id: #{id}
      type: Document
      title: #{title}
      status: #{status}
      owner: #{owner}
      created: #{created}
      ---
      [[#{id.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/\A-+|-+\z/, '')}]]
      = #{title}
    ADOC
  end
end
