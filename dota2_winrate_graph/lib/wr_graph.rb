# uses OpenDota's WebAPI to fetch data about the 100 most recent all pick matches
# and finds the winrate of each side (dire/radiant)

=begin
Links:
=======
Website for ChunkyPNG: http://chunkypng.com/
OpenDota API doc: https://docs.opendota.com/
HTTParty doc: https://github.com/jnunemaker/httparty/tree/master/docs
=end

=begin
Developer notes:
=================

Current status: fully functional for 100 matches.


To Test:
* if exception is properly thrown when no internet is connected
* the perimeters of the image are properly defined for all functions

Goals:
* might be able to make an executable with rb2exe or ocra in win10
* improve commenting
* improve README
* more input checking (negative coords, etc)
=end

require 'httparty'
require 'json'
require 'chunky_png'

#=================================================
# Variables
#=================================================

# acceptable http statuses
ACCEPTABLE_HTTP_STATUSES = [200]

# dimensions of resulting image. Keep in mind that
# making these too small will prevent certain
# elements of the graph from being generated.
IMG_WIDTH = 250
IMG_HEIGHT = 550
IMG_BG_COLOR = 0x333333ff
IMG_NAME = "winrates.png"

# variables relating to the contents of the image
# radiant
RADIANT_BAR_COLOR = :green
RADIANT_NAME_X = 30
NAME_Y = 500
TEXT_COLOR = 0xeeeeeeff
TEXT_SCALE = 3
BAR_SCALE = 6
RADIANT_BAR_X = 53
BAR_THICKNESS = 50
CHARACTER_WIDTH_PX = 4
CHARACTER_HEIGHT_PX = 6
TEXT_GAP = 3

# dire
DIRE_BAR_COLOR = :red
DIRE_NAME_X = 150
DIRE_BAR_X = 155

# x-axis
X_AXIS_X = 25
X_AXIS_Y = 490
X_AXIS_LENGTH = 200
X_AXIS_THICKNESS = 2

# list of characters that can be added to a png
# characters are a "binary" representation of
# the pixels. top left to bottom right row then col
# (like the words in a book)
ALL_CHARACTERS = {
"R" => [true, true, true, false,
			true, false, false, true,
			true, false, false, true,
			true, true, true, false,
			true, false, false, true,
			true, false, false, true],
"r" => [false, false, false, false,
			  true, false, false, false,
			  true, true, true, false,
			  true, false, false, true,
			  true, false, false, false,
			  true, false, false, false],
"a" => [false, false, false, false,
			  false, false, false, false,
			  false, true, true, false,
			  true, false, true, false,
			  true, false, true, false,
			  true, true, false, true],
"D" => [true, true, true, false,
			true, false, false, true,
			true, false, false, true,
			true, false, false, true,
			true, false, false, true,
			true, true, true, false],
"d" => [false, false, false, false,
			   false, false, true, false,
			   false, false, true, false,
			   false, true, true, false,
			   true, false, true, false,
			   true, true, false, true],
"i" => [false, false, false, false,
			   false, true, false, false,
			   false, false, false, false,
			   false, true, false, false,
			   false, true, false, false,
			   false, true, false, false],
"n" => [false, false, false, false,
			   false, false, false, false,
			   true, false, false, false,
			   true, true, true, false,
			   true, false, false, true,
			   true, false, false, true],
"t" => [false, false, false, false,
			   false, false, true, false,
			   false, true, true, true,
			   false, false, true, false,
			   false, false, true, false,
			   false, true, false, false],
"e" => [false, false, false, false,
			   false, true, true, false,
			   true, false, false, true,
			   true, true, true, true,
			   true, false, false, false,
			   false, true, true, true],
"1" => [false, false, true, false,
				false, true, true, false,
				false, false, true, false,
				false, false, true, false,
				false, false, true, false,
				true, true, true, true],
"2" => [false, true, true, false,
				true, false, false, true,
				false, false, false, true,
				false, false, true, false,
				false, true, false, false,
				true, true, true, true],
"3" => [false, true, true, false,
				true, false, false, true,
				false, false, true, false,
				false, false, false, true,
				true, false, false, true,
				false, true, true, false],
"4" => [true, false, false, true,
				true, false, false, true,
				true, false, false, true,
				false, true, true, true,
				false, false, false, true,
				false, false, false, true],
"5" => [true, true, true, true,
				true, false, false, false,
				true, true, true, false,
				false, false, false, true,
				false, false, false, true,
				true, true, true, false],
"6" => [false, true, true, true,
				true, false, false, false,
				true, true, true, false,
				true, false, false, true,
				true, false, false, true,
				false, true, true, false],
"7" => [true, true, true, true,
				false, false, false, true,
				false, false, true, false,
				false, false, true, false,
				false, true, false, false,
				false, true, false, false],
"8" => [false, true, true, false,
				true, false, false, true,
				false, true, true, false,
				true, false, false, true,
				true, false, false, true,
				false, true, true, false],
"9" => [false, true, true, true,
				true, false, false, true,
				true, false, false, true,
				false, true, true, true,
				false, false, false, true,
				false, false, false, true],
"0" => [false, true, true, false,
				true, false, false, true,
				true, false, true, true,
				true, true, false, true,
				true, false, false, true,
				false, true, true, false]
}


