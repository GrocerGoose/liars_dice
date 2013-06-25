class Seat
  attr_accessor :number, :dice_left, :player, :dice

  def init(number, player, starting_dice)
    self.number = number
    self.dice_left = starting_dice
    self.player = player
  end

  def alive?
    dice_left > 0
  end

  def dice=(value)
    @dice = value
    player.dice = value
  end
end
