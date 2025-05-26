require 'minitest/autorun'
require_relative '../lib/enigma_machine'

class EnigmaMachineTest < Minitest::Test
  def setup
    @rotors = [EnigmaMachine::Rotor.rotor_I, EnigmaMachine::Rotor.rotor_II, EnigmaMachine::Rotor.rotor_III]
    @reflector = EnigmaMachine::Reflector.reflector_B
    @plugboard = EnigmaMachine::Plugboard.new
    @machine = EnigmaMachine::Machine.new(rotors: @rotors, reflector: @reflector, plugboard: @plugboard)
    @initial_positions = @machine.rotors.map(&:position)
  end

  def test_roundtrip_encryption_decryption
    message = 'HELLOWORLD'
    encrypted = @machine.encrypt(message)
    @initial_positions.each_with_index { |pos, i| @machine.rotors[i].position = pos }
    decrypted = @machine.decrypt(encrypted)
    assert_equal message, decrypted
  end

  def test_repeated_letters_vary_ciphertext
    msg = 'AAAAA'
    ciphertext = @machine.encrypt(msg)
    refute ciphertext.chars.uniq.one?
  end

  def test_plugboard_swapping
    plug = EnigmaMachine::Plugboard.new([['A','B'], ['C','D']])
    assert_equal 'B', plug.swap('A')
    assert_equal 'A', plug.swap('B')
    assert_equal 'D', plug.swap('C')
    assert_equal 'C', plug.swap('D')
    assert_equal 'E', plug.swap('E')
  end

  def test_rotor_static_constructors
    r = EnigmaMachine::Rotor.rotor_I(ring_setting: 3, position: 'M')
    assert_equal ['Q'], r.notch
    assert_equal 12, r.position  # 'M' index
  end

  def test_reflector_reciprocity
    refl = EnigmaMachine::Reflector.reflector_B
    EnigmaMachine::Reflector::ALPHABET.each do |char|
      mapped = refl.reflect(char)
      assert_equal char, refl.reflect(mapped), "Reflector not reciprocal for #{char}"
    end
  end

  def test_ring_setting_changes_behavior
    r1 = EnigmaMachine::Rotor.rotor_IV(ring_setting: 1, position: 'A')
    r2 = EnigmaMachine::Rotor.rotor_IV(ring_setting: 2, position: 'A')
    r1.step!
    r2.step!
    out1 = r1.forward('A')
    out2 = r2.forward('A')
    refute_equal out1, out2
  end

  def test_change_rotors_default_settings
    new_rotors = [
      EnigmaMachine::Rotor.rotor_IV,
      EnigmaMachine::Rotor.rotor_V,
      EnigmaMachine::Rotor.rotor_I
    ]
    @machine.change_rotors(new_rotors)
    assert_equal new_rotors, @machine.rotors
    assert_equal [1, 1, 1], @machine.current_ring_settings
    positions = @machine.rotors.map { |r| EnigmaMachine::Rotor::ALPHABET[r.position] }
    assert_equal ['A', 'A', 'A'], positions
  end

  def test_change_rotors_custom_settings
    new_rotors = [
      EnigmaMachine::Rotor.rotor_II,
      EnigmaMachine::Rotor.rotor_III,
      EnigmaMachine::Rotor.rotor_IV
    ]
    rings = [2, 3, 4]
    starts = ['B', 'C', 'D']
    @machine.change_rotors(new_rotors, ring_settings: rings, start_positions: starts)
    assert_equal new_rotors, @machine.rotors
    assert_equal rings, @machine.current_ring_settings
    positions = @machine.rotors.map { |r| EnigmaMachine::Rotor::ALPHABET[r.position] }
    assert_equal starts, positions
  end

  def test_set_rotor_at_default
    replacement = EnigmaMachine::Rotor.rotor_III
    @machine.change_rotors(@rotors, ring_settings: [1, 1, 1], start_positions: ['A', 'A', 'A'])
    @machine.set_rotor_at(1, replacement)
    assert_equal replacement, @machine.rotors[1]
    assert_equal 1, @machine.current_ring_settings[1]
    assert_equal 'A', EnigmaMachine::Rotor::ALPHABET[@machine.rotors[1].position]
  end

  def test_set_rotor_at_custom
    replacement = EnigmaMachine::Rotor.rotor_I
    @machine.change_rotors(@rotors, ring_settings: [1, 1, 1], start_positions: ['A', 'A', 'A'])
    @machine.set_rotor_at(0, replacement, ring_setting: 5, start_position: 'E')
    assert_equal replacement, @machine.rotors[0]
    assert_equal 5, @machine.current_ring_settings[0]
    assert_equal 'E', EnigmaMachine::Rotor::ALPHABET[@machine.rotors[0].position]
  end

  def test_cipher_changes_after_rotor_change
    plaintext = 'HELLOWORLD'
    cipher_before = @machine.encrypt(plaintext)
    @machine.reset_to_created
    new_set = [
      EnigmaMachine::Rotor.rotor_V,
      EnigmaMachine::Rotor.rotor_IV,
      EnigmaMachine::Rotor.rotor_III
    ]
    @machine.change_rotors(new_set, ring_settings: [1, 1, 1], start_positions: ['A', 'A', 'A'])
    cipher_after = @machine.encrypt(plaintext)
    refute_equal cipher_before, cipher_after
  end
end

