require_relative '../test_helper'

class TestQueryParser < Minitest::Test
  def test_plain_text
    result = ZenApropos::QueryParser.parse('employee')

    assert_equal 'employee', result[:text]
    assert_empty result[:filters]
  end

  def test_multi_word_text
    result = ZenApropos::QueryParser.parse('reindex all employees')

    assert_equal 'reindex all employees', result[:text]
  end

  def test_single_filter
    result = ZenApropos::QueryParser.parse('team:search')

    assert_equal '', result[:text]
    assert_equal({ team: 'search' }, result[:filters])
  end

  def test_multiple_filters
    result = ZenApropos::QueryParser.parse('team:finance safety:destructive')

    assert_equal '', result[:text]
    assert_equal({ team: 'finance', safety: 'destructive' }, result[:filters])
  end

  def test_text_with_filter
    result = ZenApropos::QueryParser.parse('employee team:search')

    assert_equal 'employee', result[:text]
    assert_equal({ team: 'search' }, result[:filters])
  end

  def test_namespace_filter
    result = ZenApropos::QueryParser.parse('namespace:indexer')

    assert_equal({ namespace: 'indexer' }, result[:filters])
  end

  def test_keyword_filter
    result = ZenApropos::QueryParser.parse('keyword:elasticsearch')

    assert_equal({ keyword: 'elasticsearch' }, result[:filters])
  end

  def test_unknown_filter_treated_as_text
    result = ZenApropos::QueryParser.parse('foo:bar')

    assert_equal 'foo:bar', result[:text]
    assert_empty result[:filters]
  end

  def test_empty_query
    result = ZenApropos::QueryParser.parse('')

    assert_equal '', result[:text]
    assert_empty result[:filters]
  end

  def test_nil_query
    result = ZenApropos::QueryParser.parse(nil)

    assert_equal '', result[:text]
    assert_empty result[:filters]
  end
end
