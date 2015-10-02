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
  def calculate_hand
    total = 0

    cards = hand.map { |card| card.value }
    cards.each do |card|
      if card == 'J' ||
         card == 'Q' ||
         card == 'K'
        total += 10
      elsif card == "A"
        total += 11
      else
        total += card.to_i
      end
    end

    hand.select { |card| card.value == "A" }.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def show_hand
    puts "#{name}'s hand: #{calculate_hand}"
    puts hand
  end

  def is_bust?
    calculate_hand > 21
  end

  def is_blackjack?
    calculate_hand == 21
  end

  def return_cards(deck)
    1.upto(self.hand.size) do
      deck.cards << self.hand.pop
    end
  end
end

class Player
  include Hand

  attr_accessor :hand
  attr_reader   :name

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
    calculate_hand < 17
  end
end

class Game
  attr_reader :deck, :dealer, :player

  def initialize
    system 'clear'
    @deck   = Deck.new
    @dealer = Dealer.new
  end

  def greet_player
    puts "Hello!"
    begin
      puts "What is your name?"
      name = gets.chomp
    end until name =~ /[a-zA-Z\s]/
    @player = Player.new(name)
    system 'clear'
    puts "Hello #{name}, welcome to the game..."
    sleep 1
  end

  def deal_cards
    2.times do
      player.hand << deck.deal_card
      dealer.hand << deck.deal_card
    end
  end

  def display_game_state(dealer, player, conceal_hand=true)
    system 'clear'
    conceal_hand ? dealer.conceal_hand : dealer.show_hand
    puts
    player.show_hand
    sleep 0.5
  end

  def winner?
    player.is_bust? || player.is_blackjack? || dealer.is_bust? || dealer.is_blackjack?
  end

  def hit_or_stay
    loop do
      puts "\nWould you like to hit or stay? [h/s]"
      choice = gets.chomp
      player.hand << deck.deal_card if choice == "h"
      display_game_state(dealer, player, true)
      break if winner? || choice == "s"
    end
  end

  def dealer_turn
    while dealer.calculate_hand < 17 do
      dealer.hand << deck.deal_card
      display_game_state(dealer, player, false)
    end
  end

  def display_winner
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
      if player.calculate_hand > dealer.calculate_hand
        puts "#{player.name} won!"
      elsif player.calculate_hand < dealer.calculate_hand
        puts "#{dealer.name} won!"
      elsif
        puts "#{player.name} and #{dealer.name} tied!"
      end
    end
  end

  def play
    greet_player
    loop do
      deal_cards
      display_game_state(dealer, player, true)
      hit_or_stay unless winner?
      dealer_turn unless winner?
      display_winner
      puts "\nWould you like to play again? [y/n]"
      if gets.chomp != 'y'
        break
      else
        player.return_cards(deck)
        dealer.return_cards(deck)
        deck.shuffle!
      end
    end
  end

end

Game.new.play
