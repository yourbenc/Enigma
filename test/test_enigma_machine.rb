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
  def test_rotor_step_advances_position
    rotor = EnigmaMachine::Rotor.rotor_I(position: 'A')
    initial_pos = rotor.position
    rotor.step!
    expected_pos = (initial_pos + 1) % EnigmaMachine::Reflector::ALPHABET.size
    assert_equal expected_pos, rotor.position, "Rotor position should advance by one after step!"
  end

  def test_rotor_full_rotation_wraps_around
    rotor = EnigmaMachine::Rotor.rotor_III(position: 'A')
    alphabet_size = EnigmaMachine::Reflector::ALPHABET.size
    alphabet_size.times { rotor.step! }
    assert_equal rotor.position, 0, "Rotor position should wrap around to 0 after full rotation"
  end

  def test_encrypt_decrypt_with_plugboard_swaps
    plugboard = EnigmaMachine::Plugboard.new([['A','B'], ['C','D'], ['E','F']])
    machine = EnigmaMachine::Machine.new(rotors: @rotors, reflector: @reflector, plugboard: plugboard)
    message = 'FACEBAD'
    encrypted = machine.encrypt(message)
    # Сброс позиций роторов перед дешифровкой (как обычно в Enigma)
    machine.rotors.each { |r| r.position = 0 }
    decrypted = machine.decrypt(encrypted)
    assert_equal message, decrypted
  end
  def test_different_start_positions_produce_different_ciphertexts
    message = 'ENIGMA'
    machine1 = EnigmaMachine::Machine.new(rotors: @rotors, reflector: @reflector, plugboard: @plugboard)
    machine2 = EnigmaMachine::Machine.new(rotors: @rotors, reflector: @reflector, plugboard: @plugboard)

    # Установим разные стартовые позиции роторов
    machine1.rotors.each_with_index { |r, i| r.position = i }
    machine2.rotors.each_with_index { |r, i| r.position = (i + 1) % EnigmaMachine::Reflector::ALPHABET.size }

    encrypted1 = machine1.encrypt(message)
    encrypted2 = machine2.encrypt(message)

    refute_equal encrypted1, encrypted2, "Ciphertexts with different start positions should differ"
  end
end