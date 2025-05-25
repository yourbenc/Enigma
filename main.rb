  # frozen_string_literal: true
  require_relative 'rotor'
  require_relative 'reflector'
  require_relative 'plugboard'
  require_relative 'enigma_machine'

  rotor1 = Rotor.rotor_I
  rotor2 = Rotor.rotor_II
  rotor3 = Rotor.rotor_III
  reflector = Reflector.reflector_A
  plugboard = Plugboard.new([['A','M'],['F','I'],['N','V'],['P','S'],['T','U'],['W','Z']])

  machine = EnigmaMachine.new(
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



