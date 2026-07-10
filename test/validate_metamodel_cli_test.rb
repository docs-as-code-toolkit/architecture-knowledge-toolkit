# frozen_string_literal: true

# Behaviour specification bridge for the validator command-line interface.
#
# Living documentation: features/validation-cli.feature. There is no native BDD
# runner, so each Gherkin scenario is bridged to a classic Minitest method that
# drives scripts/validate-metamodel.rb as a subprocess. The method name is the
# sanitized scenario title, and the Given/When/Then phases appear as comment
# anchors separating Arrange, Act, and Assert.

require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'fileutils'
require 'pathname'

class ValidateMetamodelCliTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join('..').expand_path
  SCRIPT = 'scripts/validate-metamodel.rb'
  RUBY = RbConfig.ruby

  def test_cli_exits_zero_and_reports_success_for_valid_docs
    # Given: the valid fixtures directory
    # When: the validator script runs against it
    stdout, _stderr, status = run_cli('--docs', 'test/fixtures/valid')

    # Then: the process exits with status zero and the report says validation passed
    assert_equal 0, status.exitstatus
    assert_includes stdout, 'Validation passed.'
  end

  def test_cli_exits_nonzero_and_reports_failure_for_invalid_docs
    # Given: the invalid fixtures directory
    # When: the validator script runs against it
    stdout, _stderr, status = run_cli('--docs', 'test/fixtures/invalid')

    # Then: the process exits with a nonzero status and the report says validation failed
    refute_equal 0, status.exitstatus
    assert_includes stdout, 'Validation failed.'
  end

  def test_cli_generate_writes_the_traceability_matrix
    # Given: a temporary copy of the valid fixtures
    workspace = ROOT.join('tmp/test-cli-generate')
    docs_dir = workspace.join('docs')
    FileUtils.mkdir_p(docs_dir)
    Dir.glob(ROOT.join('test/fixtures/valid/*.adoc').to_s).each do |fixture|
      FileUtils.cp(fixture, docs_dir)
    end
    matrix_path = workspace.join('out/traceability-matrix.adoc')

    # When: the validator script runs with generate and an output path
    _stdout, _stderr, status = run_cli(
      '--docs', docs_dir.relative_path_from(ROOT).to_s,
      '--generate',
      '--output', matrix_path.relative_path_from(ROOT).to_s
    )

    # Then: the process exits with status zero and writes the traceability matrix file
    assert_equal 0, status.exitstatus
    assert_path_exists matrix_path
    assert_includes matrix_path.read, '| Artifact ID | Type | Title | Status | Outgoing relations | Incoming relations'
  ensure
    FileUtils.rm_rf(workspace) if workspace
  end

  def test_cli_reports_a_missing_docs_target
    # Given: a docs target path that does not exist
    missing = 'tmp/test-cli-missing-target'
    FileUtils.rm_rf(ROOT.join(missing))

    # When: the validator script runs against it
    stdout, _stderr, status = run_cli('--docs', missing)

    # Then: the process exits with a nonzero status and the report names the missing docs target
    refute_equal 0, status.exitstatus
    assert_includes stdout, 'docs target does not exist'
  end

  private

  def run_cli(*args)
    Open3.capture3(RUBY, SCRIPT, *args, chdir: ROOT.to_s)
  end
end
