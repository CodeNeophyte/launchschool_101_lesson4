# requires
require 'pry'
require 'yaml'

# variables
SUITS = ["Hearts", "Diamonds", "Clubs", "Spades"].freeze
CARDS = [2, 3, 4, 5, 6, 7, 8, 9, 10, "jack", "queen", "king", "ace"].freeze
GAME_LIMIT = 21
DEALER_LIMIT = 17
MESSAGES = YAML.load_file('twenty-one.yml')
round = 0

# methods
def prompt(msg)
  puts "=> #{msg}"
end

def messages(message)
  MESSAGES[message]
end

def initialize_deck
  SUITS.product(CARDS).shuffle!
end

def clear_screen
  system('clear') || system('cls')
end

def deal_card(receiver, deck)
  receiver << deck.pop
end

def initial_deal(receiver, deck)
  2.times do
    deal_card(receiver, deck)
  end
end

def ace?(total, aces)
  aces.times do
    total += if total <= (GAME_LIMIT - 11)
               11
             else
               1
             end
  end
  total
end

def calculate_total_value(hand)
  total = 0
  aces = 0
  hand.each do |_suit, value|
    if value.is_a? Integer
      total += value
    elsif value == "ace"
      aces += 1
    else
      total += 10
    end
  end
  aces > 0 ? ace?(total, aces) : total
end

def bust?(total)
  total > GAME_LIMIT
end

def player_turn(hand, deck)
  answer = ''
  loop do
    puts "(h)it or (s)tay?"
    answer = gets.chomp.downcase
    break if ['h', 's'].include?(answer)
    prompt("Incorrect value! Try again.")
  end
  return answer if answer == "s"
  deal_card(hand, deck)
end

def dealer_turn(hand, deck)
  loop do
    total = calculate_total_value(hand)
    break if total >= DEALER_LIMIT || bust?(total)
    deal_card(hand, deck)
  end
end

def translate_hand(hand)
  hand_string = []
  hand.each do |suit, value|
    hand_string << "#{value} of #{suit}"
  end
  hand_string.join(", ")
end

def display_player_hand(hand)
  total = calculate_total_value(hand)
  hand_string = translate_hand(hand)
  "Player hand: #{hand_string}; current total: #{total}"
end

def display_dealer_hand(hand)
  add_cards = if hand.length == 2
                "#{hand.length - 1} additional card"
              else
                "#{hand.length - 1} additional cards"
              end
  "Dealer hand: #{hand[0][1]} of #{hand[0][0]} and #{add_cards}"
  # binding.pry
end

def display_scores(player, dealer, tie, rounds, pscore, dscore)
  clear_screen
  puts "-" * 60
  puts display_player_hand(player)
  puts display_dealer_hand(dealer)
  puts "Player score: #{pscore}; Dealer score: #{dscore}; Ties #{tie}"
  puts "Number of rounds played: #{rounds}"
  puts "-" * 60
end

def who_won(player, dealer)
  if player > dealer
    "Player"
  elsif player == dealer
    "Tie"
  else
    "Dealer"
  end
end

def show_dealer_deck(hand, total)
  hand_string = translate_hand(hand)
  puts "Dealer hand: #{hand_string}; current total: #{total}"
end

def display_winner(winner, dealer_hand, total)
  if winner == "Tie"
    prompt "Its a tie!"
  else
    prompt "#{winner} won!"
    show_dealer_deck(dealer_hand, total)
  end
end

def play_again?
  answer = ''
  loop do
    prompt "Play again? (y or n)"
    answer = gets.chomp.downcase
    break if ['y', 'n'].include?(answer)
    prompt "Invalid entry! Try again."
  end
  answer.start_with?('y')
end

def update_scores(player_score, dealer_score, tie_score, round, winner)
  if winner == "Player"
    player_score += 1
  elsif winner == "Dealer"
    dealer_score += 1
  else
    tie_score += 1
  end
  round += 1
  [player_score, dealer_score, tie_score, round]
end

# Game logic
clear_screen
prompt(messages('welcome'))
prompt(messages('objective'))
prompt(messages('game'))
sleep(4)
loop do # main logic loop, game starts
  player_card_total = 0
  dealer_card_total = 0
  player_score = 0
  dealer_score = 0
  tie_score = 0
  winner = ''
  dealer_hand = []
  player_hand = []
  loop do # start of round
    break if player_score == 5 || dealer_score == 5
    dealer_hand = [] # initialize
    player_hand = [] # initialize
    new_deck = initialize_deck
    initial_deal(player_hand, new_deck)
    initial_deal(dealer_hand, new_deck)
    display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                   dealer_score)
    loop do # player turn
      answer = player_turn(player_hand, new_deck)
      display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                     dealer_score)
      player_card_total = calculate_total_value(player_hand)
      break if answer == "s" || bust?(player_card_total)
    end
    if bust?(player_card_total)
      winner = "Dealer"
      prompt "Player busted!"
      dealer_card_total = calculate_total_value(dealer_hand)
      dealer_score += 1
      round += 1
      display_winner(winner, dealer_hand, dealer_card_total)
      sleep(4)
      next
    end # player turn ends
    # dealer turn starts
    dealer_turn(dealer_hand, new_deck)
    display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                   dealer_score)
    dealer_card_total = calculate_total_value(dealer_hand)
    if bust?(dealer_card_total)
      winner = "Player"
      prompt "Dealer busted!"
      player_score += 1
      round += 1
      display_winner(winner, dealer_hand, dealer_card_total)
      sleep(4)
      next
    end # dealer turn ends
    winner = who_won(player_card_total, dealer_card_total)
    display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                   dealer_score)
    display_winner(winner, dealer_hand, dealer_card_total)
    sleep(4)
    player_score, dealer_score, tie_score, round = update_scores(player_score,
                                                                 dealer_score,
                                                                 tie_score,
                                                                 round, winner)
  end # end of round
  display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                 dealer_score)
  puts player_score == 5 ? "Player won the game!" : "Dealer won the game!"
  break unless play_again?
end # end game
puts "Thank you for playing twenty-one!"
