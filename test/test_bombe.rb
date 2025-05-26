require 'minitest/autorun'
require_relative '../lib/enigma_machine'
require_relative '../lib/bombe_decryptor'

class TuringDecryptorAdditionalTest < Minitest::Test
  include EnigmaMachine

  def setup
    @rotors    = [Rotor.rotor_I, Rotor.rotor_II, Rotor.rotor_III]
    @reflector = Reflector.reflector_A
    @plugboard = Plugboard.new([['A','B'], ['C','D']])

    @ring_settings = [1, 1, 1]
    @start_positions = ['A', 'A', 'A']

    @machine = Machine.new(
      rotors: @rotors,
      reflector: @reflector,
      plugboard: @plugboard,
      ring_settings: @ring_settings,
      start_positions: @start_positions
    )

    @decryptor = TuringDecryptor.new(rotors: @rotors, reflector: @reflector, plugboard: @plugboard)
    @plaintext = 'TESTMESSAGE'
    @crib      = 'MESSAGE'
    @cipher    = @machine.encrypt(@plaintext)
  end

  # 1. Проверка, что метод crack возвращает nil, если ciphertext пустая строка
  def test_crack_with_empty_ciphertext
    result = @decryptor.crack('', @crib)
    assert_nil result, 'Expected nil for empty ciphertext'
  end

  # 2. Проверка, что поиск находит хотя бы фрагмент crib в результате, даже если не в начале
  def test_crack_finds_crib_somewhere
    plain = 'XYZ' + @crib + 'ZZZ'
    test_machine = Machine.new(
      rotors: @rotors,
      reflector: @reflector,
      plugboard: @plugboard,
      ring_settings: @ring_settings,
      start_positions: @start_positions
    )
    cipher = test_machine.encrypt(plain)
    result = @decryptor.crack(cipher, @crib)
    refute_nil result, 'Expected a result containing the crib'
    assert_includes result[:plaintext], @crib
  end

  # 3. Проверка, что метод crack возвращает nil, если crib слишком длинный
  def test_crack_with_too_long_crib
    long_crib = 'X' * (@cipher.length + 1)
    result = @decryptor.crack(@cipher, long_crib)
    assert_nil result, 'Expected nil when crib is longer than ciphertext'
  end
  # 4. Проверка, что метод crack работает корректно без plugboard
  def test_crack_without_plugboard
    no_plugboard = Plugboard.new([])
    machine = Machine.new(
      rotors: @rotors,
      reflector: @reflector,
      plugboard: no_plugboard,
      ring_settings: @ring_settings,
      start_positions: @start_positions
    )
    plaintext = 'HELLOWORLD'
    crib = 'WORLD'
    cipher = machine.encrypt(plaintext)
    decryptor = TuringDecryptor.new(rotors: @rotors, reflector: @reflector, plugboard: no_plugboard)
    result = decryptor.crack(cipher, crib)
    refute_nil result, 'Expected successful crack without plugboard'
    assert_includes result[:plaintext], crib
  end
# 5. Проверка, что crack не возвращает результат, если crib не совпадает ни с одной частью текста
def test_crack_with_unmatched_crib
  unmatched_crib = 'UNMATCHED'
  result = @decryptor.crack(@cipher, unmatched_crib)
  assert_nil result, 'Expected nil for unmatched crib'
end
# 6. Проверка, что crack работает корректно с разными стартовыми позициями роторов
def test_crack_with_different_start_positions
  # Задаём другую стартовую позицию роторов
  different_positions = ['M', 'K', 'Z']
  machine_diff = Machine.new(
    rotors: @rotors,
    reflector: @reflector,
    plugboard: @plugboard,
    ring_settings: @ring_settings,
    start_positions: different_positions
  )
  cipher_diff = machine_diff.encrypt(@plaintext)

  # Убедимся, что шифротексты отличаются
  refute_equal @cipher, cipher_diff, 'Ciphertexts with different start positions should differ'

  # Попытка расшифровать с правильным crib на шифротексте с другими позициями
  result = @decryptor.crack(cipher_diff, @crib)
  refute_nil result, 'Expected crack to find plaintext with different start positions'
  assert_includes result[:plaintext], @crib
