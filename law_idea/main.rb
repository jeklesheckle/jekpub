# this file runs the program in the command line

require_relative 'actions.rb'


actions = Hash.new

# user_input = STDIN.gets.chomp

puts "Creating an action, enter its name:"

action_entered = STDIN.gets.chomp()

actions[action_entered] = Action.new

prompt_entered = "default"
while prompt_entered !=  "exit" do
    puts "enter a field prompt:"
    prompt_entered =  STDIN.gets.chomp()
    puts "enter the field's type:"
    type_entered = STDIN.gets.chomp()

    actions[action_entered] << Field.new(prompt_entered, type_entered)
    puts actions[action_entered].fields.inspect
end
