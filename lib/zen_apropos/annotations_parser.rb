# Parses annotation comment tags from lines preceding a task definition
#
# By default, recognizes # @zen tags. Configure with:
#   ZenApropos.configure { |c| c.tag = 'myapp' }
#
# Supported format:
#   # @zen team: hr-platform
#   # @zen safety: caution
#   # @zen keywords: sync, external, api
module ZenApropos
  class AnnotationsParser
    def initialize(lines)
      @lines = lines
    end

    def parse
      annotations = {}

      @lines.each do |line|
        next unless ZenApropos.configuration.tag_pattern.match?(line)
        next unless line =~ /@\w+\s+(\w+):\s*(.+)$/

        key   = Regexp.last_match(1).strip.to_sym
        value = Regexp.last_match(2).strip

        annotations[key] = key == :keywords ? value.split(/,\s*/) : value
      end

      annotations
    end

    class << self
      def parse(lines)
        new(lines).parse
      end
    end
  end
end
