# Scans and parses .rake files into searchable Entry objects
#
# Handles:
#   - namespace nesting via indentation tracking
#   - desc / zen_desc before task definitions
#   - annotation comment tags (configurable prefix)
#   - task source extraction
module ZenApropos
  module Sources
    class RakeSource < Source
      DEFAULT_PATHS = [
        'lib/tasks/**/*.rake'
      ].freeze

      attr_reader :root_path, :glob_patterns

      def initialize(root_path: Dir.pwd, glob_patterns: DEFAULT_PATHS)
        @root_path     = root_path
        @glob_patterns = glob_patterns
      end

      def entries
        scan.flat_map { |file| parse(file) }
      end

      def scan
        glob_patterns.flat_map do |pattern|
          Dir[File.join(root_path, pattern)].sort
        end
      end

      def parse(file_path)
        lines = File.readlines(file_path)
        extract_tasks(lines, file_path)
      end

      private

      def extract_tasks(lines, file_path)
        tasks               = []
        namespace_stack     = []
        pending_desc        = nil
        pending_annotations = {}
        annotation_lines    = []

        lines.each_with_index do |line, index|
          # Collect annotation tags (e.g. # @zen team: ...)
          if ZenApropos.configuration.tag_pattern.match?(line)
            annotation_lines << line
            next
          end

          # Track namespace open
          if line =~ /^\s*namespace\s+[:'"](\w+)/
            namespace_stack.push(Regexp.last_match(1))
            next
          end

          # Track namespace close (end at same or lower indentation)
          if line =~ /^\s*end\s*$/ && namespace_stack.any?
            # Simple heuristic: count leading spaces to determine if this closes a namespace
            indent    = line[/^\s*/].length
            ns_indent = (namespace_stack.length - 1) * 2
            namespace_stack.pop if indent <= ns_indent
            next
          end

          # Capture desc string
          if line =~ /^\s*desc\s+['"](.*?)['"]/
            pending_desc        = Regexp.last_match(1)
            pending_annotations = AnnotationsParser.parse(annotation_lines) if annotation_lines.any?
            next
          end

          # Capture zen_desc (description + inline annotations)
          if line =~ /^\s*zen_desc\s+['"](.*?)['"]/
            pending_desc        = Regexp.last_match(1)
            pending_annotations = parse_zen_desc_options(lines, index)
            pending_annotations.merge!(AnnotationsParser.parse(annotation_lines)) if annotation_lines.any?
            next
          end

          # Capture task definition
          if line =~ /^\s*task\s+[:'\"]?(\w+)/
            task_name = Regexp.last_match(1)
            full_name = (namespace_stack + [task_name]).join(':')
            source    = extract_task_source(lines, index)
            task_args = extract_task_args(line)

            tasks << Entry.new(
              name:        full_name,
              namespace:   namespace_stack.join(':'),
              description: pending_desc || '',
              file_path:   file_path,
              line_number: index + 1,
              source:      source,
              annotations: pending_annotations,
              args:        task_args
            )

            pending_desc        = nil
            pending_annotations = {}
            annotation_lines    = []
            next
          end

          # Reset annotation accumulator on non-comment, non-blank lines
          annotation_lines = [] unless /^\s*(#|$)/.match?(line)
        end

        tasks
      end

      # Extracts the source code of a task block starting from the task line
      def extract_task_source(lines, start_index)
        depth        = 0
        source_lines = []

        lines[start_index..].each do |line|
          source_lines << line

          # Count block openers (do, {) and closers (end, })
          stripped = line.gsub(/'[^']*'|"[^"]*"/, '') # strip strings
          depth   += stripped.scan(/\bdo\b|\{/).length
          depth   -= stripped.scan(/\bend\b|\}/).length

          break if depth <= 0 && source_lines.length > 1
        end

        source_lines.join
      end

      # Extracts argument names from task definitions like:
      #   task :sync_updates, [:days_ago] => :environment
      #   task :detect, [:limit_count, :verbose] => :environment
      def extract_task_args(line)
        return [] unless line =~ /\[([:\w,\s]+)\]\s*=>/

        Regexp.last_match(1).scan(/:?(\w+)/).flatten
      end

      # Parses keyword arguments from zen_desc calls (team:, safety:, keywords:)
      def parse_zen_desc_options(lines, start_index)
        # Collect continuation lines after zen_desc
        chunk       = lines[start_index..start_index + 5].join
        annotations = {}

        annotations[:team]     = Regexp.last_match(1) if chunk =~ /team:\s*['"](.*?)['"]/
        annotations[:safety]   = Regexp.last_match(1) if chunk =~ /safety:\s*:?(\w+)/
        annotations[:keywords] = Regexp.last_match(1).split(/,\s*/) if chunk =~ /keywords:\s*%w\[([^\]]+)\]/

        annotations
      end
    end
  end
end
