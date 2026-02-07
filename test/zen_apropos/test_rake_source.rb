require_relative '../test_helper'

class TestRakeSource < Minitest::Test
  def setup
    @source = ZenApropos::Sources::RakeSource.new(root_path: FIXTURES_PATH)
  end

  def test_scan_finds_rake_files
    files = @source.scan

    assert_equal 3, files.length
    assert files.all? { |f| f.end_with?('.rake') }
  end

  def test_entries_parses_all_tasks
    entries = @source.entries
    names   = entries.map(&:name).sort

    assert_includes names, 'indexer:employees'
    assert_includes names, 'indexer:departments'
    assert_includes names, 'indexer:reset_all'
    assert_includes names, 'approvals:sync_permissions'
    assert_includes names, 'approvals:skip_nonresponsive'
    assert_includes names, 'db_backup'
  end

  def test_namespace_tracking
    entries   = @source.entries
    employees = entries.find { |e| e.name == 'indexer:employees' }

    assert_equal 'indexer', employees.namespace
  end

  def test_top_level_task_has_empty_namespace
    entries = @source.entries
    backup  = entries.find { |e| e.name == 'db_backup' }

    assert_equal '', backup.namespace
  end

  def test_description_parsing
    entries   = @source.entries
    employees = entries.find { |e| e.name == 'indexer:employees' }

    assert_equal 'Reindex all employees', employees.description
  end

  def test_zen_annotations_parsing
    entries   = @source.entries
    employees = entries.find { |e| e.name == 'indexer:employees' }

    assert_equal 'search', employees.team
    assert_equal 'safe',   employees.safety
    assert_equal ['elasticsearch', 'reindex'], employees.keywords
  end

  def test_task_without_annotations
    entries     = @source.entries
    departments = entries.find { |e| e.name == 'indexer:departments' }

    assert_nil departments.team
    assert_nil departments.safety
    assert_equal [], departments.keywords
  end

  def test_task_args_parsing
    entries = @source.entries
    sync    = entries.find { |e| e.name == 'approvals:sync_permissions' }

    assert_equal ['days_ago'], sync.args
  end

  def test_task_without_args
    entries   = @source.entries
    employees = entries.find { |e| e.name == 'indexer:employees' }

    assert_equal [], employees.args
  end

  def test_source_extraction
    entries   = @source.entries
    employees = entries.find { |e| e.name == 'indexer:employees' }

    assert_includes employees.source, 'Employee.reindex'
  end

  def test_line_number
    entries   = @source.entries
    employees = entries.find { |e| e.name == 'indexer:employees' }

    assert_equal 6, employees.line_number
  end

  def test_zen_desc_parsing
    entries = @source.entries
    backup  = entries.find { |e| e.name == 'db_backup' }

    assert_equal 'Run database backup', backup.description
    assert_equal 'devops', backup.team
  end

  def test_custom_glob_patterns
    source  = ZenApropos::Sources::RakeSource.new(root_path: FIXTURES_PATH,glob_patterns: ['lib/tasks/indexer.rake'])
    entries = source.entries

    assert entries.all? { |e| e.name.start_with?('indexer:') }
  end
end
