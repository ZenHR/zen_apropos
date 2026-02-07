require_relative '../test_helper'

class TestEngine < Minitest::Test
  def setup
    # Clear cache to avoid cross-test interference
    cache_file = File.join(FIXTURES_PATH, 'tmp', 'zen_apropos_index.cache')
    File.delete(cache_file) if File.exist?(cache_file)
    @engine = ZenApropos::Engine.new(root_path: FIXTURES_PATH)
  end

  def test_search_returns_string
    result = @engine.search('reindex')

    assert_kind_of String, result
  end

  def test_search_finds_by_name
    result = @engine.search('employees')

    assert_includes result, 'indexer:employees'
  end

  def test_search_finds_by_description
    result = @engine.search('Reindex all')

    assert_includes result, 'indexer:employees'
  end

  def test_search_finds_by_source
    result = @engine.search('Employee.reindex')

    assert_includes result, 'indexer:employees'
  end

  def test_search_finds_by_keyword
    result = @engine.search('elasticsearch')

    assert_includes result, 'indexer:employees'
  end

  def test_search_case_insensitive
    result = @engine.search('REINDEX')

    assert_includes result, 'indexer:employees'
  end

  def test_search_no_results
    entries = @engine.search_entries('zzz_nonexistent_zzz')

    assert_empty entries
  end

  def test_filter_by_team
    result = @engine.search('team:search')

    assert_includes result, 'indexer:employees'
    refute_includes result, 'approvals:sync_permissions'
  end

  def test_filter_by_safety
    result = @engine.search('safety:destructive')

    assert_includes result, 'indexer:reset_all'
    refute_includes result, 'indexer:employees'
  end

  def test_filter_by_namespace
    result = @engine.search('namespace:approvals')

    assert_includes result, 'approvals:sync_permissions'
    refute_includes result, 'indexer:employees'
  end

  def test_text_with_filter
    result = @engine.search('reindex team:search')

    assert_includes result, 'indexer:employees'
    refute_includes result, 'approvals:sync_permissions'
  end

  def test_search_entries_returns_array
    entries = @engine.search_entries('reindex')

    assert_kind_of Array, entries
    assert entries.all? { |e| e.is_a?(ZenApropos::Entry) }
  end

  def test_last_results_populated_after_search
    assert_nil @engine.last_results
    @engine.search('reindex')
    refute_nil @engine.last_results
    assert @engine.last_results.length > 0
  end

  def test_plain_mode
    engine = ZenApropos::Engine.new(root_path: FIXTURES_PATH, plain: true)
    result = engine.search('reindex')

    # Plain mode should not have ANSI escape codes for boxes
    refute_includes result, '╭'
    refute_includes result, '╰'
  end

  def test_help_returns_string
    result = @engine.help

    assert_includes result, 'ZenApropos'
    assert_includes result, 'Query Syntax'
  end

  def test_custom_glob_patterns
    engine  = ZenApropos::Engine.new(root_path: FIXTURES_PATH,glob_patterns: ['lib/tasks/indexer.rake'])
    entries = engine.search_entries('sync_permissions')

    assert_empty entries
  end
end
