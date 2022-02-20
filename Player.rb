class Player
    SCORE_LIMIT = 21

    def initialize(name)
        @name = name
        @turn = false
    end

    def get_score(hand=nil)
        score = 0
        ace_count = 0
        cards = self.cards
        cards = self.cards[0] if hand == "left"
        cards = self.cards[1] if hand == "right"
        cards.each { |card|
            if card.name == 'Ace'
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

    def is_black_jack(hand)
        get_score(hand) == SCORE_LIMIT
    end

    def play_turn
    end
end