end
# 7. Проверка, что crack работает корректно с разными настройками кольца
def test_crack_with_different_ring_settings
  # Задаём другие настройки кольца
  different_ring_settings = [2, 3, 4]
  machine_diff = Machine.new(
    rotors: @rotors,
    reflector: @reflector,
    plugboard: @plugboard,
    ring_settings: different_ring_settings,
    start_positions: @start_positions
  )
  cipher_diff = machine_diff.encrypt(@plaintext)

  # Шифротексты должны отличаться при разных настройках кольца
  refute_equal @cipher, cipher_diff, 'Ciphertexts with different ring settings should differ'

  # Попытка расшифровать с правильным crib на шифротексте с другими настройками кольца
  decryptor_diff = TuringDecryptor.new(rotors: @rotors, reflector: @reflector, plugboard: @plugboard)
  result = decryptor_diff.crack(cipher_diff, @crib)
  refute_nil result, 'Expected crack to find plaintext with different ring settings'
  assert_includes result[:plaintext], @crib
end
  # 8
  def test_crack_finds_working_ring_settings
    known_ring_settings = [3, 2, 5]
    machine = Machine.new(
      rotors:          @rotors,
      reflector:       @reflector,
      plugboard:       @plugboard,
      ring_settings:   known_ring_settings,
      start_positions: @start_positions
    )
    cipher = machine.encrypt(@plaintext)

    result = @decryptor.crack(cipher, @crib, ring_range: 1..5)
    refute_nil result, "Ожидаем, что crack найдёт какие-то рабочие настройки"

    recovered = Machine.new(
      rotors:          @rotors.map(&:dup),
      reflector:       @reflector,
      plugboard:       @plugboard,
      ring_settings:   result[:ring_settings],
      start_positions: result[:start_positions]
    )
    decoded = recovered.decrypt(cipher)

    assert_equal @plaintext, decoded,
                 "С возвращёнными настройками не удаётся восстановить исходный plaintext"

    assert_includes decoded, @crib
  end

  #9
  def test_crack_finds_correct_start_positions
    known_start_positions = ['L', 'M', 'N']
    machine = Machine.new(
      rotors: @rotors,
      reflector: @reflector,
      plugboard: @plugboard,
      ring_settings: @ring_settings,
      start_positions: known_start_positions
    )
    cipher = machine.encrypt(@plaintext)

    # ring_range: только одно значение (по умолчанию — [1, 1, 1])
    result = @decryptor.crack(cipher, @crib)

    refute_nil result, 'Expected to find correct start positions'
    assert_equal known_start_positions, result[:start_positions], 'Start positions do not match'
    assert_includes result[:plaintext], @crib
  end

  #10
  def test_crack_returns_working_ring_and_start
    known_ring_settings   = [4, 5, 6]
    known_start_positions = ['X', 'Y', 'Z']

    machine = Machine.new(
      rotors:          @rotors,
      reflector:       @reflector,
      plugboard:       @plugboard,
      ring_settings:   known_ring_settings,
      start_positions: known_start_positions
    )
    cipher = machine.encrypt(@plaintext)
    result = @decryptor.crack(cipher, @crib, ring_range: 4..6)
    refute_nil result, "Ожидаем, что crack найдёт какие-то рабочие настройки"

    recovered = Machine.new(
      rotors:          @rotors.map(&:dup),
      reflector:       @reflector,
      plugboard:       @plugboard,
      ring_settings:   result[:ring_settings],
      start_positions: result[:start_positions]
    )
    decoded = recovered.decrypt(cipher)
    assert_equal @plaintext, decoded, "С возвращёнными настройками не удаётся восстановить исходный plaintext"
    assert_includes decoded, @crib
  end

  # 11
  def test_crack_respects_ring_range
    known_ring_settings   = [4, 5, 6]
    known_start_positions = ['X', 'Y', 'Z']

    # шифруем с кольцами 4,5,6
    machine = Machine.new(
      rotors:          @rotors,
      reflector:       @reflector,
      plugboard:       @plugboard,
      ring_settings:   known_ring_settings,
      start_positions: known_start_positions
    )
    cipher = machine.encrypt(@plaintext)
    result = @decryptor.crack(cipher, @crib, ring_range: 1..3)
    if result.nil?
      assert_nil result, "При ring_range 1..3 не ожидалось никакой конфигурации"
    else
      assert result[:ring_settings].all? { |r| (1..3).cover?(r) },
             "Найденные ring_settings #{result[:ring_settings].inspect} выходят за рамки 1..3"
      assert_includes result[:plaintext], @crib,
                      "Если возвращён результат, то plaintext должен содержать crib"
    end
  end

end

