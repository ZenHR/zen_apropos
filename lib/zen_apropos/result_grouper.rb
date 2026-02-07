# Auto-groups search results by the most useful dimension
#
# Logic:
#   - Skip any dimension used as a filter (it's constant across results)
#   - Pick the dimension with the best cluster distribution
#   - Fall back to namespace if all else is equal
#   - No grouping for < 5 results
module ZenApropos
  class ResultGrouper
    DIMENSIONS = %i[namespace team safety].freeze

    attr_reader :entries, :active_filters

    def initialize(entries, active_filters: {})
      @entries        = entries
      @active_filters = active_filters
    end

    def group
      return { nil => entries } if entries.length < 5

      dimension = best_dimension
      grouped   = entries.group_by { |e| dimension_value(e, dimension) || '(none)' }

      # Sort groups by size descending
      grouped.sort_by { |_key, items| -items.length }.to_h
    end

    def best_dimension
      candidates = DIMENSIONS.reject { |d| active_filters.key?(d) }
      return :namespace if candidates.empty?

      # Pick the dimension that creates the most balanced groups
      # (not 1 giant group, not all singletons)
      candidates.max_by { |d| grouping_score(d) } || :namespace
    end

    private

    def grouping_score(dimension)
      groups = entries.group_by { |e| dimension_value(e, dimension) }

      return 0 if groups.length <= 1        # everything in one group = useless
      return 0 if groups.length == entries.length # all singletons = useless

      # Prefer more groups with reasonable sizes
      groups.length.to_f / entries.length
    end

    def dimension_value(entry, dimension)
      case dimension
      when :namespace then entry.namespace.to_s.empty? ? nil : entry.namespace
      when :team      then entry.team
      when :safety    then entry.safety
      end
    end
  end
end
