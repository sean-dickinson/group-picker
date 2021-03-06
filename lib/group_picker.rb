require "yaml"

class GroupPicker
  # @param [Array<String, Number>] list - the flat list of entities to make groups out of. Each entry must be unique
  # @param [Array<Array<String, Number>>] previous_groups - The list of previous groupings. This should be a 2 dimensional list, where the inner lists are the previous groupings
  # @param[Number] min_group_size - the minimum size of each generated group.
  # If the full list is not evenly divisible, some groups will pick up the extra members but this minimum size is guaranteed
  def initialize(list:, previous_groups:, min_group_size:)
    @list = list
    @previous_groups = previous_groups
    @min_group_size = min_group_size
  end

  # Gets the new groups to use
  # Will create groups with minimum size of @min_group_size
  # @param [Number] num_runs - the number of times to run the algorithm
  # @return [Array<Array<String>, Hash<Symbol=>Integer>>] An array with the first items being the groupings and the second being the stats
  def get_new_groups(num_runs: 20)
    lowest_rating = -1
    stats = {}
    lowest_grouping = nil
    num_runs.times do |i|
      new_groups = groups_of_at_least_n(@list, @min_group_size)
      group_ratings = new_groups.map { |group| rate_group(group, @previous_groups) }
      group_rating_stats = get_group_rating_stats(group_ratings)
      total_rating = group_rating_stats[:total_rating]
      if total_rating < lowest_rating || lowest_rating == -1
        lowest_rating = total_rating
        stats = group_rating_stats
        lowest_grouping = new_groups.map(&:dup)
      end
    end
    [lowest_grouping, stats]
  end

  private

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


  # Aggregates the stats of the group ratings
  # @param [Array<Hash<Symbol=>Integer>] group_ratings - the group ratings
  # @return [Hash<Symbol=>Integer>] - the stats of the group ratings
  def get_group_rating_stats(group_ratings)
    stats = {
      total_rating: 0,
      total_overlaps: 0,
      highest_overlap: 0
    }
    group_ratings.each do |group_rating|
      stats[:total_rating] += group_rating[:rating]
      stats[:total_overlaps] += group_rating[:overlaps]
      stats[:highest_overlap] = group_rating[:highest_overlap]
    end
    stats
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
  # @return [Hash<Symbol=>Integer] - A hash with the overlays, highest_overlap, and rating of the group
  def rate_group(group, previous_groups)
    if previous_groups.empty?
      return {
        overlaps: 0,
        highest_overlap: 0,
        rating: 0
      }
    end

    all_ratings = previous_groups.map do |previous_group|
      intersection_count = previous_group.intersection(group).length
      if intersection_count < 2
        0
      else
        intersection_count - 1
      end
    end
    {
      overlaps: all_ratings.sum,
      highest_overlap: all_ratings.max,
      rating: all_ratings.sum * all_ratings.max
    }
  end
end

