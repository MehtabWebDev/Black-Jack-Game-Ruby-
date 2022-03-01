# frozen_string_literal: true

module IsPossible
  SCORE_LIMIT = 21
  def score_possible_to?(*expected_score)
    score = 0
    ace_count = 0
    @cards.each do |card|
      if card.name == 'Ace'
        score += card.value[0]
        ace_count += 1
      else
        score += card.value
      end
    end
    expected_score.each { |n| return true if n == score }
    false
  end

  def double_down_possible?
    if !@split
      if @cards.length == 2
        if score_possible_to?(9, 10, 11)
          true
        else
          throw :double_down, 'Double Down not possible, Score is not 9, 10 or 11'
        end
      else
        throw :double_down, "Double Down not possible after 'Hit'"
      end
    else
      throw :double_down, "Double Down after 'Split' not allowed"
    end
  end

  def insurance_possible?(dealer)
    cards = get_cards(@hand)

    if dealer.is_insurance_open
      if cards.length == 2
        if dealer.cards[0].name == 'Ace'
          true
        else
          throw :insurance, "Insurance not possible, Dealer's visible card is not 'Ace'"
        end
      else
        throw :insurance, "Insurance not possible after 'Hit'"
      end
    else
      throw :insurance, 'Insurance is not open'
    end
  end

  def split_possible?
    if !@split
      if @cards.length == 2
        if @cards.first.name == @cards.last.name
          true
        else
          throw :split, 'Split not possible, cards are differnt'
        end
      else
        throw :split, "Split not possible after 'Hit'"
      end
    else
      throw :split, "Split after 'Split' not allowed"
    end
  end

  def black_jack?(hand = nil)
    get_score(hand) == SCORE_LIMIT
  end
end
