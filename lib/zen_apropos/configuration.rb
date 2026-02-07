module ZenApropos
  class Configuration
    attr_accessor :tag, :glob_patterns

    def initialize
      @tag           = 'zen'
      @glob_patterns = nil
    end

    def tag_pattern
      /^\s*#\s*@#{Regexp.escape(tag)}\s+/
    end
  end
end
