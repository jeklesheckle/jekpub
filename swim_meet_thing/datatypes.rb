# Contains the classes used to represent swimmers and tournaments

=begin
==========
 T O D O
==========
-decide how you want to give new swimmers their times
  cuz it's 5AM and I shouldn't make that call now.
-finish "testing"
=end


Event_Times = Struct.new(:example_event, :example_event2)

#==============
#C L A S S E S
#==============

# event_times is a Hash from Events
# note that it's not currently necessary for a team
#   to exist for a swimmer to be made on that team
#   since the team's name as a string is all that's needed
class Swimmer
  attr_reader :name, :age, :team_name, :event_times
  def initialize(name, age, team_name, event_times)
    @name = name
    @age = age
    @team_name = team_name
    # event_times is a Hash of Event -> time
    @event_times = event_times
  end
end

# represents a team
class Team
  attr_reader :name
  attr_accessor :swimmers
  def initialize(name)
    @name = name
    @swimmers = []
  end
end

# represents a collection of races
class Tournament
  attr_reader :name
  attr_accessor :races
  def initialize(name, races)
    @name = name
    @races = races
  end
end

# represents a type of event (50 free, 100 back, etc)
class Event
  attr_reader :distance, :event_type
  def initialize(distance, event_type)
    @distance = distance
    @event_type = event_type
  end
end

# represents a specific race with participants from each team
class Race
  attr_reader :event, :teams
  attr_accessor :participants, :teams
  attr_accessor :participants
  def initialize(event, teams, participants)
    @event = event
    @teams = teams
    @participants = participants
  end

  def event_type()
    @event.event_type
  end

  def event_distance()
    @event.distance
  end
end
