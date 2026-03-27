# frozen_string_literal: true

# load dicationary file and select randomly a word between 5 and 12 chr

module Hangman
  require "yaml"
  ALPHABET = %w[a b c d e f g h i j k l m n o p q r s t u
                v w x y z].freeze

  class Game
    MAX_ROUND = 7
    DRAWINGS = [
      '',
      "    |––––––|\n           |\n           |\n           | \n           |",
      "    |––––––|\n    O      |\n           |\n           |\n           |",
      "    |––––––|\n    O      |\n    |      |\n    |      |\n           |",
      "    |––––––|\n    O      |\n    |/     |\n    |      |\n           |",
      "    |––––––|\n    O      |\n   \\|/     |\n    |      |\n           |",
      "    |––––––|\n    O      |\n   \\|/     |\n    |      |\n   /       |",
      "    |––––––|\n    O      |\n   \\|/     |\n    |      |\n   / \\     |"
    ].freeze
    def initialize
      @secret_word = generate_secret_word
      @player = Player.new(self)
      @available_letters = ALPHABET
      @correct_letters = []
      @wrong_letters = []
      @secret_guess = Array.new(@secret_word.length)
      @round = 1
      @wrong_guess = false
      @game_saved = 1
    end
    attr_reader :available_letters

    def play
      option_load_game
      loop do
        play_round
        break if game_finished?
      end
      winner_announcement
    end

    def variables_to_yaml
      [@secret_word,
      @available_letters,
      @correct_letters,
      @wrong_letters,
      @secret_guess,
      @round,
      @wrong_guess,
      @game_saved].to_yaml
    end

    def save_game
      File.write("save_#{@game_saved}.yaml", variables_to_yaml) 
      @game_saved += 1
    end 

    def load_saved_game(number)
      v = YAML.load_file("save_#{number}.yaml")
      @secrect_word = v[0]
      @available_letters = v[1]
      @correct_letters = v[2]
      @wrong_letters = v[3]
      @secret_guess = v[4]
      @round = v[5]
      @wrong_guess = v[6]
      @game_saved = v[7]
    end

    def load_game? 
      print "Do you want to load your presvious game? y/n: "
      yes_no_loop
    end

    def option_load_game
      if load_game?
        print "enter the number of your game saved: "
        number = gets.chomp.to_i 
        load_saved_game(number)
      end 
    end


    def winner_announcement
      if word_found?
        puts "\nWell done !\nYou found the secret word: '#{@secret_word.join}'"
      else
        puts "\nYou lost, the secret word was: '#{@secret_word.join}'"
      end
    end

    def generate_secret_word
      File.read('english-1000.txt').split.filter { |n| (n.size > 4) & (n.size < 13) }.sample.chars
    end

    def play_round
      @wrong_guess = false
      display_drawing_and_secret_lines
      loop do
        guess_letters
        option_to_save_game        
        break if wrong_guess?
      end
      @round += 1
    end

    def wrong_guess?
      @wrong_guess
    end

    def guess_letters
      letter = pick_letter
      categorize_picked_letter(letter)
      update_secret_guess
      announce_result(letter)
    end

    def option_to_save_game
      if save_game?
        puts "You have a new save number: #{@game_saved}"
        save_game
      end
    end

    def yes_no_loop
      answer = ""
      loop do 
        answer = gets.chomp.downcase
        break if (answer=="y") || (answer=="n")
        puts "Error, try 'y' or 'n'"
      end
      answer == "y"
    end

    def save_game?
      print "Do you want to save your game? y/n : "
      yes_no_loop
    end

    def categorize_picked_letter(letter)
      if correct_letter?(letter)
        @correct_letters << letter
      else
        @wrong_letters << letter
        @wrong_guess = true
      end
    end

    def announce_result(letter)
      if @correct_letters.include?(letter)
        puts "\n\nGood guess !!"
        display_secret_lines
        puts ' '
      else
        puts "\n\nWrong guess !!"
      end
      return if @wrong_letters.none?

      puts "Wrong => #{@wrong_letters.join(', ')}"
    end

    def correct_letter?(letter)
      @secret_word.include? letter.downcase
    end

    def pick_letter
      letter = @player.pick_letter
      @available_letters.delete letter
    end

    def update_secret_guess
      @secret_word.each_with_index do |letter, i|
        @secret_guess[i] = letter if @correct_letters.include? letter
      end
    end

    def game_finished?
      word_found? || max_round?
    end

    def word_found?
      @secret_guess == @secret_word
    end

    def max_round?
      @round > MAX_ROUND
    end

    def display_drawing_and_secret_lines
      puts ' '
      display_drawing
      display_secret_lines
      puts ' '
    end

    def display_drawing
      puts(DRAWINGS[@round])
    end

    def display_secret_lines
      print "\nSecret word => "
      secret_lines = ''
      @secret_guess.each do |letter|
        secret_lines += if letter.nil?
                          '_ '
                        else
                          "#{letter} "
                        end
      end
      puts secret_lines
    end

    def display_available_letters
      print "\nAvailable letters are the following: "
      puts @available_letters.join(', ')
      puts ' '
    end
  end

  class Player
    def initialize(game)
      @game = game
    end

    def pick_letter
      @game.display_available_letters
      print 'Pick a letter: '
      loop do
        letter = gets.chomp
        return letter if letter_available? letter

        puts 'This letter is not available try again'
        @game.display_available_letters
      end
    end

    def letter_available?(letter)
      available_letters.include? letter.downcase
    end

    def available_letters
      @game.available_letters
    end
  end
end


# File.open("saved_game")



Hangman::Game.new.play



