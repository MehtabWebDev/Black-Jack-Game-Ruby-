require './Player'
require './Deck'

class Dealer < Player
    MIN_SCORE = 17
    attr_accessor :turn, :chips, :name, :cards, :is_insurance_open

    def initialize(name)
        super(name)
        @deck = Deck.new
        @cards = []
        @chips = 0
        @is_insurance_open = true
    end

    def pass_himself
        @cards << @deck.withdraw
    end

    def pass_to_opponent(opponent)
        if opponent.hand == "left"
            opponent.cards[0] << @deck.withdraw
        elsif opponent.hand == "right"
            opponent.cards[1] << @deck.withdraw
        else
            opponent.cards << @deck.withdraw
        end
    end

    def show
        puts "#{@name}: "
        puts "  #{@cards.first.show}"
        puts "  #{@cards.last.hide} (hidden)"
        if @cards.first.name == 'Ace'
            puts "  Value: #{@cards.first.value[1]}"
        else
            puts "  Value: #{@cards.first.value}"
        end
        puts "\n"
    end

    def reveal
        puts "#{@name}: "
        @cards.each{ |card|
            puts "  #{card.show}"
        }
        puts "  Total Value: #{get_score}"
        puts "\n"
    end

    def check_black_jack(opponent)
        case
        when self.is_black_jack && !opponent.is_black_jack()
            # system "clear"
            puts "#{@name} has a black jack but #{opponent.name} dose not"
            puts "\n"
            lose = opponent.lose_chips()
            self.chips += lose
            self.reveal
            opponent.bust(lose)
        when self.is_black_jack && opponent.is_black_jack()
            # system "clear"
            puts "#{@name} and #{opponent.name} both have black jack"
            self.reveal
            opponent.tie()
            puts "\n"
        when !self.is_black_jack && opponent.is_black_jack()
            # system "clear"
            is_insurance_open = false
            puts "#{@name} does not has a black jack but #{opponent.name} has"
            puts "\n"
            self.show
            opponent.win(opponent.chips * 1.5)
        end
    end

    def check_black_jack_on_each_hand(opponent)
        if opponent.is_black_jack("left")
            puts "#{@name} does not has a black jack but #{opponent.name} left hand has"
            puts "\n"
            opponent.show
            opponent.win("left", opponent.chips * 1.5)
        else
            opponent.show("left")
        end

        if opponent.is_black_jack("right")
            puts "#{@name} does not has a black jack but #{opponent.name} right hand has"
            puts "\n"
            opponent.show
            opponent.win("right", opponent.chips * 1.5)
        else
            opponent.show("right")
        end


    end

    def is_black_jack
        if @cards.first.name == 'Ace' || @cards.first.value == 10 || @turn
            return self.get_score == 21
        else
            return false
        end
    end

    def make_seventeen
        unless get_score >= MIN_SCORE
            pass_himself
        end
        if get_score > SCORE_LIMIT
            puts "Dealer is Busted"
        end
    end

    def make_deal(opponent, hand=nil)

        if hand == "left"
            insured = opponent.insured[0]
            chips = opponent.chips[0]
        elsif hand == "right"
            insured = opponent.insured[1]
            chips = opponent.chips[1]
        else
            insured = opponent.insured
            chips = opponent.chips
        end


        if insured
            main_bet = chips/1.5
            insured_bet = chips - main_bet

            if get_score == SCORE_LIMIT
                opponent.win_insurance(hand, insured_bet)
            else
                opponent.lose_insurance(hand, insured_bet)
                @chips += insured_bet
            end

            if (SCORE_LIMIT - get_score) < (SCORE_LIMIT - opponent.get_score(hand))
                opponent.lose_chips(hand, main_bet)
                opponent.lose(hand, main_bet)
            elsif (SCORE_LIMIT - get_score) > (SCORE_LIMIT - opponent.get_score(hand))
                opponent.win(hand, main_bet)
            elsif get_score == opponent.get_score(hand)
                opponent.tie(hand)
            end

        else
            if (SCORE_LIMIT - get_score) < (SCORE_LIMIT - opponent.get_score(hand))
                opponent.lose_chips(hand, chips)
                opponent.lose(hand, chips)
            elsif (SCORE_LIMIT - get_score) > (SCORE_LIMIT - opponent.get_score(hand))
                opponent.win(hand, chips)
            else
                opponent.tie(hand)
            end
        end

    end

    def play_turn(opponents)
        system "clear"

        make_seventeen()
        reveal()

        opponents.count.times do |i|

            if opponents[i].split
                if opponents[i].rank[0] == nil
                    make_deal(opponents[i], "left")
                    opponents[i].show("left")
                else
                    opponents[i].show_rank("left")
                    opponents[i].show("left")
                end
                if opponents[i].rank[1] == nil
                    make_deal(opponents[i], "right")
                    opponents[i].show("right")
                else
                    opponents[i].show_rank("right")
                    opponents[i].show("right")
                end
            else
                if opponents[i].rank == nil
                    make_deal(opponents[i])
                else
                    opponents[i].show_rank()
                end
                opponents[i].show()
            end
    

        end
        
    end

    def hit(opponent)
        pass_to_opponent(opponent)
        if opponent.split
            if opponent.hand == "left"
                if opponent.get_score("left") > SCORE_LIMIT
                    lose = opponent.lose_chips("left")
                    self.chips += lose
                    opponent.bust(lose, "left")
                    opponent.show("left")
                end
            elsif opponent.hand == "right"
                if opponent.get_score("right") > SCORE_LIMIT
                    lose = opponent.lose_chips("right")
                    self.chips += lose
                    opponent.bust(lose, "right")
                    opponent.show("right")
                end
            end
        else
            if opponent.get_score > SCORE_LIMIT
                lose = opponent.lose_chips
                self.chips += lose
                opponent.bust(lose)
                opponent.show
            end
        end
    end

    def stand(opponent)
        if opponent.hand == "left"
            opponent.stand[0] = true
        elsif opponent.hand == "right"
            opponent.stand[1] = true
        else
            opponent.stand = true
        end
        opponent.make_stand
    end

    def double_down(opponent)
        opponent.make_double_down
        hit(opponent)
        if opponent.rank == nil
            opponent.show
        end
        stand(opponent)
    end

    def insurance(opponent)
        opponent.make_insurance
        if opponent.hand == "left"
            opponent.show("left")
        elsif opponent.hand == "right"
            opponent.show("right")
        else
            opponent.show()
        end
        stand(opponent)
    end

    def surrender(opponent)
        if opponent.split
            if opponent.hand == "left"
                self.chips += opponent.chips[0]/2.0
                opponent.chips[0] = opponent.chips[0]/2.0
                
            elsif opponent.hand == "right"
                self.chips += opponent.chips[1]/2.0
                opponent.chips[1] = opponent.chips[1]/2.0
            end
        else
            self.chips += opponent.chips/2.0
            opponent.chips = opponent.chips/2.0
        end
        opponent.surrender
        if opponent.hand == "left"
            opponent.show("left")
        elsif opponent.hand == "right"
            opponent.show("right")
        else
            opponent.show()
        end
        stand(opponent)
    end

    def split(opponent)
        opponent.cards[0] << @deck.withdraw
        opponent.cards[1] << @deck.withdraw
        check_black_jack_on_each_hand(opponent)
        # opponent.show
    end

    def perform(opponent)
        case opponent.choice
        when "Hit"
            hit(opponent)
        when "Stand"
            stand(opponent)
            if opponent.hand == "left"
                opponent.show("left")
            elsif opponent.hand == "right"
                opponent.show("right")
            else
                opponent.show()
            end
        when "Split" 
            split(opponent)
        when "Double Down" 
            double_down(opponent)
        when "Insurance"
            insurance(opponent)
        when "Surrender"
            surrender(opponent)
        end
        
    end

end