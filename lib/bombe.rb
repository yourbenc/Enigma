module EnigmaMachine
  class Bombe
    def initialize(ciphertext, crib, base_rotors, reflector, plugboard)
      @ciphertext = ciphertext
      @crib = crib
      @base_rotors = base_rotors # массив из 5 базовых роторов
      @reflector = reflector
      @plugboard = plugboard
    end

    def run
      possible_rotor_combinations.each do |rotors_combo|
        (1..26).each do |r1|
          (1..26).each do |r2|
            (1..26).each do |r3|
              ring_settings = [r1, r2, r3]

              ('A'..'Z').each do |p1|
                ('A'..'Z').each do |p2|
                  ('A'..'Z').each do |p3|
                    start_positions = [p1, p2, p3]

                    machine = EnigmaMachine::Machine.new(
                      rotors:           deep_clone_rotors(rotors_combo),
                      reflector:        @reflector,
                      plugboard:        @plugboard,
                      ring_settings:    ring_settings,
                      start_positions:  start_positions
                    )
                    snippet = machine.decrypt(@ciphertext[0...@crib.length])
                    next unless matches_crib?(snippet, @crib)
                    machine.reset_to_created
                    full_plain = machine.decrypt(@ciphertext)

                    return {
                      rotors:          rotors_combo,
                      ring_settings:   ring_settings,
                      start_positions: start_positions,
                      snippet:         snippet,
                      plaintext:       full_plain
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

    private

    def possible_rotor_combinations
      @base_rotors.permutation(3).to_a
    end

    def deep_clone_rotors(rotors)
      rotors.map { |rotor| rotor.clone } 
    end

    def matches_crib?(decrypted_text, crib)
      decrypted_text == crib
    end
  end
end
