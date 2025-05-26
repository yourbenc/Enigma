module EnigmaMachine
  class Bombe
    def initialize(ciphertext, crib, base_rotors, reflector, plugboard)
      @ciphertext   = ciphertext
      @crib         = crib
      @base_rotors  = base_rotors    # массив из 5 базовых роторов
      @reflector    = reflector
      @plugboard    = plugboard
      @ring_settings   = [1, 1, 1]   # фиксированные кольцевые настройки
      @start_positions = ['A', 'A', 'A'] # фиксированные стартовые позиции
    end

    def run
      possible_rotor_combinations.each do |rotors_combo|
        machine = EnigmaMachine::Machine.new(
          rotors:           deep_clone_rotors(rotors_combo),
          reflector:        @reflector,
          plugboard:        @plugboard,
          ring_settings:    @ring_settings,
          start_positions:  @start_positions
        )

        snippet = machine.decrypt(@ciphertext[0...@crib.length])
        next unless matches_crib?(snippet, @crib)

        machine.reset_to_created
        full_plain = machine.decrypt(@ciphertext)

        return {
          rotors:          rotors_combo,
          ring_settings:   @ring_settings,
          start_positions: @start_positions,
          snippet:         snippet,
          plaintext:       full_plain
        }
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
