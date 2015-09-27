SUIT  = ['H', 'S', 'C', 'D']
CARDS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

def say(msg)
  puts "\n=> #{msg}"
end

def card_suit(card)
  case card
  when 'H'
    "Hearts"
  when 'S'
    "Spades"
  when 'C'
    "Clubs"
  when 'D'
    "Diamonds"
  end
end

def suit_card(card)
  case card
  when 'J'
    "Jack"
  when 'Q'
    "Queen"
  when 'K'
    "King"
  when 'A'
    "Ace"
  else
    card
  end
end

def ask_name
  say "What is your name?"
  gets.chomp
end

def shuffle_deck
  SUIT.product(CARDS).shuffle
end

def value_of_hand(hand)
  total = 0
  cards = hand.map { |c| c[1] }
  cards.each do |card|
    if card == 'J' ||
       card == 'Q' ||
       card == 'K'
      total += 10
    elsif card == 'A'
      total > 10 ? total += 1 : total += 11
    else
      total += card.to_i
    end
  end
  total
end

def conceal_hand(cards)
  card = cards[0]
  puts "Dealers hand: ??"
  puts "> #{suit_card(card[1])} of #{card_suit(card[0])}"
  puts "> ??"
end

def display_hand(person, cards)
  puts "#{person}'s hand: #{value_of_hand(cards)}"
  cards.each do |card|
    puts "> #{suit_card(card[1])} of #{card_suit(card[0])}"
  end
end

def display_game_state(players_name, dealers_cards, players_cards,
                       conceal_hand=false)
  system 'clear'
  conceal_hand ? conceal_hand(dealers_cards) : display_hand("Dealer", dealers_cards)
  puts
  display_hand(players_name, players_cards)
end

system 'clear'
puts "Welcome to Blackjack!"
players_name = ask_name

begin loop
  system 'clear'
  deck = shuffle_deck

  players_cards = []
  dealers_cards = []
  players_cards << deck.shift
  dealers_cards << deck.shift
  players_cards << deck.shift
  dealers_cards << deck.shift

  display_game_state(players_name, dealers_cards, players_cards, true)

  loop do
    if value_of_hand(players_cards) == 21
      puts "\n#{players_name} got Blackjack!"
      break
    else
      say "Would you like to hit or stay? [h/s]"
      hit_or_stay = gets.chomp
      if hit_or_stay == 'h'
        players_cards << deck.shift
        display_game_state(players_name, dealers_cards, players_cards, true)
        if value_of_hand(players_cards) > 21
          display_game_state(players_name, dealers_cards, players_cards)
          puts "\n#{players_name} is bust!"
          break
        end
      elsif hit_or_stay == 's'
        while value_of_hand(dealers_cards) < 17
          dealers_cards << deck.shift
          display_game_state(players_name, dealers_cards, players_cards, true)
        end
        if value_of_hand(dealers_cards) > 21
          display_game_state(players_name, dealers_cards, players_cards)
          puts "\nDealer is bust!"
          break
        elsif value_of_hand(dealers_cards) == 21
          display_game_state(players_name, dealers_cards, players_cards)
          puts "\nDealer hit Blackjack!"
          break
        elsif value_of_hand(dealers_cards) > value_of_hand(players_cards)
          display_game_state(players_name, dealers_cards, players_cards)
          puts "\nDealer won!"
          break
        elsif value_of_hand(dealers_cards) < value_of_hand(players_cards)
          display_game_state(players_name, dealers_cards, players_cards)
          puts "\n#{players_name} won!"
          break
        else
          display_game_state(players_name, dealers_cards, players_cards)
          puts "\nIt was a tie!"
          break
        end
      end
    end
  end

  say "Would you like to play again #{players_name}? (y/n)"
end until gets.chomp != "y"
