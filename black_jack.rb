# frozen_string_literal: true

require 'io/console'
require './dealer'
require './opponent'

def change_turn(opp_index)
  stay
  opp_index + 1
end

def check_rank_and_change_turn(opponents, opp_index)
  opponent = opponents[opp_index]
  if opponent.split
    if opponent.hand.eql?('left') && opponent.ranked?('left')
      opponent.hand = 'right'
      stay
      return check_rank_and_change_turn(opponents, opp_index)
    elsif opponent.ranked?('right')
      opp_index = change_turn(opp_index)
    end
  elsif opponent.ranked?
    opp_index = change_turn(opp_index)
  end
  opp_index
end

def stay
  print 'Enter any key to continue: '
  get
  system 'clear'
end

def play_against_dealer(players, player_i, dealer)
  players[player_i].play_turn(dealer)
  dealer.perform(players[player_i])
  check_rank_and_change_turn(players, player_i)
end

def play(dealer, opponents)
  system 'clear'
  players = opponents + [dealer]
  player_i = 0
  while player_i < players.count - 1
    if !players[player_i].split && players[player_i].ranked?
      player_i += 1
    else
      player_i = play_against_dealer(players, player_i, dealer)
    end
  end
  dealer.turn = true
  dealer.play_turn(opponents)
end

def get
  input = $stdin.getch
  control_c_code = "\u0003"
  exit(1) if input == control_c_code
  input
end

def get_player_info(player_count, players)
  player_count.times do |i|
    print "\nEnter Name of Player#{i + 1}: "
    players << Opponent.new(gets.chomp)
    players[i].bet
  end
  players
end

def distribute_cards(player_count, players, dealer)
  2.times do
    player_count.times do |i|
      dealer.pass_to_opponent(players[i])
    end
    dealer.pass_himself
  end
  system 'clear'
end

def check_black_jack(player_count, dealer, players)
  player_count.times do |i|
    dealer.check_black_jack(players[i])
    next if players[i].rank.nil?

    players[i].show
    print 'Press any key to continue: '
    get
  end
end

def start_game(players, dealer)
  print 'Enter No of Players(1-5): '
  player_count = gets.to_i
  players = get_player_info(player_count, players)
  distribute_cards(player_count, players, dealer)
  check_black_jack(player_count, dealer, players)
  play(dealer, players)
end

start_game([], Dealer.new('Dealer'))
puts 'Game Over'
