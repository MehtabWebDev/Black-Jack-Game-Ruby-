# frozen_string_literal: true

require './player'
require './deck'
require './dealer_show'
require './dealer_action'
require './dealer_check'
require './dealer_pass'

class Dealer < Player
  include Action
  include Pass
  include Show
  include Check

  MIN_SCORE = 17

  attr_accessor :turn, :chips, :name, :cards, :is_insurance_open

  def initialize(name)
    super(name)
    @deck = Deck.new
    @cards = []
    @chips = 0
    @is_insurance_open = true
    @turn = false
  end

  def deal_insured(chips, opponent, hand)
    main_bet = chips / 1.5
    insured_bet = chips - main_bet
    check_insured_bet(opponent, insured_bet, hand)
    check_main_bet(opponent, main_bet, hand)
  end

  def deal_not_insured(chips, opponent, hand, dealer_score, opponent_score)
    dealer_gap = SCORE_LIMIT - dealer_score
    opponent_gap = SCORE_LIMIT - opponent_score
    if dealer_gap < opponent_gap && dealer_gap >= 0
      opponent.lose_chips(hand, chips)
      opponent.lose(chips, hand)
    elsif dealer_gap > opponent_gap && opponent_gap >= 0
      opponent.win(chips, hand)
    else
      opponent.tie(hand)
    end
  end

  def make_deal(opponent, hand = nil)
    opponent_score = opponent.get_score(hand)
    dealer_score = get_score
    case hand
    when 'left'
      insured = opponent.insured[0]
      chips = opponent.chips[0]
    when 'right'
      insured = opponent.insured[1]
      chips = opponent.chips[1]
    else
      insured = opponent.insured
      chips = opponent.chips
    end
    if insured
      deal_insured(chips, opponent, hand)
    else
      deal_not_insured(chips, opponent, hand, dealer_score, opponent_score)
    end
  end

  def decide_rank(opponent, rank, hand)
    rank.nil? ? make_deal(opponent, hand) : opponent.show_rank(hand)
    opponent.show(hand)
  end

  def play_turn(opponents)
    system 'clear'
    make_seventeen
    reveal
    opponents.each do |opponent|
      if opponent.split
        decide_rank(opponent, opponent.rank[0], 'left')
        decide_rank(opponent, opponent.rank[1], 'right')
      else
        decide_rank(opponent, opponent.rank, nil)
      end
    end
  end

  def perform(opponent)
    case opponent.choice
    when 'Hit'
      hit(opponent)
    when 'Stand'
      stand(opponent)
      opponent.show(opponent.hand)
    when 'Split'
      split(opponent)
    when 'Double Down'
      double_down(opponent)
    when 'Insurance'
      insurance(opponent)
    when 'Surrender'
      surrender(opponent)
    end
  end
end
