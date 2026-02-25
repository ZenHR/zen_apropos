# DSL extension for Rake that adds metadata to task descriptions
#
# Usage in .rake files:
#   zen_desc 'Employees reindex',
#     keywords: %w[search elasticsearch reindex],
#     team: 'search',
#     safety: :safe
#
#   task employees: :environment do
#     ...
#   end
#
# Calls the original `desc` under the hood so `rake -T` still works
module ZenApropos
  module ZenDesc
    @pending = nil

    class << self
      # Returns and clears the pending metadata set by the last zen_desc call.
      # Works like Rake's own desc — the next task definition consumes it.
      def consume
        meta     = @pending
        @pending = nil
        meta || {}
      end

      def store(metadata)
        @pending = metadata
      end
    end
  end
end

# Monkey-patch the zen_desc method into the top-level scope where rake files execute
def zen_desc(description, **options)
  ZenApropos::ZenDesc.store(options)
  desc description
end
