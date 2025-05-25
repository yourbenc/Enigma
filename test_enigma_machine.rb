require 'minitest/autorun'
require_relative 'rotor'
require_relative 'reflector'
require_relative 'plugboard'
require_relative 'enigma_machine'

class EnigmaMachineTest < Minitest::Test
  def setup
    @rotors = [Rotor.rotor_I, Rotor.rotor_II, Rotor.rotor_III]
    @reflector = Reflector.reflector_B
    @plugboard = Plugboard.new
    @machine = EnigmaMachine.new(rotors: @rotors, reflector: @reflector, plugboard: @plugboard)
    @initial_positions = @machine.rotors.map(&:position)
  end

  def teardown
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
    plug = Plugboard.new([['A','B'], ['C','D']])
    assert_equal 'B', plug.swap('A')
    assert_equal 'A', plug.swap('B')
    assert_equal 'D', plug.swap('C')
    assert_equal 'C', plug.swap('D')
    assert_equal 'E', plug.swap('E')
  end

  def test_rotor_static_constructors
    r = Rotor.rotor_I(ring_setting: 3, position: 'M')
    assert_equal ['Q'], r.notch
    assert_equal 12, r.position
  end

  def test_reflector_reciprocity
    refl = Reflector.reflector_B
    Reflector::ALPHABET.each do |char|
      mapped = refl.reflect(char)
      assert_equal char, refl.reflect(mapped), "Reflector not reciprocal for #{char}"
    end
  end

  def test_ring_setting_changes_behavior
    r1 = Rotor.rotor_IV(ring_setting: 1, position: 'A')
    r2 = Rotor.rotor_IV(ring_setting: 2, position: 'A')
    r1.step!
    r2.step!
    out1 = r1.forward('A')
    out2 = r2.forward('A')
    refute_equal out1, out2
  end
end

