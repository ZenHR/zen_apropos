# Base class for source adapters
#
# Subclasses must implement:
#   #entries  - returns Array of Entry objects
#   #scan     - returns Array of file paths to process
#   #parse    - returns Array of Entry objects for a single file
module ZenApropos
  class Source
    def entries
      raise NotImplementedError
    end

    def scan
      raise NotImplementedError
    end

    def parse(_file_path)
      raise NotImplementedError
    end
  end
end
