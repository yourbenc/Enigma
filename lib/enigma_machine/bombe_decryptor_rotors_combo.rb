# frozen_string_literal: true
require_relative "../enigma_machine"

module EnigmaMachine
  class TuringDecryptorLevelUp
    def initialize(rotors:, reflector:, plugboard: Plugboard.new)
      @available_rotors = rotors # список всех возможных роторов
      @reflector = reflector
      @plugboard = plugboard
    end

    def crack(ciphertext, crib, ring_range: 1..1, max_attempts: nil)
      total = 0
      rotor_triplets = @available_rotors.combination(3).flat_map(&:permutation)

      rotor_triplets.each do |rotor_set|
        ring_range.each do |r0|
          ring_range.each do |r1|
            ring_range.each do |r2|
              rotors_copy = rotor_set.map(&:dup)
              [r0, r1, r2].each_with_index do |ring_val, idx|
                rotors_copy[idx].ring_setting = ring_val - 1
              end
              # Создаем машину с заданными настройками колец и стартовыми позициями
              machine = Machine.new(
                rotors: rotors_copy,
                reflector: @reflector,
                plugboard: @plugboard,
                start_positions: ['A', 'A', 'A']
              )

              ('A'..'Z').each do |p0|
                ('A'..'Z').each do |p1|
                  ('A'..'Z').each do |p2|
                    total += 1
                    if max_attempts && total > max_attempts
                      raise "Превышено максимальное число попыток: #{max_attempts}"
                    end

                    machine.reset_to_factory
                    machine.set_start_position(0, p0)
                    machine.set_start_position(1, p1)
                    machine.set_start_position(2, p2)

                    plaintext = machine.decrypt(ciphertext)
                    if plaintext.include?(crib)
                      return {
                        plaintext: plaintext,
                        ring_settings: [r0, r1, r2],
                        start_positions: [p0, p1, p2],
                        rotors: rotor_set,
                        reflector: @reflector,
                        plugboard: @plugboard,
                        attempts: total
                      }
                    end
                  end
                end
              end
            end
          end
        end
      end

      nil
    end
  end
end
