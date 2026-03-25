# frozen_string_literal: true

# load dicationary file and select randomly a word between 5 and 12 chr

module Hangman
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
      @secrect_word = generate_secret_word
      @player = Player.new(self)
      @available_letters = ALPHABET
      @correct_letters = []
      @wrong_letters = []
      @secrect_guess = Array.new(@secrect_word.length)
      @round = 1
      @wrong_guess = false
    end
    attr_reader :available_letters

    def play
      loop do
        play_round
        break if game_finished?
      end
      winner_announcement
    end

    def winner_announcement
      if word_found?
        puts "\nWell done !\nYou found the secret word: '#{@secrect_word.join}'"
      else
        puts "\nYou lost, the secret word was: '#{@secrect_word.join}'"
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
      @secrect_word.include? letter.downcase
    end

    def pick_letter
      letter = @player.pick_letter
      @available_letters.delete letter
    end

    def update_secret_guess
      @secrect_word.each_with_index do |letter, i|
        @secrect_guess[i] = letter if @correct_letters.include? letter
      end
    end

    def game_finished?
      word_found? || max_round?
    end

    def word_found?
      @secrect_guess == @secrect_word
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
      @secrect_guess.each do |letter|
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

# Hangman::Game.new.play