#=============================
# Functions for data retreival
#=============================

#returns an HTTParty Response obj that match winners will be extracted from
def getMatchHistory(max_match_id = nil)
	begin
		if max_match_id then
			response = HTTParty.get("https://api.opendota.com/api/publicMatches?less_than_match_id=#{max_match_id}")
		else
			response = HTTParty.get("https://api.opendota.com/api/publicMatches")
		end

  	# checks to make sure we got a good response before parsing
  	until ACCEPTABLE_HTTP_STATUSES.include? response.code
    	print "failed to get matchIDs, trying again in (response code: #{response.code})"
    	(5..1).each do |num|
      	print "#{num}... "
      	sleep(1)
    	end
    	puts ""

		# requests the match data
    	response = HTTParty.get("https://api.opendota.com/api/publicMatches")
  	end

  	return response

	rescue
		raise "Failed to request data, seems you may not be connected to the internet."
	end
end


#=================================
# Functions for data visualization
#=================================

# adds a rectangle to the png.
# png_obj: the png to add the rectangle to (Chunky_PNG::Image)
# start_x: left edge of the rectangle (Int)
# start_y: top top edge of the rectangle (Int)
# width: how many columns of pixels the rectangle spans (Int)
# height: how many rows of pixels the rectangle spans (Int)
# color: color of rectangle, default is :black (Chunky_PNG::Color / hex representation of rgba color)
def add_rectangle(png_obj, start_x, start_y, width, height, color = nil)
	# check to see if it will go out of bounds (thickness and length)
	if start_x + width >= png_obj.width then
		puts "add_rectangle: out of bounds (width / start_x)"
		return false
	end
	if start_y + height >= png_obj.height then
		puts "add_rectangle out of bounds (height / start_y)"
		return false
	end

	# set default values for nil args
	if color == nil then
		color = :black
	end

	# actually add the rectangle
	(0...height).each do |row|
		(0...width).each do |col|
			png_obj[start_x + col, start_y + row] = color
		end
	end

	return true
end


# adds a character to a png. Returns true if the character was added, false otherwise.
# png_obj: the png to add the characer to (Chunky_PNG::Image)
# characters: the hash of characters available to add (Hash, see ALL_CHARACTERS)
# character: the key for a character to be chosen from characters (String)
# start_x: left edge of the character's CHARACTER_WIDTH_PX x CHARACTER_HEIGHT_PX area (Int)
# start_y: top top edge of the character's CHARACTER_WIDTH_PX x CHARACTER_HEIGHT_PX area (Int)
# color: color of character, default is :black (Chunky_PNG::Color / hex representation of rgba color)
# scale: size of the character. Default is 4, minumum is 1 (Int)
def add_char_to_png(png_obj, characters, character, start_x, start_y, color = nil, scale = nil)
	#check to see if character is in characters
	pixel_map = characters[character]
	if pixel_map == nil then
		return false
	end

	#check to see if character will go out of bounds of the png
	if (start_x + (scale * CHARACTER_WIDTH_PX) >= png_obj.width ||
		start_y + (scale * CHARACTER_HEIGHT_PX) >= png_obj.height) then
		puts "add_char_to_png: character exceeded bounds of image"
		return false
	end
	#assign default values for nil args
	if color == nil then
		color = :black
	end
	if scale == nil then
		scale = 4
	elsif scale < 1 then
		puts "add_char_to_png: invalid scale"
		return false
	end

	# iterate through the size of a char (CHARACTER_WIDTH_PX x CHARACTER_HEIGHT_PX), filling in
	# the pixels for the char with color
	(0...(CHARACTER_WIDTH_PX * scale)).each do |row|
		(0...(CHARACTER_HEIGHT_PX * scale)).each do |col|
			px_map_i = (col/scale) * CHARACTER_WIDTH_PX + (row/scale)

			if pixel_map[px_map_i] then
				png_obj[start_x + row, start_y + col] = color
			end
		end
	end

	return true
end

