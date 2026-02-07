# Checks rake tasks for missing annotations
#
# Usage:
#   ZenApropos::Linter.new.run                    # Check all rake files
#   ZenApropos::Linter.new(changed_only: true).run # Check only changed files
module ZenApropos
  class Linter
    attr_reader :warnings

    def initialize(changed_only: false)
      @changed_only = changed_only
      @warnings     = []
    end

    def run
      files = rake_files
      files.each { |file| check_file(file) }
      print_results
      warnings.any? ? 1 : 0
    end

    private

    def tag
      ZenApropos.configuration.tag
    end

    def rake_files
      if @changed_only
        changed = `git diff --name-only --diff-filter=ACMR HEAD~1 2>/dev/null`.strip.split("\n")
        changed.select { |f| f.end_with?('.rake') && File.exist?(f) }
      else
        Dir['lib/tasks/**/*.rake'].sort
      end
    end

    def check_file(file_path)
      lines = File.readlines(file_path)

      lines.each_with_index do |line, index|
        next unless line =~ /^\s*desc\s+['"]/
        next if preceding_has_tags?(lines, index)

        task_name = extract_next_task_name(lines, index)
        next unless task_name

        warnings << { file: file_path, line: index + 1, task_name: task_name }
      end
    end

    def preceding_has_tags?(lines, desc_index)
      i = desc_index - 1
      while i >= 0
        line = lines[i]
        return true if ZenApropos.configuration.tag_pattern.match?(line)
        return true if line =~ /^\s*zen_desc\s+/
        break unless line =~ /^\s*(#|$)/
        i -= 1
      end
      false
    end

    def extract_next_task_name(lines, desc_index)
      lines[desc_index + 1..desc_index + 3]&.each do |line|
        return Regexp.last_match(1) if line =~ /^\s*task\s+[:'"]?(\w+)/
      end
      nil
    end

    def print_results
      if warnings.empty?
        puts "\n✅ All rake tasks have @#{tag} annotations.\n"
        return
      end

      puts ''
      warnings.each do |w|
        puts "⚠ #{w[:file]}:#{w[:line]} — task \"#{w[:task_name]}\" has no @#{tag} annotations"
      end
      puts "\n#{warnings.length} task(s) missing annotations. Consider adding @#{tag} tags or using zen_desc.\n"
    end
  end
end
