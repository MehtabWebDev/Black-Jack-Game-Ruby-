# frozen_string_literal: true

require './card'

class Deck
  CARD_CAT = %w[Spades Hearts Diamonds Clubs].freeze
  CARDS = %w[Ace 2 3 4 5 6 7 8 9 10 King Queen Jack].freeze

  def initialize
    @deck = []
    CARD_CAT.each do |cat|
      CARDS.each do |name|
        @deck << Card.new(cat, name)
      end
    end
  end

  def withdraw
    @deck.delete(@deck.sample)
  end
end
