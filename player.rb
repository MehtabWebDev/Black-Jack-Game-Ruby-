# frozen_string_literal: true

class Player
  SCORE_LIMIT = 21

  def initialize(name)
    @name = name
    @turn = false
  end

  def calc_basic_score(cards)
    score = 0
    ace_count = 0
    cards.each do |card|
      if card.name == 'Ace'
        score += card.value[0]
        ace_count += 1
      else
        score += card.value
      end
    end
    [score, ace_count]
  end

  def get_score(hand = nil)
    cards = self.cards
    cards = self.cards[0] if hand == 'left'
    cards = self.cards[1] if hand == 'right'
    score, ace_count = calc_basic_score(cards)
    ace_count.times do
      score += 10 if score + 10 <= SCORE_LIMIT
    end
    score
  end
end
