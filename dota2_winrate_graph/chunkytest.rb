# just a little ruby file to test out coloring in chunkypng

=begin
Current TODO:
* improve commenting on the whole thing really (main file too)
* improve input checking
* add the functions for the xaxis
* add the function for the graph bars 
* transfer everything over to get_data
* maybe reimplement characters as binary strings or use some more robust system
  for character encoding / display
=end

require 'chunky_png'

# starting at the top left of an image, true if 
# a pixel is filled in, false otherwise 
all_characters = {
"big_r" => [true, true, true, false,
			true, false, false, true,
			true, false, false, true,
			true, true, true, false,
			true, false, false, true,
			true, false, false, true],
"little_r" => [false, false, false, false,
			  true, false, false, false,
			  true, true, true, false,
			  true, false, false, true,
			  true, false, false, false,
			  true, false, false, false],
"little_a" => [false, false, false, false,
			  false, false, false, false,
			  false, true, true, false,
			  true, false, true, false,
			  true, false, true, false,
			  true, true, false, true],
"big_d" => [true, true, true, false,
			true, false, false, true,
			true, false, false, true,
			true, false, false, true,
			true, false, false, true,
			true, true, true, false],
"little_d" => [false, false, false, false,
			   false, false, true, false,
			   false, false, true, false,
			   false, true, true, false,
			   true, false, true, false,
			   true, true, false, true],
"little_i" => [false, false, false, false,
			   false, true, false, false,
			   false, false, false, false,
			   false, true, false, false,
			   false, true, false, false,
			   false, true, false, false],
"little_n" => [false, false, false, false,
			   false, false, false, false,
			   true, false, false, false,
			   true, true, true, false,
			   true, false, false, true,
			   true, false, false, true],
"little_t" => [false, false, false, false,
			   false, false, true, false,
			   false, true, true, true,
			   false, false, true, false,
			   false, false, true, false,
			   false, true, false, false],
"little_e" => [false, false, false, false,
			   false, true, true, false,
			   true, false, false, true,
			   true, true, true, true,
			   true, false, false, false,
			   false, true, true, true]
}

# graphs a rectangle given top-left start
# coords, length, thickness, and color 
def add_rectangle(png_obj, start_x, start_y, width, height, color = nil)
	# check to see if it will go out of bounds (thickness and length)
	
	# set default values for nil args
	if color == nil then color = :black end
	
	# actually add the rectangle
	(0..height).each do |col|
		(0..width).each do |row|
			png_obj[start_x + col, start_y + row] = color
		end
	end
end

# graph a character given the character, a png
# and a top-left location for the character
# each character is 4 pixels long and 6 tall
# If input is invalid, will return a message
# stating and will not alter the png
# returns true if the char was graphed, false
# otherwise.
# default color is pure black.
# default scale is 4x (16x as many pixels)
def add_char_to_png(png_obj, characters, character, start_x, start_y, color = nil, scale = nil)
	#check to see if character is one I've precoded
	
	pixel_map = characters[character]
	if pixel_map == nil then return false end
	
	#check to see if you'll go out of bounds
	
	
	#actually edit the png 
	if color == nil then color = :black end
	if scale == nil then scale = 4 end
	
	# iterate through the size of a char (4 x 6), filling in
	# the pixels for the char with color 
	(0...(4 * scale)).each do |row|
		(0...(6 * scale)).each do |col|
			px_map_i = (col/scale) * 4 + (row/scale)
			
			if pixel_map[px_map_i] then
				# plots extra pixels if scaled up
				png_obj[start_x + row, start_y + col] = color
			end
		end
	end
end

# adds a word to the png given a top-left starting coord,
# an array of characters, a color, and a scale.
# default color is black, scale is 4x
def add_word_to_png(png_obj, characters, chars_to_add, start_x, start_y, color = nil, scale = nil)
	# may be able to check both at the same time
	# check to make sure coords won't go out of bounds
	# check to make sure all characters are in the list
	
	# add default values for any nil args
	if color == nil then color = :black end
	if scale == nil then scale = 4 end
	
	# generate an int to keep track of the space between chars
	gap = 0
	if scale > 4 then 
		gap = 4
	else
		gap = scale
	end
	
	size_of_char = 4 * scale
	diff_btw_char_start_xs = size_of_char + gap
	
	# for each char in chars_to_add, add it to the png
	current_x = start_x
	
	chars_to_add.each do |current_char|
		add_char_to_png(png_obj, characters, current_char, current_x, start_y, color, scale)
		current_x += diff_btw_char_start_xs
	end
end

width = 250
height = 550

#png[x,y] is the format
# coords go from 0 to width / height - 1

png = ChunkyPNG::Image.new(width, height, 0x333333ff)

radiant = ["big_r", "little_a", "little_d", "little_i", "little_a", "little_n", "little_t"]
dire = ["big_d", "little_i", "little_r", "little_e"]
add_word_to_png(png, all_characters, radiant, 33, 400, 0xeeeeeeff, 3)
add_word_to_png(png, all_characters, dire, 158, 400, 0xeeeeeeff, 3)

#will have to do a bit of math to determine where the rectangle starts since they're top-down
add_rectangle(png, 30, 30, 30, 30)

png.save('chunkytest.png', :interlace => true)

# seems that 0,0 is the top leftmost pixel

# to test:
# find a good way to write out the team names (write a function)
# add a bar above the team names, have the graphed bars go out from above that bar 
# add bigass rectangles to simulate the bars 
# also dynamically create and graph the numbers above the bars

# I think I'll end up tracking the top left coordinate of most group-graphed structures