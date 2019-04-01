# uses Steam's WebAPI to fetch data about the 500 most recent all pick matches
# and finds the winrate of each side (dire/radiant)

=begin
Links:
=======

WebApi page of TF2 wiki: https://wiki.teamfortress.com/wiki/WebAPI
Steam WebAPI guide: https://steamwebapi.azurewebsites.net/
HTTParty doc: https://github.com/jnunemaker/httparty/tree/master/docs
=end

=begin
Developer notes:
=================

API key: 37FB080E73DCCC7BA31BC11B52C5C453

Current status: gonna need to use GetMatchDetails instead to get who won.
unsure of how to parse the results (I believe they are strings)
=end

require 'httparty'

# request format:
# https://{base_url}/{interface}/{method}/{version}?{parameters}
# parameters are delimited with '&'
response = HTTParty.get(  # needed 570 in place of <ID> since dota's ID is 570"
  'https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v1/?key=37FB080E73DCCC7BA31BC11B52C5C453&game_mode=1'
)

puts response.body