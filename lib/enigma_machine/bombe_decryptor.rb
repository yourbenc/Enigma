require_relative "../enigma_machine"

module EnigmaMachine
  class TuringDecryptor
    def initialize(rotors:, reflector:, plugboard: Plugboard.new)
      @base_rotors = rotors
      @reflector = reflector
      @plugboard = plugboard
    end

    def crack(ciphertext, crib, ring_range: 1..1, max_attempts: nil)
      total = 0
      ring_range.each do |r0|
        ring_range.each do |r1|
          ring_range.each do |r2|
            rotors = @base_rotors.map(&:dup)
            machine = Machine.new(
              rotors: rotors,
              reflector: @reflector,
              plugboard: @plugboard,
              ring_settings: [r0, r1, r2],
              start_positions: ['A','A','A']
            )

            ('A'..'Z').each do |p0|
              ('A'..'Z').each do |p1|
                ('A'..'Z').each do |p2|
                  total += 1
                  if max_attempts && total > max_attempts
                    raise "Превышено максимальное число попыток: #{max_attempts}"
                  end

                  machine.reset_to_created
                  machine.set_start_position(0, p0)
                  machine.set_start_position(1, p1)
                  machine.set_start_position(2, p2)

                  plaintext = machine.decrypt(ciphertext)
                  if plaintext.include?(crib)
                    return {
                      plaintext: plaintext,
                      ring_settings: [r0, r1, r2],
                      start_positions: [p0, p1, p2],
                      rotors: rotors,
                      reflector: @reflector,
                      plugboard: @plugboard
                    }
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