require 'pry'

# Constants variables
INITIAL_MARKER = " ".freeze
PLAYER_MARKER = "X".freeze
COMPUTER_MARKER = "O".freeze
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                [[1, 5, 9], [3, 5, 7]].freeze       # diagonals
number_of_games = 0

# methods
def prompt(msg)
  puts "=> #{msg}"
end

def clear_screen
  system('clear') || system('cls')
end

def display_round_winner(winner, round)
  if round.zero?
    return puts ""
  elsif winner == "Player" || winner == "Computer"
    return puts "#{winner} won round: #{round}"
  else
    return puts "Round was a tie!"
  end
end

def display_scores(player, computer, tie)
  puts "-" * 25
  puts "Player: #{PLAYER_MARKER}, score: #{player}"
  puts "Computer: #{COMPUTER_MARKER}, score: #{computer}"
  puts "Ties: #{tie}"
  puts "-" * 25
end

# rubocop:disable Metrics/AbcSize
def create_board(brd)
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def display_board(brd, player, computer, tie, round, winner)
  clear_screen
  display_scores(player, computer, tie)
  create_board(brd)
  display_round_winner(winner, round)
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def joinor(arr, delimiter= ', ', conjunction= 'or ')
  return arr[0] if arr.size == 1
  arr.join(delimiter).insert(-2, conjunction)
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    puts "Sorry, that's not a valid choice"
  end
  brd[square] = PLAYER_MARKER
end

def detect_two(brd, marker1, marker2)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(marker1) == 2 &&
       brd.values_at(*line).count(marker2) == 1 # ignores sets where
      # the player already filled the third square
      next
    elsif brd.values_at(*line).count(marker1) == 2 &&
          brd.values_at(*line).count(marker2).zero?
      return line
    end
  end
  []
end

def select_empty_space(brd, array) # selects the empty space after detect two
  array.each do |num|
    if brd[num] != INITIAL_MARKER
      next
    else
      return num
    end
  end
end

def pick_five_or_empty(brd)
  selection = 0
  if brd[5] == INITIAL_MARKER
    selection = 5
  else
    selection = empty_squares(brd).sample
  end
  selection
end

def computer_places_piece!(brd) # offensive first, then defensive
  offensive_opportunities = detect_two(brd, COMPUTER_MARKER, PLAYER_MARKER)
  defensive_opportunities = detect_two(brd, PLAYER_MARKER, COMPUTER_MARKER)
  if !offensive_opportunities.empty?
    square = select_empty_space(brd, offensive_opportunities)
  elsif offensive_opportunities.empty?
    if !defensive_opportunities.empty?
      square = select_empty_space(brd, defensive_opportunities)
    elsif defensive_opportunities.empty?
      square = pick_five_or_empty(brd)
    end
  end
  brd[square] = COMPUTER_MARKER
end

def place_piece!(brd, current_player)
  if current_player == "Player"
    player_places_piece!(brd)
  elsif current_player == "Computer"
    computer_places_piece!(brd)
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def first_player(num_games, winner)
  answer = ''
  if num_games.zero?
    clear_screen
    loop do
      puts "Choose first player: Player or Computer"
      answer = gets.chomp.capitalize
      break if answer == "Player" || answer == "Computer"
      puts "Invalid entry. Try again!"
    end
  else
    winner == "Player" ? answer = "Computer" : answer = "Player"
  end
  answer
end

def alternate_player(cur_player)
  cur_player = cur_player == "Player" ? "Computer" : "Player"
end

# Main logic
loop do # Main loop
  player_score = 0 # reset score variables to zero
  computer_score = 0
  tie_score = 0
  round = 0
  winner = ''
  board = ''
  current_player = first_player(number_of_games, winner)
  loop do
    board = initialize_board # self-explanatory

    loop do # Play loop
      display_board(board, player_score, computer_score, tie_score, round,
                    winner)
      place_piece!(board, current_player)
      current_player = alternate_player(current_player)
      break if someone_won?(board) || board_full?(board)
    end

    display_board(board, player_score, computer_score, tie_score, round, winner)

    if someone_won?(board)
      winner = detect_winner(board)
      winner == "Player" ? player_score += 1 : computer_score += 1
    else
      winner = ''
      tie_score += 1
    end
    round += 1
    display_board(board, player_score, computer_score, tie_score, round, winner)
    sleep(2)
    break if player_score == 5 || computer_score == 5
  end
  display_board(board, player_score, computer_score, tie_score, round, winner)
  puts player_score == 5 ? "Player won the game!" : "Computer won the game!"
  number_of_games += 1
  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt "Thanks for playing Tic Tac Toe!!"
