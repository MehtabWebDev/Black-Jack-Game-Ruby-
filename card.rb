# frozen_string_literal: true

class Card
  attr_accessor :value, :name, :cat

  def initialize(cat, name)
    @cat = cat
    @name = name
    @value = case @name
             when 'King'
               10
             when 'Queen'
               10
             when 'Jack'
               10
             when 'Ace'
               [1, 11]
             else
               @name.to_i
             end
  end

  def show
    "#{@name} of #{@cat}"
  end

  def hide
    '*'
  end
end
