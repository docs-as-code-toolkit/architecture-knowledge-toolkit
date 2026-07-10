#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'fileutils'
require 'optparse'
require 'pathname'
require 'set'
require 'yaml'

class MetamodelValidator
  REQUIRED_FIELDS = %w[id type title status created].freeze

  Artifact = Struct.new(:path, :metadata, :document_id, keyword_init: true)

  attr_reader :errors, :warnings, :root, :docs_dir

  def initialize(root:, docs_dir:, relations_schema:)
    @root = Pathname.new(root).expand_path
    @docs_paths = Array(docs_dir).map { |path| Pathname.new(path).expand_path }
    @docs_dir = @docs_paths.length == 1 ? @docs_paths.first : @docs_paths
    @relations_schema = Pathname.new(relations_schema).expand_path
    @errors = []
    @warnings = []
  end

  def validate
    @errors = []
    @warnings = []

    relation_schema = load_yaml(@relations_schema)
    relation_types = relation_schema.fetch('$defs').fetch('relationshipType').fetch('enum')
    relation_keys = relation_schema.fetch('$defs').fetch('relation').fetch('properties').keys

    artifacts = scan_artifacts
    validate_artifacts(artifacts)
    validate_filename_matches_id(artifacts)
    validate_decimal_classification(artifacts)
    validate_unique_ids(artifacts)
    validate_relations(artifacts, relation_types, relation_keys)
    detect_bidirectional_relations(artifacts)

    artifacts
  rescue StandardError => e
    @errors << "validator setup failed: #{e.message}"
    []
  end

  def print_report(artifacts, io: $stdout)
    io.puts 'Architecture metamodel validation report'
    io.puts "Docs target: #{docs_target_label}"
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
    paths = @docs_paths.flat_map do |docs_path|
      unless docs_path.exist?
        @errors << "docs target does not exist: #{relative(docs_path)}"
        next []
      end

      if docs_path.directory?
        Dir.glob(docs_path.join('**/*.adoc').to_s)
      else
        [docs_path.to_s]
      end
    end.uniq.sort

    paths.map do |path|
      artifact_path = Pathname.new(path)
      next if generated_path?(artifact_path)

      metadata = read_front_matter(artifact_path)
      Artifact.new(
        path: artifact_path,
        metadata: metadata,
        document_id: document_id_for(artifact_path, metadata)
      )
    end.compact
  end

  def generated_path?(path)
    path.expand_path.each_filename.include?('generated')
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
      id = artifact.document_id
      by_id[id] << artifact if id
    end

    by_id.each do |id, matches|
      next if matches.length == 1

      paths = matches.map { |artifact| relative(artifact.path) }.join(', ')
      @errors << "duplicate artifact id '#{id}' in #{paths}"
    end
  end

  def validate_filename_matches_id(artifacts)
    artifacts.each do |artifact|
      id = artifact.document_id
      next unless id

      expected = "#{normalized_id(id)}.adoc"
      actual = artifact.path.basename.to_s
      next if actual == expected

      @warnings << "#{relative(artifact.path)} filename should be '#{expected}' to match artifact id '#{id}'"
    end
  end

  def validate_decimal_classification(artifacts)
    artifacts.each do |artifact|
      id = artifact.document_id
      next unless id&.start_with?('DOC-')

      arc42_relative = arc42_relative_path(artifact.path)
      next unless arc42_relative

      parts = arc42_relative.each_filename.to_a
      if parts.length == 1
        expected_chapter = chapter_from_root_filename(parts.first)
        next unless expected_chapter

        expected_prefix = "DOC-#{expected_chapter}000-"
        next if id.start_with?(expected_prefix)

        @warnings << "#{relative(artifact.path)} artifact id should start with '#{expected_prefix}' for arc42 chapter #{expected_chapter}"
      elsif parts.first =~ /\A(\d{2})-/
        chapter = Regexp.last_match(1)
        expected_prefix = "DOC-#{chapter}"
        next if id =~ /\ADOC-#{chapter}\d{3}-/ && !id.start_with?("DOC-#{chapter}000-")

        @warnings << "#{relative(artifact.path)} artifact id should start with '#{expected_prefix}' plus a three-digit local sequence greater than 000"
      end
    end
  end

  def validate_relations(artifacts, relation_types, relation_keys)
    known_ids = artifacts.map(&:document_id).compact.to_set

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

  def detect_bidirectional_relations(artifacts)
    # Build a map of all outgoing relations: source_id -> [target_ids]
    outgoing_map = Hash.new { |hash, key| hash[key] = Set.new }
    artifacts.each do |artifact|
      metadata = artifact.metadata
      next unless metadata && metadata['id']
      source_id = metadata['id']
      (metadata['relations'] || []).each do |relation|
        next unless relation.is_a?(Hash)
        target_id = relation['target']
        outgoing_map[source_id] << target_id if target_id
      end
    end

    # Track seen pairs to avoid duplicate warnings (A->B and B->A)
    seen_pairs = Set.new

    # Check for bidirectional patterns: if A -> B exists, check if B -> A exists
    outgoing_map.each do |source_id, target_ids|
      target_ids.each do |target_id|
        # Check if the target has a relation back to the source
        if outgoing_map.key?(target_id) && outgoing_map[target_id].include?(source_id)
          # Normalize pair to avoid duplicate warnings
          pair_key = [source_id, target_id].sort
          next if seen_pairs.include?(pair_key)
          seen_pairs << pair_key
          @warnings << "Bidirectional relation detected: #{source_id} -> #{target_id} and #{target_id} -> #{source_id}. " \
                     "Consider removing the reciprocal relation from one artifact."
        end
      end
    end
  end

  def read_front_matter(path)
    text = path.read
    return nil unless text.start_with?("---\n")

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

  def document_id_for(path, metadata)
    return metadata['id'] if metadata && metadata['id']

    path.each_line.first(20).each do |line|
      return Regexp.last_match(1).strip if line =~ /^:id:\s*(.+?)\s*$/
    end
    nil
  end

  def load_yaml(path)
    YAML.safe_load(path.read, permitted_classes: [Date], aliases: false)
  end

  def blank?(value)
    value.nil? || (value.respond_to?(:empty?) && value.empty?)
  end

  def normalized_id(id)
    id.to_s
      .downcase
      .gsub(/[^a-z0-9]+/, '-')
      .gsub(/\A-+|-+\z/, '')
  end

  def arc42_relative_path(path)
    expanded = path.expand_path
    @docs_paths.each do |docs_path|
      base = docs_path.directory? ? docs_path : docs_path.dirname
      arc42 = base.basename.to_s == 'arc42' ? base : base.join('arc42')
      next unless expanded.to_s.start_with?("#{arc42.expand_path}/")

      return expanded.relative_path_from(arc42.expand_path)
    end
    nil
  rescue ArgumentError
    nil
  end

  def chapter_from_root_filename(filename)
    return Regexp.last_match(1) if filename =~ /\Adoc-(\d{2})000-/
    return Regexp.last_match(1) if filename =~ /\Adoc-(\d{2})\d{3}-/

    nil
  end

  def relative(path)
    Pathname.new(path).expand_path.relative_path_from(@root).to_s
  rescue ArgumentError
    path.to_s
  end

  def docs_target_label
    @docs_paths.map { |path| relative(path) }.join(', ')
  end
