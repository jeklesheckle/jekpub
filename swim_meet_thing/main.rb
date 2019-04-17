# Contains the main code for the project

=begin
==========
 T O D O
==========
-implement basic functions
-test them a bit
-add to this list
=end


#==============
#C L A S S E S
#==============

# event_times is a Hash from Events
class Swimmer
  attr_reader :name, :age, :team, :event_times
  def initialize(name, age, team, event_times)
    @name = name
    @age = age
    @team = team
    @event_times = event_times
  end
end

class Team
  attr_reader :name
  attr_accessor :swimmers
  def initialize(name)
    @name = name
    @swimmers = [Swimmer.new("empty_swimmer", 0, self, [])]
  end
end

class Tournament
  attr_reader :name
  attr_accessor :events
  def initialize(name, events)
    @name = name
    @events = events
  end
end

class Event
  attr_reader :distance, :event_type
  def initialize(distance, event_type)
    @distance = distance
    @event_type = event_type
  end
end

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


#=================
#F U N C T I O N S
#=================

def add_swimmer_to_team()

end

def create_team(name)
  new_team = Hash.new {"name" => name, "swimmers" => []}

end
