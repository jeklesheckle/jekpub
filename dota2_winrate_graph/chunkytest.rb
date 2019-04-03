# just a little ruby file to test out coloring in chunkypng

=begin
Current TODO:
* add the rest of the characters
* scale them up by a factor of 4
* add the functions for the xaxis
* add the function for the graph bars 
* transfer everything over to get_data
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
			true, false, false, true]
}

# graphs the x-axis of the bar graph 
def graph_x_axis()

end

# graph a character given the character, a png
# and a top-left location for the character
# each character is 4 pixels long and 6 tall
# If input is invalid, will return a message
# stating and will not alter the png
# returns true if the char was graphed, false
# otherwise.
# default color is pure black.
def add_char_to_png(png_obj, characters, character, start_x, start_y, color = nil)
	#check to see if character is one I've precoded
	
	pixel_map = characters[character]
	if pixel_map == nil then return false end
	
	#check to see if you'll go out of bounds
	
	
	#actually edit the png 
	if color == nil then color = :black end
	
	# iterate through the size of a char (4 x 6), filling in
	# the pixels for the char with color 
	(0...4).each do |row|
		(0...6).each do |col|
			px_map_i = col * 4 + row
			if pixel_map[px_map_i] then 
				png_obj[start_x + row, start_y + col] = color
			end
		end
	end
end

width = 250
height = 550

#png[x,y] is the format
# coords go from 0 to width / height - 1

png = ChunkyPNG::Image.new(width, height, 0x333333ff)

add_char_to_png(png, all_characters, "big_r", 50, 50)

png.save('chunkytest.png', :interlace => true)

# seems that 0,0 is the top leftmost pixel

# to test:
# find a good way to write out the team names (write a function)
# add a bar above the team names, have the graphed bars go out from above that bar 
# add bigass rectangles to simulate the bars 
# also dynamically create and graph the numbers above the bars

# I think I'll end up tracking the top left coordinate of most group-graphed structures