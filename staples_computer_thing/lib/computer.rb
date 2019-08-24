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
# if a computer by that name already exists, it is replaced
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


# deletes the file containing the information for all computers
def delete_all_computers(password)
  #this password is intended to provide basic security, NOT a
  # useful solution against a deliberate attack
  # someone can just delete the file manually if they want to

  if password == "yes, actually delete all computers" then
    puts "Are you sure you want to DELETE all computers? (y/n)"
    choice = gets.chomp
    if choice == "y" then
      File.delete("computers.cstore")
    else
      puts "you did not select \"y\" =, no computers deleted."
    end

  else
    puts "incorrect password, no computers deleted."
  end
end

# returns the computer object named in the args from file storage
def load_computer(name)
  computers_arr = Marshal.restore(File.open("computers.cstore", "r+"))

  for computer in computers_arr do
    if computer.name == name then
      return computer
    end
  end
  # TODO: idk about this syntax but i cant get online to check for sumfin better
  raise(ArgumentError.new "no computer with name #{name} was found")
end


# creates a new empty computer
# takes a hash of computer traits that contains a mapping from strings
# describing the detail to the value of that detail.
# OUTDATED
def create_computer_from_hash(name, details_hash)
  return Computer.new(name, details_hash["os"], details_hash["processor"], details_hash["storage"],
    details_hash["memory"], details_hash["screen"], details_hash["battery"],
    details_hash["keyboard"], details_hash["display_ports"], details_hash["other_ports"],
    details_hash["upgrade_specs"], details_hash["peripherals"])
end


# returns a computer created in the command line
def create_computer_from_cmd(name)
  new_comp = Computer.new(name)

  new_comp.enter_all_specs

  return new_comp
end

# finds the Computer(s) with the highest value for a particular numerical
# aspect. Returns as an array of Computers.
def find_superlative(min_or_max, key1, key2 = nil, comp_array)
  if min_or_max == "min" then
    for comp in comp_array do
      min = Float::MAX
      mins = []
      aspect_val = comp.get_aspect(key1, key2)

      if aspect_val < min then
        mins = [comp]
      elsif aspect_val == min then
        mins << comp
      end
    end

    return mins

  elsif min_or_max == "max" then
    for comp in comp_array do
      max = Float::MIN
      max = []
      aspect_val = comp.get_aspect(key1, key2)

      if aspect_val < max then
        max = [comp]
      elsif aspect_val == max then
        max << comp
      end
    end

    return max

  else
    raise ArgumentError.new "min_or_max was neither \"min\" nor \"max\""
  end
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
  PROCESSOR_ASPECTS = ["model", "base clock", "boost clock", "cores", "threads",
  "multithreading", "graphics", "TDP", "lithography"]
  STORAGE_ASPECTS = ["size", "type", "rpm"]
  MEMORY_ASPECTS = ["size", "speed", "type", "slots used", "slots available"]
  SCREEN_ASPECTS = ["size", "resolution", "touch?"]
  BATTERY_ASPECTS = ["estimated life", "mAH"]
  KEYBOARD_ASPECTS = ["backlit?", "numpad?"]
  UPGRADE_ASPECTS = ["max ram", "processor soldered?"]

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

  # used to retreive details about the computer
  # method is here to increase ease of use for later developed
  # code to retreive these details
  def get_aspect(key1, key2 = nil)
    case key1
    when "os"
      value1 = os
    when "processor"
      value1 = processor
    when "storage"
      value1 = storage
    when "memory"
      value1 = memory
    when "screen"
      value1 = screen
    when "battery"
      value1 = battery
    when "keyboard"
      value1 = keyboard
    when "display_ports"
      value1 = display_ports
    when "other_ports"
      value1 = other_ports
    when "upgrade_specs"
      value1 = upgrade_specs
    when "peripherals"
      value1 = peripherals
    end ## add default case that throws error

    if key2 == nil then
      return value1
    else
      return value1[key2]
    end
  end

  # takes an introductory string containing the part of the computer
  # and then detail = which aspect of that part is to be entered.
  # then simply prompts the user to enter a value for that aspect
  # and returns it.
  def get_entry(intro, detail)
    puts intro + " " + detail + ": "
    return gets.chomp
  end

  # gets all entries given a hash, an array of aspects (keys), and
  # an introductory prompt string. Returns a hash.
  def get_entries(hash, aspect_arr, intro)
    for aspect in aspect_arr do
      hash[aspect] = get_entry(intro, aspect)
    end

    return hash
  end

  # allows the user to enter strings until they enter the string "done".
  # once done is entered, returns an array of entered strings
  def get_array(intro)
    puts intro + ", enter \"done\" to finish. "
    arr = []
    while true do
      puts arr.inspect + " + "
      value = gets.chomp
      if value == "done" then
        return arr
      else
        arr << value
      end
    end
  end

  def enter_all_specs
    enter_os
    enter_processor
    enter_storage
    enter_memory
    enter_screen
    enter_battery
    enter_keyboard
    enter_display_ports
    enter_other_ports
    enter_upgrades
    enter_peripherals
  end

  # gets the os from the command line
  def enter_os
    @os = get_entry("enter operating system", "")
  end

  # gets the processor specs from command line
  def enter_processor
    @processor = get_entries(Hash.new, PROCESSOR_ASPECTS, "enter processor")
  end

  #gets the storage details from the command line
  def enter_storage
    @storage = get_entries(Hash.new, STORAGE_ASPECTS, "enter storage")
  end

  # gets the memory details from the command line
  def enter_memory
    @memory = get_entries(Hash.new, MEMORY_ASPECTS, "enter memory")
  end

  # gets the screen details from the command line
  def enter_screen
    @screen = get_entries(Hash.new, SCREEN_ASPECTS, "enter screen")
  end

  # gets the battery details from the command line
  def enter_battery
    @battery = get_entries(Hash.new, BATTERY_ASPECTS, "enter battery")
  end

  # gets the keyboard details from the command line
  def enter_keyboard
    @keyboard = get_entries(Hash.new, KEYBOARD_ASPECTS, "enter keyboard")
  end

  # gets the display ports from the command line
  def enter_display_ports
    @display_ports = get_array("enter display ports")
  end

  # gets the other ports from the command line
  def enter_other_ports
    @other_ports = get_array("enter all other ports")
  end

  # gets upgrade details from the command line
  def enter_upgrades
    @upgrade_specs = get_entries(Hash.new, UPGRADE_ASPECTS, "enter upgrade")
  end

  # gets the included peripherals from the command line
  def enter_peripherals
    @peripherals = get_array("enter all peripherals")
  end
end
