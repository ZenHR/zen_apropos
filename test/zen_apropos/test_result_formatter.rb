require_relative '../test_helper'

class TestResultFormatter < Minitest::Test
  def setup
    @entries = [
      build_entry(name: 'indexer:employees',   namespace: 'indexer',   description: 'Reindex employees', team: 'search', safety: 'safe'),
      build_entry(name: 'indexer:departments', namespace: 'indexer',   description: 'Reindex departments'),
      build_entry(name: 'approvals:sync',      namespace: 'approvals', description: 'Sync approvals', args: ['days_ago'])
    ]

    @grouped   = { 'indexer' => @entries[0..1], 'approvals' => [@entries[2]] }
    @formatter = ZenApropos::ResultFormatter.new(results: @entries, grouped_results: @grouped, query: 'test', group_dimension: :namespace)
  end

  def test_format_rich_contains_header
    output = @formatter.format_rich

    assert_includes output, 'ZenApropos'
    assert_includes output, '3 results'
  end

  def test_format_rich_contains_numbered_entries
    output = @formatter.format_rich

    assert_includes output, '[1]'
    assert_includes output, '[2]'
    assert_includes output, '[3]'
  end

  def test_format_rich_contains_usage
    output = @formatter.format_rich

    assert_includes output, '$ bundle exec rake indexer:employees'
    assert_includes output, '$ bundle exec rake approvals:sync[days_ago]'
  end

  def test_format_rich_contains_safety_badge
    output = @formatter.format_rich

    assert_includes output, 'safe'
    assert_includes output, 'team: search'
  end

  def test_format_plain
    formatter = ZenApropos::ResultFormatter.new(results: @entries, grouped_results: @grouped, query: 'test', group_dimension: nil)
    output    = formatter.format_plain
    lines     = output.split("\n")

    assert_equal 3, lines.length
    assert_includes lines[0], 'indexer:employees'
    assert_includes lines[0], 'search'
  end

  def test_format_plain_missing_annotations
    formatter = ZenApropos::ResultFormatter.new(results: [@entries[1]], grouped_results: { nil => [@entries[1]] }, query: 'test', group_dimension: nil)
    output    = formatter.format_plain

    assert_includes output, '-'
  end

  def test_summary_line
    formatter = ZenApropos::ResultFormatter.new(results: @entries, grouped_results: @grouped, query: 'test', group_dimension: :namespace, elapsed: 0.05)
    output    = formatter.format_rich

    assert_includes output, '3 results across 2 namespaces'
    assert_includes output, '0.05s'
  end
end
