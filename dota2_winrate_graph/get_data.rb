# This program will fetch the data from Steam's servers using their WebApi
# via Net::HTTP

=begin
Links:
=======

Steam WebAPI guide: https://steamwebapi.azurewebsites.net/
HTTParty doc: https://github.com/jnunemaker/httparty/tree/master/docs
=end

=begin
Developer notes:
=================

API key: 37FB080E73DCCC7BA31BC11B52C5C453

Current status: just figured out how to do requests in browser. need to do more
testing in code
=end

require 'httparty'

# request format:
# https://{base_url}/{interface}/{method}/{version}?{parameters}
# parameters are delimited with '&'
response = HTTParty.get(  # needed 570 in place of <ID> since dota's ID is 570"
  'https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v1/?key=37FB080E73DCCC7BA31BC11B52C5C453&game_mode=16'
)
puts response
