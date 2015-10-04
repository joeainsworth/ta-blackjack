require 'pry'

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    ['H', 'S', 'C', 'D'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |card|
        @cards << Card.new(suit, card)
      end
    end
    shuffle!
  end

  def shuffle!
    cards.shuffle!
  end

  def deal_card
    cards.shift
  end

  def size
    cards.size
  end
end

class Card < Deck
  attr_reader   :suit
  attr_accessor :value

  def initialize(suit, value)
    @suit   = suit
    @value  = value
  end

  def to_s
    "#{value} of #{find_suit}"
  end

  def find_suit
    case suit
      when "H" then "Hearts"
      when "D" then "Diamonds"
      when "S" then "Spades"
      when "C" then "Clubs"
    end
  end
end

module Hand
  def total
    total = 0
    face_values = hand.map { |card| card.value }
    face_values.each do |value|
      if value == "A"
        total += 11
      else
        total += (value.to_i == 0 ? 10 : value.to_i )
      end
    end

    face_values.select { |value| value == "A" }.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def show_hand
    puts "#{name}'s hand: #{total}"
    puts hand
  end

  def is_bust?
    total > Game::BLACKJACK_VALUE
  end

  def is_blackjack?
    total == Game::BLACKJACK_VALUE
  end

  def add_card(new_card)
    hand << new_card
  end

  def return_cards(deck)
    1.upto(self.hand.size) do
      deck.cards << self.hand.pop
    end
  end
end

class Player
  include Hand

  attr_accessor :hand, :name

  def initialize(name)
    @name = name
    @hand = []
  end
end

class Dealer
  include Hand

  attr_accessor :hand
  attr_reader   :name

  include Hand

  def initialize
    @name = "Dealer"
    @hand = []
  end

  def conceal_hand
    puts "#{name}'s hand:"
    puts hand[0]
    puts "???"
  end

  def must_hit?
    total < Game::DEALER_MIN_VALUE
  end
end

class Game
  BLACKJACK_VALUE  = 21
  DEALER_MIN_VALUE = 17

  attr_reader :deck, :dealer, :player

  def initialize
    system 'clear'
    @deck   = Deck.new
    @player = Player.new("Player")
    @dealer = Dealer.new
  end

  def get_player_name
    puts "Hello!"
    begin
      puts "What is your name?"
      player_name = gets.chomp
    end until player_name =~ /[a-zA-Z\s]/
    player.name = player_name
    system 'clear'
    puts "Hello #{player.name}, welcome to the game..."
    sleep 1
  end

  def deal_cards
    2.times do
      player.add_card(deck.deal_card)
      dealer.add_card(deck.deal_card)
    end
  end

  def display_game_state(conceal_hand=true)
    system 'clear'
    conceal_hand ? dealer.conceal_hand : dealer.show_hand
    puts
    player.show_hand
    sleep 0.5
  end

  def winner?
    player.is_bust? || player.is_blackjack? || dealer.is_bust? || dealer.is_blackjack?
  end

  def player_turn
    loop do
      puts "\nHit or stay? [h/s]"
      hit_or_stay = gets.chomp
      player.add_card(deck.deal_card) if hit_or_stay == "h"
      display_game_state
      break if winner? || hit_or_stay == "s"
    end
  end

  def dealer_turn
    while dealer.total < Game::DEALER_MIN_VALUE do
      dealer.add_card(deck.deal_card)
      display_game_state(false)
    end
  end

  def display_winner
    display_game_state(false)
    puts
    if player.is_blackjack?
      puts "#{player.name} got blackjack!"
    elsif dealer.is_blackjack?
      puts "#{dealer.name} got blackjack!"
    elsif player.is_blackjack? && dealer.is_blackjack?
      puts "#{player.name} and #{dealer.name} got blackjack! It's a tie!"
    elsif player.is_bust?
      puts "#{player.name} is bust!"
      puts "#{dealer.name} won!"
    elsif dealer.is_bust?
      puts "#{dealer.name} is bust!"
      puts "#{player.name} won!"
    elsif
      if player.total > dealer.total
        puts "#{player.name} won!"
      elsif player.total < dealer.total
        puts "#{dealer.name} won!"
      elsif
        puts "#{player.name} and #{dealer.name} tied!"
      end
    end
  end

  def play_again?
    puts "\n#{player.name}, would you like to play again? [y/n]"
    if gets.chomp.downcase == 'y'
      player.hand = []
      dealer.hand = []
      deck = Deck.new
    else
      exit
    end
  end

  def play
    get_player_name
    loop do
      deal_cards
      display_game_state
      player_turn unless winner?
      dealer_turn unless winner?
      display_winner
      play_again?
    end
  end

end

Game.new.play
