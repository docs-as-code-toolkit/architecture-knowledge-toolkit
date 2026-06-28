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
    output_path = ROOT.join('tmp/test-adr-index.adoc')

    first = generator.render(artifacts, definition, output_path)
    second = generator.render(artifacts, definition, output_path)

    assert_equal first, second
    assert_includes first, '[[adr-index]]'
    assert_includes first, '| ADR | Title | Status | Notes'
    assert_includes first, 'xref:adr-001-valid[ADR-001]'
    assert_includes first, '| accepted'
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
        ROOT.join('src/docs/arc42.adoc'),
        ROOT.join('src/docs/arc42')
      ],
      relations_schema: SCHEMA
    )
    artifacts = validator.validate
    assert_empty validator.errors

    artifacts_by_id = artifacts.each_with_object({}) { |artifact, index| index[artifact.metadata['id']] = artifact }
    incoming = [
      {
        'source' => 'DOC-109-architecture-decisions',
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

    assert_includes content, 'xref:architecture-decisions[DOC-109-architecture-decisions]'
    refute_includes content, 'xref:09-architecture-decisions'
  end
end
