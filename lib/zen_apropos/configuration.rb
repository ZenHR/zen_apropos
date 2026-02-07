module ZenApropos
  class Configuration
    attr_accessor :tag

    def initialize
      @tag = 'zen'
    end

    def tag_pattern
      /^\s*#\s*@#{Regexp.escape(tag)}\s+/
    end
  end
end
