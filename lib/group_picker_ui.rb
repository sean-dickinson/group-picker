require_relative 'group_picker'

class GroupPickerUI

  # @param [String] full_list_file - the path to the txt file that contains the full list of names. They should be separated by newlines.
  # @param [String] group_dir_path - the path to the directory where previous groups are generated and stored
  def initialize(full_list_file: 'full_list.txt', group_dir_path: "previous_groups")
    @full_list_file = full_list_file
    @group_dir_path = group_dir_path
    @group_picker = GroupPicker.new(list: get_full_list, previous_groups: get_previous_groups, min_group_size: 5)
  end

  # The main ui of the program (command line)
  def main
    num_runs = 20
    puts "Welcome to the group picker!"
    puts "Press enter to get a new group"
    gets
    while true
      lowest_grouping, stats = @group_picker.get_new_groups(num_runs: num_runs)
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
          num_runs = num_runs == "" ? 20 : num_runs.to_i
        else
          break
        end
      end
    end
    puts "Done!"
  end

  private

  # Loads the previous groups into memory
  # @return [Array<Array<String>>] The previous groups
  def get_previous_groups
    previous_groups = []
    if Dir.exist?(@group_dir_path)
      Dir.glob("#{@group_dir_path}/*.yml").each do |file|
        previous_groups += YAML.load_file(file)
      end
    end
    previous_groups
  end

  # Reads in the full list to make groups from
  # @return [Array<String>] The full list
  def get_full_list
    if File.exist?(@full_list_file)
      File.readlines(@full_list_file).map(&:chomp)
    else
      puts "Warning, no list found!"
      []
    end
  end

  # Gets the next group file name to use
  # @return [String] The next group file name
  def get_next_group_file_name
    num_files = 0
    if Dir.exist?(@group_dir_path)
      num_files = Dir.glob("#{@group_dir_path}/*.yml").size
    else
      Dir.mkdir(@group_dir_path)
    end
    "#{@group_dir_path}/groupings_#{num_files + 1}"
  end
end