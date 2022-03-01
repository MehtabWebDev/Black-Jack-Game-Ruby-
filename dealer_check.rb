# frozen_string_literal: true

module Check
  def black_jacked(who, opponent)
    case who
    when 'dealer'
      self.chips += opponent.chips
      reveal
      opponent.bust(opponent.chips)
      opponent.lose_chips
    when 'both'
      reveal
      opponent.tie
    when 'opponent'
      @is_insurance_open = false
      show
      opponent.win(opponent.chips * 1.5)
    end
  end

  def check_black_jack(opponent)
    if black_jack?
      if !opponent.black_jack?
        puts "#{@name} has a black jack but #{opponent.name} dose not\n"
        black_jacked('dealer', opponent)
      elsif opponent.black_jack?
        puts "#{@name} and #{opponent.name} both have black jack\n"
        black_jacked('both', opponent)
      end
    elsif opponent.black_jack?
      puts "#{@name} does not has a black jack but #{opponent.name} has\n"
      black_jacked('opponent', opponent)
    end
  end

  def black_jack_on(hand, opponent)
    puts "#{@name} does not has a black jack but #{opponent.name} #{hand} hand has\n"
    opponent.show
    opponent.win(opponent.chips * 1.5, hand)
  end

  def check_black_jack_on_each_hand(opponent)
    if opponent.black_jack?('left')
      black_jack_on('left', opponent)
    else
      opponent.show('left')
    end

    if opponent.black_jack?('right')
      black_jack_on('right', opponent)
    else
      opponent.show('right')
    end
  end

  def black_jack?
    if @cards.first.name == 'Ace' || @cards.first.value == 10 || @turn
      get_score == 21
    else
      false
    end
  end

  def check_insured_bet(opponent, insured_bet, hand)
    if get_score == SCORE_LIMIT
      opponent.win_insurance(insured_bet, hand)
    else
      opponent.lose_insurance(insured_bet, hand)
      @chips += insured_bet
    end
  end

  def check_main_bet(opponent, main_bet, hand)
    if (SCORE_LIMIT - get_score) < (SCORE_LIMIT - opponent.get_score(hand))
      opponent.lose_chips(hand, main_bet)
      opponent.lose(main_bet, hand)
    elsif (SCORE_LIMIT - get_score) > (SCORE_LIMIT - opponent.get_score(hand))
      opponent.win(main_bet, hand)
    elsif get_score == opponent.get_score(hand)
      opponent.tie(hand)
    end
  end
end
