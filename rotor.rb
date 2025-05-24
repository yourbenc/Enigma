# frozen_string_literal: true
# первым ротором считается самый правый

class Rotor
  ALPHABET = ('A'..'Z').to_a

  attr_accessor :wiring, :notch, :ring_setting, :position

  def initialize(wiring:, notch:, ring_setting: 1, position: 'A')
    @wiring = wiring.chars  # массив из 26 символов, на которые происходит замена
    @notch = notch.chars # список зубчиков, при которых проворачивается еще и следующий ротор
    @ring_setting = ring_setting - 1  # zero-index
    @position = ALPHABET.index(position) # текущая позиция ротора
  end

  def step!
    @position = (@position + 1) % 26
  end

  # Проверяет, нужно ли ротору провернуть соседа
  def at_notch?
    notch.include?(ALPHABET[@position])
  end

  # Шифровка при прохождении сигнала через ротор вперед
  def forward(c)
    index = (ALPHABET.index(c) + position - ring_setting) % 26
    wired = wiring[index]
    ALPHABET[(ALPHABET.index(wired) - position + ring_setting) % 26]
  end

  # Шифровка при прохождении сигнала через ротор назад(от отражателя)
  def backward(c)
    index = (ALPHABET.index(c) + position - ring_setting) % 26
    wired_index = wiring.index(ALPHABET[index])
    ALPHABET[(wired_index - position + ring_setting) % 26]
  end
end
