# sort of the main file until I restructure the project.
# will contain the "main" functionalities of the code

require_relative 'datatypes'

# test Swimmer
swimmer1_event_times = Event_Times.new(93.123, 76.098)
swimmer1 = Swimmer.new("jek", 19, "humans", swimmer1_event_times)
#puts swimmer1.inspect

swimmer_nil = Swimmer.new(nil, nil, nil, nil)
#puts swimmer_nil.inspect

# test Team
team1 = Team.new("humans")
#puts team1.inspect
team1.swimmers << swimmer1
#puts team1.inspect

# test Tournament
tournament1 = Tournament.new("rat race", [])
#puts tournament1.inspect

# test Event
event1 = Event.new(50, "free")

# test Race (and add to tournaments)
