# this function runs the program in the command line

require_relative 'actions.rb'

# user_input = STDIN.gets.chomp

puts "Please enter an action:"

action_entered = STDIN.gets.chomp()

action = create_action(action_entered)

for field in action do
  print field.prompt
  field.response = STDIN.gets.chomp()
end

puts action.inspect()
#my_action[0] now represents the perp field
