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
end

