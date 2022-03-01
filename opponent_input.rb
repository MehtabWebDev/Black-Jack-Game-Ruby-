# frozen_string_literal: true

module Input
  def show_options
    puts "->Press 'h' for 'Hit'"
    puts "->Press 's' for 'Stand'"
    puts "->Press 'p' for 'Split'"
    puts "->Press 'd' for 'Double Down'"
    puts "->Press 'i' for 'Insurance'"
    puts "->Press 'r' for 'Surrender'"
    puts "\n"
  end

  def input_again
    print "\nwrong input! "
    if @split && @hand == 'left'
      print "#{@name} Try Again from left hand: "
    elsif @split && @hand == 'right'
      print "#{@name} Try Again from right hand: "
    else
      print "#{@name} Try Again: "
    end
    get
  end

  def input
    if @split && @hand == 'left'
      print "#{@name} Choose one option from left hand: "
    elsif @split && @hand == 'right'
      print "#{@name} Choose one option from right hand: "
    else
      print "#{@name} Choose one option: "
    end
    get
  end

  def prompt_again
    show
    show_options
    input_again
  end

  def prompt(dealer)
    system 'clear'
    dealer.show
    show
    show_options
    input
  end
end
