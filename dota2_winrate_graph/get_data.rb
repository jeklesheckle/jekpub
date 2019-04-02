# uses Steam's WebAPI to fetch data about the 100 most recent all pick matches
# and finds the winrate of each side (dire/radiant)

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

API key: 37FB080E73DCCC7BA31BC11B52C5C453

Current status: fully functional for 100 matches. 
Visualization status: need to gem install ChunkyPNG. Writing out beginning test
  at end of file

Goals:
* visualize the data (ChunkyPNG?)
	- I think this program is simple enough that we can include the visualization
	  within this file. We can generate the png with ChunkyPNG. I think a simple
	  shell script would allow me to run this code then open the resulting image.
* less hardcoded numbers
* more matches
* faster requests (Opendota API?)
=end

require 'httparty'
require 'json'
require 'chunky_png'

#returns an HTTParty Response obj that 100 match IDs will be extracted from
def getMatchHistory()
  response = HTTParty.get(  # needed 570 in place of <ID> since dota's ID is 570"
    'https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v1/?key=37FB080E73DCCC7BA31BC11B52C5C453&game_mode=1'
  )

  # checks to make sure we got a good response before parsing
  until response.code == 200
    print "failed to get matchIDs, trying again in "
    (5..1).each do |num|
      print "#{num}... "
      sleep(1)
    end
    puts ""

    response = HTTParty.get(  # needed 570 in place of <ID> since dota's ID is 570"
      'https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v1/?key=37FB080E73DCCC7BA31BC11B52C5C453&game_mode=1'
    )
  end

  return response
end

radiant_wins = 0
dire_wins = 0


# to store matchIDs
match_id_array = Array.new

# parses the response's json String into a Hash
json_hash = JSON.parse(getMatchHistory().body)

# extracts all of the matchIDs from the hash and adds them to match_id_array
json_hash["result"]["matches"].each do |match|
  match_id_array << match["match_id"]
end

# tries to get the winning team of each match. If a match doesn't provide a proper
# response to the request, it is ignored.
match_id_array.each do |id|
  sleep(1)
  match_response = HTTParty.get(
    "http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/v1/?key=37FB080E73DCCC7BA31BC11B52C5C453&match_id=#{id}"
  )

  # get the status of the request, don't parse if it wasn't good
  id_req_status = match_response.code
  if id_req_status != 200 then
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
      puts "radiant_wins was #{rad_wins}"
    end
  end
end

puts "radiant: #{radiant_wins}\tdire:#{dire_wins}"

# generate dark grey 250px X 550px png object
graph_PNG = ChunkyPNG::Image.new(250, 550, 0x33333300)
# add basic template stuff like team names, frames, borders
# add the actual bars for each team s
# save the PNG
graph_PNG.save('wins.png', :interlace => true)