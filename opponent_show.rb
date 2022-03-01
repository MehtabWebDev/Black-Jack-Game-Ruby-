# frozen_string_literal: true

module Show
  def show_cards(cards)
    cards.each do |card|
      puts "  #{card.name} of #{card.cat}"
    end
  end

  def show_left
    puts ' Left Hand:'
    show_cards(@cards[0])
    puts "  Total Value: #{get_score('left')}"
    puts "  Bet: $#{@chips[0]}"
    puts "\n"
  end

  def show_right
    puts ' Right Hand:'
    show_cards(@cards[1])
    puts "  Total Value: #{get_score('right')}"
    puts "  Bet: $#{@chips[1]}"
    puts "\n"
  end

  def show(hand = nil)
    puts "#{@name}: "
    if @split
      case hand
      when 'left'
        show_left
      when 'right'
        show_right
      else
        show_left
        show_right
      end
    else
      show_cards(@cards)
      puts "  Total Value: #{get_score}"
      puts "  Bet: $#{@chips}"
    end

    puts "\n"
  end

  def win_insurance(ins, hand = nil)
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{@name}#{hand_temp} has Win Insurance of $#{ins}"
    @chips += ins
  end

  def lose_insurance(ins, hand = nil)
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{@name}#{hand_temp} has Lost Insurance of $#{ins}"
    case hand
    when 'left'
      @chips[0] -= ins
    when 'right'
      @chips[1] -= ins
    else
      @chips -= ins
    end
  end

  def show_rank(hand = nil)
    hand_temp = " #{hand} hand" unless hand.nil?
    rank = get_rank(hand)

    case rank
    when 0
      puts "#{@name}#{hand_temp} has Won"
    when 1
      puts "Tie between #{@name}#{hand_temp} and Dealer"
    when 2
      puts "#{@name}#{hand_temp} has Lose"
    when 3
      puts "#{@name}#{hand_temp} has Surrendered"
    end
  end
end
