# frozen_string_literal: true

module Action
  def bet
    print "#{@name} Enter your Bet between $2-$500: "
    @chips = gets.to_i
    until @chips > 1 && @chips < 501
      print 'wrong input! please choose bet between $2-$500: '
      @chips = gets.to_i
    end
    puts "#{@name}'s bet is: #{@chips}\n"
  end

  def double_bet
    @choice = 'Double Down'
    reason = catch(:double_down) do
      if double_down_possible?
        @chips *= 2
        return false
      end
    end
    show
    show_options
    puts reason
    input_again
  end

  def make_split
    @choice = 'Split'
    reason = catch(:split) do
      if split_possible?
        @cards = [[@cards.first], [@cards.last]]
        @chips = [@chips, @chips]
        @rank = [nil, nil]
        @insured = [false, false]
        @hand = 'left'
        @stand = [nil, nil]
        @split = true
        return false
      end
    end
    show
    show_options
    puts reason
    input_again
  end

  def add_half_of_bet
    if @split
      case @hand
      when 'left'
        @chips[0] += 1.5 * @chips[0]
      when 'right'
        @chips[1] += 1.5 * @chips[1]
      end
    else
      @chips += 1.5 * @chips
    end
  end

  def add_insurance
    case @hand
    when 'left'
      @insured[0] = true
      @chips[0] = 1.5 * @chips[0]
    when 'right'
      @insured[1] = true
      @chips[1] = 1.5 * @chips[1]
    else
      @insured = true
      @chips = 1.5 * @chips
    end
  end

  def insure(dealer)
    @choice = 'Insurance'
    reason = catch(:insurance) do
      if insurance_possible?(dealer)
        add_insurance
        return false
      end
    end
    show
    show_options
    puts reason
    input_again
  end

  def make_stand
    hand_temp = " #{hand} hand" unless hand.nil?
    puts "#{name}#{hand_temp} Stood"
    # self.show
  end

  def make_insurance
    hand_temp = " #{@hand} hand" unless @hand.nil?
    case @hand
    when 'left'
      puts "#{@name}#{hand_temp} Insured with $#{@chips[0] - @chips[0] / 1.5}"
    when 'right'
      puts "#{@name}#{hand_temp} Insured with $#{@chips[1] - @chips[1] / 1.5}"
    else
      puts "#{@name}#{hand_temp} Insured with $#{@chips - @chips / 1.5}"
    end
  end

  def make_double_down
    hand_temp = " #{@hand} hand" unless @hand.nil?
    puts "#{@name}#{hand_temp} has Double Down"
  end
end
