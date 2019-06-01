# this file has functions and definitions for computer objects

# takes a computer and stores it into the database as a line of characters
def store_computer(computer)

end

# creates a new empty computer
# takes a hash of computer traits that contains a mapping from strings
# describing the detail to the value of that detail.
def create_computer(details_hash)

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
      "type" -> [String] Type of storage (HDD, SSD, eMMC, etc.)
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
upgrade_specs: [Hash] Traits relating to upgradability
      "max_ram" -> [Int] The maximum amount of RAM the machine supports
      "hard_drive_easy?" -> [Bool] True if the technician believes a normal
        person would be able to easily find and swap the hard drive.
      "processor_soldered?" -> [Bool] If the processor is soldered to the mobo
Peripherals: [Array] Strings describing peripherals included in the box
  (also includes speakers built into the device)

also want to add: upgrades, ports, peripherals....
=end
class Computer
  # each of these member vars can be an object/struct with several members
  # e.g. processor has base_clock, boost_clock, cores, etc.
  attr_accessor :os, :processor
end
