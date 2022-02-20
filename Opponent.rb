require './Player'

class Opponent < Player
    attr_accessor :turn, :chips, :cards, :name, :choice, :insured, :split, :rank, :hand, :stand

    def initialize(name)
        super(name)
        @cards = []
        @chips = 0
        @insured = false
        @split = false
        @rank = nil
        @stand = nil
    end

    def get_score(hand=nil)
        score = 0
        ace_count = 0
        cards = self.cards
        cards = self.cards[0] if hand == "left"
        cards = self.cards[1] if hand == "right"
        cards.each { |card|
            if card.name == "Ace"
                score += card.value[0]
                ace_count += 1
            else
                score += card.value
            end
        }
        ace_count.times {
            if score + 10 <= SCORE_LIMIT
                score += 10
            end
        }
        score
    end

    def is_black_jack(hand=nil)
        get_score(hand) == SCORE_LIMIT
    end

    def bet
        print "#{@name} Enter your Bet between $2-$500: "
        @chips = gets.to_i 
        until @chips>1 && @chips<501
            print "wrong input! please choose bet between $2-$500: "
            @chips = gets.to_i
        end
        puts "#{@name}'s bet is: #{@chips}"
        puts "\n"
    end

    def show_cards(cards)
        cards.each{ |card|
            puts "  #{card.name} of #{card.cat}"
        }
    end

    def show_left
        puts " Left Hand:"
        show_cards(@cards[0])
        puts "  Total Value: #{self.get_score("left")}"
        puts "  Bet: $#{@chips[0]}"
        puts "\n"
    end

    def show_right
        puts " Right Hand:"
        show_cards(@cards[1])
        puts "  Total Value: #{self.get_score("right")}"
        puts "  Bet: $#{@chips[1]}"
        puts "\n"
    end

    def show(hand=nil)
        puts "#{@name}: "
        if @split
            if hand == "left"
                show_left()
            elsif hand == "right"
                show_right()
            else
                show_left()
                show_right()
            end
        else
            show_cards(@cards)
            puts "  Total Value: #{self.get_score}"
            puts "  Bet: $#{@chips}"
        end
        
        puts "\n"
    end

    def double_bet
        @chips *= 2
    end

    def is_score_possible_to(*expected_score)
        score = 0
        ace_count = 0
        @cards.each { |card|
            unless card.name == 'Ace'
                score += card.value
            else
                score += card.value[0]
                ace_count += 1
            end
        }
        expected_score.each {|n| return true if n == score}
        return false
    end

    def is_double_down_possible
        if !@split
            if @cards.length == 2
                if is_score_possible_to(9,10,11)
                    return true
                else
                    throw :double_down, "Double Down not possible, Score is not 9, 10 or 11"
                end
            else
                throw :double_down, "Double Down not possible after 'Hit'"
            end
        else
            throw :double_down, "Double Down after 'Split' not allowed"
        end
    end

    def is_insurance_possible(dealer)
        cards = @cards
        if @split
            if @hand == "left"
                cards = @cards[0]
            elsif @hand == "right"
                cards = @cards[1]
            end
        end

        if dealer.is_insurance_open
            if cards.length == 2
                if dealer.cards[0].name == 'Ace'
                    return true
                else
                    throw :insurance, "Insurance not possible, Dealer's visible card is not 'Ace'"
                end
            else
                throw :insurance, "Insurance not possible after 'Hit'"
            end
        else
            throw :insurance, "Insurance is not open"
        end
    end

    def is_split_possible
        if !@split
            if @cards.length == 2
                if @cards.first.name == @cards.last.name
                    return true
                else
                    throw :split, "Split not possible, cards are differnt"
                end
            else
                throw :split, "Split not possible after 'Hit'"
            end
        else
            throw :split, "Split after 'Split' not allowed"
        end
    end

    def make_split
        @cards = [[@cards.first], [@cards.last]]
        @chips = [@chips, @chips]
        @rank = [nil, nil]
        @insured = [false, false]
        @hand = "left"
        @stand = [nil, nil]
    end

    def add_half_of_bet
        if @split
            if @hand == "left"
                @chips[0] += 1.5 * @chips[0]
            elsif @hand == "right"
                @chips[1] += 1.5 * @chips[1]
            end
        else
            @chips += 1.5 * @chips
        end
    end

    def show_options
        puts "->Press 'h' for 'Hit'"
        puts "->Press 's' for 'Stand'"
        puts "->Press 'p' for 'Split'"
        puts "->Press 'd' for 'Double Down'"
        puts "->Press 'i' for 'Insurance'"
        puts "->Press 'r' for 'Surrender'"
        puts "\n"
    end

    def get_input_again
        if @split && @hand == "left"
            print "#{@name} Try Again from left hand: "
        elsif @split && @hand == "right"
            print "#{@name} Try Again from right hand: "
        else
            print "#{@name} Try Again: "
        end
    end

    def play_turn(dealer)
        
        system "clear"
        dealer.show
        self.show
        show_options

        if @split && @hand == "left"
            print "#{@name} Choose one option from left hand: "
        elsif @split && @hand == "right"
            print "#{@name} Choose one option from right hand: "
        else
            print "#{@name} Choose one option: "
        end

        
        option = get_char
        puts "\n\n"

        system "clear"
        dealer.show

        while true do
            case option
            when 'h'
                @choice = 'Hit'
                break
            when 's' 
                @choice = "Stand"
                break
            when 'p' 
                @choice = "Split"
                reason = catch(:split) do
                    if is_split_possible
                        self.make_split
                        @split = true
                        @hand = "left"
                        return    
                    end
                end
                self.show
                show_options
                puts reason
                # print "Enter Again: "
                get_input_again()
                option = get_char
                system "clear"
                dealer.show
            when 'd' 
                @choice = "Double Down"
                reason = catch(:double_down) do
                    if is_double_down_possible
                        self.double_bet
                        return    
                    end
                end
                self.show
                show_options
                puts reason
                # print "Enter Again: "
                get_input_again()
                option = get_char
                system "clear"
                dealer.show
            when 'i' 
                @choice = "Insurance"
                reason = catch(:insurance) do
                    if is_insurance_possible(dealer)
                        self.insure
                        return
                    end
                end
                self.show
                show_options
                puts reason
                # print "Enter Again: "
                get_input_again()
                option = get_char
                system "clear"
                dealer.show
            when 'r' 
                @choice = "Surrender"
                break
            else
                self.show
                show_options
                print "\nwrong input! "
                get_input_again()
                option = get_char
                system "clear"
                dealer.show
            end
        end
        
                

    end

    def bust(lost, hand=nil)
        if hand == "left"
            @rank[0] = 2
        elsif hand == "right"
            @rank[1] = 2
        else
            @rank = 2
        end
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{self.name}#{hand_temp} is Busted and lost $#{lost}"
    end

    def win(hand=nil, bet)
        if hand == "left"
            self.rank[0] = 0
            @chips[0] += bet
        elsif hand == "right"
            self.rank[1] = 0
            @chips[1] += bet
        else
            self.rank = 0
            @chips += bet
        end
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{self.name}#{hand_temp} has Won $#{bet}"
    end

    def lose(hand=nil, bet)
        if hand == "left"
            self.rank[0] = 2
        elsif hand == "right"
            self.rank[1] = 2
        else
            self.rank = 2
        end
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{self.name}#{hand_temp} Lose $#{bet}"
    end

    def tie(hand=nil)
        if hand == "left"
            @rank[0] = 1
        elsif hand == "right"
            @rank[1] = 1
        else
            @rank = 1
        end
        hand_temp = " " + hand + " hand" if hand != nil
        puts "Tie between #{self.name}#{hand_temp} and Dealer"
    end

    def surrender
        chips = nil
        if hand == "left"
            @rank[0] = 3
            chips = @chips[0]
        elsif hand == "right"
            @rank[1] = 3
            chips = @chips[1]
        else
            @rank = 3
            chips = @chips
        end
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{self.name}#{hand_temp} Surrendered on $#{chips}"
    end

    def lose_chips(hand=nil, chips=nil)
        lose = 0

        if hand == "left"
            if chips != nil
                @chips[0] -= chips
            else
                lose = @chips[0]
                @chips[0] = 0
            end
        elsif hand == "right"
            if chips != nil
                @chips[1] -= chips
            else
                lose = @chips[1]
                @chips[1] = 0
            end
        else

            if chips != nil
                @chips -= chips
            else
                lose = @chips
                @chips = 0
            end
        end
        lose
    end

    def insure
        if @hand == "left"
            @insured[0] = true
            @chips[0] = 1.5 * @chips[0]
        elsif @hand == "right"
            @insured[1] = true
            @chips[1] = 1.5 * @chips[1]
        else
            @insured = true
            @chips = 1.5 * @chips
        end
    end

    def make_stand
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{self.name}#{hand_temp} Stood"
        # self.show 
    end

    def make_insurance
        hand_temp = " " + @hand + " hand" if @hand != nil
        if @hand == "left"
            puts "#{@name}#{hand_temp} Insured with $#{@chips[0] - @chips[0]/1.5}"
        elsif @hand == "right"
            puts "#{@name}#{hand_temp} Insured with $#{@chips[1] - @chips[1]/1.5}"
        else
            puts "#{@name}#{hand_temp} Insured with $#{@chips - @chips/1.5}"
        end
    end

    def make_double_down
        hand_temp = " " + @hand + " hand" if @hand != nil
        puts "#{@name}#{hand_temp} has Double Down"
    end

    def win_insurance(hand=nil, ins)
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{@name}#{hand_temp} has Win Insurance of $#{ins}"
        @chips += ins
    end

    def lose_insurance(hand=nil, ins)
        hand_temp = " " + hand + " hand" if hand != nil
        puts "#{@name}#{hand_temp} has Lost Insurance of $#{ins}"
        if hand == "left"
            @chips[0] -= ins
        elsif hand == "right"
            @chips[1] -= ins
        else
            @chips -= ins
        end
    end

    def show_rank(hand=nil)
        hand_temp = " " + hand + " hand" if hand != nil
        rank = nil
        if hand == "left"
            rank = @rank[0]
        elsif hand == "right"
            rank = @rank[1]
        else
            rank = @rank
        end

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