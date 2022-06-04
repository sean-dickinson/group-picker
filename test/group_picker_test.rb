require "minitest/autorun"
require "./lib/group_picker"


describe "Group Picker" do

  describe "#get_new_groups" do

    it "returns evenly distributed groups if the list is divisible by n" do
      picker = GroupPicker.new(list: (1..10).to_a, previous_groups: [], min_group_size: 2)
      groups, _stats = picker.get_new_groups(num_runs: 1)
      assert_equal(5, groups.size)
      assert groups.all? { |group| group.size == 2 }
    end

    it "creates groups larger than n if the list is not divisible by n" do
      picker = GroupPicker.new(list: (1..10).to_a, previous_groups: [], min_group_size: 4)
      groups, _stats = picker.get_new_groups(num_runs: 1)
      assert_equal(2, groups.size)
      assert groups.all? { |group| group.size == 5 }
    end

    it "creates groupings that have no overlap between previous groups when possible" do
      list = (1..4).to_a
      previous_groups = [
        [1,2],
        [3,4],
      ]
      picker = GroupPicker.new(list:, previous_groups:, min_group_size: 2)
      groups, stats = picker.get_new_groups

      expected_stats = { total_rating: 0,
                         total_overlaps: 0,
                         highest_overlap: 0
                        }
      assert_equal expected_stats, stats

      expected_groups = list.permutation(2).to_a - previous_groups.map {|l| l.permutation(2).to_a}.flatten

      assert expected_groups.include?(groups[0])
      assert expected_groups.include?(groups[1])

    end

    it "creates groupings that have the minimal overlap between previous groups" do
      list = (1..6).to_a
      previous_groups = [
        [1,2,3],
        [4,5,6],
      ]
      picker = GroupPicker.new(list:, previous_groups:, min_group_size: 3)
      groups, stats = picker.get_new_groups

      expected_stats = { total_rating: 2,
                         total_overlaps: 2,
                         highest_overlap: 1
                       }

      assert_equal expected_stats, stats
    end

  end

end

