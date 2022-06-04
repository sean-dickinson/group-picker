# Group Picker
A simple ruby script to randomly generate a list of groups of a certain size from a given list. 
The goal is to minimize the number of overlapping members compared to previous groups already generated.

This particular project is used by By the Pixel to generate "pods" for team members to meet up for fun social activities, 
and thus it is attempting to ensure that each team member gets exposed to as many different team members as possible.

See the code documentation for a description of the algorithm being used.

Previous groups are expected to be stored in the directory `lib/previous_groups/`.
This folder should contain yml files of the groups.
There should be a single 2d arrays in each file, where the array elements are the groups

## Running the script
- run `ruby lib/run_me.rb`

## Local Development
- `bundle install`

## Testing
Run the following command from the project root
`ruby -Ilib:test test/group_picker_test.rb`