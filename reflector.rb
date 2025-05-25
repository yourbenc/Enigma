# frozen_string_literal: true

class Reflector
  ALPHABET = ('A'..'Z').to_a

  attr_reader :wiring

  def initialize(wiring)
    @wiring = wiring.chars
  end

  def self.reflector_A
    #          ABCDEFGHIJKLMNOPQRSTYVWXYZ
    new('EJMZALYXVBWFCRQUONTSPIKHGD')
  end
  def self.reflector_B
    #          ABCDEFGHIJKLMNOPQRSTYVWXYZ
    new('YRUHQSLDPXNGOKMIEBFZCWVJAT')
  end
  def self.reflector_C
    #          ABCDEFGHIJKLMNOPQRSTYVWXYZ
    new('FVPJIAOYEDRZXWGCTKUQSBNMHL')
  end

  def reflect(c)
    wiring[ALPHABET.index(c)]
  end
end