end

class TraceabilityMatrixGenerator
  DEFAULT_OUTPUT = 'generated/traceability-matrix.adoc'

  def initialize(root:, docs_dir:, output_path: nil)
    @root = Pathname.new(root).expand_path
    @docs_dir = Array(docs_dir).first
    @docs_dir = Pathname.new(@docs_dir).expand_path
    @output_path = Pathname.new(output_path || @docs_dir.join(DEFAULT_OUTPUT)).expand_path
  end

  def write(artifacts)
    content = render(artifacts)
    FileUtils.mkdir_p(@output_path.dirname)
    @output_path.write(content)
    @output_path
  end

  def render(artifacts)
    artifacts_by_id = artifacts.each_with_object({}) do |artifact, index|
      index[artifact.metadata['id']] = artifact if artifact.metadata
    end
    incoming = incoming_relations(artifacts)
    sorted = artifacts.sort_by { |artifact| [artifact.metadata['type'].to_s, artifact.metadata['id'].to_s] }

    lines = []
    lines << "[[#{anchor_for(@output_path)}]]"
    lines << '= Traceability Matrix'
    lines << ':toc:'
    lines << ':toclevels: 1'
    lines << ''
    lines << '// Generated from architecture artifact metadata. Do not edit manually.'
    lines << ''
    lines << '[cols="1,1,2,1,3,3", options="header"]'
    lines << '|==='
    lines << '| Artifact ID | Type | Title | Status | Outgoing relations | Incoming relations'
    lines << ''

    sorted.each do |artifact|
      metadata = artifact.metadata
      id = metadata['id']
      lines << "| #{artifact_link(artifact)}"
      lines << "| #{cell(metadata['type'])}"
      lines << "| #{cell(metadata['title'])}"
      lines << "| #{cell(metadata['status'])}"
      lines << "| #{relations_cell(metadata['relations'] || [], artifacts_by_id, :outgoing)}"
      lines << "| #{relations_cell(incoming.fetch(id, []), artifacts_by_id, :incoming)}"
      lines << ''
    end

    lines << '|==='
    lines << ''
    lines.join("\n")
  end

  private

  def incoming_relations(artifacts)
    artifacts.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |artifact, index|
      source_id = artifact.metadata['id']
      Array(artifact.metadata['relations']).each do |relation|
        index[relation['target']] << relation.merge('source' => source_id)
      end
    end
  end

  def relations_cell(relations, artifacts_by_id, direction)
    return '-' if relations.empty?

    sorted = relations.sort_by do |relation|
      other_id = direction == :outgoing ? relation['target'] : relation['source']
      [relation['type'].to_s, other_id.to_s]
    end

    sorted.map do |relation|
      if direction == :outgoing
        "#{cell(relation['type'])} -> #{artifact_ref(relation['target'], artifacts_by_id)}"
      else
        "#{artifact_ref(relation['source'], artifacts_by_id)} -> #{cell(relation['type'])}"
      end
    end.join(" +\n")
  end

  def artifact_link(artifact)
    target = artifact.path.expand_path.relative_path_from(@output_path.dirname).to_s
    "xref:#{target}##{artifact_anchor(artifact.path)}[#{cell(artifact.metadata['id'])}]"
  end

  def anchor_for(path)
    normalized_anchor(path.basename(path.extname).to_s)
  end

  def artifact_anchor(path)
    explicit_anchor(path) || anchor_for(path)
  end

  def artifact_ref(id, artifacts_by_id)
    artifact = artifacts_by_id[id]
    return cell(id) unless artifact

    artifact_link(artifact)
  end

  def cell(value)
    value.to_s.gsub('|', '\|').gsub("\n", ' ')
  end

  def explicit_anchor(path)
    text = Pathname.new(path).read
    body = text.start_with?("---\n") ? text.split(/^---\s*$/, 3).last.to_s : text
    body.each_line.first(20).each do |line|
      return Regexp.last_match(1) if line =~ /\[\[([a-z][a-z0-9-]*)\]\]/
      return Regexp.last_match(1) if line =~ /\[#([a-z][a-z0-9-]*)\]/
    end
    nil
  rescue Errno::ENOENT
    nil
  end

  def normalized_anchor(value)
    value.to_s
         .downcase
         .sub(/\A[0-9]+[-_ ]+/, '')
         .gsub(/[^a-z0-9]+/, '-')
         .gsub(/\A-+|-+\z/, '')
  end
end

class ArtifactIndexGenerator
  INDEX_DEFINITIONS = {
    'ADR' => {
      output: '09-architecture-decisions/generated/doc-09001-adr-index.adoc',
      anchor: 'adr-index',
      title: 'ADR Index',
      cols: '1,2,1,2,3',
      columns: ['ADR', 'Title', 'Status', 'Derived from', 'Notes'],
      row: lambda do |artifact, helper|
        metadata = artifact.metadata
        [
          helper.artifact_link(artifact, label: helper.short_id(metadata['id'])),
          helper.cell(metadata['title']),
          helper.cell(metadata['status']),
          helper.derived_from_cell(metadata['derived_from']),
          helper.cell(metadata['summary'])
        ]
      end
    },
    'QualityScenario' => {
      output: '10-quality-requirements/generated/doc-10001-quality-scenarios.adoc',
      anchor: 'quality-scenarios',
      title: 'Quality Scenarios',
      cols: '1,1,2,2,2,2,2,2',
      columns: ['ID', 'Objective', 'Source', 'Stimulus', 'Artifact', 'Environment', 'Response', 'Response measure'],
      row: lambda do |artifact, helper|
        fields = helper.definition_table_fields(artifact)
        [
          helper.artifact_link(artifact, label: helper.short_id(artifact.metadata['id'])),
          helper.relation_targets(artifact, 'refines'),
          helper.cell(fields['Source']),
          helper.cell(fields['Stimulus']),
          helper.cell(fields['Artifact']),
          helper.cell(fields['Environment']),
          helper.cell(fields['Response']),
          helper.cell(fields['Response Measure'])
        ]
      end
    },
    'Risk' => {
      output: '11-risks-and-technical-debt/generated/doc-11001-risks.adoc',
      anchor: 'risks',
      title: 'Risks',
      cols: '1,3,1,1,1,3',
      columns: ['ID', 'Risk', 'Probability', 'Impact', 'Priority', 'Mitigation/action'],
      row: lambda do |artifact, helper|
        fields = helper.definition_table_fields(artifact)
        [
          helper.artifact_link(artifact, label: helper.short_id(artifact.metadata['id'])),
          helper.cell(artifact.metadata['title']),
          helper.cell(fields['Likelihood']),
          helper.cell(fields['Impact']),
          helper.cell(fields['Priority']),
          helper.relation_targets(artifact, 'affects')
        ]
      end
    }
  }.freeze

  attr_reader :output_paths

  def initialize(root:, docs_dir:)
    @root = Pathname.new(root).expand_path
    @docs_dir = output_base(docs_dir)
    @output_paths = []
  end

  def write(artifacts)
    @output_paths = []

    INDEX_DEFINITIONS.each_value do |definition|
      output_path = @docs_dir.join(definition.fetch(:output))
      content = render(artifacts, definition, output_path)
      FileUtils.mkdir_p(output_path.dirname)
      output_path.write(content)
      @output_paths << output_path
    end

    @output_paths
  end

  def render(artifacts, definition, output_path = @docs_dir.join(definition.fetch(:output)))
    type = INDEX_DEFINITIONS.key(definition)
    selected = artifacts.select { |artifact| artifact.metadata && artifact.metadata['type'] == type }
                        .sort_by { |artifact| artifact.metadata['id'].to_s }

    lines = []
    lines << "[[#{definition.fetch(:anchor)}]]"
    lines << "== #{definition.fetch(:title)}"
    lines << ''
    lines << '// Generated from architecture artifact metadata. Do not edit manually.'
    lines << ''
    lines << %([cols="#{definition.fetch(:cols)}", options="header"])
    lines << '|==='
    lines << "| #{definition.fetch(:columns).join(' | ')}"
    lines << ''

    selected.each do |artifact|
      helper = ArtifactRenderHelper.new(output_path, artifacts)
      definition.fetch(:row).call(artifact, helper).each do |value|
        lines << "| #{value}"
      end
      lines << ''
    end

    lines << '|==='
    lines << ''
    lines.join("\n")
  end
end

class OpenQuestionsIndexGenerator
  Question = Struct.new(:anchor, :id, :title, :role, keyword_init: true)

  OUTPUT = '09-architecture-decisions/generated/open-questions.adoc'

  attr_reader :output_paths

  def initialize(root:, docs_dir:, questions_path: nil)
    @root = Pathname.new(root).expand_path
    @docs_dir = output_base(docs_dir)
    @questions_path = Pathname.new(questions_path || @root.join('src/docs/doc-005-questions-and-answers.adoc')).expand_path
    @output_paths = []
  end

  def write
    output_path = @docs_dir.join(OUTPUT)
    content = render(output_path)
    FileUtils.mkdir_p(output_path.dirname)
    output_path.write(content)
    @output_paths = [output_path]
  end

  def render(output_path = @docs_dir.join(OUTPUT))
    questions = parse_open_questions(@questions_path.read)

    lines = []
    lines << '[[open-questions]]'
    lines << '== Open Questions'
    lines << ''
    lines << '// Generated from doc-005-questions-and-answers.adoc. Do not edit manually.'
    lines << ''

    if questions.empty?
      lines << 'No open questions recorded.'
      lines << ''
      return lines.join("\n")
    end

    lines << '[cols="1,1,3", options="header"]'
    lines << '|==='
    lines << '| Question | Role | Topic'
    lines << ''

    questions.each do |question|
      lines << "| xref:#{question.anchor}[#{cell(question.id)}]"
      lines << "| #{cell(question.role)}"
      lines << "| #{cell(question.title)}"
      lines << ''
    end

    lines << '|==='
    lines << ''
    lines.join("\n")
  end

  def parse_open_questions(text)
    role = nil
    pending_anchor = nil
    current = nil
    questions = []

    text.each_line do |line|
      case line
      when /^==\s+Open Questions For\s+(.+?)\s*$/
        role = Regexp.last_match(1)
      when /^\[\[(q-[a-z]+-[0-9]{3})\]\]\s*$/
        pending_anchor = Regexp.last_match(1)
      when /^===\s+(Q-[A-Z]+-[0-9]{3}):\s*(.+?)\s*$/
        current = Question.new(
          anchor: pending_anchor,
          id: Regexp.last_match(1),
          title: Regexp.last_match(2),
          role: role
        )
        pending_anchor = nil
      when /^Answer:\s+Open\.\s*$/
        questions << current if current&.anchor
      end
    end

    questions.sort_by { |question| question.id.to_s }
  end

  private

  def cell(value)
    text = value.to_s.strip
    return '-' if text.empty?

    text.gsub('|', '\|').gsub("\n", ' ')
  end
end

class TraceabilityFragmentGenerator
  attr_reader :output_paths

  def initialize(root:, docs_dir:)
    @root = Pathname.new(root).expand_path
    @output_paths = []
  end

  def write(artifacts)
    artifacts_by_id = artifacts.each_with_object({}) do |artifact, index|
      index[artifact.metadata['id']] = artifact if artifact.metadata
    end
    incoming = incoming_relations(artifacts)

    @output_paths = artifacts.map do |artifact|
      output_path = traceability_output_path(artifact)
      content = render(artifact, artifacts_by_id, incoming.fetch(artifact.metadata['id'], []), output_path)
      FileUtils.mkdir_p(output_path.dirname)
      output_path.write(content)
      output_path
    end
  end

  def render(artifact, artifacts_by_id, incoming, output_path)
    metadata = artifact.metadata
    outgoing = Array(metadata['relations'])
    helper = ArtifactRenderHelper.new(output_path, artifacts_by_id.values)

    lines = []
    lines << "[[generated-traceability-#{anchor_for(artifact.path)}]]"
    lines << '== Matrix'
    lines << ''
    lines << '// Generated from architecture artifact metadata. Do not edit manually.'
    lines << ''
    lines << '[cols="1,1,3", options="header"]'
    lines << '|==='
    lines << '| Direction | Relation | Target'
    lines << ''

    if outgoing.empty? && incoming.empty?
      lines << '| -'
      lines << '| -'
      lines << '| No relations recorded in metadata.'
      lines << ''
    else
      outgoing.sort_by { |relation| [relation['type'].to_s, relation['target'].to_s] }.each do |relation|
        lines << '| outgoing'
        lines << "| #{helper.cell(relation['type'])}"
        lines << "| #{helper.artifact_ref(relation['target'], artifacts_by_id)}"
        lines << ''
      end

      incoming.sort_by { |relation| [relation['type'].to_s, relation['source'].to_s] }.each do |relation|
        lines << '| incoming'
        lines << "| #{helper.cell(relation['type'])}"
        lines << "| #{helper.artifact_ref(relation['source'], artifacts_by_id)}"
        lines << ''
      end
    end

    lines << '|==='
    lines << ''
    lines.join("\n")
  end

  private

  def incoming_relations(artifacts)
    artifacts.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |artifact, index|
      source_id = artifact.metadata['id']
      Array(artifact.metadata['relations']).each do |relation|
        index[relation['target']] << relation.merge('source' => source_id)
      end
    end
  end

  def anchor_for(path)
    normalized_anchor(path.basename(path.extname).to_s)
  end

  def normalized_anchor(value)
    value.to_s
         .downcase
         .sub(/\A[0-9]+[-_ ]+/, '')
         .gsub(/[^a-z0-9]+/, '-')
         .gsub(/\A-+|-+\z/, '')
  end

  def traceability_output_path(artifact)
    artifact.path.dirname.join('generated', "#{anchor_for(artifact.path)}-traceability.adoc")
  end
end

class ImpactFragmentGenerator
  attr_reader :output_paths

  def initialize(root:, docs_dir:)
    @root = Pathname.new(root).expand_path
    @output_paths = []
  end

  def write(artifacts)
    artifacts_by_id = artifacts.each_with_object({}) do |artifact, index|
      index[artifact.metadata['id']] = artifact if artifact.metadata
    end

    @output_paths = artifacts.map do |artifact|
      output_path = impact_output_path(artifact)
      content = render(artifact, artifacts_by_id, output_path)
      FileUtils.mkdir_p(output_path.dirname)
      output_path.write(content)
      output_path
    end
  end

  def render(artifact, artifacts_by_id, output_path)
    metadata = artifact.metadata
    outgoing = Array(metadata['relations'])
    helper = ArtifactRenderHelper.new(output_path, artifacts_by_id.values)

    lines = []
    lines << "[[generated-impact-#{anchor_for(artifact.path)}]]"
    lines << '== Matrix'
    lines << ''
    lines << '// Generated from architecture artifact metadata. Do not edit manually.'
    lines << ''
    lines << '[cols="1,1,3", options="header"]'
    lines << '|==='
    lines << '| Artifact | Impact | Rationale'
    lines << ''

    if outgoing.empty?
      lines << '| -'
      lines << '| -'
      lines << '| No outgoing impact relations recorded in metadata.'
      lines << ''
    else
      outgoing.sort_by { |relation| [relation['type'].to_s, relation['target'].to_s] }.each do |relation|
        lines << "| #{helper.artifact_ref(relation['target'], artifacts_by_id)}"
        lines << "| #{helper.cell(relation['type'])}"
        lines << "| #{helper.cell(relation['rationale'])}"
        lines << ''
      end
    end

    lines << '|==='
    lines << ''
    lines.join("\n")
  end

  private

  def anchor_for(path)
    normalized_anchor(path.basename(path.extname).to_s)
  end

  def normalized_anchor(value)
    value.to_s
         .downcase
         .sub(/\A[0-9]+[-_ ]+/, '')
         .gsub(/[^a-z0-9]+/, '-')
         .gsub(/\A-+|-+\z/, '')
  end

  def impact_output_path(artifact)
    artifact.path.dirname.join('generated', "#{anchor_for(artifact.path)}-impact.adoc")
  end
end

class MetadataAttributeFragmentGenerator
  attr_reader :output_paths

  def initialize(root:, docs_dir:)
    @root = Pathname.new(root).expand_path
    @output_paths = []
  end

  def write(artifacts)
    @output_paths = artifacts.map do |artifact|
      output_path = attributes_output_path(artifact)
      content = render(artifact)
      FileUtils.mkdir_p(output_path.dirname)
      output_path.write(content)
      output_path
    end
  end

  def render(artifact)
    metadata = artifact.metadata
    attributes = {
      'artifact_id' => metadata['id'],
      'artifact_type' => metadata['type'],
      'artifact_title' => metadata['title'],
      'artifact_status' => metadata['status'],
      'artifact_owner' => metadata['owner'],
      'artifact_created' => metadata['created'],
      'artifact_updated' => metadata['updated'],
      'artifact_summary' => metadata['summary'],
      'derived_from_description' => derived_from_description(metadata['derived_from'])
    }

    lines = []
    lines << "// Generated from architecture artifact metadata for #{metadata['id']}. Do not edit manually."
    attributes.each do |name, value|
      next if blank?(value)

      lines << ":#{name}: #{attribute_value(value)}"
    end
    lines << ''
    lines.join("\n")
  end

  private

  def derived_from_description(entries)
    origins = Array(entries).compact
    return nil if origins.empty?

    origins.map do |entry|
      entry.is_a?(Hash) ? entry['description'] : entry
    end.compact.join('; ')
  end

  def attribute_value(value)
    value.to_s.strip.gsub(/\s+/, ' ')
  end

  def blank?(value)
    value.nil? || (value.respond_to?(:empty?) && value.empty?)
  end

  def anchor_for(path)
    normalized_anchor(path.basename(path.extname).to_s)
  end

  def normalized_anchor(value)
    value.to_s
         .downcase
         .sub(/\A[0-9]+[-_ ]+/, '')
         .gsub(/[^a-z0-9]+/, '-')
         .gsub(/\A-+|-+\z/, '')
  end

  def attributes_output_path(artifact)
    artifact.path.dirname.join('generated', "#{anchor_for(artifact.path)}-attributes.adoc")
  end
end

class ChapterIncludeFragmentGenerator
  attr_reader :output_paths

  def initialize(root:, docs_dir:)
    @root = Pathname.new(root).expand_path
    @docs_dir = output_base(docs_dir)
    @output_paths = []
  end

  def write(artifacts)
    @output_paths = chapter_groups(artifacts).map do |chapter, details|
      output_path = include_output_path(chapter)
      content = render(chapter, details, output_path)
      FileUtils.mkdir_p(output_path.dirname)
      output_path.write(content)
      output_path
    end
  end

  def render(chapter, details, output_path = include_output_path(chapter))
    sorted = details.sort_by { |artifact| artifact.metadata['id'].to_s }

    lines = []
    lines << "// Generated from arc42 chapter metadata for #{chapter.metadata['id']}. Do not edit manually."
    lines << ''

    sorted.each do |artifact|
      target = artifact.path.expand_path.relative_path_from(output_path.dirname).to_s
      lines << ''
      lines << "include::#{target}[]"
      lines << ''
    end

    lines.join("\n")
  end

  private

  def chapter_groups(artifacts)
    metadata_artifacts = artifacts.select(&:metadata)
    chapters = metadata_artifacts.select { |artifact| chapter_artifact?(artifact) }
    details_by_chapter = metadata_artifacts
                         .reject { |artifact| chapter_artifact?(artifact) }
                         .reject { |artifact| chapter_number_for(artifact.path).nil? }
                         .group_by { |artifact| chapter_number_for(artifact.path) }

    chapters.each_with_object({}) do |chapter, groups|
      chapter_number = chapter_number_for(chapter.path)
      next unless chapter_number

      details = details_by_chapter.fetch(chapter_number, [])
      groups[chapter] = details unless details.empty?
    end
  end

  def chapter_artifact?(artifact)
    relative = arc42_relative_path(artifact.path)
    return false unless relative

    parts = relative.each_filename.to_a
    # Chapter overview documents live directly below arc42; nested files are
    # detail documents grouped by their numbered chapter directory.
    parts.length == 1 && parts.first =~ /\Adoc-\d{2}000-.*\.adoc\z/
  end

  def chapter_number_for(path)
    relative = arc42_relative_path(path)
    return nil unless relative

    parts = relative.each_filename.to_a
    if parts.length == 1 && parts.first =~ /\Adoc-(\d{2})000-/
      Regexp.last_match(1)
    elsif parts.first =~ /\A(\d{2})-/
      Regexp.last_match(1)
    end
  end

  def arc42_relative_path(path)
    expanded = path.expand_path
    return expanded.relative_path_from(@docs_dir) if expanded.to_s.start_with?("#{@docs_dir}/")

    nil
  rescue ArgumentError
    nil
  end

  def include_output_path(chapter)
    @docs_dir.join('generated', "#{chapter.path.basename(chapter.path.extname)}-includes.adoc")
  end
end

def output_base(docs_dir)
  targets = Array(docs_dir).map { |path| Pathname.new(path).expand_path }
  directory = targets.find(&:directory?)
  return directory.join('arc42') if directory && directory.basename.to_s == 'docs' && directory.join('arc42').directory?

  directory || targets.first.dirname
end

class ArtifactRenderHelper
  def initialize(output_path, artifacts)
    @output_path = Pathname.new(output_path).expand_path
    @artifacts_by_id = artifacts.each_with_object({}) do |artifact, index|
      index[artifact.metadata['id']] = artifact if artifact.metadata
    end
  end

  def artifact_link(artifact, label: nil)
    "xref:#{artifact_anchor(artifact.path)}[#{cell(label || artifact.metadata['id'])}]"
  end

  def artifact_ref(id, artifacts_by_id = @artifacts_by_id)
    artifact = artifacts_by_id[id]
    return cell(id) unless artifact

    artifact_link(artifact)
  end

  def relation_targets(artifact, type)
    matches = Array(artifact.metadata['relations']).select { |relation| relation['type'] == type }
    return '-' if matches.empty?

    matches.map { |relation| artifact_ref(relation['target']) }.join(" +\n")
  end

  def derived_from_cell(entries)
    origins = Array(entries).compact
    return '-' if origins.empty?

    origins.map { |entry| derived_from_entry(entry) }.join(" +\n")
  end

  def definition_table_fields(artifact)
    body = artifact.path.read.split(/^---\s*$/, 3).last.to_s
    fields = {}
    body.scan(/^\|\s*([^|\n]+?)\s*\|\s*([^|\n]+(?:\n(?!\|===|\| [^|]+\s*\|).*)*)/m) do |key, value|
      fields[key.strip] = value.strip.gsub(/\s+/, ' ').delete_suffix('.')
    end
    fields
  end

  def short_id(id)
    id.to_s.split('-', 3).first(2).join('-')
  end

  def cell(value)
    text = value.to_s.strip
    return '-' if text.empty?

    text.gsub('|', '\|').gsub("\n", ' ')
  end

  private

  def derived_from_entry(entry)
    return cell(entry) unless entry.is_a?(Hash)

    description = entry['description'].to_s.strip
    label = description.empty? ? derived_from_fallback_label(entry) : description

    if present?(entry['target'])
      target = artifact_ref(entry['target'])
      description.empty? ? target : "#{cell(label)} (#{target})"
    elsif present?(entry['anchor'])
      "xref:#{cell(entry['anchor'])}[#{cell(label)}]"
    elsif present?(entry['uri'])
      "link:#{cell(entry['uri'])}[#{cell(label)}]"
    elsif present?(entry['path'])
      "#{cell(label)} (`#{cell(entry['path'])}`)"
    else
      cell(label)
    end
  end

  def derived_from_fallback_label(entry)
    entry.values.compact.map(&:to_s).find { |value| !value.strip.empty? }.to_s
  end

  def present?(value)
    value.respond_to?(:empty?) ? !value.empty? : !value.nil?
  end

  def anchor_for(path)
    normalized_anchor(path.basename(path.extname).to_s)
  end

  def artifact_anchor(path)
    explicit_anchor(path) || anchor_for(path)
  end

  def explicit_anchor(path)
    text = Pathname.new(path).read
    body = text.start_with?("---\n") ? text.split(/^---\s*$/, 3).last.to_s : text
    body.each_line.first(20).each do |line|
      return Regexp.last_match(1) if line =~ /\[\[([a-z][a-z0-9-]*)\]\]/
      return Regexp.last_match(1) if line =~ /\[#([a-z][a-z0-9-]*)\]/
    end
    nil
  rescue Errno::ENOENT
    nil
  end

  def normalized_anchor(value)
    value.to_s
         .downcase
         .sub(/\A[0-9]+[-_ ]+/, '')
         .gsub(/[^a-z0-9]+/, '-')
         .gsub(/\A-+|-+\z/, '')
  end
end

class DocumentationGenerator
  def initialize(root:, docs_dir:, matrix_output_path: nil)
    @root = Pathname.new(root).expand_path
    @docs_dir = Array(docs_dir)
    @matrix_output_path = matrix_output_path
  end

  def write(artifacts)
    written = []
    metadata_artifacts = artifacts.select(&:metadata)
    matrix = TraceabilityMatrixGenerator.new(
      root: @root,
      docs_dir: @docs_dir,
      output_path: @matrix_output_path
    )
    written << matrix.write(metadata_artifacts)

    artifact_indexes = ArtifactIndexGenerator.new(root: @root, docs_dir: @docs_dir)
    written.concat(artifact_indexes.write(metadata_artifacts))

    open_questions = OpenQuestionsIndexGenerator.new(root: @root, docs_dir: @docs_dir)
    written.concat(open_questions.write)

    chapter_includes = ChapterIncludeFragmentGenerator.new(root: @root, docs_dir: @docs_dir)
    written.concat(chapter_includes.write(metadata_artifacts))

    metadata_attributes = MetadataAttributeFragmentGenerator.new(root: @root, docs_dir: @docs_dir)
    written.concat(metadata_attributes.write(metadata_artifacts))

    impact = ImpactFragmentGenerator.new(root: @root, docs_dir: @docs_dir)
    written.concat(impact.write(metadata_artifacts))

    traceability = TraceabilityFragmentGenerator.new(root: @root, docs_dir: @docs_dir)
    written.concat(traceability.write(metadata_artifacts))

    written
  end
end


if $PROGRAM_NAME == __FILE__
  root = Pathname.new(__dir__).join('..').expand_path
  default_docs_targets = [
    root.join('src/docs')
  ]
  options = {
    docs_dir: default_docs_targets,
    relations_schema: root.join('metamodel/relations.schema.yaml'),
    generate: false,
    output: nil,
    custom_docs: false
  }

  OptionParser.new do |parser|
    parser.banner = 'Usage: ruby scripts/validate-metamodel.rb [options]'
    parser.on('--docs PATH', 'Architecture .adoc file or directory; may be repeated') do |value|
      options[:docs_dir] = [] if options[:docs_dir] == default_docs_targets
      options[:docs_dir] << Pathname.new(value)
      options[:custom_docs] = true
    end
    parser.on('--relations-schema FILE', 'Path to metamodel/relations.schema.yaml') do |value|
      options[:relations_schema] = Pathname.new(value)
    end
    parser.on('--generate', 'Generate derived AsciiDoc indexes and traceability fragments after successful validation') do
      options[:generate] = true
    end
    parser.on('--output FILE', 'Generated traceability matrix path; legacy override for --generate') do |value|
      options[:output] = Pathname.new(value)
    end
  end.parse!

  validator = MetamodelValidator.new(
    root: root,
    docs_dir: options[:docs_dir],
    relations_schema: options[:relations_schema]
  )
  artifacts = validator.validate
  validator.print_report(artifacts)
  exit(1) unless validator.errors.empty?

  if options[:generate]
    output_path = options[:output] || if options[:custom_docs]
      first_docs_target = Pathname.new(Array(options[:docs_dir]).first)
      output_base = first_docs_target.directory? ? first_docs_target : first_docs_target.dirname
      output_base.join('generated/traceability-matrix.adoc')
    else
      root.join('src/docs/generated/traceability-matrix.adoc')
    end
    generator = DocumentationGenerator.new(
      root: root,
      docs_dir: options[:docs_dir],
      matrix_output_path: output_path
    )
    output_paths = generator.write(artifacts)
    output_paths.each do |path|
      puts "Generated: #{path.relative_path_from(root)}"
    end
  end
end
