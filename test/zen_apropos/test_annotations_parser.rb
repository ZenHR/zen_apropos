require_relative '../test_helper'

class TestAnnotationsParser < Minitest::Test
  def test_parses_team
    lines  = ["  # @zen team: hr-platform\n"]
    result = ZenApropos::AnnotationsParser.parse(lines)

    assert_equal 'hr-platform', result[:team]
  end

  def test_parses_safety
    lines  = ["  # @zen safety: caution\n"]
    result = ZenApropos::AnnotationsParser.parse(lines)

    assert_equal 'caution', result[:safety]
  end

  def test_parses_keywords
    lines  = ["  # @zen keywords: sync, permissions, api\n"]
    result = ZenApropos::AnnotationsParser.parse(lines)

    assert_equal ['sync', 'permissions', 'api'], result[:keywords]
  end

  def test_parses_multiple_annotations
    lines = [
      "  # @zen team: search\n",
      "  # @zen safety: safe\n",
      "  # @zen keywords: elasticsearch, reindex\n"
    ]
    result = ZenApropos::AnnotationsParser.parse(lines)

    assert_equal 'search', result[:team]
    assert_equal 'safe', result[:safety]
    assert_equal ['elasticsearch', 'reindex'], result[:keywords]
  end

  def test_ignores_non_zen_comments
    lines  = ["  # This is a regular comment\n"]
    result = ZenApropos::AnnotationsParser.parse(lines)

    assert_empty result
  end

  def test_empty_lines
    result = ZenApropos::AnnotationsParser.parse([])

    assert_empty result
  end
end
