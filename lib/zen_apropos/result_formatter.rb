# Formats search results for terminal output
#
# Two modes:
#   - Rich (default): colored boxes grouped by dimension
#   - Plain (--plain): pipeable tab-separated output
module ZenApropos
  class ResultFormatter
    SAFETY_BADGES = {
      'safe'        => "\e[32m⚡ safe\e[0m",
      'caution'     => "\e[33m⚠️  caution\e[0m",
      'destructive' => "\e[31m🔴 destructive\e[0m"
    }.freeze

    RESET  = "\e[0m".freeze
    CYAN   = "\e[36m".freeze
    BOLD   = "\e[1m".freeze
    DIM    = "\e[2m".freeze
    YELLOW = "\e[33m".freeze

    attr_reader :results, :grouped_results, :query, :group_dimension, :matches, :elapsed

    def initialize(results:, grouped_results:, query:, group_dimension:, matches: {}, elapsed: 0)
      @results         = results
      @grouped_results = grouped_results
      @query           = query
      @group_dimension = group_dimension
      @matches         = matches
      @elapsed         = elapsed
    end

    def format_rich
      output = []
      output << header_box
      output << ''

      global_index = 0
      grouped_results.each do |group_name, entries|
        output << format_group(group_name, entries, start_index: global_index)
        output << ''
        global_index += entries.length
      end

      output << summary_line
      output.join("\n")
    end

    def format_plain
      results.map do |entry|
        safety = entry.safety || '-'
        team   = entry.team || '-'
        [
          entry.name.ljust(40),
          (entry.description || '').ljust(50),
          safety.ljust(12),
          team
        ].join(' | ')
      end.join("\n")
    end

    private

    def header_box
      title = "ZenApropos — #{results.length} results for \"#{query}\""
      group_label = group_dimension ? "Grouped by: #{group_dimension}" : nil

      width = 60
      lines = []
      lines << "#{CYAN}╭#{'─' * width}╮#{RESET}"
      lines << "#{CYAN}│#{RESET}  #{BOLD}#{title}#{RESET}#{' ' * [0, width - title.length - 2].max}#{CYAN}│#{RESET}"
      if group_label
        lines << "#{CYAN}│#{RESET}  #{DIM}#{group_label}#{RESET}#{' ' * [0, width - group_label.length - 2].max}#{CYAN}│#{RESET}"
      end
      lines << "#{CYAN}╰#{'─' * width}╯#{RESET}"
      lines.join("\n")
    end

    def format_group(group_name, entries, start_index: 0)
      lines = []
      lines << "#{CYAN}┌ #{BOLD}#{group_name}#{RESET} #{'─' * [0, 55 - group_name.to_s.length].max}"

      entries.each_with_index do |entry, i|
        number = start_index + i + 1
        lines << "#{CYAN}│#{RESET} #{DIM}[#{number}]#{RESET} #{BOLD}rake #{entry.name}#{RESET}"
        lines << "#{CYAN}│#{RESET}   #{entry.description}" unless entry.description.empty?
        lines << "#{CYAN}│#{RESET}   #{DIM}$ #{entry.usage}#{RESET}"
        lines << "#{CYAN}│#{RESET}   #{format_badges(entry)}" if entry.safety || entry.team
        lines << format_match_context(entry) if matches[entry.name]
        lines << "#{CYAN}│#{RESET}" if i < entries.length - 1
      end

      lines << "#{CYAN}└#{'─' * 58}#{RESET}"
      lines.join("\n")
    end

    def format_badges(entry)
      parts = []
      parts << SAFETY_BADGES[entry.safety] if entry.safety
      parts << "#{DIM}team: #{entry.team}#{RESET}" if entry.team
      parts.join("  ·  ")
    end

    def format_match_context(entry)
      match_info = matches[entry.name]
      return '' unless match_info && match_info[:source_lines]

      lines = []
      match_info[:source_lines].each do |line_num, content|
        prefix = match_info[:matched_line] == line_num ? "#{YELLOW}>" : " "
        lines << "#{CYAN}│#{RESET}   #{DIM}#{prefix} #{line_num}:#{RESET} #{content.rstrip}"
      end
      lines.join("\n")
    end

    def summary_line
      group_count = grouped_results.keys.length
      group_word  = group_dimension || 'groups'
      elapsed_str = format('%.2fs', elapsed)

      "#{results.length} results across #{group_count} #{group_word}#{group_count > 1 ? 's' : ''} (#{elapsed_str})"
    end
  end
end
