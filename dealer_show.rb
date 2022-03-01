# frozen_string_literal: true

module Show
  ACE = 'Ace'
  def show
    puts "#{@name}: "
    puts "  #{@cards.first.show}"
    puts "  #{@cards.last.hide} (hidden)"
    if @cards.first.name == ACE
      puts "  Value: #{@cards.first.value[1]}\n"
    else
      puts "  Value: #{@cards.first.value}\n"
    end
  end

  def reveal
    puts "#{@name}: "
    @cards.each do |card|
      puts "  #{card.show}"
    end
    puts "  Total Value: #{get_score}"
    puts "\n"
  end
end
