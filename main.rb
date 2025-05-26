# frozen_string_literal: true
require_relative 'lib/enigma_machine'
require_relative 'lib/bombe_decryptor'

rotor1 = EnigmaMachine::Rotor.rotor_I
rotor2 = EnigmaMachine::Rotor.rotor_II
rotor3 = EnigmaMachine::Rotor.rotor_III
reflector = EnigmaMachine::Reflector.reflector_A
plugboard = EnigmaMachine::Plugboard.new([['A','M'],['F','I'],['N','V'],['P','S'],['T','U'],['W','Z']])

machine = EnigmaMachine::Machine.new(
  rotors: [rotor1, rotor2, rotor3],
  reflector: reflector,
  plugboard: plugboard
)

initial_positions = machine.rotors.map(&:position)

puts 'Enter message to encrypt:'
input = gets.chomp.strip.upcase #добавить обрезку на ввод только букв (чтобы ошибочно не обрабатывались пробелы)
encrypted = machine.encrypt(input)
puts "Encrypted: #{encrypted}"

initial_positions.each_with_index do |pos, i|
  machine.rotors[i].position = pos
end

decrypted = machine.decrypt(encrypted)
puts "Decrypted: #{decrypted}"

puts "Now, try to decrypt with TuringDecryptor!"

# Конфигурация машины: роторы, отражатель, штекерная панель
decryptor = EnigmaMachine::TuringDecryptor.new(
  rotors:    [rotor1, rotor2, rotor3],
  reflector: reflector,
  plugboard: plugboard
)

puts "Введите зашифрованный текст:"
ciphertext = gets.chomp.strip.upcase

puts "Введите известный фрагмент (crib):"
crib = gets.chomp.strip.upcase

puts "Запуск перебора (ring settings 1..1)..."
result = nil
begin
  result = decryptor.crack(ciphertext, crib, ring_range: 1..1)
rescue => e
  puts "Ошибка: #{e.message}"
  exit 1
end

if result
  puts "\nУспех!"
  puts "Расшифрованный текст: #{result[:plaintext]}"
  puts "Start positions: #{result[:start_positions].join(', ')}"
  puts "Ring settings:  #{result[:ring_settings].join(', ')}"
  
else
  puts "Не удалось найти совпадение. Попробуйте другой crib или ring settings."
end