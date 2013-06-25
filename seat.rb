class Seat
  attr_accessor :number, :dice_left, :player

  def init(number, player, starting_dice)
    self.number = number
    self.dice_left = starting_dice
    self.player = player
  end

  def alive?
    dice_left > 0
  end
end
