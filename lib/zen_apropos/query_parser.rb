# Parses a search query into structured filters and free-text terms
#
# Examples:
#   "employee"                        => { text: "employee", filters: {} }
#   "team:finance safety:destructive" => { text: "", filters: { team: "finance", safety: "destructive" } }
#   "employee team:search"            => { text: "employee", filters: { team: "search" } }
module ZenApropos
  class QueryParser
    FILTER_KEYS = %w[team safety namespace keyword].freeze

    def initialize(raw_query)
      @raw_query = raw_query.to_s.strip
    end

    def parse
      filters = {}
      text_parts = []

      @raw_query.split(/\s+/).each do |token|
        key, value = token.split(':', 2)

        if FILTER_KEYS.include?(key) && value && !value.empty?
          filters[key.to_sym] = value
        else
          text_parts << token
        end
      end

      { text: text_parts.join(' '), filters: filters }
    end

    class << self
      def parse(raw_query)
        new(raw_query).parse
      end
    end
  end
end
