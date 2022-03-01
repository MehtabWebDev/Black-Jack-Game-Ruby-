# frozen_string_literal: true

module Action
  SCORE_LIMIT = 21
  def bust_opponent(opponent_chips, opponent, hand)
    self.chips += opponent_chips
    opponent.bust(opponent.lose_chips(hand), hand)
    opponent.show(hand)
  end

  def hit(opponent)
    pass_to_opponent(opponent)
    if opponent.split
      case opponent.hand
      when 'left'
        bust_opponent(opponent.chips[0], opponent, 'left') if opponent.get_score('left') > SCORE_LIMIT
      when 'right'
        bust_opponent(opponent.chips[1], opponent, 'right') if opponent.get_score('right') > SCORE_LIMIT
      end
    elsif opponent.get_score > SCORE_LIMIT
      bust_opponent(opponent.chips, opponent, nil)
    end
  end

  def stand(opponent)
    case opponent.hand
    when 'left'
      opponent.stand[0] = true
    when 'right'
      opponent.stand[1] = true
    else
      opponent.stand = true
    end
    opponent.make_stand
  end

  def double_down(opponent)
    opponent.make_double_down
    hit(opponent)
    opponent.show if opponent.rank.nil?
    stand(opponent)
  end

  def insurance(opponent)
    opponent.make_insurance
    case opponent.hand
    when 'left'
      opponent.show('left')
    when 'right'
      opponent.show('right')
    else
      opponent.show
    end
    stand(opponent)
  end

  def surrender_hand(opponent_chips, opponent)
    self.chips += opponent_chips / 2.0
    opponent.do_surrender(opponent.hand)
    opponent.show(opponent.hand)
    stand(opponent)
    opponent_chips / 2.0
  end

  def surrender(opponent)
    if opponent.split
      case opponent.hand
      when 'left'
        opponent.chips[0] = surrender_hand(opponent.chips[0], opponent)
      when 'right'
        opponent.chips[1] = surrender_hand(opponent.chips[1], opponent)
      end
    else
      opponent.chips = surrender_hand(opponent.chips, opponent)
    end
  end

  def split(opponent)
    opponent.cards[0] << @deck.withdraw
    opponent.cards[1] << @deck.withdraw
    check_black_jack_on_each_hand(opponent)
  end
end
