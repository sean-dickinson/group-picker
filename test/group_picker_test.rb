require "minitest/autorun"
require "./lib/group_picker"


describe "Group Picker Functionality" do

  describe "#get_previous_groups" do
    it "Should return an empty array if no folder exists or if it is empty" do
      Dir.stub :exists?, false do
        assert_equal [], get_previous_groups
        Dir.stub :glob, [] do
          assert_equal [], get_previous_groups
        end
      end
    end
  end

  describe "#groups_of_at_least_n" do
    it "returns evenly distributed groups if the list is divisible by n" do
      list = (1..10).to_a
      groups = groups_of_at_least_n(list, 2)
      assert_equal(5, groups.size)
      assert groups.all? { |group| group.size == 2 }
    end

    it "creates groups larger than n if the list is not divisible by n" do
      list = (1..10).to_a
      groups = groups_of_at_least_n(list, 4)
      assert_equal(2, groups.size)
      assert groups.all? { |group| group.size == 5 }
    end
  end

  describe "#rate_group" do
    it "returns the correct rating of the group" do
      previous_groups = [[1,2,3,4], [5,6,7,8]]
      assert_equal 2, rate_group([1,5,3,7], previous_groups)
      assert_equal 9, rate_group([1,2,3,4,5], previous_groups)
      assert_equal 0, rate_group([9,10,11,12], previous_groups)
    end
  end
end

