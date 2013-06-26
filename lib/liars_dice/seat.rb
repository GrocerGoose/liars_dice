module LiarsDice
  class Seat
    attr_accessor :number, :player
    attr_reader :dice_left, :dice

    def initialize(number, player, starting_dice)
      self.number = number
      @dice_left = starting_dice
      self.player = player
    end

    def alive?
      dice_left > 0
    end

    def dice=(value)
      @dice = value
      player.dice = value
    end

    def lose_die
      @dice_left -= 1
    end
  end
end
