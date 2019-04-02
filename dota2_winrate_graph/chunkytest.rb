# just a little ruby file to test out coloring in chunkypng

require 'chunky_png'

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
def png_char(png_object, character, start_x, start_y)
	#check to see if character is one I've precoded
	
	#check to see if you'll go out of bounds
	
	
end

width = 250
height = 550

#png[x,y] is the format
# coords go from 0 to width / height - 1

png = ChunkyPNG::Image.new(width, height, 0x333333ff)

border_thickness = 5

(0...width).each do |x_coord|
	(0...border_thickness).each do |y_coord|
		png[x_coord, y_coord] = :black
	end
end


png.save('chunkytest.png', :interlace => true)

# seems that 0,0 is the top leftmost pixel

# to test:
# find a good way to write out the team names (write a function)
# add a bar above the team names, have the graphed bars go out from above that bar 
# add bigass rectangles to simulate the bars 
# also dynamically create and graph the numbers above the bars

# I think I'll end up tracking the top left coordinate of most group-graphed structures