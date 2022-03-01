# frozen_string_literal: true

module Rank
  def bust(lost, hand = nil)
    case hand
    when 'left'
      @rank[0] = 2
    when 'right'
      @rank[1] = 2
    else
      @rank = 2
    end
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{name}#{hand_temp} is Busted and lost $#{lost}"
  end

  def win(bet, hand = nil)
    case hand
    when 'left'
      rank[0] = 0
      @chips[0] += bet
    when 'right'
      rank[1] = 0
      @chips[1] += bet
    else
      self.rank = 0
      @chips += bet
    end
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{name}#{hand_temp} has Won $#{bet}"
  end

  def lose(bet, hand = nil)
    case hand
    when 'left'
      rank[0] = 2
    when 'right'
      rank[1] = 2
    else
      self.rank = 2
    end
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{name}#{hand_temp} Lose $#{bet}"
  end

  def tie(hand = nil)
    case hand
    when 'left'
      @rank[0] = 1
    when 'right'
      @rank[1] = 1
    else
      @rank = 1
    end
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "Tie between #{name}#{hand_temp} and Dealer"
  end

  def do_surrender(hand = nil)
    chips = nil
    case hand
    when 'left'
      @rank[0] = 3
      chips = @chips[0]
    when 'right'
      @rank[1] = 3
      chips = @chips[1]
    else
      @rank = 3
      chips = @chips
    end
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{name}#{hand_temp} Surrendered on $#{chips}"
  end

  def get_rank(hand = nil)
    case hand
    when 'left'
      @rank[0]
    when 'right'
      @rank[1]
    else
      @rank
    end
  end

  def get_stand(hand)
    case hand
    when 'left'
      @stand[0]
    when 'right'
      @stand[1]
    else
      @stand
    end
  end

  def ranked?(hand = nil)
    rank = get_rank(hand)
    stand = get_stand(hand)
    !rank.nil? || stand
  end
end
