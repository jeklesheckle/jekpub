# uses Steam's WebAPI to fetch data about the 100 most recent all pick matches
# and finds the winrate of each side (dire/radiant)

## this code will not work unless you store your api key in a file named
## api_key.txt. you should add that file to your gitignore if you want
## to avoid publicly publishing your api key, which is a violation of the ToS

=begin
Links:
=======
Website for ChunkyPNG: http://chunkypng.com/
WebApi page of TF2 wiki: https://wiki.teamfortress.com/wiki/WebAPI
Steam WebAPI guide: https://steamwebapi.azurewebsites.net/
HTTParty doc: https://github.com/jnunemaker/httparty/tree/master/docs
=end

=begin
Developer notes:
=================

Current status: fully functional for 100 matches. 
Visualization status: need to gem install ChunkyPNG. Writing out beginning test
  at end of file

Goals:
* currently gets very angry if you're not connected to the internet. fix?
* rename the chars to just be the character they represent
* reduce the delay to simply ensure that it takes no less than
  a second between requests
* more matches
* faster requests (Opendota API?)
* improve commenting
* improve input checking
* research ways to reimplement character printing
=end

require 'httparty'
require 'json'
require 'chunky_png'

#=================================================
# Variables 
#=================================================

# acceptable http statuses
ACCEPTABLE_HTTP_STATUSES = [200]

# gets the api key from a file, you can change the name / location of the file here
api_key = File.open("api_key.txt").read

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


#=============================
# Functions for data retreival
#=============================

#returns an HTTParty Response obj that 100 match IDs will be extracted from
def getMatchHistory(api_key_arg)
  response = HTTParty.get(  # needed 570 in place of <ID> since dota's ID is 570
    "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v1/?key=#{api_key_arg}&game_mode=1"
  )

  # checks to make sure we got a good response before parsing
  until ACCEPTABLE_HTTP_STATUSES.include? response.code
    print "failed to get matchIDs, trying again in "
    (5..1).each do |num|
      print "#{num}... "
      sleep(1)
    end
    puts ""

	# requests the match data using the IDOTA2Match_<ID> interface and a GetMatchHistory call
    response = HTTParty.get(  # needed 570 in place of <ID> since dota's ID is 570"
      "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v1/?key=#{api_key_arg}&game_mode=1"
    )
  end

  return response
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
		puts "add_rectangle" out of bounds (height / start_y)
		return false
	end
	
	# set default values for nil args
	if color == nil then color = :black end
	
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
# start_x: left edge of the character's 4 x 6 area (Int)
# start_y: top top edge of the character's 4 x 6 area (Int) 
# color: color of character, default is :black (Chunky_PNG::Color / hex representation of rgba color)
# scale: size of the character. 1 is 1px / px, 2 is 4px / px, 3 is 9px / px, etc. Default is 4 (Int)
def add_char_to_png(png_obj, characters, character, start_x, start_y, color = nil, scale = nil)
	#check to see if character is in characters
	pixel_map = characters[character]
	if pixel_map == nil then return false end
	
	#check to see if character will go out of bounds of the png
	if start_x + (scale * 4) >= png_obj.width ||
		start_y + (scale * 6) >= png_obj.height then
		puts "add_char_to_png: character exceeded bounds of image"
		return false
	end
	
	#assign default values for nil args
	if color == nil then color = :black end
	if scale == nil then scale = 4 end
	
	# iterate through the size of a char (4 x 6), filling in
	# the pixels for the char with color
	(0...(4 * scale)).each do |row|
		(0...(6 * scale)).each do |col|
			px_map_i = (col/scale) * 4 + (row/scale)
			
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
# scale: size of the characters. 1 is 1px / px, 2 is 4px / px, 3 is 9px / px, etc. Default is 4 (Int)
def add_word_to_png(png_obj, characters, chars_to_add, start_x, start_y, color = nil, scale = nil)
	# may be able to check both at the same time
	# check to make sure coords won't go out of bounds
	# check to make sure all characters are in the list
	size_of_char = 4 * scale
	
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
	
	# generates the difference between the start columns of two chars
	diff_btw_char_start_xs = size_of_char + gap
	
	# adds the characters to the png
	current_x = start_x
	
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

# to store matchIDs
match_id_array = Array.new

# parses the response's json String into a Hash
json_hash = JSON.parse(getMatchHistory(api_key).body)

# extracts all of the matchIDs from the hash and adds them to match_id_array
json_hash["result"]["matches"].each do |match|
  match_id_array << match["match_id"]
end

# tries to get the winning team of each match. If a match doesn't provide a proper
# response to the request, it is ignored and the next match is tried.
match_id_array.each do |id|
  sleep(1) # need to delay 1 second in order to not violate ToS
  match_response = HTTParty.get(
    "http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/v1/?key=37FB080E73DCCC7BA31BC11B52C5C453&match_id=#{id}"
  )

  # get the status of the request, don't parse if it wasn't acceptable
  id_req_status = match_response.code
  if !(ACCEPTABLE_HTTP_STATUSES.include? id_req_status) then
    puts "status for id: #{id} was #{id_req_status}"

  else
    # increment either team's win variable
    match_json_hash = JSON.parse(match_response.body)
    rad_wins = match_json_hash["result"]["radiant_win"]
    if  rad_wins == true then
      radiant_wins += 1
      puts "radiant won"
    elsif rad_wins == false then
      dire_wins += 1
      puts "dire won"
    else
      puts "radiant_wins was #{rad_wins}" #should never happen
    end
  end
end

puts "radiant: #{radiant_wins}\tdire:#{dire_wins}"


### Generating the image

# create a new png object
png = ChunkyPNG::Image.new(IMG_WIDTH, IMG_HEIGHT, IMG_BG_COLOR)

# create words (arrays of character keys) for each team
radiant = ["big_r", "little_a", "little_d", "little_i", "little_a", "little_n", "little_t"]
dire = ["big_d", "little_i", "little_r", "little_e"]

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

# save the file
png.save(IMG_NAME, :interlace => true)
