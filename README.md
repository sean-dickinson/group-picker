# Group Picker
A simple ruby script to randomly pick a group from a given list. 
The goal is to minimize the number of overlapping members compared to previous groups.

Previous groups are expected to be stored in the directory `lib/previous_groups/`.
This folder should contain yml files of the groups.
There should be a single 2d arrays in each file, where the array elements are the groups 

## Local Development
- run `bundle install`

## Testing
Run the following command from the project root
`ruby -Ilib:test test/group_picker_test.rb`