require_relative '../test_helper'

class TestEntry < Minitest::Test
  def default_entry(**overrides)
    build_entry(
      name: 'indexer:employees', namespace: 'indexer', description: 'Reindex all employees',
      file_path: '/app/lib/tasks/indexer.rake', line_number: 5,
      source: "task employees: :environment do\n  Employee.reindex\nend\n",
      team: 'search', safety: 'safe', keywords: ['elasticsearch', 'reindex'],
      **overrides
    )
  end

  def test_team
    assert_equal 'search', default_entry.team
  end

  def test_safety
    assert_equal 'safe', default_entry.safety
  end

  def test_keywords
    assert_equal ['elasticsearch', 'reindex'], default_entry.keywords
  end

  def test_keywords_defaults_to_empty_array
    entry = build_entry(name: 'indexer:employees')

    assert_equal [], entry.keywords
  end

  def test_usage_without_args
    assert_equal 'bundle exec rake indexer:employees', default_entry.usage
  end

  def test_usage_with_args
    entry = build_entry(name: 'approvals:sync', args: ['days_ago'])

    assert_equal 'bundle exec rake approvals:sync[days_ago]', entry.usage
  end

  def test_usage_with_multiple_args
    entry = build_entry(name: 'task:run', args: ['limit', 'verbose'])

    assert_equal 'bundle exec rake task:run[limit,verbose]', entry.usage
  end

  def test_relative_path
    Dir.stub(:pwd, '/app') do
      assert_equal 'lib/tasks/indexer.rake', default_entry.relative_path
    end
  end
end
