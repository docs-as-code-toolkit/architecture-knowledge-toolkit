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
end
