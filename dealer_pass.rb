# frozen_string_literal: true

module Pass
  MIN_SCORE = 16
  SCORE_LIMIT = 21

  def pass_himself
    @cards << @deck.withdraw
  end

  def pass_to_opponent(opponent)
    case opponent.hand
    when 'left'
      opponent.cards[0] << @deck.withdraw
    when 'right'
      opponent.cards[1] << @deck.withdraw
    else
      opponent.cards << @deck.withdraw
    end
  end

  def make_seventeen
    pass_himself unless get_score >= MIN_SCORE
    puts 'Dealer is Busted' if get_score > SCORE_LIMIT
  end
end
