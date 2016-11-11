require 'pry'
# variables
SUITS = ["Hearts", "Diamonds", "Clubs", "Spades"].freeze
CARDS = [2, 3, 4, 5, 6, 7, 8, 9, 10, "jack", "queen", "king", "ace"].freeze
player_score = 0
dealer_score = 0
tie_score = 0
winner = ''
round = 0

# methods
def prompt(msg)
  puts "=> #{msg}"
end

def initialize_deck
  temp_deck = []
  SUITS.each do |suit|
    CARDS.each do |card|
      temp_deck << [suit, card]
    end
  end
  temp_deck
end

def clear_screen
  system('clear') || system('cls')
end

def deal_card(receiver, deck)
  receiver << deck.shuffle!.pop
end

def initial_deal(receiver, deck)
  2.times do
    deal_card(receiver, deck)
  end
end

def ace?(total, aces)
  aces.times do
    total = if total <= 10
              total += 11
            else
              total += 1
            end
  end
  total
end

def calculate_total_value(hand)
  total = 0
  aces = 0
  hand.each do |_suit, value|
    if value.class == Fixnum
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
  total > 21
end

def player_turn(hand, deck)
  puts "hit or stay?"
  answer = gets.chomp.downcase
  return answer if answer == "stay"
  deal_card(hand, deck)
end

def dealer_turn(hand, deck)
  loop do
    total = calculate_total_value(hand)
    break if total >= 17 || bust?(total)
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
  add_cards = "#{hand.length - 1} additional cards"
  "Dealer hand: #{hand[0][1]} of #{hand[0][0]} and #{add_cards}"
end

def display_scores(player, dealer, tie, rounds, pscore, dscore)
  clear_screen
  puts "-" * 60
  puts display_player_hand(player)
  puts display_dealer_hand(dealer)
  puts "Player score: #{pscore}; Dealer score: #{dscore}; Ties #{tie}"
  puts "Number of games played: #{rounds}"
  puts "-" * 60
end

def winner?(player, dealer)
  if player > dealer
    "Player"
  elsif player == dealer
    "Tie"
  else
    "Dealer"
  end
end

# Game logic
clear_screen
puts "Welcome to twenty-one!"
sleep(2)
loop do # main logic loop
  # clear_screen
  dealer_hand = []
  player_hand = []
  loop do
    new_deck = initialize_deck
    initial_deal(player_hand, new_deck)
    initial_deal(dealer_hand, new_deck)
    display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                   dealer_score)
    loop do
      answer = player_turn(player_hand, new_deck)
      display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                     dealer_score)
      total = calculate_total_value(player_hand)
      break if answer == "stay" || bust?(total)
    end
    player_total = calculate_total_value(player_hand)
    if bust?(player_total)
      winner = "Dealer"
      prompt "Player busted!"
      sleep(2)
      break
    end
    dealer_turn(dealer_hand, new_deck)
    display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                   dealer_score)
    dealer_total = calculate_total_value(dealer_hand)
    if bust?(dealer_total)
      winner = "Player"
      prompt "Dealer busted!"
      sleep(2)
      break
    end
    winner = winner?(player_total, dealer_total)
    break unless winner.empty?
  end
  display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                 dealer_score)
  if winner == "Tie"
    prompt "Its a tie!"
  else
    prompt "#{winner} won!"
  end
  sleep(2)
  if winner == "Player"
    player_score += 1
  elsif winner == "Dealer"
    dealer_score += 1
  else
    tie_score += 1
  end
  round += 1
  display_scores(player_hand, dealer_hand, tie_score, round, player_score,
                 dealer_score)
  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end
puts "Thank you for playing twenty-one!"
