require './Card'

class Deck
    CARD_CAT = ['Spades', 'Hearts', 'Dimonds', 'Clubs']
    CARDS = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'King', 'Queen', 'Jack']
    
    def initialize
        @deck = []
        CARD_CAT.each{ |cat|
            CARDS.each { |card|
                @deck << Card.new(cat, card)
            }
        }
        
    end

    def withdraw
        @deck.delete(@deck.sample)
    end
end