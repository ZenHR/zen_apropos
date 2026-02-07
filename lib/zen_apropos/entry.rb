# Represents a single searchable rake task entry
module ZenApropos
  Entry = Struct.new(
    :name,        # full task name e.g. "indexer:employees"
    :namespace,   # namespace portion e.g. "indexer"
    :description, # the desc string
    :file_path,   # absolute path to .rake file
    :line_number, # line where task is defined
    :source,      # full source of the task block
    :annotations, # hash of @zen metadata { team:, safety:, keywords: }
    :args,        # array of argument names e.g. ["days_ago"]
    keyword_init: true
  ) do
    def team
      annotations[:team]
    end

    def safety
      annotations[:safety]
    end

    def keywords
      annotations[:keywords] || []
    end

    def relative_path
      file_path.sub("#{Dir.pwd}/", '')
    end

    def usage
      if args&.any?
        "bundle exec rake #{name}[#{args.join(',')}]"
      else
        "bundle exec rake #{name}"
      end
    end
  end
end
