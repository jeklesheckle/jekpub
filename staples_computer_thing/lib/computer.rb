# this file has functions and definitions for computer objects

######################################################################
# H E L P E R  F U N C T I O N S
######################################################################
# takes a string and returns true/false based on what the string spells
def to_bool(string)
  capstring = string.to_s.upcase
  if capstring == "TRUE" then
    return true
  else if capstring == "FALSE" then
    return false
  else
    raise "Argument error: to_bool expected true or false but was given something else"
  end
end


######################################################################
# A C T U A L  C O M P U T E R  S T U F F
######################################################################
# takes a computer and stores it into the database as a line of characters
def store_computer(computer)

end

# returns the computer object named in the args from file storage
def load_computer(name)
  File.open("computers.cstor", "r") do |file|
    #match the name then match and get the params
    while(line = file.gets) do
      # captures the stored objects
      line.match(/#{name}|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|(.*)|/) do |entry|
        # parsing the stored object strings for individual fields
        # fields are delimited by % symbols
        # 0: os, 1: processor, 2: storage, 3: memory, 4: screen, 5: battery,
        # 6: keyboard, 7: display_ports, 8: other_ports, 9: upgrade_specs,
        # 10: peripherals
        caps = entry.captures

        details_hash = Hash.new
        details_hash["os"] = caps[0]

        # may want a check to see if string is valid
        # will need to confirm that nils are generated rather than ""
        processor_fields = caps[0].split("%")
        processor_hash = Hash.new
        processor_hash["name"] = processor_fields[0].to_s
        processor_hash["base_clock"] = processor_fields[1].to_f
        processor_hash["boost_clock"] = processor_fields[2].to_f
        processor_hash["cores"] = processor_fields[3].to_i
        processor_hash["threads"] = processor_fields[4].to_i
        processor_hash["hyperthreading?"] = to_bool(processor_fields[5])
        processor_hash["graphics"] = processor_fields[6].to_s
        processor_hash["TDP"] = processor_fields[7].to_i
        processor_hash["lithography"] = processor_fields[8].to_i
        details_hash["processor"] = processor_hash

        storage_fields = caps[1].split("%")
        storage_hash = Hash.new
        storage_hash["size"] = storage_fields[0].to_i
        storage_hash["type"] = storage_fields[1].to_s
        storage_hash["rpm"] = storage_fields[2].to_i
        details_hash["storage"] = storage_hash

        memory_fields = caps[2].split("%")
        memory_hash = Hash.new
        memory_hash["size"] = memory_fields[0].to_i
        memory_hash["speed"] = memory_fields[1].to_i
        memory_hash["type"] = memory_fields[2].to_i
        memory_hash["slots_used"] = memory_fields[3].to_i
        memory_hash["slots_available"] = memory_fields[4].to_i
        details_hash["memory"] = memory_hash

        screen_fields = caps[3].split("%")
        screen_hash = Hash.new
        screen_hash["size"] = screen_fields[0].to_f
        screen_hash["resolution"] = screen_fields[1].split("$")
        screen_hash["touch?"] = to_bool(screen_fields[2])
        details_hash["screen"] = screen_hash

        battery_fields = caps[4].split("%")
        battery_hash = Hash.new
        battery_hash["life_estimate"] = battery_fields[0].to_i
        battery_hash["mAH"] = battery_fields[1].to_i
        details_hash["battery"] = battery_hash

        keyboard_fields = caps[5].split("%")
        keyboard_hash = Hash.new
        keyboard_hash["backlit?"] = to_bool(keyboard_fields[0])
        keyboard_hash["numpad?"] = to_bool(keyboard_fields[1])
        details_hash["keyboard"] = keyboard_hash

        details_hash["display_ports"] = caps[6].split("$") # arr elements del. by $

        details_hash["other_ports"] = caps[7].split("$")

        upgrade_traits = caps[8].split("%")
        upgrade_hash = Hash.new
        upgrade_hash["max_ram"] = upgrade_traits[0].to_i
        upgrade_hash["hard_drive_easy?"] = to_bool(upgrade_traits[1])
        upgrade_hash["processor_soldered?"] = to_bool(upgrade_traits[2])
        details_hash["upgrade"] = upgrade_hash

        details_hash["peripherals"] = caps[9].split("$")

        return create_computer(details_hash)
      end
    end
    return nil
  end
end

# creates a new empty computer
# takes a hash of computer traits that contains a mapping from strings
# describing the detail to the value of that detail.
def create_computer(details_hash)
  return Computer.new(details_hash["processor"], details_hash["storage"],
    details_hash["memory"], details_hash["screen"], details_hash["battery"]),
    details_hash["keyboard"], details_hash["display_ports"], details_hash["other_ports"],
    details_hash["upgrade_specs"], details_hash["peripherals"])
end

=begin
Represents a computer, centered around a hash of all of the traits

Traits:
os: [String] The operating system the device comes with
processor: [Hash] Processor traits:
      "name" -> [String] The model of processor
      "base_clock" -> [Float] The base clock speed
      "boost_clock" -> [Float] The boost clock speed
      "cores" -> [Int] Number of cores
      "threads" -> [Int] Number of threads
      "hyperthreading?" -> [Bool] Whether an Intel processor has hyperthreading
      "graphics" -> [String] Onboard graphics
      "TDP" -> [Int] Power draw in Watts
      "lithography" -> [String] Lithography (die size in nanometers)
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
  attr_accessor :os, :processor, :storage, :memory, :screen, :battery, :keyboard
    , :display_ports, :other_ports, :upgrade_specs, :peripherals

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
