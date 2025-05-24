# frozen_string_literal: true

class Plugboard
  attr_reader :mapping

  def initialize(pairs = [])
    @mapping = {}.tap do |m|
      ('A'..'Z').each { |c| m[c] = c }
      pairs.each do |a, b|
        m[a] = b
        m[b] = a
      end
    end
  end

  def swap(c)
    mapping[c]
  end
end