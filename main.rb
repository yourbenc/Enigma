  # frozen_string_literal: true
  require_relative 'lib/enigma_machine'

  rotor1 = EnigmaMachine::Rotor.rotor_I
  rotor2 = EnigmaMachine::Rotor.rotor_II
  rotor3 = EnigmaMachine::Rotor.rotor_III
  reflector = EnigmaMachine::Reflector.reflector_A
  plugboard = EnigmaMachine::Plugboard.new([['A','M'],['F','I'],['N','V'],['P','S'],['T','U'],['W','Z']])

  machine = EnigmaMachine::Machine.new(
    rotors: [rotor1, rotor2, rotor3],
    reflector: reflector,
    plugboard: plugboard
  )

  initial_positions = machine.rotors.map(&:position)

  puts 'Enter message to encrypt:'
  input = gets.chomp
  encrypted = machine.encrypt(input)
  puts "Encrypted: #{encrypted}"

  initial_positions.each_with_index do |pos, i|
    machine.rotors[i].position = pos
  end

  decrypted = machine.decrypt(encrypted)
  puts "Decrypted: #{decrypted}"



