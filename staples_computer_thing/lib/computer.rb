# this file has functions and definitions for computer objects

######################################################################
# H E L P E R  F U N C T I O N S
######################################################################
# takes a string and returns true/false based on what the string spells

def to_bool(string)
  capstring = string.to_s.upcase
  if capstring == "TRUE" then
    return true
  elsif capstring == "FALSE" then
    return false
  else
    raise "Argument error: to_bool expected true or false but was given something else"
  end
end


######################################################################
# A C T U A L  C O M P U T E R  S T U F F
######################################################################
# takes a computer and stores it into the database as a line of characters
def store_computer(computer_to_store)
  # check to make sure file exists
  if File.exists?("computers.cstore") then
    # open file
    computers_file_r = File.open("computers.cstore")

    # read it into an array of Computers (restore it using Marshal)
    computers_arr = Marshal.restore(computers_file_r)
    computers_file_r.close

    # find if the computer already exists by parsing that var (remove it if so)
    computers_arr.delete_if {|curr_computer| curr_computer.name == computer_to_store.name}

    # store the computer in the array (computer locations are arbitrary)
    computers_arr << computer_to_store

    # serialize and save the file
    computers_file_w = File.open("computers.cstore", "w")
    Marshal.dump(computers_arr, computers_file_w)
  else
    computers_file_w = File.open("computers.cstore", "w")
    Marshal.dump([computer_to_store], computers_file_w)
  end

  computers_file_w.close
end


# returns the computer object named in the args from file storage
def load_computer(name)
  return Marshal.restore(File.open("computers.cstore", "r+"))
end


# prints the computer's contents to console

# creates a new empty computer
# takes a hash of computer traits that contains a mapping from strings
# describing the detail to the value of that detail.
def create_computer(details_hash)
  return Computer.new(details_hash["os"], details_hash["processor"], details_hash["storage"],
    details_hash["memory"], details_hash["screen"], details_hash["battery"],
    details_hash["keyboard"], details_hash["display_ports"], details_hash["other_ports"],
    details_hash["upgrade_specs"], details_hash["peripherals"])
end

=begin
Represents a computer, centered around a hash of all of the traits

Traits:
os: [String] The operating system the device comes with
processor: [Hash] Processor traits:
      "name" -> [String] The model of processor
      "base_clock" -> [Float] The base clock speed in gigahertz
      "boost_clock" -> [Float] The boost clock speed in gigahertz
      "cores" -> [Int] Number of cores
      "threads" -> [Int] Number of threads
      "hyperthreading?" -> [Bool] Whether an Intel processor has hyperthreading
      "graphics" -> [String] Onboard graphics
      "TDP" -> [Int] Power draw in Watts
      "lithography" -> [int] Lithography (die size in nanometers)
storage: [Hash] Storage traits:
      "size" -> [Int] Size in gigabytes
      "type" -> [String] Type of storage (HDD3.5, SSD2.5, eMMC, etc.)
      "rpm" -> [Int] Speed of the disk if HDD or 0
memory: [Hash] Memory traits:
      "size" -> [Int] Amount of memory in GB
      "speed" -> [Int] Memory speed in MHz
      "type" -> [String] Type of memory (SODIMM, DIMM, etc.)
      "slots_used" -> [Int] Number of memory slots used
      "slots_available" -> [Int] Number of memory slots available
screen: [Hash] Screen traits (if present, else entire object is nil):
      "size" -> [Float] The diagonal size of the screen
      "resolution" -> [Array len 2 of Ints] The w and l of the resolution
      "touch?" -> [Bool] If the screen supports touch
battery: [Hash] Battery traits:
      "life_estimate" -> [Float] Battery life in hours
      "mAH" -> [Int] Battery life in mAH
keyboard: [Hash] Keyboard traits
      "backlit?" -> [Bool] If keyboard is backlit
      "numpad?" -> [Bool] If keyboard has numpad
display_ports: [Array] Each element is the String name of a display port.
  duplicates are listed multiple times.
other_ports: [Array] Each element is the String name of a port, duplicates are
  listed multiple times.
upgrade: [Hash] Traits relating to upgradability
      "max_ram" -> [Int] The maximum amount of RAM the machine supports
      "hard_drive_easy?" -> [Bool] True if the technician believes a normal
        person would be able to easily find and swap the hard drive.
      "processor_soldered?" -> [Bool] If the processor is soldered to the mobo
peripherals: [Array] Strings describing peripherals included in the box
  (also includes speakers built into the device)
=end
class Computer
  # each of these member vars can be an object/struct with several members
  # e.g. processor has base_clock, boost_clock, cores, etc.
  (attr_accessor :os, :processor, :storage, :memory, :screen, :battery, :keyboard,
  :display_ports, :other_ports, :upgrade_specs, :peripherals)

  attr_reader :name

  def initialize(name, os = nil, processor = nil, storage = nil, memory = nil,
      screen = nil, battery = nil, keyboard = nil, display_ports = nil,
      other_ports = nil, upgrade_specs = nil, peripherals = nil)
      @name = name
      @os = os
      @processor = processor   ## these might not be in the proper form
      @storage = storage
      @memory = memory
      @screen = screen
      @battery = battery
      @keyboard = keyboard
      @display_ports = display_ports
      @other_ports = other_ports
      @upgrade_specs = upgrade_specs
      @peripherals = peripherals
  end
end
