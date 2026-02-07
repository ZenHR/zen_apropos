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
    # Registry for zen_desc metadata, keyed by description string
    @registry = {}

    class << self
      attr_reader :registry

      def store(description, metadata)
        @registry[description] = metadata
      end

      def lookup(description)
        @registry[description] || {}
      end
    end
  end
end

# Monkey-patch the zen_desc method into the top-level scope where rake files execute
def zen_desc(description, **options)
  ZenApropos::ZenDesc.store(description, options)
  desc description
end
