require "yaml"


def get_previous_groups
  previous_groups = []
  if Dir.exists?("./previous_groups")
    Dir.glob("./previous_groups/*.yml").each do |file|
      previous_groups << YAML.load_file(file)
    end
  end
  previous_groups
end


# Divides the list into groups >= n
# @param [Array<String>] list - the full list to divide into groups
# @param [Integer] n - the minimum size of each group
# @return [Array<Array<String>] - the list divided into groups
def groups_of_at_least_n(list, n)
  if list.length < n
    raise ArgumentError, "List must be at least #{n} elements long"
  end
  groups = list.shuffle.each_slice(n).to_a
  if groups.last.length < n
    too_small_group = groups.pop
    too_small_group.each_with_index do |member, index|
      groups[index % groups.size] << member
    end
  end
  groups
end

# Rates the group based on its difference from the previous groups
# Lower ratings are better
# --
# The rating algorithm is to gather the number of overlapping elements between the group and each of the previous groups
# Then we take the sum of these overlaps and multiply by the maximum number of overlapping elements in the list
# This algorithm is designed to maximize groups with the fewest overlaps
# --
# @param [Array<String>] group - the group to rate
# @param [Array<Array<String>>] previous_groups - the previous groups to compare against
# @return [Integer] - the rating of the group
def rate_group(group, previous_groups)
  all_ratings = previous_groups.map do |previous_group|
    intersection_count = previous_group.intersection(group).length
    if intersection_count < 2
      0
    else
      intersection_count - 1
    end
  end
  all_ratings.sum * all_ratings.max
end
