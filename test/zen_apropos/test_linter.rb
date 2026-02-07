require_relative '../test_helper'

class TestLinter < Minitest::Test
  def lint_rake_content(filename, content)
    Dir.mktmpdir do |dir|
      tasks_dir = File.join(dir, 'lib', 'tasks')
      FileUtils.mkdir_p(tasks_dir)
      File.write(File.join(tasks_dir, filename), content)

      Dir.chdir(dir) do
        ZenApropos::Linter.new.run
      end
    end
  end

  def test_finds_unannotated_tasks
    Dir.chdir(FIXTURES_PATH) do
      linter = ZenApropos::Linter.new
      linter.run
      unannotated_names = linter.warnings.map { |w| w[:task_name] }
      assert_includes unannotated_names, 'departments'
      assert_includes unannotated_names, 'skip_nonresponsive'
    end
  end

  def test_does_not_flag_annotated_tasks
    Dir.chdir(FIXTURES_PATH) do
      linter = ZenApropos::Linter.new
      linter.run
      flagged_names = linter.warnings.map { |w| w[:task_name] }
      refute_includes flagged_names, 'employees'
      refute_includes flagged_names, 'sync_permissions'
      refute_includes flagged_names, 'reset_all'
    end
  end

  def test_returns_0_when_all_annotated
    exit_code = lint_rake_content('good.rake', <<~RAKE)
      # @zen team: core
      desc 'A well annotated task'
      task good: :environment do
      end
    RAKE

    assert_equal 0, exit_code
  end

  def test_returns_1_when_unannotated
    exit_code = lint_rake_content('bad.rake', <<~RAKE)
      desc 'No annotations here'
      task bad: :environment do
      end
    RAKE

    assert_equal 1, exit_code
  end

  def test_recognizes_zen_desc_as_annotated
    exit_code = lint_rake_content('dsl.rake', <<~RAKE)
      zen_desc 'A zen_desc task', team: 'core'
      task dsl_task: :environment do
      end
    RAKE

    assert_equal 0, exit_code
  end
end
