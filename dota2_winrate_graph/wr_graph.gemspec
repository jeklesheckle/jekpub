# encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name           = "NAME"
  spec.version        = '1.0'
  spec.authors        = ["Jackson Pielstick"]
  spec.email          = ["jackpielstick@gmail.com"]
  spec.summary        = %q{Generates a bar graph illustrating win percentages of the radiant and dire.}
  spec.description    = %q{Uses OpenDota's WebAPI to gather the
    winning team of 1000 random recent matches. Uses that information
    to generate a PNG bar graph illustrating the winrates of each team}
  spec.homepage       = "idonthaveawebsite.com"
  spec.license        = "MIT"

  spec.files          = ['lib/wr_graph.rb']
  spec.executables    = ['bin/wr_graph']
  spec.test_files     = ['tests/test_wr_graph.rb']
  spec.require_paths  = ["lib"]
end
