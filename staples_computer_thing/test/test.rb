# this file is for live testing, may have other files for unit testing later
require 'pp'
require '../lib/computer.rb'


## this does not use the object creation methodology
# that i want to follow in the future, i want to create
# objects in the command line and eventually using the scraper
# in synchrony with a gui
##############################################################
#####         S A M P L E  C O M P U T E R          ##########
##############################################################

details_hash = Hash.new
details_hash["os"] = "ubuntu"

# may want a check to see if string is valid
# will need to confirm that nils are generated rather than ""
processor_hash = Hash.new
processor_hash["name"] = "jektel i69"
processor_hash["base_clock"] = 5.0
processor_hash["boost_clock"] = 6.9
processor_hash["cores"] = 4
processor_hash["threads"] = 8
processor_hash["hyperthreading?"] = true
processor_hash["graphics"] = "jektel hd420"
processor_hash["TDP"] = 2
processor_hash["lithography"] = 6
details_hash["processor"] = processor_hash

storage_hash = Hash.new
storage_hash["size"] = 9
storage_hash["type"] = "NVMe"
storage_hash["rpm"] = 0
details_hash["storage"] = storage_hash

memory_hash = Hash.new
memory_hash["size"] = 16
memory_hash["speed"] = 2400
memory_hash["type"] = "DDR4"
memory_hash["slots_used"] = 2
memory_hash["slots_available"] = 4
details_hash["memory"] = memory_hash

screen_hash = Hash.new
screen_hash["size"] = 15.6
screen_hash["resolution"] = [1080, 720]
screen_hash["touch?"] = false
details_hash["screen"] = screen_hash

battery_hash = Hash.new
battery_hash["life_estimate"] = 10
battery_hash["mAH"] = 10000
details_hash["battery"] = battery_hash

keyboard_hash = Hash.new
keyboard_hash["backlit?"] = true
keyboard_hash["numpad?"] = true
details_hash["keyboard"] = keyboard_hash

details_hash["display_ports"] = ["HDMI", "DVI"]

details_hash["other_ports"] = ["USB-C", "USB3.1", "SD"]

upgrade_hash = Hash.new
upgrade_hash["max_ram"] = 64
upgrade_hash["hard_drive_easy?"] = true
upgrade_hash["processor_soldered?"] = false
details_hash["upgrade"] = upgrade_hash

details_hash["peripherals"] = []

sample_computer = create_computer("jektop15", details_hash)

########################### ACTUALLY DOING THINGS WITH SAMPLE
store_computer(sample_computer)
comp_obj = load_computer(sample_computer)

puts "AFTER: " + comp_obj.pretty_inspect

#### current bug is just that store / the hash isn't set up right, ezpc fix
