require_relative 'zen_apropos/version'
require_relative 'zen_apropos/configuration'
require_relative 'zen_apropos/entry'
require_relative 'zen_apropos/source'
require_relative 'zen_apropos/annotations_parser'
require_relative 'zen_apropos/query_parser'
require_relative 'zen_apropos/sources/rake_source'
require_relative 'zen_apropos/index'
require_relative 'zen_apropos/result_grouper'
require_relative 'zen_apropos/result_formatter'
require_relative 'zen_apropos/engine'
require_relative 'zen_apropos/linter'
# zen_desc is opt-in: require 'zen_apropos/zen_desc'

module ZenApropos
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
