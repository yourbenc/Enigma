# frozen_string_literal: true

module EnigmaMachine
class Machine
  attr_accessor :rotors
  def initialize(rotors:, reflector:, plugboard: Plugboard.new, ring_settings: nil, start_positions: nil)
    @rotors = rotors  # слева направо
    @reflector = reflector
    @plugboard = plugboard

    default_ring = Array.new(@rotors.size, 1)
    default_start = Array.new(@rotors.size, 'A')

    @created_ring_settings = ring_settings ? ring_settings.dup : default_ring
    @created_positions = start_positions ? start_positions.dup : default_start

    @rotors.each_with_index do |rotor, i|
      rotor.ring_setting = @created_ring_settings[i] - 1
      rotor.position = Rotor::ALPHABET.index(@created_positions[i])
    end
  end

  def set_ring_setting(rotor_index, ring_value)
    @rotors[rotor_index].ring_setting = ring_value - 1
  end

  def set_start_position(rotor_index, letter)
    @rotors[rotor_index].position = Rotor::ALPHABET.index(letter)
  end

  def current_ring_settings
    @rotors.map { |r| r.ring_setting + 1 }
  end

  def reset_to_factory
    @rotors.each do |rotor|
      rotor.ring_setting = 0
      rotor.position = Rotor::ALPHABET.index('A')
    end
  end

  def reset_to_created
    @rotors.each_with_index do |rotor, i|
      rotor.ring_setting = @created_ring_settings[i] - 1
      rotor.position = Rotor::ALPHABET.index(@created_positions[i])
    end
  end

  def step_rotors
    if @rotors[1].at_notch?
      @rotors[0].step!
      @rotors[1].step!
    elsif @rotors[2].at_notch?
      @rotors[1].step!
    end
    @rotors[2].step!
  end

  def encrypt_char(c)
    return c unless ('A'..'Z').include?(c)
    step_rotors
    # сначала пропускаем через комутационную панель
    c = @plugboard.swap(c)
    rotors.reverse_each { |r| c = r.forward(c) }
    c = @reflector.reflect(c)
    rotors.each { |r| c = r.backward(c) }
    @plugboard.swap(c)
  end

  def encrypt(message)
    message.upcase.chars.map { |c| encrypt_char(c) }.join
  end

  def change_rotors(new_rotors, ring_settings: nil, start_positions: nil)
    @rotors = new_rotors
    default_ring = Array.new(@rotors.size, 1)
    default_start = Array.new(@rotors.size, 'A')

    @created_ring_settings = ring_settings ? ring_settings.dup : default_ring
    @created_positions     = start_positions     ? start_positions.dup     : default_start

    @rotors.each_with_index do |rotor, i|
      rotor.ring_setting = @created_ring_settings[i] - 1
      rotor.position     = Rotor::ALPHABET.index(@created_positions[i])
    end
  end

  def set_rotor_at(index, new_rotor, ring_setting: nil, start_position: nil)
    @rotors[index] = new_rotor

    rs = ring_setting || (@created_ring_settings[index] || 1)
    sp = start_position || (@created_positions[index]     || 'A')

    new_rotor.ring_setting = rs - 1
    new_rotor.position     = Rotor::ALPHABET.index(sp)

    @created_ring_settings[index] = rs
    @created_positions[index]     = sp
  end

  # Чтобы работало, нужно чтобы роторы были в том же положении, как при начале кодировки
  def decrypt(message)
    encrypt(message)
  end
end
end