# frozen_string_literal: true

class EnigmaMachine
  # временно
  attr_accessor :rotors
  def initialize(rotors:, reflector:, plugboard: Plugboard.new)
    @rotors = rotors  # слева направо
    @reflector = reflector
    @plugboard = plugboard
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

  # Чтобы работало, нужно чтобы роторы были в том же положении, как при начале кодировки
  def decrypt(message)
    encrypt(message)
  end
end