#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'
require 'pathname'
require 'set'
require 'yaml'

class MetamodelValidator
  REQUIRED_FIELDS = %w[id type title status created].freeze

  Artifact = Struct.new(:path, :metadata, keyword_init: true)

  attr_reader :errors, :warnings

  def initialize(root:, docs_dir:, relations_schema:)
    @root = Pathname.new(root).expand_path
    @docs_dir = Pathname.new(docs_dir).expand_path
    @relations_schema = Pathname.new(relations_schema).expand_path
    @errors = []
    @warnings = []
  end

  def validate
    relation_schema = load_yaml(@relations_schema)
    relation_types = relation_schema.fetch('$defs').fetch('relationshipType').fetch('enum')
    relation_keys = relation_schema.fetch('$defs').fetch('relation').fetch('properties').keys

    artifacts = scan_artifacts
    validate_artifacts(artifacts)
    validate_unique_ids(artifacts)
    validate_relations(artifacts, relation_types, relation_keys)

    artifacts
  rescue StandardError => e
    @errors << "validator setup failed: #{e.message}"
    []
  end

  def print_report(artifacts, io: $stdout)
    io.puts 'Architecture metamodel validation report'
    io.puts "Docs directory: #{relative(@docs_dir)}"
    io.puts "Artifacts scanned: #{artifacts.length}"
    io.puts "Errors: #{@errors.length}"
    io.puts "Warnings: #{@warnings.length}"

    unless @errors.empty?
      io.puts
      io.puts 'Errors:'
      @errors.each { |error| io.puts "  - #{error}" }
    end

    unless @warnings.empty?
      io.puts
      io.puts 'Warnings:'
      @warnings.each { |warning| io.puts "  - #{warning}" }
    end

    io.puts
    io.puts(@errors.empty? ? 'Validation passed.' : 'Validation failed.')
  end

  private

  def scan_artifacts
    unless @docs_dir.directory?
      @errors << "docs directory does not exist: #{relative(@docs_dir)}"
      return []
    end

    Dir.glob(@docs_dir.join('**/*.adoc').to_s).sort.map do |path|
      artifact_path = Pathname.new(path)
      Artifact.new(path: artifact_path, metadata: read_front_matter(artifact_path))
    end
  end

  def validate_artifacts(artifacts)
    artifacts.each do |artifact|
      metadata = artifact.metadata
      next unless metadata

      REQUIRED_FIELDS.each do |field|
        next if metadata.key?(field) && !blank?(metadata[field])

        @errors << "#{relative(artifact.path)} missing required metadata field '#{field}'"
      end
    end
  end

  def validate_unique_ids(artifacts)
    by_id = Hash.new { |hash, key| hash[key] = [] }

    artifacts.each do |artifact|
      id = artifact.metadata && artifact.metadata['id']
      by_id[id] << artifact if id
    end

    by_id.each do |id, matches|
      next if matches.length == 1

      paths = matches.map { |artifact| relative(artifact.path) }.join(', ')
      @errors << "duplicate artifact id '#{id}' in #{paths}"
    end
  end

  def validate_relations(artifacts, relation_types, relation_keys)
    known_ids = artifacts.map { |artifact| artifact.metadata && artifact.metadata['id'] }.compact.to_set

    artifacts.each do |artifact|
      metadata = artifact.metadata
      next unless metadata

      relations = metadata['relations'] || []
      unless relations.is_a?(Array)
        @errors << "#{relative(artifact.path)} metadata field 'relations' must be a list"
        next
      end

      relations.each_with_index do |relation, index|
        location = "#{relative(artifact.path)} relation ##{index + 1}"

        unless relation.is_a?(Hash)
          @errors << "#{location} must be a mapping"
          next
        end

        unknown_keys = relation.keys.map(&:to_s) - relation_keys
        unless unknown_keys.empty?
          @errors << "#{location} has unknown relation key(s): #{unknown_keys.sort.join(', ')}"
        end

        type = relation['type']
        target = relation['target']

        @errors << "#{location} missing required relation key 'type'" if blank?(type)
        @errors << "#{location} missing required relation key 'target'" if blank?(target)
        @errors << "#{location} missing required relation key 'status'" if blank?(relation['status'])

        if type && !relation_types.include?(type)
          @errors << "#{location} uses unknown relation type '#{type}'"
        end

        if target && !known_ids.include?(target)
          @errors << "#{location} references unknown artifact id '#{target}'"
        end
      end
    end
  end

  def read_front_matter(path)
    text = path.read
    unless text.start_with?("---\n")
      @errors << "#{relative(path)} missing YAML front matter"
      return nil
    end

    parts = text.split(/^---\s*$/, 3)
    if parts.length < 3
      @errors << "#{relative(path)} has no closing YAML front matter marker"
      return nil
    end

    data = YAML.safe_load(parts[1], permitted_classes: [Date], aliases: false)
    unless data.is_a?(Hash)
      @errors << "#{relative(path)} YAML front matter must be a mapping"
      return nil
    end

    data.transform_keys(&:to_s)
  rescue Psych::SyntaxError => e
    @errors << "#{relative(path)} has invalid YAML front matter: #{e.message.lines.first.strip}"
    nil
  end

  def load_yaml(path)
    YAML.safe_load(path.read, permitted_classes: [Date], aliases: false)
  end

  def blank?(value)
    value.nil? || (value.respond_to?(:empty?) && value.empty?)
  end

  def relative(path)
    Pathname.new(path).expand_path.relative_path_from(@root).to_s
  rescue ArgumentError
    path.to_s
  end
end


if $PROGRAM_NAME == __FILE__
  root = Pathname.new(__dir__).join('..').expand_path
  options = {
    docs_dir: root.join('examples/sample-project/docs'),
    relations_schema: root.join('metamodel/relations.schema.yaml')
  }

  OptionParser.new do |parser|
    parser.banner = 'Usage: ruby scripts/validate-metamodel.rb [options]'
    parser.on('--docs DIR', 'Directory containing architecture .adoc artifacts') do |value|
      options[:docs_dir] = Pathname.new(value)
    end
    parser.on('--relations-schema FILE', 'Path to metamodel/relations.schema.yaml') do |value|
      options[:relations_schema] = Pathname.new(value)
    end
  end.parse!

  validator = MetamodelValidator.new(
    root: root,
    docs_dir: options[:docs_dir],
    relations_schema: options[:relations_schema]
  )
  artifacts = validator.validate
  validator.print_report(artifacts)
  exit(validator.errors.empty? ? 0 : 1)
end
