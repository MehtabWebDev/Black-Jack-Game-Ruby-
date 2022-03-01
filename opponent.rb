# frozen_string_literal: true

require './player'
require './opponent_action'
require './opponent_check_possibility'
require './opponent_input'
require './opponent_rank'
require './opponent_show'

class Opponent < Player
  include Show
  include Rank
  include Input
  include IsPossible
  include Action
  attr_accessor :turn, :chips, :cards, :name, :choice, :insured, :split, :rank, :hand, :stand

  def initialize(name)
    super(name)
    @cards = []
    @chips = 0
    @insured = false
    @split = false
    @rank = nil
    @stand = nil
  end

  def get_cards(hand = nil)
    cards = self.cards
    cards = self.cards[0] if hand == 'left'
    cards = self.cards[1] if hand == 'right'
    cards
  end

  def get_score(hand = nil)
    ace_count = 0
    score = 0
    cards = get_cards(hand)
    cards.each do |card|
      if card.name == 'Ace'
        score += card.value[0]
        ace_count += 1
      else
        score += card.value
      end
    end
    ace_count.times do
      score += 10 if score + 10 <= SCORE_LIMIT
    end
    score
  end

  def calc_minus_chips(hand, chips)
    if chips.nil?
      chips = case hand
              when 'left'
                @chips[0]
              when 'right'
                @chips[1]
              else
                @chips
              end
    end
    chips
  end

  def lose_chips(hand = nil, chips = nil)
    chips = calc_minus_chips(hand, chips)
    case hand
    when 'left'
      @chips[0] -= chips
    when 'right'
      @chips[1] -= chips
    else
      @chips -= chips
    end
    chips
  end

  def make_immediate_choice(option)
    case option
    when 'h'
      @choice = 'Hit'
      false
    when 's'
      @choice = 'Stand'
      false
    when 'r'
      @choice = 'Surrender'
      false
    end
  end

  def make_not_immediate_choice(option, dealer)
    case option
    when 'p'
      make_split
    when 'd'
      double_bet
    when 'i'
      insure(dealer)
    end
  end

  def play_turn(dealer)
    option = prompt(dealer)
    while option
      system 'clear'
      dealer.show
      option = case option
               when 'h', 's', 'r'
                 make_immediate_choice(option)
               when 'p', 'd', 'i'
                 make_not_immediate_choice(option, dealer)
               else
                 prompt_again
               end
    end
  end
end
