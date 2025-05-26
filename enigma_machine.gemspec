Gem::Specification.new do |s|
  s.name        = "enigma_machine"
  s.version     = EnigmaMachine::VERSION
  s.summary     = "Enigma cipher machine emulator"
  s.description = "Emulates the WWII Enigma machine with 3 rotors, reflector, plugboard and ring settings."
  s.authors     = ["Ilya Petrov", "Victoriya Gorbanyova"]
  s.email       = ["asldjasjd@gmail.com"]
  s.files       = Dir["lib/**/*.rb"]
  s.test_files  = Dir["test/**/*"]
  s.homepage    = "https://github.com/yourbenc/Enigma"
  s.license     = "MIT"
  s.required_ruby_version = ">= 2.5"
end