require "yaml"

MIN_GROUP_SIZE = 4
PREVIOUS_GROUP_DIR_PATH = "previous_groups"

# Loads the previous groups into memory
# @return [Array<Array<String>>] The previous groups
def get_previous_groups
  previous_groups = []
  if Dir.exist?(PREVIOUS_GROUP_DIR_PATH)
    Dir.glob("#{PREVIOUS_GROUP_DIR_PATH}/*.yml").each do |file|
      previous_groups += YAML.load_file(file)
    end
  end
  previous_groups
end


# Reads in the full list to make groups from
# @return [Array<String>] The full list
def get_full_list(path = "full_list.txt")
  if File.exist?(path)
    File.readlines(path).map(&:chomp)
  else
    []
  end
end

# Gets the next group file name to use
# @return [String] The next group file name
def get_next_group_file_name
  num_files = 0
  if Dir.exist?(PREVIOUS_GROUP_DIR_PATH)
    num_files = Dir.glob("#{PREVIOUS_GROUP_DIR_PATH}/*.yml").size
  else
    Dir.mkdir(PREVIOUS_GROUP_DIR_PATH)
  end
  "#{PREVIOUS_GROUP_DIR_PATH}/groupings_#{num_files + 1}"
end


# Gets the new groups to use
# Will create groups with minimum size of  MIN_GROUP_SIZE
# @param [Integer] num_runs - The number of times to run the algorithm
# @return [Array<Array<String>, Hash<Symbol=>Integer>>] An array with the first items being the groupings and the second being the stats
def get_new_groups(num_runs)
  full_list = get_full_list
  previous_groups = get_previous_groups
  lowest_rating = -1
  stats = {}
  lowest_grouping = nil
  num_runs.times do|i|
    new_groups = groups_of_at_least_n(full_list, MIN_GROUP_SIZE)
    group_ratings = new_groups.map { |group| rate_group(group, previous_groups) }
    group_rating_stats = get_group_rating_stats(group_ratings)
    total_rating = group_rating_stats[:total_rating]
    puts "Run: #{i}: Total rating: #{total_rating}"
    if total_rating < lowest_rating || lowest_rating == -1
      lowest_rating = total_rating
      stats = group_rating_stats
      lowest_grouping = new_groups.map(&:dup)
    end
  end
  [lowest_grouping, stats]
end

def ui
  puts "Welcome to the group picker!"
  puts "Press enter to get a new group"
  gets
  num_runs = 5
  while true
    lowest_grouping, stats = get_new_groups(num_runs)
    puts "Results of best run: "
    pp stats
    puts "Would you like to keep this run? (y/n)"
    keep = gets.chomp
    if keep == "y"
      puts "Writing to file..."
      file_name = get_next_group_file_name

      yaml_file = File.new("#{file_name}.yml", "w")
      YAML::dump(lowest_grouping, yaml_file)
      yaml_file.close

      txt_file = File.new("#{file_name}.txt", "w")
      lowest_grouping.each do |group|
        txt_file.write group.join("\n")
        txt_file.write "\n\n"
      end
      txt_file.close
      break
    else
      puts "Would you like to run the algorithm again? (y/n)"
      again = gets.chomp
      if again == "y"
        puts "How many times would you like to run the algorithm: (100 is default)"
        num_runs = gets.chomp
        num_runs = num_runs == "" ? 100 : num_runs.to_i
      else
        break
      end
    end
  end
  puts "Done!"
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