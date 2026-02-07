# Search engine that ties together parsing, indexing, searching, grouping, and formatting
#
# Usage:
#   ZenApropos::Engine.new.search("employee")
#   ZenApropos::Engine.new.search("team:finance safety:destructive")
module ZenApropos
  class Engine
    attr_reader :index, :plain, :last_results

    def initialize(root_path: Dir.pwd, plain: false, glob_patterns: nil)
      source = Sources::RakeSource.new(
        root_path: root_path,
        glob_patterns: glob_patterns || Sources::RakeSource::DEFAULT_PATHS
      )
      @index = Index.new(source: source)
      @plain = plain
    end

    def help
      <<~HELP

        🔍 ZenApropos - Rake Task Search

        Usage:
          CLI:     zen_apropos <query> [--plain]
          Console: apropos "query"

        Query Syntax:
          Free text      Search task names, descriptions, annotations, and source
          team:<name>    Filter by team annotation
          safety:<level> Filter by safety level (safe, caution, destructive)
          namespace:<ns> Filter by rake namespace
          keyword:<word> Filter by declared keyword

        Examples:
          apropos "employee"
          apropos "reindex"
          apropos "namespace:indexer"
          apropos "team:finance safety:destructive"
          apropos "Employee.find_each"
          apropos "reindex", plain: true

      HELP
    end

    def search(raw_query)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      parsed  = QueryParser.parse(raw_query)
      results = find_entries(parsed)
      matches = build_match_context(results, parsed[:text])

      grouper         = ResultGrouper.new(results, active_filters: parsed[:filters])
      grouped         = grouper.group
      group_dimension = results.length >= 5 ? grouper.best_dimension : nil

      # Store results in display order so interactive viewer matches the numbered output
      @last_results = grouped.values.flatten

      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

      formatter = ResultFormatter.new(
        results:         results,
        grouped_results: grouped,
        query:           raw_query,
        group_dimension: group_dimension,
        matches:         matches,
        elapsed:         elapsed
      )

      plain ? formatter.format_plain : formatter.format_rich
    end

    # Returns raw filtered results (for interactive mode)
    def search_entries(raw_query)
      find_entries(QueryParser.parse(raw_query))
    end

    private

    def find_entries(parsed)
      results = filter(index.entries, parsed)
      text_search(results, parsed[:text])
    end

    def filter(entries, parsed)
      filters = parsed[:filters]
      return entries if filters.empty?

      entries.select do |entry|
        filters.all? do |key, value|
          case key
          when :team      then entry.team&.downcase == value.downcase
          when :safety    then entry.safety&.downcase == value.downcase
          when :namespace then entry.namespace&.downcase == value.downcase
          when :keyword   then entry.keywords.any? { |k| k.downcase == value.downcase }
          else true
          end
        end
      end
    end

    def text_search(entries, text)
      return entries if text.nil? || text.empty?

      query_lower = text.downcase

      entries.select do |entry|
        entry.name.downcase.include?(query_lower)        ||
          entry.description.downcase.include?(query_lower) ||
          entry.keywords.any? { |k| k.downcase.include?(query_lower) } ||
          entry.source.downcase.include?(query_lower)
      end
    end

    # Builds 3-line source context for entries that matched on source code
    def build_match_context(entries, text)
      return {} if text.nil? || text.empty?

      context     = {}
      query_lower = text.downcase

      entries.each do |entry|
        # Only show source context if the match was in source (not name/desc)
        next if entry.name.downcase.include?(query_lower)
        next if entry.description.downcase.include?(query_lower)

        next unless entry.source.downcase.include?(query_lower)

        source_lines = entry.source.lines
        source_lines.each_with_index do |line, i|
          next unless line.downcase.include?(query_lower)

          actual_line = entry.line_number + i
          context_lines = {}

          # 1 line before
          if i > 0
            context_lines[actual_line - 1] = source_lines[i - 1]
          end
          # matched line
          context_lines[actual_line] = line
          # 1 line after
          if i < source_lines.length - 1
            context_lines[actual_line + 1] = source_lines[i + 1]
          end

          context[entry.name] = { source_lines: context_lines, matched_line: actual_line }
          break # only show first match
        end
      end

      context
    end
  end
end
