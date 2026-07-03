# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'
require_relative '../scripts/validate-metamodel'

class ValidateMetamodelTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join('..').expand_path
  SCHEMA = ROOT.join('metamodel/relations.schema.yaml')

  def test_valid_fixture_passes
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/valid'),
      relations_schema: SCHEMA
    )

    artifacts = validator.validate

    assert_equal 2, artifacts.length
    assert_empty validator.errors
  end

  def test_invalid_fixture_reports_errors
    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: ROOT.join('test/fixtures/invalid'),
      relations_schema: SCHEMA
    )

    validator.validate

    assert_includes validator.errors.join("\n"), "missing required metadata field 'title'"
    assert_includes validator.errors.join("\n"), 'unknown relation key(s): confidence'
    assert_includes validator.errors.join("\n"), "references unknown artifact id 'QS-999-missing'"
  end

  def test_filename_warning_when_artifact_id_does_not_match_filename
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

    validator.validate

    assert_includes validator.warnings.join("\n"), "wrong-name.adoc filename should be 'doc-999-right-name.adoc'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_filename_warning_for_asciidoc_attribute_id
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

    validator.validate

    assert_empty validator.errors
    assert_includes validator.warnings.join("\n"), "legacy-name.adoc filename should be 'doc-998-attribute-id-document.adoc'"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_decimal_classification_warning_for_arc42_detail_document
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

    validator.validate

    assert_includes validator.warnings.join("\n"), "artifact id should start with 'DOC-02' plus a three-digit local sequence greater than 000"
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_traceability_matrix_output_is_deterministic
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

    first = generator.render(artifacts)
    second = generator.render(artifacts)

    assert_equal first, second
    assert_includes first, '| Artifact ID | Type | Title | Status | Outgoing relations | Incoming relations'
    assert_includes first, 'xref:../test/fixtures/valid/ADR-001-valid.adoc#adr-001-valid[ADR-001-valid]'
    assert_includes first, 'relates_to -> xref:../test/fixtures/valid/QS-001-valid.adoc#qs-001-valid[QS-001-valid]'
    assert_includes first, 'xref:../test/fixtures/valid/ADR-001-valid.adoc#adr-001-valid[ADR-001-valid] -> relates_to'
  end

  def test_artifact_index_output_is_deterministic
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

    first = generator.render(artifacts, definition, output_path)
    second = generator.render(artifacts, definition, output_path)

    assert_equal first, second
    assert_includes first, '[[adr-index]]'
    assert_includes first, '| ADR | Title | Status | Notes'
    assert_includes first, 'xref:adr-001-valid[ADR-001]'
    assert_includes first, '| accepted'
  end

  def test_open_questions_index_output_is_deterministic
    generator = OpenQuestionsIndexGenerator.new(
      root: ROOT,
      docs_dir: ROOT.join('src/docs/arc42')
    )
    output_path = ROOT.join('tmp/test-open-questions.adoc')

    first = generator.render(output_path)
    second = generator.render(output_path)

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

    content = generator.render(artifacts_by_id.fetch('ADR-001-valid'), artifacts_by_id, incoming, output_path)

    assert_includes content, '[[generated-traceability-adr-001-valid]]'
    assert_includes content, '| outgoing'
    assert_includes content, '| relates_to'
    assert_includes content, 'xref:qs-001-valid[QS-001-valid]'
  end

  def test_traceability_fragment_uses_explicit_anchor_for_numbered_chapter_file
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

    content = generator.render(
      artifacts_by_id.fetch('ADR-001-asciidoc-primary-source'),
      artifacts_by_id,
      incoming,
      output_path
    )

    assert_includes content, 'xref:architecture-decisions[DOC-09000-architecture-decisions]'
    refute_includes content, 'xref:09-architecture-decisions'
  end

  def test_chapter_include_fragment_output_is_deterministic_and_sorted_by_artifact_id
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

    first = generator.render(chapter, details, output_path)
    second = generator.render(chapter, details, output_path)

    assert_equal first, second
    assert_includes first, '// Generated from arc42 chapter metadata for DOC-01000-introduction-and-goals. Do not edit manually.'
    assert_operator first.index('include::../01-introduction-and-goals/doc-01001-quality-goals.adoc[]'), :<,
                    first.index('include::../01-introduction-and-goals/doc-01002-requirements-overview.adoc[]')
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_chapter_include_fragment_write_skips_generated_artifacts
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

    output_paths = generator.write(artifacts)
    content = output_paths.first.read

    assert_equal 2, artifacts.length
    assert_equal [arc42_dir.join('generated/doc-01000-introduction-and-goals-includes.adoc')], output_paths
    assert_includes content, 'include::../01-introduction-and-goals/doc-01001-quality-goals.adoc[]'
    refute_includes content, 'generated-detail'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def test_bidirectional_relation_detection
    # Create a temporary directory with test artifacts that have bidirectional relations
    temp_dir = ROOT.join('tmp/test-bidirectional')
    FileUtils.mkdir_p(temp_dir)

    # Create ADR-999 with relation to QS-999
    adr_content = <<~ADOC
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
    adr_path = temp_dir.join('ADR-999-test.adoc')
    adr_path.write(adr_content)

    # Create QS-999 with reciprocal relation to ADR-999
    qs_content = <<~ADOC
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
    qs_path = temp_dir.join('QS-999-test.adoc')
    qs_path.write(qs_content)

    validator = MetamodelValidator.new(
      root: ROOT,
      docs_dir: temp_dir,
      relations_schema: SCHEMA
    )

    artifacts = validator.validate

    # Should detect the bidirectional relation
    warnings_text = validator.warnings.is_a?(Array) ? validator.warnings.join("\n") : ""
    assert_includes warnings_text, "Bidirectional relation detected: ADR-999-test -> QS-999-test"

    # Cleanup
    FileUtils.rm_rf(temp_dir)
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
