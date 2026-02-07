require_relative '../test_helper'

class TestResultGrouper < Minitest::Test
  def test_no_grouping_under_5_results
    entries = 3.times.map { |i| build_entry(name: "task_#{i}", namespace: "ns_#{i}") }
    grouper = ZenApropos::ResultGrouper.new(entries)
    grouped = grouper.group

    assert_equal 1, grouped.keys.length
    assert_nil grouped.keys.first
  end

  def test_groups_by_namespace
    entries = [
      build_entry(name: 'a:one',   namespace: 'a'),
      build_entry(name: 'a:two',   namespace: 'a'),
      build_entry(name: 'a:three', namespace: 'a'),
      build_entry(name: 'b:one',   namespace: 'b'),
      build_entry(name: 'b:two',   namespace: 'b')
    ]

    grouper = ZenApropos::ResultGrouper.new(entries)
    grouped = grouper.group

    assert_includes grouped.keys, 'a'
    assert_includes grouped.keys, 'b'
  end

  def test_skips_filtered_dimension
    entries = [
      build_entry(name: 'a:one',   namespace: 'a', team: 'x'),
      build_entry(name: 'a:two',   namespace: 'a', team: 'y'),
      build_entry(name: 'b:one',   namespace: 'b', team: 'x'),
      build_entry(name: 'b:two',   namespace: 'b', team: 'y'),
      build_entry(name: 'b:three', namespace: 'b', team: 'z')
    ]
    grouper = ZenApropos::ResultGrouper.new(entries, active_filters: { namespace: 'a' })
    # Should not group by namespace since it's already filtered
    refute_equal :namespace, grouper.best_dimension
  end

  def test_sorted_by_size_descending
    entries = [
      build_entry(name: 'b:one',   namespace: 'b'),
      build_entry(name: 'a:one',   namespace: 'a'),
      build_entry(name: 'a:two',   namespace: 'a'),
      build_entry(name: 'a:three', namespace: 'a'),
      build_entry(name: 'b:two',   namespace: 'b')
    ]
    grouper = ZenApropos::ResultGrouper.new(entries)
    grouped = grouper.group
    sizes   = grouped.values.map(&:length)

    assert_equal sizes, sizes.sort.reverse
  end
end