# adds multiple chars to a png. Returns true if the word was added, false otherwise.
# png_obj: the png to add the word to (Chunky_PNG::Image)
# characters: the hash of characters available to add (Hash, see ALL_CHARACTERS)
# chars_to_add: an array of characters comprising the word (Array of Strings)
# start_x: left edge of the word (Int)
# start_y: top top edge of the word (Int)
# color: color of characters, default is :black (Chunky_PNG::Color / hex representation of rgba color)
# scale: size of the characters. Default is 4, minimum is 1. (Int)
def add_word_to_png(png_obj, characters, chars_to_add, start_x, start_y, color = nil, scale = nil)
	# check if characters are defined
	chars_to_add.each do |name_of_char|
		if ALL_CHARACTERS[name_of_char] == nil then
			puts "add_word_to_png: invalid character name \"#{name_of_char}\""
			return false
		end
	end

	# calculations for checking if characters will fit in image
	width_of_char = CHARACTER_WIDTH_PX * scale

	# add default values for any nil args
	if color == nil then
		color = :black
	end
	if scale == nil then
		scale = 4
	elsif scale < 1 then
		puts "add_word_to_png: invalid scale"
		return false
	end

	# generates the difference between the start columns of two chars
	diff_btw_char_start_xs = width_of_char + TEXT_GAP

	current_x = start_x

	if (start_x + (diff_btw_char_start_xs * chars_to_add.length) >= png_obj.width ||
		start_y + (CHARACTER_HEIGHT_PX * scale) >= png_obj.height) then
		puts "add_word_to_png: word exceeded bounds of image"
		return false
	end

	# adds the characters to the png
	chars_to_add.each do |current_char|
		add_char_to_png(png_obj, characters, current_char, current_x, start_y, color, scale)
		current_x += diff_btw_char_start_xs
	end

	return true
end


#=====================
# The actual code part
#=====================

#### Getting the wins
radiant_wins = 0
dire_wins = 0
number_matches = 0

min_match_id = 9999999999

# stores matchIDs (needed to prevent counting duplicates)
parsed_matches = []

# this is to track api calls so we don't exceed their limits
api_calls = 0

while number_matches < 1000 do
	api_calls += 1

	if api_calls > 59 then
		raise "made too many calls to api, stopped to not break ToS."
	end

	# parses the response's json String into a Hash
	if min_match_id == 9999999999 then
		json_hash = JSON.parse(getMatchHistory().body)
	else
		json_hash = JSON.parse(getMatchHistory(min_match_id).body)
	end

	json_hash.each do |match|
		match_id = match["match_id"]
		if !parsed_matches.include?(match_id) then
			if match_id < min_match_id then
				min_match_id = match_id
			end
			parsed_matches << match_id

			if match["radiant_win"] then
				radiant_wins += 1
			else
				dire_wins	+= 1
			end
			number_matches += 1

		else
			puts("found duplicate match (id:#{})", match_id)
			sleep(1)
		end
	end
end

puts "radiant: #{radiant_wins}\tdire:#{dire_wins}\ttotal: #{number_matches}"

if radiant_wins % 100 > 49 then
	radiant_wins = radiant_wins / 10 + 1
	dire_wins /= 10
else
	radiant_wins /= 10
	dire_wins = dire_wins / 10 + 1
end

### Generating the image

# create a new png object
png = ChunkyPNG::Image.new(IMG_WIDTH, IMG_HEIGHT, IMG_BG_COLOR)

# create words (arrays of character keys) for each team
radiant = ["R", "a", "d", "i", "a", "n", "t"]
dire = ["D", "i", "r", "e"]

# create words for each score
radiant_score = []
radiant_wins.to_s.each_char do |r_char|
	radiant_score << r_char
end
dire_score = []
dire_wins.to_s.each_char do |d_char|
	dire_score << d_char
end

# actually add the teams' names to the png
add_word_to_png(png, ALL_CHARACTERS, radiant, RADIANT_NAME_X, NAME_Y, TEXT_COLOR, TEXT_SCALE)
add_word_to_png(png, ALL_CHARACTERS, dire, DIRE_NAME_X, NAME_Y, TEXT_COLOR, TEXT_SCALE)

# add the x-axis to the png
add_rectangle(png, X_AXIS_X, X_AXIS_Y, X_AXIS_LENGTH, X_AXIS_THICKNESS)

# add the team bars
rad_bar_ht = radiant_wins * BAR_SCALE
dire_bar_ht = dire_wins * BAR_SCALE
add_rectangle(png, RADIANT_BAR_X, X_AXIS_Y - rad_bar_ht, BAR_THICKNESS, rad_bar_ht, RADIANT_BAR_COLOR)
add_rectangle(png, DIRE_BAR_X, X_AXIS_Y - dire_bar_ht, BAR_THICKNESS, dire_bar_ht, DIRE_BAR_COLOR)

# add the percentages above the bars

# find location to start the radiant and dire bar labels
rad_bar_label_x = (RADIANT_BAR_X + (BAR_THICKNESS / 2)) - (((radiant_score.length * ((CHARACTER_WIDTH_PX  * TEXT_SCALE) + TEXT_GAP)) - radiant_score.length) / 2)
dire_bar_label_x = (DIRE_BAR_X + (BAR_THICKNESS / 2)) - (((dire_score.length * ((CHARACTER_WIDTH_PX  * TEXT_SCALE) + TEXT_GAP)) - dire_score.length) / 2)

add_word_to_png(png, ALL_CHARACTERS, radiant_score, rad_bar_label_x, X_AXIS_Y - rad_bar_ht - 30, TEXT_COLOR, TEXT_SCALE)
add_word_to_png(png, ALL_CHARACTERS, dire_score, dire_bar_label_x, X_AXIS_Y - dire_bar_ht - 30, TEXT_COLOR, TEXT_SCALE)

# save the file
png.save(IMG_NAME, :interlace => true)

puts "Graph saved in winrates.png"
