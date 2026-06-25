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
    assert_includes first, 'xref:../test/fixtures/valid/ADR-001-valid.adoc[ADR-001-valid]'
    assert_includes first, 'relates_to -> xref:../test/fixtures/valid/QS-001-valid.adoc[QS-001-valid]'
    assert_includes first, 'xref:../test/fixtures/valid/ADR-001-valid.adoc[ADR-001-valid] -> relates_to'
  end
end
