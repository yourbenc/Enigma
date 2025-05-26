# frozen_string_literal: true
require_relative 'lib/enigma_machine'
require_relative 'lib/enigma_machine/bombe_decryptor'
require_relative 'lib/enigma_machine/bombe'
#require_relative 'lib/bombe_decryptor_rotors_combo'

rotor1 = EnigmaMachine::Rotor.rotor_I
rotor1.name = 1;
rotor2 = EnigmaMachine::Rotor.rotor_II
rotor2.name = 2;
rotor3 = EnigmaMachine::Rotor.rotor_III
rotor3.name = 3;
rotor4 = EnigmaMachine::Rotor.rotor_IV
rotor4.name = 4;
rotor5 = EnigmaMachine::Rotor.rotor_V
rotor5.name = 5;

reflector = EnigmaMachine::Reflector.reflector_A
plugboard = EnigmaMachine::Plugboard.new([['A','M'],['F','I'],['N','V'],['P','S'],['T','U'],['W','Z']])

machine = EnigmaMachine::Machine.new(
  rotors: [rotor2, rotor1, rotor3],
  reflector: reflector,
  plugboard: plugboard
)

initial_positions = machine.rotors.map(&:position)

puts 'Enter message to encrypt:'
input = gets.chomp.strip.upcase #добавлена обрезку на ввод только букв (чтобы ошибочно не обрабатывались пробелы)
encrypted = machine.encrypt(input)
puts "Encrypted: #{encrypted}"

initial_positions.each_with_index do |pos, i|
  machine.rotors[i].position = pos
end

decrypted = machine.decrypt(encrypted)
puts "Decrypted: #{decrypted}"



#Дешифратор Bombe ____________________________________________________________________________________________ 
puts "Now, try to decrypt with TuringDecryptor!"

# Конфигурация машины: роторы, отражатель, штекерная панель
decryptor = EnigmaMachine::TuringDecryptor.new(
  rotors:    [rotor2, rotor1, rotor3],
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

#Дешифратор Bombe с перебором роторов ___________________


puts "Введите зашифрованный текст:"
ciphertext = gets.chomp.strip.upcase
puts "Введите известный фрагмент (crib):"
crib = gets.chomp.strip.upcase

puts "\nЗапуск Bombe с перебором роторов и настроек..."
base_rotors = [rotor1, rotor2, rotor3, rotor4, rotor5]
bombe = EnigmaMachine::Bombe.new(ciphertext, crib, base_rotors, reflector, plugboard)
bombe_result = bombe.run
if bombe_result
  puts "Bombe нашла подходящую конфигурацию!"
  #puts "Роторы: #{bombe_result[:rotors].map(&:class)}"
  puts "Роторы: #{bombe_result[:rotors].map(&:name).join(', ')}"
  puts "Настройки кольца: #{bombe_result[:ring_settings].join(', ')}"
  puts "Стартовые позиции: #{bombe_result[:start_positions].join}"
  puts "Полный расшифрованный текст: #{bombe_result[:plaintext]}"
else
  puts "Bombe не нашла подходящей конфигурации."
end