# take a filename
puts "filename:"
filename = STDIN.gets.chomp()

# take a string
puts "string:"
string = STDIN.gets.chomp()


# create a file by that name
file = File.open(filename, "w")
for curr_char in string.chars do
  file.print(curr_char + " ")
end
