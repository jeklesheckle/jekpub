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
=end
class Computer
  # each of these member vars can be an object/struct with several members
  # e.g. processor has base_clock, boost_clock, cores, etc.
  attr_accessor :os, :processor, :ram, :keyboard, :peripherals, :ports
end
