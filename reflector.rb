# frozen_string_literal: true

class Reflector
  ALPHABET = ('A'..'Z').to_a

  attr_reader :wiring

  def initialize(wiring)
    @wiring = wiring.chars
  end

  def reflect(c)
    wiring[ALPHABET.index(c)]
  end
end
